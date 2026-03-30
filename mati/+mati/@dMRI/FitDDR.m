function fitout = FitDDR(fitout)
%% mati.dMRI.FitDDR fits DDR(diffusion dispersion rate) using polyfit 
% INPUTS:
%       fitout: a structure that contains MATI fitted results
% OUTPUTS:
%       fitout: the same as input fitout but with a new field of DDR
% -------------------------------------------------------------------------------------------------------------------------
% Author: Junzhong Xu, 2024/10/25 
%
% -------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    [Nx, Ny, Nz] = size(fitout.ADC1) ; 
    pulse = fitout.ADCpulse ; 
    ADC2D = zeros([Nx*Ny*Nz, pulse.Nacq]) ; 
    for n=1:pulse.Nacq
        eval(sprintf('ADC2D(:,%d) = fitout.ADC%d(:) ; ', n, n)) ; 
    end
    
    % --------------------------------- DDR fit --------------------------------
    tmpADC2D = ADC2D(fitout.data.mask, :) ; 
    % linear fit
    [tmpP] =arrayfun(@(n) polyfit(fitout.ADCpulse.f, tmpADC2D(n,:), 1), [1:size(tmpADC2D,1)], 'UniformOutput', false) ; 
    fitout.DDR = single(fitout.data.mask) ; 
    fitout.DDR(fitout.data.mask) = cellfun(@(x) x(1), tmpP) ; 
    
end

