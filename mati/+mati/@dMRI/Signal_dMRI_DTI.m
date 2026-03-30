function out = Signal_dMRI_DTI(parms, model)
%% Calculate DTI signals with model parms = [DTI]
% INPUTS
%       parms: Input parameters. 
%               [option#1]: a cell array {D11, D22, D33, D12, D13, D23} and will perform ndgrid(D11, D22, D33, D12, D13, D23) to get all combinations
%               [option#2]: a 6xN numeric array. Necessary for data fitting. !!!! Note: rows are varying pulse parameters; columns are varying structure parms !!!
%       model: signal model
% OUTPUTS
%       out:  calculated dMRI DTI signal
% -------------------------------------------------------------------------------------------------------------------------
% NOTES: 
%       1. Rows are varying pulse parameters; columns are varying structual parms
%       2. Make sure pulse (column vector) .* parms (row vector) to match dimensions
% -------------------------------------------------------------------------------------------------------------------------


    %% check inputs
    if ~strcmp(model.structure.modelName, 'dMRI_DTI'), error('%s: The input structure.ModelName is not ''dMRI_DTI''',mfilename) ; end
    % if ~ismember(model.structure.geometry, {'plane','cylinder','sphere'})
    %     error('%s: The input structure.geometry must be plane, cylinder, or sphere geometry',mfilename) ; 
    % end
    if iscell(parms)            % input cell array
        for n = 1:length(parms)
            if ~isnumeric(parms{n}), error('%s: The input parms\{%d\} should be numeric',mfilename,n); end     
        end
        if length(parms)~= 6, error('%s: The input parms should take 6 (D11, D22, D33, D12, D13, D23) parameters',mfilename) ; end
        % set up parms dimensions
        D11 = parms{1}(:) ; D22 = parms{2}(:) ; D33 = parms{3}(:) ; D12 = parms{4}(:) ; D13 = parms{5}(:) ; D23 = parms{6}(:) ; 
        [D11, D22, D33, D12, D13, D23] = ndgrid(D11, D22, D33, D12, D13, D23) ; 
        % parms = [D11(:)' ; D22(:)' ; D33(:)'; D12(:)' ; D13(:)'; D23(:)'] ; 
    elseif isnumeric(parms)    % input matrix
        if size(parms,1) ~= 6, error('%s: The input parms should be a 6 x N numetric array', mfilename) ; end
        % ff = parms(1,:) ; Df = parms(2,:) ; Ds = parms(3,:) ; 
    else
        error('%s: The input parms should be either a cell array or a 3xN numetric array',mfilename) ; 
    end
    % parameter array
    
    %% calculate signals
    % 3D tensor
    ND = numel(D11) ; 
    D11 = reshape(D11, [1 1 ND]) ; 
    D22 = reshape(D22, [1 1 ND]) ; 
    D33 = reshape(D33, [1 1 ND]) ; 
    D12 = reshape(D12, [1 1 ND]) ; 
    D13 = reshape(D13, [1 1 ND]) ; 
    D23 = reshape(D23, [1 1 ND]) ; 
    
    D3D = cat(1, D11, D12, D13, D12, D22, D23, D13, D23, D33) ; D3D = reshape(D3D, [3 3 ND]) ; 
    out = squeeze(sum(pagemtimes(model.pulse.gdir, D3D) .* model.pulse.gdir, 2)) .* model.pulse.b ; 
    
end