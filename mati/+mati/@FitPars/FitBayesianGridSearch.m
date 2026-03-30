function ind = FitBayesianGridSearch(signalDictionary, data, fitpars)
%% mati.FitPars.FitDictionaryMatching to perform data fitting using the dictionary matching method
% INPUTS:
%       signalDictionary: dictionary signal matrix (Nparms * Nt)
%       signal: all signals (Nt * Nvoxel)
%       fitpars: FitPars object
% OUTPUTS:
%       ind: indices of fitted results
% -------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    numByte = 4 ; % number of bytes for each number single = 32 bits = 4 bytes
    Nvoxel = sum(data.mask(:)) ; 
    % reshape acquired signals  (# of experiments) * 1 * (# of  voxels) 
    signal = reshape(data.img(repmat(data.mask,[1,1,1,data.Nt])), [Nvoxel, data.Nt])' ; % (# of experiments) * 1 * (# of voxels)
    signal = reshape(signal,[data.Nt, 1, Nvoxel]) ; 
    % get sigma
    if isempty(data.sigma)
        warndlg(sprintf('MATI: %s: The data.sigma = []. Set data.sigma to 0.001 for the Bayesian data fitting', mfilename))
        noiseSigma = 0.001 ; 
    elseif isscalar(data.sigma)
        noiseSigma  = data.sigma ; 
    else
          noiseSigma = reshape(data.img(repmat(data.sigma,[1,1,1,data.Nt])), [sum(data.mask(:)), data.Nt])' ; % (# of experiments) * 1 * (# of voxels)
          noiseSigma = reshape(noiseSigma,[data.Nt, 1, sum(data.mask(:))]) ; 
    end

    % initialization
    ind = zeros([1, Nvoxel]) ; 

    if any(strcmpi(fitpars.fitopts.flag.useGPU, {'y','yes'})) 
        if ~canUseGPU               % No usable GPU for MATLAB 
            errordlg('MATLAB found no available GPU''s. This could be (1) a GPU was not appropriately installed or (2) the system does not support GPU. For example,  MATLAB does not support GPU usage on Mac OS!')
        else
            if gpuDeviceCount("available") > 1 && fitpars.fitopts.flag.indGPU==1         % multiple GPUs for MATLAB
                warning('It seems you have more than one GPU and you will GPU#1. If this is not what you want, please set fitopts.flag.indGPU to the index of the GPU that you want to use.')
            end
            gpuDevice(fitpars.fitopts.flag.indGPU) ; 
        end
        signalDictionary = gpuArray(signalDictionary) ; 
        signal = gpuArray(signal) ; 
        ind = gpuArray(ind) ; 
        memInfo = gpuDevice ; 
        memAvailable = memInfo.AvailableMemory ; % Available GPU memory in bytes
    else
        tmp = mati.Tools.memoryInfo('byte') ;       % available memory in bytes
        memAvailable = tmp.memoryAvailable ; 
    end

    % memInfo = memory ; 
    if numel(signalDictionary)*size(signal,3)*numByte < memAvailable        % available memory is sufficient for the whole dotProduct 
        loglikelihood = mati.Physics.LogLikelihood(signalDictionary', signal, noiseSigma) ; 
        % weighted by prior distribution
        loglikelihood = exp(loglikelihood) .* fitpars.fitopts.priorDist.pd.pd ; 
        % dictionary matching (similarity)
        [~, ind] = max(loglikelihood, [], 1) ; 
    else                    % available memory is not sufficient for the whole dotProduct. use segmented calculation instead. 
        % segmentation of the signal matrix 
        Nblock = floor(memAvailable / numel(signalDictionary) /numByte /10 ) ; % a half of Nblock to prevent any memory issues
        Nseg = floor(Nvoxel/Nblock) ; 
        for n=1:(Nseg+1)
            % dot products of n-th segmented voxels
            if n<(Nseg+1)
                indRange = ((n-1)*Nblock+1):(n*Nblock) ; 
            elseif Nseg*Nblock == Nvoxel
                continue ; 
            else
                indRange = (Nseg*Nblock+1):Nvoxel ; 
            end

            loglikelihood = mati.Physics.LogLikelihood(signalDictionary', signal(:,:, indRange), noiseSigma) ; 
            % weighted by prior distribution
            loglikelihood = exp(loglikelihood) .* fitpars.fitopts.priorDist.pd.pd ; 
            % dictionary matching (similarity)
            [~, ind(indRange)] = max(loglikelihood, [], 1) ; 
        end
    end

    if fitpars.fitopts.flag.useGPU == 'y'
        ind = gather(ind) ; 
    end

end % End of FitDictionaryMatching 
