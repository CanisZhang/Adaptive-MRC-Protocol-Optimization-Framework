function dictionary = CreateDictionary(this, model)
%% mati.FitPars.CreateDictionary to create (and cache) a dictionary for data fitting
%  Windows + MATLAB R2023b
%  Disk-persistent cache keyed by (FcnSignal, dictionary.parms, model)
%  Cache folder: fullfile(prefdir, 'mati_dictionary_cache')

    % ----- 1) build cache key & path -----
    sig = iComputeSignature(this, model); % SHA-256 hex string
    cacheDir  = fullfile(prefdir, 'mati_dictionary_cache');
    if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
    cacheFile = fullfile(cacheDir, [sig, '.mat']);

    % ----- 2) reuse if cache hit -----
    if isfile(cacheFile)
        S = load(cacheFile, 'dictionary');   % expect variable 'dictionary'
        dictionary = S.dictionary;
        return
    end

    % ----- 3) cache miss → compute dictionary (original logic) -----
    % calculate signal dictionary
    dictionary.signal = single(feval(this.model.FcnSignal, this.fitopts.dictionary.parms, model)') ; 

    % calculate individual parameter dictionaries for fast indexing.
    parms = this.fitopts.dictionary.parms ; 
    par   = cell(size(parms)) ; 
    str1  = 'par{1}' ; 
    str2  = 'parms{1}(:)' ; 
    for n = 2:length(this.fitopts.dictionary.parms)
        str1 = [str1, sprintf(', par{%d}',n)] ; 
        str2 = [str2, sprintf(', parms{%d}(:)',n)] ; 
    end
    % ndgrid
    eval(sprintf('[%s]=ndgrid(%s) ; ',str1, str2)) ; 
    % assign individual parameter dictionary
    for n=1:this.model.NumParms
        dictionary.(this.model.parmsLabels(n)) = single(par{n}(:)) ; 
    end

    dictionary.parmsLabels = this.model.parmsLabels ; 

    % ----- 4) persist to disk for future reuse -----
    meta.signature = sig; %#ok<NASGU> 
    try
        save(cacheFile, 'dictionary', 'meta', '-v7.3');
    catch
        % 安全降级：若保存失败，不影响本次返回
        % (可根据需要添加 warning)
        warning("保存失败");
    end
end % End of function CreateDictionary 


% =========================
% ===== helper below ======
% =========================
function sig = iComputeSignature(this, model)
% Compose a stable byte stream from: FcnSignal (by text), parms, model
% Then compute SHA-256 hex string using Java MessageDigest.
    md = java.security.MessageDigest.getInstance('SHA-256');

    % (a) function handle signature (text form is stable enough across sessions)
    try
        ftxt = func2str(this.model.FcnSignal);
    catch
        % fallback: class name if func2str fails
        ftxt = class(this.model.FcnSignal);
    end
    md.update(uint8(ftxt));

    % (b) parms content
    try
        bytes_parms = getByteStreamFromArray(this.fitopts.dictionary.parms);
        md.update(bytes_parms);
    catch
        % fallback: stringify
        md.update(uint8(evalc('disp(this.fitopts.dictionary.parms)')));
    end

    % (c) model content
    try
        bytes_model = getByteStreamFromArray(model);
        md.update(bytes_model);
    catch
        % fallback: best-effort textual dump
        md.update(uint8(class(model)));
        md.update(uint8(evalc('disp(model)')));
    end

    % finalize to hex
    raw = typecast(md.digest(), 'uint8');
    sig = lower(reshape(dec2hex(raw).', 1, []));
end
