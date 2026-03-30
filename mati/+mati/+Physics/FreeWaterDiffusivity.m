function [ DC ] = FreeWaterDiffusivity(T)
%% FreeWaterDiffusivity() provides intrinsic diffusion coefficient of free liquid water
% Reference: Holz M, Heil SR and Sacco A. Phys. Chem. Chem. Phys., 2000, 2, 4740È4742
% Inputs: 
%       T: temperature of water in Celsius degree
% Outputs:
%       ADC: intrinsic diffusion coefficient of liquid water
% -------------------------------------------------------------
% Author: Junzhong Xu, 2012_02_16
% -------------------------------------------------------------

    % Constants 
    D0 = 16.35 ; % micron^2/ms
    Ts = 215.05 ; % Kelvin degree
    gamma = 2.063 ; 
    
    % Speedy-Angell power-law approach 
    % D=D0*[T/Ts-1]^2(gamma) (Eq.[1] in Ref.)
    DC = D0 .* (((T+273.15)./Ts) -1 ).^gamma ; 


end

