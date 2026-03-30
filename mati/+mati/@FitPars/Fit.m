function [out,this] = Fit(this, data)
%% mati.FitPars.Fit to fit any model to data
%
% -------------------------------------------------------------------------------------------------------------------------
% INPUTS:
%       this: a mati.FitPars object
%       data: a mati.ImageData object
% OUTPUTS:
%       out: a structure
%           .mapLabels: the name labels of output parametric map
%           .NumParms: number of fitting parameters
%           .{parm}: if fittingMethod=={'normal','general','dictionary'}, fitted parameter maps. # of maps vary based on this.model.parms_labels
%           . resnorm: map of squared 2-norm of the residual 
%           .exitflag: map of exitflag. false: fitting successful; true: fitting failed
%       this: a mati.FitPars object with updated info such as dictionary, priorDist
%       data: updated mati.ImageData object with normalized or ivim-corrected data 
% -------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    warning('off') ; 
    % check input 
    if ~isa(this,'mati.FitPars') || ~isa(data,'mati.ImageData'), error('%s: The inputs should be an FitPars object and an ImageData object',mfilename) ; end

    %% preprocessing data
    % denoise always as the first step
    if any(strcmpi(this.fitopts.flag.denoise, {'y','yes'})) 
        % Also recommend to use MRtrix dwidenoise
        addpath(genpath(fullfile(mati.Tools.pathMATI,'External')))
        if data.Nz<=1
            warning('%s: The input data has only one slice i.e., Nz=1. Denoising disabled. ', mfilename) ; 
        else
            if data.Nz<5        % if image size < kernal size
                tmp.kernal = [min(5, data.Nx), min(5, data.Ny), data.Nz] ; 
                data = data.UpdateImg(MPdenoising(data.img,[],tmp.kernal)) ; 
            else
                data = data.UpdateImg(MPdenoising(data.img)) ; 
            end
        disp('------ denoising performed -----------') ; 
        end
    end
    % degibbs
    if any(strcmpi(this.fitopts.flag.degibbs, {'y','yes'}))
        % do nothing here. Recommend to use MRtrix degibbs to remove gibbs ringing. 
    end
    % remove IVIM or signal normalization
    if  isa(this.model.pulse, 'mati.DiffusionPulseSequence') % diffusion MRI
        data = mati.dMRI.PreProcessDWI(this, data) ; 
    end

    % output normalized/corrected data
    out.data = data ; 

    %% fitting preparation 
    % preparation of output parametric maps
     switch this.fitopts.fittingMethod
         case {'normal','general','dictionary_matching','polynomial_regression','bayesian_grid_search','nls','nlls','nllsq'}       % normal/general fitting methods, i.e., minimize ObjectiveFcn     
            map0 = zeros([data.Nx, data.Ny, data.Nz]) ; 
            out.mapLabels = this.model.parmsLabels ; 
            for n = 1:length(out.mapLabels) , out.(out.mapLabels(n)) = map0 ; end
            clear map0 ; 
         case 'special'                 % special fitting such as MRI-cytometry
            out.mapLabels = this.model.parmsLabels ; 
            out.parms = cell([data.Nx, data.Ny, data.Nz]) ; 
        otherwise 
            error('%s: The fitopts.fittingMethod must be ''normal'' or ''special''',mfilename) ; 
     end
    
    %% fitting
    switch this.fitopts.fittingMethod           
        % ********************** Pixel-wise normal/general fitting methods, i.e., minimize ObjectiveFcn *******************
        case {'normal','general','nls','nlls','nllsq','special'}       
            %  pixel-wise resnorm and exitflag
            out.resnorm = zeros([data.Nx, data.Ny, data.Nz]) ; out.exitflag = false([data.Nx, data.Ny, data.Nz]) ; 
            % ------------------ preparation for parallel computing -------------------
            if any(strcmpi(this.fitopts.flag.parfor,{'y','yes'}))
                poolobj = gcp ;  Ncore = poolobj.NumWorkers ; 
            else
                Ncore = 0 ; 
            end
            if any(strcmpi(this.fitopts.flag.multistart,{'y','yes'}))  
                NumStarts = this.fitopts.NumStarts ; 
            else
                NumStarts = 1 ; 
            end
            % calculate voxels with the mask
            [row, col, slice]=ind2sub(size(data.mask),find(data.mask>0)) ;     Npixel = length(row) ; 
            parmap1d = cell([Npixel,1]) ;     resnormmap1d = zeros([Npixel,1]) ; exitflag1d = zeros([Npixel,1]) ; 
            % prepare parfor
            if any(strcmpi(this.fitopts.flag.parfor,{'y','yes'}))  % copy data and this(fitpars) to all workers to save communication time
                parData = parallel.pool.Constant(data) ; 
                parFitPars = parallel.pool.Constant(this) ; 
            else    % if no parfor, define variables for code consistency
                parData.Value = data ; 
                parFitPars.Value = this ; 
            end
            % ---------------------------------- fitting ------------------------------------ 
            parfor (npixel = 1:Npixel, Ncore)
            % for npixel=1:Npixel         % debugging purpose
                nx = row(npixel) ; ny = col(npixel) ; nz = slice(npixel) ; 
                signal = squeeze(parData.Value.img(nx,ny,nz,:)) ; 
                % noise sigma
                if isempty(parData.Value.sigma) || isscalar(parData.Value.sigma)
                    sigma = parData.Value.sigma ; 
                else
                    sigma = parData.Value.sigma(nx,ny,nz) ; 
                end
                % fitting
                try
                   [x, resnorm] = run_optimization(parFitPars.Value, signal, sigma, NumStarts) ; 
                catch
                    warning('Fitting in the npixel=%d (%d,%d,%d) went wrong. Set all zeros for output parameters ...', npixel, nx, ny, nz)
                    x = zeros([parFitPars.Value.model.NumParms,1]) ; resnorm = 0 ; 
                    exitflag1d(npixel) = true ; 
                end
                % save fitting results
                parmap1d{npixel}  = x ; resnormmap1d(npixel) = resnorm ; 
            end % end of parfor loop
            % -------------------------------- output results ---------------------------------------------
            for npixel = 1:Npixel
                switch this.fitopts.fittingMethod
                    case {'normal','general','nls','nlls','nllsq'}       % normal/general fitting methods, i.e., minimize ObjectiveFcn 
                        for n=1:length(out.mapLabels)
                            out.(out.mapLabels(n))(row(npixel),col(npixel),slice(npixel)) = parmap1d{npixel}(n) ; 
                        end
                    case 'special'
                        out.parms{row(npixel),col(npixel),slice(npixel)} = parmap1d{npixel} ; 
                end
                out.resnorm(row(npixel),col(npixel),slice(npixel)) = resnormmap1d(npixel) ; 
                out.exitflag(row(npixel),col(npixel),slice(npixel)) = exitflag1d(npixel) ; 
            end

        % *************** non-pixel-wise dictionary-based fitting, including dictionary matching and Bayesian ***************************
        case {'dictionary_matching','polynomial_regression','bayesian_grid_search'}       
            % --------------------- generate dictionary ---------------------
            this.fitopts.dictionary = this.CreateDictionary(this.model) ; % (# of parameter combinations) * (# of experiments)
            % --------------------- generate prior distribution ---------------------
            this.fitopts.priorDist.pd.pd = this.CreatePriorDistribution(this.model) ; 
            % ---------------- dictionary fitting ---------------------
            switch this.fitopts.fittingMethod
                case {'dictionary_matching'}       % dictionary matching, requiring normalization in both the dictionary and signals
                    % normalize dictionary signal for each acquisition
                    signalDictionary = this.fitopts.dictionary.signal ./ sqrt(sum(this.fitopts.dictionary.signal.^2,2)) ; 
                    % reshape and normalize acquired signal voxel-wisely
                    signal = reshape(data.img(repmat(data.mask,[1,1,1,data.Nt])), [sum(data.mask(:)), data.Nt])' ; % (# of experiments) * (# of voxels)
                    signal = signal ./ sqrt(sum(signal.^2,1)) ;          % signal normalization voxel-wisely
                    % dictionary matching fitting
                    ind = mati.FitPars.FitDictionaryMatching(signalDictionary, signal, this) ; 
                    % output fitting results
                    for n=1:this.model.NumParms
                        out.(this.model.parmsLabels(n))(data.mask) = this.fitopts.dictionary.(this.model.parmsLabels(n))(ind) ; 
                    end

                case {'polynomial_regression'}           % supervised machine learning regression
                    degree = 3 ; 
                    parms = zeros([size(this.fitopts.dictionary.signal,1), this.model.NumParms], 'single') ; 
                    for n=1:this.model.NumParms
                        parms(:,n) = this.fitopts.dictionary.(this.model.parmsLabels(n)) ; 
                    end
                    % physics-informed MR training and fitting
                    x_train = mati.FitPars.MomentsExtended(mati.Physics.AddRicianNoise(this.fitopts.dictionary.signal,data.sigma),degree);

                    if this.fitopts.flag.useGPU == 'y'
                        x_train = gpuArray(x_train) ; 
                    end

                    Pinv_X=pinv(x_train) ; 
                    coeffs=Pinv_X*parms ; 

                    % fitting
                    signal = reshape(data.img(repmat(data.mask,[1,1,1,data.Nt])), [sum(data.mask(:)), data.Nt]) ; % (# of experiments) * (# of voxels)

                    if this.fitopts.flag.useGPU == 'y'
                        signal = gpuArray(signal) ; 
                    end

                    x_test = mati.FitPars.MomentsExtended(signal,degree);
                    x_fit = x_test*coeffs;
                    for n=1:this.model.NumParms
                        out.(this.model.parmsLabels(n))(data.mask) = x_fit(:,n) ; 
                    end
                    
                case {'bayesian_grid_search'}                       % simple bayesian_grid_search fitting 
                    % Bayesian grid search fitting
                    ind = mati.FitPars.FitBayesianGridSearch(this.fitopts.dictionary.signal, data, this) ; 
                    % output fitting results
                    for n=1:this.model.NumParms
                        out.(this.model.parmsLabels(n))(data.mask) = this.fitopts.dictionary.(this.model.parmsLabels(n))(ind) ; 
                    end

            end     % End of solverName
    end     % End of fittingMethod


    %% ADC maps for diffusion MRI
    if  isa(this.model.pulse, 'mati.DiffusionPulseSequence') % diffusion MRI
        % fit ADC
        if any(strcmpi(this.fitopts.flag.getADC, {'y','yes'}))
            out = mati.dMRI.FitADC(data, this, out) ; 
            % tmpOut = this.FitADC(data) ; 
            % out.tdiff = tmpOut.tdiff ; 
            % for ntdiff=1:length(tmpOut.tdiff)
            %     eval(sprintf('out.ADC%d = tmpOut.ADC%d ; \n', ntdiff, ntdiff)) ; 
            %     eval(sprintf('out.mapLabels = [out.mapLabels, "ADC%d"] ; \n',ntdiff)) ; 
            % end
        end
    end

    %% post-process 
    if any(strcmpi(this.fitopts.flag.postProcess, {'y','yes'})) 
        out = this.model.FcnPostProcess(out) ; 
    end

    %% convert data type
    for n = 1:length(out.mapLabels)
        out.(out.mapLabels(n)) = single(out.(out.mapLabels(n))) ; 
    end

end  % end of function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [x, resnorm] = run_optimization(this,signal, sigma, NumStarts) 
% run optimization 
    switch this.fitopts.fittingMethod
        case {'normal','general','nls','nlls','nllsq'}       % normal/general fitting methods, i.e., minimize ObjectiveFcn 
            % create optimization problem
            switch this.fitopts.solverName
                case {'lsqcurvefit'}         % the simple least-square curve fitting. It actualy calls lsqnonlin() 
                    problem = createOptimProblem('lsqcurvefit','x0',this.fitopts.x0,'objective',this.model.FcnSignal,'lb',this.fitopts.lb,'ub',this.fitopts.ub,'xdata',this.model,'ydata',signal,'options',this.fitopts.options);
                case {'lsqnonlin'}
                    ObjectiveFcn = @(parms)mati.FitPars.ObjectiveFcn(parms, this, signal, sigma) ; 
                    problem = createOptimProblem(this.fitopts.solverName,'x0',this.fitopts.x0,'objective',ObjectiveFcn,'lb',this.fitopts.lb,'ub',this.fitopts.ub,'options',this.fitopts.options);
                case {'fmincon'}
                    ObjectiveFcn = @(parms)mati.FitPars.ObjectiveFcn(parms, this, signal, sigma) ; 
                    problem = createOptimProblem(this.fitopts.solverName,'x0',this.fitopts.x0,'objective',ObjectiveFcn,'lb',this.fitopts.lb,'ub',this.fitopts.ub,'Aeq',this.fitopts.Aeq,'beq',this.fitopts.beq,'Aineq',this.fitopts.Aineq,'beq',this.fitopts.beq,'nonlcon',this.fitopts.nonlcon,'options',this.fitopts.options);
            end
            ms = MultiStart('UseParallel',false,'Display','off') ; 
            [x, resnorm] = run(ms,problem,NumStarts) ;    
        case 'special'          % special fitting method required by individual models
            [x, resnorm] = feval(this.fitopts.FitFcn, this, signal, sigma) ; 
    end
end

