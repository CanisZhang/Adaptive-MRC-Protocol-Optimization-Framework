function pd = CreatePriorDistribution(this, model)
%% mati.FitPars.CreatePriorDistribution to create prior distribution for data fitting using dictionary matching or Bayesian
% INPUTS:
%       this: a mati.FitPars object
%       model: a mati.SignalModel object
% OUTPUTS:
%       pd: a struct that contains probability density of prior distributions of all parameters
% -------------------------------------------------------------------------------------------------------------------------

    switch this.fitopts.priorDist.distName
        case {'none','uniform'}
            pd = ones([size(this.fitopts.dictionary.signal,1),1],'single') ; 
        otherwise
            % calculate prior distribution of all parameters
            pds = cell([this.model.NumParms,1]) ; 
            str1 = 'pds{1}' ; str2 = sprintf('this.fitopts.priorDist.pd.%ss(:)',this.model.parmsLabels(1)) ; 
            for n = 2:this.model.NumParms
                str1 = [str1, sprintf(', pds{%d}',n)] ; 
                str2 = [str2, sprintf(', this.fitopts.priorDist.pd.%ss(:)',this.model.parmsLabels(n))] ; 
            end
            % ndgrid
            eval(sprintf('[%s]=ndgrid(%s) ; ',str1, str2)) ; 
        
            % calculate prior distribution of all parametes combined
            str1 = 'pds{1}(:)' ; 
            for n=2:this.model.NumParms
                str1 = [str1, sprintf('.* pds{%d}(:)', n)] ; 
            end
            eval(sprintf('pd=%s;',str1))
        
            % normlization
            pd = pd ./ norm(pd) ; 
            pd = single(pd) ; 
    end

end % End of function CreateDictionary 


