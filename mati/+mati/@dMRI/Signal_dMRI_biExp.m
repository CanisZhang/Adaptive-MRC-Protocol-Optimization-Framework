function out = Signal_dMRI_biExp(parms, model)
%% Calculate mono exponential dMRI with model parms = [ADC]
% INPUTS
%       parms: Input parameters. 
%               [option#1]: a cell array {d, Din} and will perform ndgrid(d, Din) to get all combinations of d and Din
%               [option#2]: a 2xN numeric array. Necessary for data fitting. !!!! Note: rows are varying pulse parameters; columns are varying structure parms !!!
%       model: signal model
% OUTPUTS
%       out:  calculated dMRI signal
% -------------------------------------------------------------------------------------------------------------------------
% NOTES: 
%       1. Rows are varying pulse parameters; columns are varying structual parms
%       2. Make sure pulse (column vector) .* parms (row vector) to match dimensions, e.g., b(column) .* Dex (row)
%       3. The structure geometry must be a member of {'plane','cylinder','sphere'}. The hollowSphere geometry is in another function mati.IMPULSED.Sigal_d_Din_hollow()
% -------------------------------------------------------------------------------------------------------------------------


    %% check inputs
    if ~strcmp(model.structure.modelName, 'dMRI_biExp'), error('%s: The input structure.ModelName is not ''dMRI_biExp''',mfilename) ; end
    % if ~ismember(model.structure.geometry, {'plane','cylinder','sphere'})
    %     error('%s: The input structure.geometry must be plane, cylinder, or sphere geometry',mfilename) ; 
    % end
    if iscell(parms)            % input cell array
        for n = 1:length(parms)
            if ~isnumeric(parms{n}), error('%s: The input parms\{%d\} should be numeric',mfilename,n); end     
        end
        if length(parms)~= 3, error('%s: The input parms should take 3 (ff, Df, Ds) parameters',mfilename) ; end
        % set up parms dimensions
        ff = parms{1}(:) ; Df = parms{2}(:) ; Ds = parms{3}(:) ; 
        [ff, Df, Ds] = ndgrid(ff, Df, Ds) ; 
        parms = [ff(:)' ; Df(:)' ; Ds(:)'] ; 
    elseif isnumeric(parms)    % input matrix
        if size(parms,1) ~=3, error('%s: The input parms should be a 3 x N numetric array', mfilename) ; end
        ff = parms(1,:) ; Df = parms(2,:) ; Ds = parms(3,:) ; 
    else
        error('%s: The input parms should be either a cell array or a 3xN numetric array',mfilename) ; 
    end
    % parameter array
    
    %% calculate signals
    out = parms(1,:).*exp(-model.pulse.b .* parms(2,:)) + (1-parms(1,:)).*exp(-model.pulse.b .* parms(3,:)) ; 
    
end