function [signal, comptSignals] = RunSim(structure, acqPulses, flag)  
%% This function simulate diffusion-weighted signals
% INPUT
%       files: microstructural file
%       structure: microstructural parameters including temporal resolution
%       acqPulses: acquisition pulse sequences
%
% OUTPUT
%       signal: signal from all compartments
%       s0:  signal(b=0) from all compartment
%       comptSignals: {signals arising from each compartment}, a cell array
%       comptS0s: {signal(b=0) arising from each compartment}, a cell array
%
% -------------------------------------------------------------------------------------------------------------------
% NOTE
%       1. The function can loop through multiple simulation variables (dx, Pm, etc), and multiple pulses in the acqPulses
%       2. The output each Signal has a dimension of (# pulses, # of vars, # files)
%       3. All s0 signals here assumes homogenous T2. If T2 is considered, need to calculate s0 with a pulse (b=0). 
% 
% -------------------------------------------------------------------------------------------------------------------
% 
% Author: Junzhong "JZ" Xu, Dec 30, 2022
%       Comments or questions? Please contact junzhong.xu@vanderbilt.edu
% 
% -------------------------------------------------------------------------------------------------------------------

    %% initialization of result arrays 
    signal = zeros([acqPulses.Nacq, 1]) ; 
    comptSignals = cell([structure.Ncompt,1]) ; 
    for n=1:structure.Ncompt
        comptSignals{n} = zeros([acqPulses.Nacq, 1]) ; 
    end
    
    % initialize finite difference matrix or transition matrix, 2D sparse matrix, (Nx * Ny *Nz) by (Nx * Ny *Nz)
    structure = mati.Sim.SetFDMatrix(structure) ; 

    % set up T2 relaxation matrix
    if structure.useT2 == 'y'     % compartmental T2 needs to be considered
        structure.T2 = zeros(size(structure.tissue)) ; 
        for n=1:structure.Ntype
            structure.T2(structure.tissue==n) = structure.T2(n) ; 
        end
        structure.T2 = exp(-structure.dt ./ structure.T2(:)) ; 
    end    
        
    %% iteration through all acquisition pulses
    for nacq = 1:acqPulses.Nacq
        % convert the mati pulse object to a pulse struct for simulation
        pulse = struct(acqPulses(nacq)) ; 
        pulse.dt = structure.dt ; 

        fprintf('\ttdiff=%.2f, b=%.02f ...\n', pulse.tdiff, pulse.b) ; 

        % diffusion gradient shape
        pulse = mati.Sim.SetGradShape(pulse) ; 
        % diffusion gradient
        pulse.grad = pulse.gShape .* pulse.G ; 
        % intergral of diffusion gradient
        pulse.gIntegral = pulse.gShapeIntegral .* pulse.G ; 

        %  set coordinates range 
        [structure, pulse] = mati.Sim.SetCoordRange(structure, pulse) ; 

        % debug
        if flag.verbose == 'y'
            figure(11) ; subplot(acqPulses.Nacq,1,nacq) ; plot(pulse.gShape) ; ylim([-1 1]*1.5) ; 
        end

        % check parameters
         [status, msg] = mati.Sim.CheckParameters(structure, pulse) ; 
         if status~=0,              error(msg);          end

        % --------------- simulation -------------------
        M = mati.Sim.SimSignal(structure, pulse, flag) ; 

        % ---------------- calculate signals ------------------------
        % overall signal
        signal(nacq) = abs(sum(M(:))) ; 
        % compartmental signals
        for n=1:structure.Ncompt
            comptSignals{n}(nacq)= abs(sum(M(structure.tissue(:)==n))) ; 
        end

    end % acqPulses

    
end
