function out = RemoveIVIM(this, data)
% RemoveIVIM_Improved 
% 基于原始 RemoveIVIM，演示如何引入：
% 1) 多阶段拟合  2) 更鲁棒的目标函数  
% 3) Rician 噪声模型 4) 自适应正则化 5) 并行加速

    %% =============== 0. 初步检查与初始化 ===============
    if ~isa(data, 'mati.ImageData')
        error('%s: the input data should be an ImageData object', mfilename);
    end
    
    % 获取脉冲序列和图像尺寸
    pulse = this.model.pulse; 
    [Nx, Ny, Nz, Nt] = deal(data.Nx, data.Ny, data.Nz, data.Nt);
    
    % 初始化输出图像
    img = zeros(Nx, Ny, Nz, Nt);
    
    % 判断是否并行
    if any(strcmpi(this.fitopts.flag.parfor, {'y', 'yes'}))
        poolobj = gcp;
        Ncore = poolobj.NumWorkers;
    else
        Ncore = 0;
    end
    
    %% =============== 1. 找到 mask 内需要处理的像素 ===============
    [row, col, slice] = ind2sub(size(data.mask), find(data.mask > 0));
    Npixel = length(row);
    
    % 用于存放处理后信号的一维数组
    img1d = zeros(Nt, Npixel);
    
    %% =============== 2. 多阶段 & 鲁棒拟合主循环 ===============
    parfor (npixel = 1 : Npixel, Ncore)
     % for npixel = 1:Npixel
        nx = row(npixel); ny = col(npixel); nz = slice(npixel);
        signal_raw = squeeze(data.img(nx, ny, nz, :));  % 原始信号
        if any(signal_raw == 0) || any(isnan(signal_raw))
            img1d(:, npixel) = signal_raw; % 保留原始信号
            continue;
        end
        
        % 准备输出信号
        signal_corrected = zeros(size(signal_raw));
        
        % 针对每一个 tdiff 单独做拟合
        tdiffs = unique(pulse.tdiff);
        Ntdiff = length(tdiffs);
        
        for ntd = 1 : Ntdiff
            idx_tdiff = (pulse.tdiff == tdiffs(ntd));
            
            % 只用满足一定 b 值阈值 或 特殊脉冲条件下的数据做拟合
            idx_fit = (pulse.tdiff == tdiffs(ntd)) & ...
                      (((pulse.b > this.model.defaultFitopts.ADCfit_bmin) & ...
                       (pulse.b < this.model.defaultFitopts.ADCfit_bmax)) | pulse.n ~= 0);
            
            if sum(idx_fit) < 2
                % 如果可用于拟合的点太少，则保留原始信号
                signal_corrected(idx_tdiff) = signal_raw(idx_tdiff);
                continue;
            end
            
            % 取用于拟合的 b 值和对应信号
            bvals_fit = pulse.b(idx_fit);
            sig_fit   = signal_raw(idx_fit);
            
            % ========== 第 1 阶段：单指数 / 简易估计，得到 D_slow, S0 等初值 ==========
            [D_slow_init, S0_init] = initialSingleExpFit(bvals_fit, sig_fit);
            
            % ========== 第 2 阶段：双指数 + 鲁棒损失 + Rician 噪声 + 自适应 λ ========== 
            % 参数顺序: [D1, D2, f1, S0]
            x0 = [1.5,  ...  
                  D_slow_init,       ...  % 慢扩散初值 
                  0.5,               ...  % 灌注分数 f1
                  S0_init];               % S0 初始值
            
            lb = [1e-2, 1e-3, 0, 0];
            ub = [2, 0.4, 1, 2 * S0_init];

            % 自定义拟合选项
            options = optimset('Display','off',...
                               'MaxIter',200,...
                               'TolFun',1e-6,...
                               'TolX',1e-6);
            
            % 多次迭代 / 自适应更新 λ
            maxIter =1;
            x_final = x0;            
            lambda = this.fitopts.IVIMlambda;     % 初始正则化强度
            for iter = 1 :  maxIter
                costfun = @(params) robustRicianResidual(params, bvals_fit, sig_fit, lambda);
                
                % 使用 lsqnonlin 做拟合
                [x_temp, ~] = lsqnonlin(costfun, x_final, lb, ub, options);
                x_final = x_temp;
                
                % == 根据残差和部分启发式调整 λ (示例) ==
                % 也可根据中位数残差, AIC/BIC 等方式自适应更新
                r = costfun(x_final);
                rmse = sqrt(mean(r.^2));
                
                % 简单示例：残差大 -> 增大 λ；残差小 -> 减小 λ
                if rmse > 0.2 * mean(sig_fit)  % 纯演示阈值
                    lambda = lambda * 2;
                else
                    lambda = lambda * 0.5;
                end
            end
            
            % 取拟合后的 S0，用于去除 IVIM 影响 (示例: 归一化)
            S0_est = x_final(4);
            if abs(S0_est) < 1e-6
                % 防止极端情况
                signal_corrected(idx_tdiff) = signal_raw(idx_tdiff);
            else
                signal_corrected(idx_tdiff) = signal_raw(idx_tdiff) / S0_est;
            end
        end
        
        % 收集拟合后的信号
        img1d(:, npixel) = signal_corrected;
    end
    
    %% =============== 3. 重建输出图像 ===============
    for npixel = 1 : Npixel
        img(row(npixel), col(npixel), slice(npixel), :) = ...
            reshape(img1d(:, npixel), [1, 1, 1, Nt]);
    end
    
    % 更新并输出
    out = data.UpdateImg(img);
end

%% =========================================================================
% 辅助函数：第 1 阶段单指数或简易估计 (示例)
%% =========================================================================
function [D_slow_init, S0_init] = initialSingleExpFit(bvals, sig)
    % 简单方法：对高 b 值 (bvals > X) 做线性拟合 ln(S) vs b
    % 也可以加判断避免 log(0) 等情况
    if isempty(sig) || all(sig <= 0)
        D_slow_init = 0.8;  % fallback
        S0_init = max(sig,[],'omitnan');
        return;
    end
    
    % 拟合时只使用 bvals > 200 的高 b 值(示例)
    idx_high = (bvals > 0.19);
    if sum(idx_high) < 2
        idx_high = (bvals > 0); % 如果都不满足，则退化到所有
    end
    
    x = bvals(idx_high);
    y = log(sig(idx_high));
    
    p = polyfit(x, y, 1);  % y = a*x + b
    slope = p(1);
    inter = p(2);
    
    D_slow_init = -slope;            % ADC
    S0_init     = exp(inter);        % S0
end

%% =========================================================================
% 辅助函数：双指数 + Rician 噪声 + Huber loss + 正则化 残差
%% =========================================================================
function res = robustRicianResidual(params, b, signal, lambda)
    % params = [D1, D2, f1, S0]
    D1 = params(1);
    D2 = params(2);
    f1 = params(3);
    S0 = params(4);
    
    % ------ 1) 模型信号 ------
    model_signal = S0 .* ( f1 * exp(-b * D1) + (1 - f1) * exp(-b * D2) );
    
    % ------ 2) Rician 概率建模 (示例写法) ------
    % 若测量信号 = M，模型信号 = m
    % Rician 似然: p(M|m, sigma) = (M/sigma^2) * exp(-(M^2+m^2)/(2sigma^2)) * I0(M*m/sigma^2)
    % 这里只做一个近似：取 resid = M^2 + m^2 - 2 * M * m * I0(...) ~ (M - m)^2  之类
    % 也可直接将 log-likelihood 当作 cost. 下文仅做简化示例:
    %  先做 (M - m) 作为差异量，再引入 Huber loss
    
    diff_approx = signal - model_signal;
    
    % ------ 3) Huber loss 计算 (示例) ------
    c = 10;  % Huber 门限，可根据实际情况调整
    abs_diff = abs(diff_approx);
    is_outlier = abs_diff > c;
    
    huber_res = diff_approx;
    huber_res(is_outlier) = c * sign(diff_approx(is_outlier)) .* ...
                            (abs_diff(is_outlier) - 0.5*c);
    
    % ------ 4) 正则化项 (L2 范数示例) ------
    % 对参数做约束，避免过大震荡
    reg_term = lambda * sum(params.^2);
    
    res = [huber_res; sqrt(reg_term)];  %#ok
end
