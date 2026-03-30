function signal  = SIRqMTSignal(parms, model)
%% Calculates SIR qMT MRI signals 
% 
% -------------------------------------------------------------------------------------------------------------------------
% INPUTS: 
%       parms: 
%           [R1f; pmf; kmf; Sf; Mfinf; R1m; Sm]
%       model:
%           model.pulse: pulse sequence parameters. The elements such as TI and TD should be scalars or matrices with the same dimensions
%           model.structure.signalType: signal is 'abs' or 'real' 
% OUTPUTS:
%       signal:   SIR qMT signal Nacq x size(parms,2)
% -------------------------------------------------------------------------------------------------------------------------
% NOTES:
%        1. 
% -------------------------------------------------------------------------------------------------------------------------
%
% originally written by Ke Li & Junzhong Xu
% revised by Junzhong Xu, 2012_02_08
% Author: Junzhong Xu, Oct 10, 2024
% 
% -------------------------------------------------------------------------------------------------------------------------


    %% preliminary
    R1f  = parms(1,:) ; 
    pmf  = parms(2,:) ; 
    kmf  = parms(3,:) ; 
    Sf  = parms(4,:) ; 
    Mfinf = parms(5,:) ; 
    R1m = parms(6,:) ; 
    Sm = parms(7,:) ; 
    
    ti = model.pulse.TI ; 
    td = model.pulse.TD ; 

    %% calculation
    R1diff  = sqrt( (R1f-R1m+(pmf-1) .* kmf) .^ 2 + 4 * pmf .* kmf .* kmf ) ; 
    
    R1plus  = 0.5 .* (R1f + R1m + (1+pmf).*kmf + R1diff) ; 

    R1minus = R1plus - R1diff ; 

    bftdplus = -(R1f - R1minus) ./ R1diff;
    bftdminus = (R1f - R1plus) ./ R1diff;

    bmtdplus  = -(R1m - R1minus) ./ R1diff;
    bmtdminus = (R1m - R1plus) ./ R1diff;

    Mftd = bftdplus .* exp(-R1plus .* td) + bftdminus .* exp(-R1minus .* td) + 1 ; 
    Mmtd = bmtdplus .* exp(-R1plus .* td) + bmtdminus .* exp(-R1minus .* td) + 1 ; 

    bfplus = ( (Sf .* Mftd -1) .* (R1f - R1minus)  +  (Sf .* Mftd - Sm .* Mmtd) .* pmf .* kmf  ) ./ R1diff ; 
    bfminus = -( (Sf .* Mftd -1).* (R1f - R1plus)  +  (Sf .* Mftd - Sm .* Mmtd) .* pmf .* kmf  ) ./ R1diff ; 

    signal = (bfplus .* exp ( - R1plus .* ti) + bfminus .* exp ( -R1minus .*ti) +1) .* Mfinf ;
    
    % get amplitude of signal only
    if strcmp(model.structure.signalType,'abs')
        signal = abs(signal) ; 
    end

end

