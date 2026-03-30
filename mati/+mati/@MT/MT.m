classdef MT < mati.SignalModel
%% class definition of IMPULSED  
% IMPULSED can take different structure models
% Model choices: 
%           'SIRqMT_R1f_PSR_Sf':       selective inversion recovery (SIR) quantitative magnetizatio transfer (qMT)
%           'SIRqMT_R1f_PSR_Sf_kmf':       selective inversion recovery (SIR) quantitative magnetizatio transfer (qMT)
% NOTES: 
%       1. 
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
        out = Signal_SIRqMT_R1f_PSR_Sf(parms,this) ; 
        out = Signal_SIRqMT_R1f_PSR_Sf_kmf(parms,this) ; 
    end

    %% other methods
    methods                
        % ------------------------------- Constructor -------------------------------------
        % MT should take two inputs: a struct (structure model) and an object (PulseSequence)
        function this = MT(varargin)
            if nargin == 0 , return ; end      % return an empty object
            for n = 1:length(varargin)
                if isa(varargin{n},'mati.PulseSequence')
                    this.pulse = varargin{n};
                elseif isstruct(varargin{n})
                    inputStructure = varargin{n};
                else
                    error('Inputs for MT should be StructureModel, PulseSequence')
                end
            end    

            %------------------------ setting signal function handle and default fitopts --------------------------
            % !!! Note that the DefaultFitopts.x0, lb, ub should all be column vectors !!!
            switch inputStructure.modelName
                case 'SIRqMT_R1f_PSR_Sf'                                                                                      % [PSR, R1f, Sf]
                    this.parmsLabels = ["R1f", "PSR", "Sf"] ; this.NumParms = 3 ; 
                    this.FcnSignal = @mati.MT.Signal_SIRqMT_R1f_PSR_Sf ; 
                    this.defaultFitopts.x0 = [1, 0.1, -0.95]' ;  this.defaultFitopts.lb = [0.01, 0.001, 1]' ; this.defaultFitopts.ub = [5, 0.9, -0.1]' ; 
                    this.defaultStructure.modelName = 'SIRqMT_R1f_PSR_Sf'  ; this.defaultStructure.Sm = 0.83 ; this.defaultStructure.R1m = 1 ; this.defaultStructure.signalType = 'abs' ; 
                    this.defaultStructure.kmf = 12.5 ; this.defaultStructure.R1m = 1 ; 

                    this.defaultFitopts.dictionary.R1fs = 1./[0.2:0.05:3] ; this.defaultFitopts.dictionary.PSRs = [0:0.005:0.4] ; this.defaultFitopts.dictionary.Sfs = [-1.2:0.02:0] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.R1fs, this.defaultFitopts.dictionary.PSRs, this.defaultFitopts.dictionary.Sfs} ; 
                    this.defaultFitopts.priorDist.distName = 'gaussian' ; 
                    this.defaultFitopts.priorDist.pd.R1fs = normpdf(this.defaultFitopts.dictionary.R1fs,0.5,10) ; this.defaultFitopts.priorDist.pd.PSRs = normpdf(this.defaultFitopts.dictionary.PSRs,0.15,3) ; this.defaultFitopts.priorDist.pd.Sfs = normpdf(this.defaultFitopts.dictionary.Sfs,-1, 20) ; 
                case 'SIRqMT_R1f_PSR_Sf_kmf'                                                                                      % [PSR, R1f, Sf, kmf]
                    this.parmsLabels = ["R1f", "PSR", "Sf", "kmf"] ; this.NumParms = 4 ; 
                    this.FcnSignal = @mati.MT.Signal_SIRqMT_R1f_PSR_Sf_kmf ; 
                    this.defaultFitopts.x0 = [1, 0.1, -0.95, 30]' ;  this.defaultFitopts.lb = [0.01, 0.001, 1, 0.01]' ; this.defaultFitopts.ub = [5, 0.9, -0.1, 500]' ; 
                    this.defaultStructure.modelName = 'SIRqMT_R1f_PSR_Sf_kmf'  ; this.defaultStructure.Sm = 0.83 ; this.defaultStructure.R1m = 1 ; this.defaultStructure.signalType = 'abs' ; 
                    this.defaultStructure.R1m = 1 ; 

                    this.defaultFitopts.dictionary.R1fs = 1./[0.2:0.05:3] ; this.defaultFitopts.dictionary.PSRs = [0:0.005:0.4] ; this.defaultFitopts.dictionary.Sfs = [-1.2:0.02:0] ; this.defaultFitopts.dictionary.kmfs = [1:0.5:40] ; 
                    this.defaultFitopts.dictionary.parms = {this.defaultFitopts.dictionary.R1fs, this.defaultFitopts.dictionary.PSRs, this.defaultFitopts.dictionary.Sfs, this.defaultFitopts.dictionary.kmfs} ; 
                    this.defaultFitopts.priorDist.distName = 'gaussian' ; 
                    this.defaultFitopts.priorDist.pd.R1fs = normpdf(this.defaultFitopts.dictionary.R1fs,0.5,10) ; this.defaultFitopts.priorDist.pd.PSRs = normpdf(this.defaultFitopts.dictionary.PSRs,0.15,3) ; this.defaultFitopts.priorDist.pd.Sfs = normpdf(this.defaultFitopts.dictionary.Sfs,-1, 20) ; this.defaultFitopts.priorDist.pd.kmfs = normpdf(this.defaultFitopts.dictionary.kmfs,20, 400) ; 
                otherwise
                    error('%s: No matached structure.modelName',mfilename) ; 
            end
            
            % ------------------ update structure -----------------------
            this.structure = this.defaultStructure ; 
            names = fieldnames(inputStructure) ; 
            for n=1:length(names)
                if ~isfield(this.structure, names{n}) , error('%s: The input structure has a field that is not a field of mati.MT.structure',mfilename) ; end
                this.structure.(names{n}) = inputStructure.(names{n}) ; 
            end

            % -------------------- set other defaultFitopts fields --------------------------------
            this.defaultFitopts.fittingMethod = 'dictionary_matching' ;          % fittingMethod: {'dictionary_matching',{'nls','nlls','normal', 'general'}, 'bayesian','special'}
            this.defaultFitopts.priorDist.distName = 'gaussian' ;                        % prior distribution {{'none','uniform'}, 'gaussian', 'customized'}
            this.defaultFitopts.solverName = 'fmincon' ;          % NLS solver name: {'lsqcurvefit','lsqnonlin','fmincon'}
            this.defaultFitopts.noiseModel = 'none' ;       % {'none','simple','rician','meanrician'}
            this.defaultFitopts.options =optimset('Display','off') ; 
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
            this.defaultFitopts.flag.denoise = 'y' ; 
            this.defaultFitopts.flag.degibbs = 'n' ; 
            this.defaultFitopts.flag.deivim = 'y' ; 
            this.defaultFitopts.flag.multistart = 'n' ; 
            this.defaultFitopts.flag.parfor = 'y' ; 
            
            if ~iscolumn(this.defaultFitopts.x0) && ~iscolumn(this.defaultFitopts.lb) && ~iscolumn(this.defaultFitopts.ub)
                error('%s: the DefaultFitopts.x0, lb, ub should all be column vectors',mfilename) ; 
            end
            
        end % End of Constructor
        
    end % End of Methods
    
end % End of class
