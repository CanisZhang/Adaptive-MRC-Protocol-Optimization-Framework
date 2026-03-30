classdef JOINT < mati.SignalModel
%% class definition of JOINT  
% JOINT can take different structure models. For OGSE signals, water exchange effects are ignored. Fore PGSE signals, water exchange effects are included using Karger model.
% Model choices: 
%           'joint_vin_d_Dex_Din_kin:   two-compartment with vin (intracellular proton fraction), d (intracelular size), Dex (extracelluar diffusion coefficient), and kin (water exchange rate)
%           'joint_vin_d_Dex_kin:    two-compartment with vin, d, kin and a fixed Din      
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
        out = Signal_JOINT_vin_d_Dex_Din_kin(parms, this) ;
        out = Signal_JOINT_vin_d_Dex_kin(parms, this) ;
        [ M_in, M_ex ] = generalSolution_blochEQ( Ain,Aex,kin,kex,Min0,Mex0,t ) ; 
    end

    %% other methods
    methods                
        % ------------------------------- Constructor -------------------------------------
        % JOINT should take two inputs: a struct (structure model) and an object (DiffusionPulseSequence)
        function this = JOINT(varargin)
            if nargin == 0 , return ; end      % return an empty object
            for n = 1:length(varargin)
                if isa(varargin{n},'mati.DiffusionPulseSequence')
                    this.pulse = varargin{n};
                elseif isstruct(varargin{n})
                    inputStructure = varargin{n};
                else
                    error('Inputs for JOINT should be StructureModel, DiffusionPulseSequence')
                end
            end    
            
            %------------------------ setting signal function handle and default fitopts --------------------------
            % !!! Note that the DefaultFitopts.x0, lb, ub should all be column vectors !!!
            switch inputStructure.modelName
                case 'JOINT_vin_d_Dex_Din_kin'
                    this.parmsLabels = ["vin", "d", "Dex", "Din", "kin"] ; 
                    this.FcnSignal = @mati.JOINT.Signal_JOINT_vin_d_Dex_Din_kin; 
                    this.defaultFitopts.x0 = [0.5, 10, 1.5, 1.56, 1/200]' ; this.defaultFitopts.lb = [0, 0, 0, 0, 1/1000]' ; this.defaultFitopts.ub = [1, 30, 3,3,1/10]' ; 
                    this.defaultStructure.modelName = 'JOINT_vin_d_Dex_Din_kin'  ; this.defaultStructure.betaex = 0 ; this.defaultStructure.geometry = 'sphere' ; 
                    this.defaultFitopts.dictionary.vins = [0.025:0.025:0.9] ; this.defaultFitopts.dictionary.ds = [2:0.2:30] ; this.defaultFitopts.dictionary.Dexs = [0.25:0.25:3] ; this.defaultFitopts.dictionary.Dins = [1:0.5:3] ; this.defaultFitopts.dictionary.kins = linspace(1/1000,1/10,20); 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.vins, this.defaultFitopts.dictionary.ds, this.defaultFitopts.dictionary.Dexs, this.defaultFitopts.dictionary.Dins, this.defaultFitopts.dictionary.kins} ; 
                    this.defaultFitopts.priorDist.distName = 'gaussian' ; 
                    this.defaultFitopts.priorDist.pd.vins = normpdf(this.defaultFitopts.dictionary.vins,0.7,14) ; this.defaultFitopts.priorDist.pd.ds = normpdf(this.defaultFitopts.dictionary.ds,15,300) ; this.defaultFitopts.priorDist.pd.Dexs = normpdf(this.defaultFitopts.dictionary.Dexs,1.8,40) ; this.defaultFitopts.priorDist.pd.Dins = normpdf(this.defaultFitopts.dictionary.Dins,1.56,40) ; this.defaultFitopts.priorDist.pd.kins = normpdf(this.defaultFitopts.dictionary.kins,1/20,1e2) ; 
                case 'JOINT_vin_d_Dex_kin'
                    this.parmsLabels = ["vin", "d", "Dex", "kin"] ; 
                    this.FcnSignal = @mati.JOINT.Signal_JOINT_vin_d_Dex_kin; 
                    this.defaultFitopts.x0 = [0.5, 10, 1.5, 1/200]' ; this.defaultFitopts.lb = [0, 0, 0, 1/1000]' ; this.defaultFitopts.ub = [1, 30, 3,1/10]' ; 
                    this.defaultStructure.modelName = 'JOINT_vin_d_Dex_kin'  ; this.defaultStructure.Din = 1.56 ; this.defaultStructure.betaex = 0 ; this.defaultStructure.geometry = 'sphere' ; 
                    this.defaultFitopts.dictionary.vins = [0.025:0.025:0.9] ; this.defaultFitopts.dictionary.ds = [2:0.2:30] ; this.defaultFitopts.dictionary.Dexs = [0.25:0.25:3] ; this.defaultFitopts.dictionary.kins = linspace(1/1000,1/10,20); 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.vins, this.defaultFitopts.dictionary.ds, this.defaultFitopts.dictionary.Dexs, this.defaultFitopts.dictionary.kins} ; 
                    this.defaultFitopts.priorDist.distName = 'gaussian' ; 
                    this.defaultFitopts.priorDist.pd.vins = normpdf(this.defaultFitopts.dictionary.vins,0.7,14) ; this.defaultFitopts.priorDist.pd.ds = normpdf(this.defaultFitopts.dictionary.ds,15,300) ; this.defaultFitopts.priorDist.pd.Dexs = normpdf(this.defaultFitopts.dictionary.Dexs,1.8,40) ; this.defaultFitopts.priorDist.pd.kins = normpdf(this.defaultFitopts.dictionary.kins,1/20,1e2) ; 
                otherwise
                    error('%s: No matached structure.modelName',mfilename) ; 
            end
            this.NumParms = length(this.parmsLabels);            
            % ------------------ update structure -----------------------
            this.structure = this.defaultStructure ; 
            names = fieldnames(inputStructure) ; 
            for n=1:length(names)
                if ~isfield(this.structure, names{n}) , error('%s: The input structure has a field that is not a field of mati.JOINT.structure',mfilename) ; end
                this.structure.(names{n}) = inputStructure.(names{n}) ; 
            end

            % ------------------- set default postProcess function -------------------
            this.FcnPostProcess = @mati.IMPULSED.PostProcessIMPULSED ; 

            % -------------------- set other defaultFitopts fields --------------------------------
            this.defaultFitopts.fittingMethod = 'dictionary_matching' ;          % fittingMethod: {'dictionary','normal', 'general', 'special'}
            this.defaultFitopts.solverName = 'fmincon' ;          % solver name: {'matching','lsqcurvefit','lsqnonlin','fmincon'}
            this.defaultFitopts.noiseModel = 'none' ;       % {'none','simple','rician','meanrician'}
            this.defaultFitopts.options =optimset('Display','off') ; 
            this.defaultFitopts.S0_bmax = 0.05 ;          % maximum b for S=0 images
            this.defaultFitopts.ADCfit_bmin = 0.19 ;                % minimum b for ADC fitting
            this.defaultFitopts.ADCfit_bmax = 1.05 ;             % maximum b for ADC fitting
            this.defaultFitopts.NumStarts = 50 ; 
            % fmincon 
            this.defaultFitopts.Aeq = [] ; 
            this.defaultFitopts.beq = [] ; 
            this.defaultFitopts.Aineq = [] ; 
            this.defaultFitopts.bineq = [] ; 
            this.defaultFitopts.nonlcon = [] ; 
            % flags for many options
            this.defaultFitopts.flag.useGPU = 'y' ; 
            this.defaultFitopts.flag.indGPU = 1 ; 
            this.defaultFitopts.flag.denoise = 'y' ; 
            this.defaultFitopts.flag.degibbs = 'n' ; 
            this.defaultFitopts.flag.deivim = 'n' ; 
            this.defaultFitopts.flag.getADC = 'n' ; 
            this.defaultFitopts.flag.postProcess = 'y' ; 
            this.defaultFitopts.flag.multistart = 'n' ; 
            this.defaultFitopts.flag.parfor = 'y' ; 
            
            if ~iscolumn(this.defaultFitopts.x0) && ~iscolumn(this.defaultFitopts.lb) && ~iscolumn(this.defaultFitopts.ub)
                error('%s: the DefaultFitopts.x0, lb, ub should all be column vectors',mfilename) ; 
            end
            
        end % End of Constructor
        
    end % End of Methods
    
end % End of class
