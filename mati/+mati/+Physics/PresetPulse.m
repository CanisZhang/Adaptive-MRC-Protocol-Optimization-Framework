function pulse = PresetPulse(acqMethod) 
%% This function loads pre-defined pulse sequence that have been published previously. 
% There are currently 5 options
% 1. ADC_spectrum: multiple diffusion times ranging from 1.25 ms to 1000ms with the same b value
%       Reference: Xu et al. 
% 2. impulsed_animal: The IMPULSED protocol for animal imaging with Gmax<=360mT/m on each gradient axis. 
%       Reference: Jiang et al. Magn Reson Med. 2017;78(1):156-64. Epub 2016/08/09. doi: 10.1002/mrm.26356. PubMed PMID: 27495144; 
% 3. impulsed_human_65mTm: The IMPULSED protocol for human imaging with Gmax<=65mT/m for any single gradient gradient axis. 
%       Reference: Xu et al. Magn Reson Med. 2020;83(6):2002-14. Epub 20191125. doi: 10.1002/mrm.28056. PubMed PMID: 31765494; PMCID: PMC7047520.
% 4. impulsed_human_45mTm: The IMPULSED protocol for human imaging with Gmax<=45mT/m for any single gradient gradient axis. 
%       Reference: Wu et al. Radiology. 2022 Jun;303(3):578-587. doi: 10.1148/radiol.211180. PubMed PMID: 35258368; 
% 5. verdict: The VERDICT protocol for human imaging particularly for prostate imaging. 
%       Reference: Johnston et al. Radiology. 2019;291(2):391-7. Epub 20190402. doi: 10.1148/radiol.2019181749. PubMed PMID: 30938627; PMCID: PMC6493214.
% 6. ssift: The SSIFT protocol for brain cancer imaging and radiation necrosis
%       Reference: Devan et al. Cancer Res. 2022 Oct 4;82(19):3603-3613. doi: 10.1158/0008-5472.CAN-21-2929. PubMed PMID: 35877201; PMCID: PMC9532360. 
%
% ---------------------------------------------------------------------------------------------------------------------
% NOTE
%       1. Although it is flexible to specify any sequence parameters, it is recommend to set the first acquisition as b=0 as the T2-weighted b=0 signal.
% 
% ---------------------------------------------------------------------------------------------------------------------
% Author: Junzhong (JZ) Xu, Dec 25, 2022
% 
% ---------------------------------------------------------------------------------------------------------------------


%%create pulse using the mati package
    switch lower(acqMethod)
        case 'adc_spectrum'      %------------- ADC spectrum with multiple diffusion times but with the same b value -------------------
            Nacq = 31 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               110,...                 % echo time [ms]
                'delta',            [10, 10,15,20, 25, 30, 35, 40, 20, 25, 30, 35, 40, ones([1 18])*12],...                  % gradient duration [ms]
                'Delta',            [40, 40,40,40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 14, 19, 24, 34, 54, 74, 104, 154, 204, 254, 304,404,504,604,704,804,904,1004],...                  % separation of two gradients [ms]
                'b',                  [0, ones(1,30)*0.2], ...      % b value [ms/μm^2]
                'n',                  [2, 2,2,2, 2, 2, 2, 2, 1, 1, 1, 1, 1, zeros([1 18])] , ...             % number of oscillating cycles
                'shape',         [repmat("tcos",[1 13]), repmat("tpgse",[1 18])], ...                  % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.1) ;                  % gradient rise time [ms]
        case 'impulsed_animal'       % ------------ the IMPULSED protocol for animal imaging with Gmax<=360 mT/m on each gradient axis ------------------
            Nacq = 20 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               67 ,...                 % echo time [ms]
                'delta',            [ones(1,5)*3, ones(1,5)*20, ones(1,5)*20, ones(1,5)*20],...                  % gradient duration [ms]
                'Delta',            [ones(1,5)*46, ones(1,5)*25, ones(1,5)*25, ones(1,5)*25],...                  % separation of two gradients [ms]
                'b',                  [[0,0.375, 0.750, 1.125, 1.50], [0,0.375, 0.750, 1.125, 1.50], [0,0.33, 0.66, 1.0, 1.32], [0, 0.15, 0.3,0.45,0.6]], ...      % b value [ms/μm^2]
                'n',                  [zeros(1,5), ones(1,5)*1, ones(1,5)*2, ones(1,5)*3],...             % number of oscillating cycles
                'shape',         [repmat("tpgse",[1,5]), repmat("cos",[1,5]), repmat("cos",[1,5]), repmat("tcos",[1,5])],...                 % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.9) ;                  % gradient rise time [ms]
        case 'impulsed_human_65mtm'       % ------------ the IMPULSED protocol for human imaging with Gmax<=65 mT/m on any single gradient axis -------------------
            Nacq = 16 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               110,...                 % echo time [ms]
                'delta',            [ones(1,7)*12.9, ones(1,5)*40.9, ones(1,4)*40.9],...                  % gradient duration [ms]
                'Delta',            [ones(1,7)*74, ones(1,5)*51.4, ones(1,4)*51.4],...                  % separation of two gradients [ms]
                'b',                  [[0:0.25:1, 1.4, 1.8], 0:0.25:1, [0,0.1, 0.2, 0.3]], ...      % b value [ms/μm^2]
                'n',                  [zeros(1,7), ones(1,5), ones(1,4)*2],...             % number of oscillating cycles
                'shape',         [repmat("tpgse",[1,7]), repmat("tcos",[1,5]), repmat("tcos",[1,4])],...                 % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.9) ;                  % gradient rise time [ms]
        case 'impulsed_human_45mtm'       % ------------ the IMPULSED protocol for human imaging with Gmax<=45 mT/m on any single gradient axis -------------------
            Nacq = 11 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               145,...                 % echo time [ms]
                'delta',            [ones(1,4)*10, ones(1,4)*60, ones(1,3)*60],...                  % gradient duration [ms]
                'Delta',            [ones(1,4)*30, ones(1,4)*71.4, ones(1,3)*71.4],...                  % separation of two gradients [ms]
                'b',                  [[0:0.4:1.2], 0:0.4:1.2, [0:0.3:0.6]], ...      % b value [ms/μm^2]
                'n',                  [zeros(1,4), ones(1,4), ones(1,3)*2],...             % number of oscillating cycles
                'shape',         [repmat("tpgse",[1,4]), repmat("tcos",[1,4]), repmat("tcos",[1,3])],...                 % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.6) ;                  % gradient rise time [ms]            
        case 'verdict'
            Nacq = 10 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               [50, 50, 65, 65, 90, 90, 71, 71, 80, 80],...                 % echo time [ms]
                'delta',            [3.9, 3.9, 11.4, 11.4, 23.9, 23.9, 14.4, 14.4, 18.9, 18.9],...                  % separation of two gradients [ms]
                'Delta',            [23.8, 23.8, 31.3, 31.3, 43.8, 43.8, 34.3, 34.3, 38.8, 38.8],...                  % gradient duration [ms]
                'b',                  [0, 0.09, 0, 0.5, 0, 1.5, 0, 2.0, 0, 3.0], ...      % b value [ms/μm^2]
                'n',                  [0],...             % number of oscillating cycles
                'shape',         ["tpgse"],...                 % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.9) ;                  % gradient rise time [ms]
        case 'ssift'
            Nacq = 4 ;          % total number of acquisition points
            pulse = mati.DiffusionPulseSequence(Nacq,...
                'TE',               [110],...                 % echo time [ms]
                'delta',            [12.9, 12.9, 40.9, 40.9],...                  % separation of two gradients [ms]
                'Delta',            [74, 74, 51.4, 51.4],...                  % gradient duration [ms]
                'b',                  [0, 1, 0, 1], ...      % b value [ms/μm^2]
                'n',                  [0, 0, 1, 1],...             % number of oscillating cycles
                'shape',         ["tpgse", "tpgse", "tcos", "tcos"],...                 % gradient waveform shape
                'gdir',             [1 0 0],...              % gradient directions. It should be a Nx3 matrix
                'trise',            0.9) ;                  % gradient rise time [ms]
        otherwise
            error('The input nMethod should be adc_spectrum, impulsed_animal, impulsed_human, verdict, or ssift')
    end


end
