function output = Signal_SIRqMT_R1f_PSR_Sf_kmf(parms, model)
%% SIR qMT with kmf=const with model parms = [R1f, PSR, Sf, kmf]
% INPUTS
%       parms: Input parameters. 
%               [option#1]: a cell array {R1f, PSR, Sf} and will perform ndgrid(R1f, PSR, Sf) to get all combinations of R1f, PSR, and Sf
%               [option#2]: a 3xN numeric array. Necessary for data fitting. !!!! Note: rows are varying pulse parameters; columns are varying structure parms !!!
%       model: signal model
% OUTPUTS
%       out:  calculated SIR qMT signal
% -------------------------------------------------------------------------------------------------------------------------
% NOTES: 
%       1. Rows are varying pulse parameters; columns are varying structual parms
%       2. Make sure pulse (column vector) .* parms (row vector) to match dimensions
% -------------------------------------------------------------------------------------------------------------------------

    %% check inputs
    if ~strcmp(model.structure.modelName, 'SIRqMT_R1f_PSR_Sf_kmf'), error('%s: The input structure.ModelName is not ''SIRqMT_R1f_PSR_Sf_kmf''',mfilename) ; end

    if ~ismember(model.structure.signalType, {'abs','real'})
        error('%s: The input structure.signalType must be abs or real',mfilename) ; 
    end
    if iscell(parms)            % input cell array
        for n = 1:length(parms)
            if ~isnumeric(parms{n}), error('%s: The input parms\{%d\} should be numeric',mfilename,n); end     
        end
        if length(parms) ~= 4, error('%s: The input parms should take three (R1f, PSR, Sf, kmf) parameters',mfilename) ; end
        % set up parms dimensions
        R1f = parms{1}(:) ; PSR = parms{2}(:) ; Sf = parms{3}(:) ; kmf = parms{4}(:) ; 
        [R1f, PSR, Sf, kmf] = ndgrid(R1f, PSR, Sf, kmf) ; 
        parms = [R1f(:)'; PSR(:)'; Sf(:)'; kmf(:)'] ; 
    elseif isnumeric(parms)    % input matrix
        if size(parms,1) ~=4, error('%s: The input parms should be a 4 x N numetric array', mfilename) ; end
    else
        error('%s: The input parms should be either a cell array or a 4xN numetric array',mfilename) ; 
    end
    
    % set Din the same dimension
    R1m = ones(size(R1f)) * model.structure.R1m ; 
    Sm = ones(size(R1f)) * model.structure.Sm ; 
    Mfinf = ones(size(R1f)) ; 
    
    %% calculation of signals
    % parms: [R1f; pmf; kmf; Sf; Mfinf; R1m, Sm]
    output = mati.Physics.SIRqMTSignal([R1f(:)'; PSR(:)'; kmf(:)'; Sf(:)'; Mfinf(:)'; R1m(:)'; Sm(:)'], model) ; 
   
end
    