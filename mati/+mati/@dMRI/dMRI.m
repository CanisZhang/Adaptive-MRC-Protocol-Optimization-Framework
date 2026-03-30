classdef dMRI < mati.SignalModel
%% class definition of dMRI  
% dMRI can take different structure models
% Model choices: 
%           'dMRI_1compt_d_Din':       a single restricted geometry with a size d and an intracellular diffusion coefficient Din
%           'dMRI_1comptHollow_din_dout_Din':     a single restricted hollow sphere with din (inner diameter), dout (outer diameter), and Din
% NOTES: 
%       1. 1comptHollow can be used to simulate signals but has not been supported for data fitting yet
% -------------------------------------------------------------------------------------------------------------------------
% 
% -------------------------------------------------------------------------------------------------------------------------

    %% properties
    properties (SetAccess = private)
        structure
        defaultStructure
    end
    
    %% static methods
    methods (Static)
        out = FitADC(data, fitpars, fitout) ; 
        out = FitDDR(fitout) ; 
        [out, fitout] = PreProcessDWI(fitpars, data) ;         
        out = Signal_dMRI_1compt_d_Din(parms,this) ; 
        out = Signal_dMRI_1comptHollow_din_dout_Din(parms,this) ; 
        out = Signal_dMRI_monoExp(parms,this) ; 
        out = Signal_dMRI_biExp(parms,this) ; 
        out = Signal_dMRI_DTI(parms,this) ; 
    end

    %% other methods
    methods                
        % ------------------------------- Constructor -------------------------------------
        % IMPULSED should take two inputs: a struct (structure model) and an object (DiffusionPulseSequence)
        function this = dMRI(varargin)
            if nargin == 0 , return ; end      % return an empty object
            for n = 1:length(varargin)
                if isa(varargin{n},'mati.DiffusionPulseSequence')
                    this.pulse = varargin{n};
                elseif isstruct(varargin{n})
                    inputStructure = varargin{n};
                else
                    error('Inputs for dMRI should be StructureModel, DiffusionPulseSequence')
                end
            end    
            
            %------------------------ setting signal function handle and default fitopts --------------------------
            % !!! Note that the DefaultFitopts.x0, lb, ub should all be column vectors !!!
            switch inputStructure.modelName
                case  'dMRI_1compt_d_Din'                                                                                          % [din, Din], 1compartment
                    this.parmsLabels = ["d","Din"] ; this.NumParms = 2 ; 
                    this.FcnSignal = @mati.dMRI.Signal_dMRI_1compt_d_Din ;  
                    this.defaultFitopts.x0 = [10, 1.5]' ; this.defaultFitopts.lb = [0 0]' ; this.defaultFitopts.ub = [30 3.07]' ; 
                    this.defaultStructure.modelName = 'dMRI_1compt_d_Din' ; this.defaultStructure.geometry = 'sphere' ; 
                    this.defaultFitopts.dictionary.ds = [0.5:0.5:30] ; this.defaultFitopts.dictionary.Dins = [0.25:0.25:3] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.ds, this.defaultFitopts.dictionary.Dins} ; 
                    this.defaultFitopts.priorDist.distName = 'none' ; 
                    this.defaultFitopts.priorDist.pd.ds = ones(size(this.defaultFitopts.dictionary.ds)) ; this.defaultFitopts.priorDist.pd.Dins = ones(size(this.defaultFitopts.dictionary.Dins)) ; 
                case  'dMRI_1comptHollow_din_dout_Din'                                                                    % [din, dout, Din], 1compartment
                    this.parmsLabels = ["din","dout","Din"] ; this.NumParms = 3 ; 
                    this.FcnSignal = @mati.dMRI.Signal_dMRI_1comptHollow_din_dout_Din ;  
                    this.defaultFitopts.x0 = [1,10, 1.5]' ; this.defaultFitopts.lb = [0 0 0]' ; this.defaultFitopts.ub = [5 30 3.07]' ; 
                    this.defaultStructure.modelName = 'dMRI_1comptHollow_din_dout_Din' ; this.defaultStructure.geometry = 'hollowSphere' ; 
                    this.defaultFitopts.dictionary.dins = [0.5:0.5:30] ; this.defaultFitopts.dictionary.douts = [0.5:0.5:30] ; this.defaultFitopts.dictionary.Dins = [0.25:0.25:3] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.dins, this.defaultFitopts.dictionary.douts, this.defaultFitopts.dictionary.Dins} ; 
                    this.defaultFitopts.priorDist.distName = 'none' ; 
                    this.defaultFitopts.priorDist.pd.dins = ones(size(this.defaultFitopts.dictionary.dins)) ; this.defaultFitopts.priorDist.pd.douts = ones(size(this.defaultFitopts.dictionary.douts)) ; this.defaultFitopts.priorDist.pd.Dins = ones(size(this.defaultFitopts.dictionary.Dins)) ; 
                case  'dMRI_monoExp'                                                                                          % [din, Din], 1compartment
                    this.parmsLabels = ["ADC"] ; this.NumParms = 1 ; 
                    this.FcnSignal = @mati.dMRI.Signal_dMRI_monoExp ;  
                    this.defaultFitopts.x0 = [1]' ; this.defaultFitopts.lb = [0]' ; this.defaultFitopts.ub = [3.07]' ; 
                    this.defaultStructure.modelName = 'dMRI_monoExp' ; %this.defaultStructure.geometry = 'sphere' ; 
                    this.defaultFitopts.dictionary.ADCs = [0.02:0.01:3.07] ; %this.defaultFitopts.dictionary.Dins = [0.25:0.25:3] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.ADCs} ; 
                    this.defaultFitopts.priorDist.distName = 'none' ; 
                    this.defaultFitopts.priorDist.pd.ADCs = ones(size(this.defaultFitopts.dictionary.ADCs)) ; 
                case  'dMRI_biExp'                                                                                          % [din, Din], 1compartment
                    this.parmsLabels = ["ff","Df","Ds"] ; this.NumParms = 3 ; 
                    this.FcnSignal = @mati.dMRI.Signal_dMRI_biExp ;  
                    this.defaultFitopts.x0 = [0.3, 1, 1]' ; this.defaultFitopts.lb = [0, 0, 0]' ; this.defaultFitopts.ub = [1, 3.07, 3.07]' ; 
                    this.defaultStructure.modelName = 'dMRI_biExp' ; %this.defaultStructure.geometry = 'sphere' ; 
                    this.defaultFitopts.dictionary.ffs = [0.01:0.01:1] ; this.defaultFitopts.dictionary.Dfs = [0.02:0.02:3.07] ; this.defaultFitopts.dictionary.Dss = [0.02:0.02:3.07] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.ffs, this.defaultFitopts.dictionary.Dfs, this.defaultFitopts.dictionary.Dss} ; 
                    this.defaultFitopts.priorDist.distName = 'none' ; 
                    this.defaultFitopts.priorDist.pd.ffs = ones(size(this.defaultFitopts.dictionary.ffs)) ; this.defaultFitopts.priorDist.pd.Dfs = ones(size(this.defaultFitopts.dictionary.Dfs)) ; this.defaultFitopts.priorDist.pd.Dss = ones(size(this.defaultFitopts.dictionary.Dss)) ; 
                case  'dMRI_DTI'                                                                                          % [D11, D22, D33, D12, D13, D23]
                    this.parmsLabels = ["D11","D22","D33","D12", "D13", "D23"] ; this.NumParms = 6 ; 
                    this.FcnSignal = @mati.dMRI.Signal_dMRI_DTI ;  
                    this.defaultFitopts.x0 = [1, 0.5, 0.5, 0.5, 0.5, 0.5]' ; this.defaultFitopts.lb = [0, 0, 0, 0, 0, 0]' ; this.defaultFitopts.ub = [3.07, 3.07, 3.07, 3.07, 3.07, 3.07]' ; 
                    this.defaultStructure.modelName = 'dMRI_DTI' ; 
                    this.defaultFitopts.dictionary.D11s = single([0.0:0.2:3.07]) ;                     
                    this.defaultFitopts.dictionary.D22s = single([0.0:0.2:3.07]) ;                     
                    this.defaultFitopts.dictionary.D33s = single([0.0:0.2:3.07]) ;                     
                    this.defaultFitopts.dictionary.D12s = single([0.0:0.2:3.07]) ;                     
                    this.defaultFitopts.dictionary.D13s = single([0.0:0.2:3.07]) ;                     
                    this.defaultFitopts.dictionary.D23s = single([0.0:0.2:3.07]) ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.D11s, this.defaultFitopts.dictionary.D22s, this.defaultFitopts.dictionary.D33s, this.defaultFitopts.dictionary.D12s, this.defaultFitopts.dictionary.D13s, this.defaultFitopts.dictionary.D23s} ; 
                    this.defaultFitopts.priorDist.distName = 'none' ; 
                    this.defaultFitopts.priorDist.pd.D11s = ones(size(this.defaultFitopts.dictionary.D11s)) ; 
                    this.defaultFitopts.priorDist.pd.D22s = ones(size(this.defaultFitopts.dictionary.D22s)) ; 
                    this.defaultFitopts.priorDist.pd.D33s = ones(size(this.defaultFitopts.dictionary.D33s)) ; 
                    this.defaultFitopts.priorDist.pd.D12s = ones(size(this.defaultFitopts.dictionary.D12s)) ; 
                    this.defaultFitopts.priorDist.pd.D13s = ones(size(this.defaultFitopts.dictionary.D13s)) ; 
                    this.defaultFitopts.priorDist.pd.D23s = ones(size(this.defaultFitopts.dictionary.D23s)) ; 
                otherwise
                    error('%s: No matached structure.modelName',mfilename) ; 
            end
            
            % ------------------ update structure -----------------------
            this.structure = this.defaultStructure ; 
            names = fieldnames(inputStructure) ; 
            for n=1:length(names)
                if ~isfield(this.structure, names{n}) , error('%s: The input structure has a field that is not a field of mati.dMRI.structure',mfilename) ; end
                this.structure.(names{n}) = inputStructure.(names{n}) ; 
            end

            % -------------------- set other defaultFitopts fields --------------------------------
            this.defaultFitopts.fittingMethod = 'dictionary_matching' ;          % fittingMethod: {'dictionary_matching',{'nls','nlls','normal', 'general'}, 'bayesian','special'}
            this.defaultFitopts.solverName = 'fmincon' ;          % NLS solver name: {'lsqcurvefit','lsqnonlin','fmincon'}
            this.defaultFitopts.noiseModel = 'none' ;       % {'none','simple','rician','meanrician'}
            this.defaultFitopts.options =optimset('Display','off') ; 
            this.defaultFitopts.S0_bmax = 0.020 ;                  % maximum b for S(b=0)
            this.defaultFitopts.ADCfit_bmin = 0.19 ;                % minimum b for ADC fitting
            this.defaultFitopts.ADCfit_bmax = 1.05 ;             % maximum b for ADC fitting
            this.defaultFitopts.NumStarts = 5 ; 
            % fmincon 
            this.defaultFitopts.Aeq = [] ; 
            this.defaultFitopts.beq = [] ; 
            this.defaultFitopts.Aineq = [] ; 
            this.defaultFitopts.bineq = [] ; 
            this.defaultFitopts.nonlcon = [] ; 
            % flags for many options
            this.defaultFitopts.flag.useGPU = 'y' ; 
            this.defaultFitopts.flag.indGPU = 1 ; 
            this.defaultFitopts.flag.denoise = 'n' ; 
            this.defaultFitopts.flag.degibbs = 'n' ; 
            this.defaultFitopts.flag.deivim = 'n' ; 
            this.defaultFitopts.flag.multistart = 'n' ; 
            this.defaultFitopts.flag.parfor = 'y' ; 
            this.defaultFitopts.flag.getADC = 'n' ; 
            
            if ~iscolumn(this.defaultFitopts.x0) && ~iscolumn(this.defaultFitopts.lb) && ~iscolumn(this.defaultFitopts.ub)
                error('%s: the DefaultFitopts.x0, lb, ub should all be column vectors',mfilename) ; 
            end
            
        end % End of Constructor
        
    end % End of Methods
    
end % End of class
