function fitout = FitADC(data, fitpars, fitout)
%% mati.dMRI.FitADC fits ADC(tdiff) using polyfit 
% If fitopts.flag.getADC == 'y', ADC(tdiff) will be calculated at the end of mati.FitPars.Fit. 
% INPUTS:
%       fitpars: a mati.FitPars object
%       data: a mati.ImageData object
% OUTPUTS:
%       out: a mati.ImageData object
% -------------------------------------------------------------------------------------------------------------------------
% Author: Junzhong Xu, 2024/10/25 
%
% -------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    if nargin == 3
        if isfield(fitout, 'ADCpulse')
            error('%s: The input fitout already has a field of ADCpulse', mfilename);     
        end
    end
    fitout.ADCpulse = [] ;  
    
    % check input 
    if ~isa(data,'mati.ImageData'), error('%s: the input data should be an ImageData object',mfilename) ; end
    warning('off') ; 
    
    % preparation 
    pulse = fitpars.model.pulse ; 
    Img2D = reshape(data.img, [data.Nx*data.Ny*data.Nz, data.Nt]) ; 

    % --------------------------------- ADC fit --------------------------------
    nCount = 0 ; 
    tdiffs = unique(pulse.tdiff) ; tdiffs = sort(tdiffs, 'descend') ; 
    for ntdiff = 1:length(tdiffs)
        ind_fit = (pulse.tdiff==tdiffs(ntdiff)) & (pulse.b <= fitpars.fitopts.ADCfit_bmax) &  ((pulse.b >= fitpars.fitopts.ADCfit_bmin) | (pulse.n ~=0)) ; 
        switch sum(ind_fit)
            case {0,1}      % not enough points to perform ADC fitting
                warning on ; warning('%s: Not sufficient points for ADC fitting with tdiff=%.2f ms. ',mfilename, tdiffs(ntdiff)) ; warning off ; 
            otherwise  % fit -log(signal) ~ -b*D to get S(b=0)
                % fitting all ind_fit
                tmpImg = Img2D(data.mask, ind_fit) ; 
                % mono-exponential fit
                [tmpP] =arrayfun(@(n) polyfit(pulse.b(ind_fit), -log(tmpImg(n,:)), 1), [1:size(tmpImg,1)], 'UniformOutput', false) ; 
                tmpADC = cellfun(@(x) x(1), tmpP) ; 

                nCount = nCount + 1 ; 
                % generate ADCmap (tdiff)
                eval(sprintf('fitout.ADC%d = zeros([data.Nx, data.Ny, data.Nz]); \n', nCount))
                eval(sprintf('fitout.ADC%d(data.mask) = tmpADC(:); \n', nCount))
                eval(sprintf('fitout.mapLabels = [fitout.mapLabels, "ADC%d"] ; \n', nCount))

                % update ADCpulse
                tmpPulse = pulse(ind_fit) ; tmpPulse = tmpPulse(sum(ind_fit)) ; 
                if isempty(fitout.ADCpulse)
                    fitout.ADCpulse = tmpPulse ; 
                else
                    fitout.ADCpulse = mati.PulseSequence.cat(fitout.ADCpulse, tmpPulse) ; 
                end
        end 
    end

