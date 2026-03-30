function maxb = OGSEbmax(frequency, N)
    % 计算给定频率和N的最大b值
    OGSEdelta = N * 1000 / frequency;  
    gmax = 30e-5;
    pulse_tcos = mati.DiffusionPulseSequence(1, ...
        'TE', 150, ...              % Echo time
        'delta', OGSEdelta, ...     % 小delta
        'Delta', OGSEdelta + 7, ... % 大delta
        'G', [gmax], ...          % 最大梯度强度，注意调整
        'n', N * ones(1, 1), ...    % 周期数
        'shape', "tcos", ...        % 脉冲形状
        'gdir', [0 0 0], ...        % 梯度方向
        'trise', 1.54);             % 上升时间
    maxb = 1000*pulse_tcos.b(1);% 注意调整
end