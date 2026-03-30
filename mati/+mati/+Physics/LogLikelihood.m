function loglikelihood = LogLikelihood(E, S, sigma)
%% Computes the log likelihood of the measurements given the model signals for the Rician noise model.
%
% loglikelihood = LogLikelihood(S, E, sigma) returns the likelihood of measuring S given the analytical expectation E with the noise standard deviation sigma. 
% The equation is based on Alexander DC. Magn Reson Med 2008 Vol. 60 Issue 2 Pages 439-48. DOI: 10.1002/mrm.21646. https://www.ncbi.nlm.nih.gov/pubmed/18666109
% ----------------------------------------------------------------------------------------------------------------------------------------
% Inputs: 
%       E: The theory-predicted signals (i.e., dictionary) with the dimension: (# of experiments) * (# of parameter combinations)
%       S: The acquired signals from experiments with the dimension: (# of experiments) * 1 * (# of  different voxels) 
%       sigma: The standard deviation of the Gaussian distributions underlying the Rician distribution. sigma must be a scalar or has the same dimension as S. 
% ----------------------------------------------------------------------------------------------------------------------------------------
% Outputs: 
%       loglikelihood:  The log likelihood of E and S with the dimension: (# of experiments) * (# of parameter combinations) * (# of different voxels)
% 
% ----------------------------------------------------------------------------------------------------------------------------------------
%  Author: Junzhong  Xu. 
% 20240419: version 2, adapted to be included in the MATI package
% 20160702: version 1
% ----------------------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    % read input parameters
    if (nargin<2 || nargin>3) 
        error('%s: the number of input arguments must be 2 {E, S} or 3 {E, S, sigma}', mfilename) ; 
    elseif nargin == 2 
        warning('%s: noise sigma is not provided. Set sigma = 0.01', mfilename) ; 
    end

    %% Calculate log likelihood 
    logliks = log(S) - log(sigma.^2) + logbesseli0(E.*S./(sigma.^2)) - (E.^2 + S.^2)./(2*sigma.^2) ;
    loglikelihood = squeeze(sum(logliks,1)) ; 

end


function lb0 = logbesseli0(x)
%% Computes log(besseli(0,x)) robustly.  
% Computing it directly causes % numerical problems at high x, but the function has asymptotic linear behaviour, which we approximate here for high x.
% For very large arguments to besseli, we approximate log besseli using a linear model of the asymptotic behaviour.
% The linear parameters come from this command: 
% app=regress(log(besseli(0,500:700))',[ones(201,1) (500:700)']);
% ----------------------------------------------------------------------------------------------------------------------------------------
% Original author: Daniel C Alexander (d.alexander@ucl.ac.uk)
% The code was adapted from the NODDI package
% ----------------------------------------------------------------------------------------------------------------------------------------

    %% preliminary
    x = double(x) ; % x must be double for the besseli()
    x_size = size(x) ; 
    
    app = [-3.61178295877576 0.99916157999904];

    lb0 = zeros(length(x(:)), 1);
    exact = find(x<700);
    approx = find(x>=700);
    lb0(exact) = log(besseli(0, x(exact)));
    %lb0(approx) = x(approx)*app(2) + app(1);

    % This is a more standard approximation.  For large x, I_0(x) -> exp(x)/sqrt(2 pi x).
    lb0(approx) = x(approx) - log(2*pi*x(approx))/2 ;

    lb0 = reshape(lb0, x_size) ; 
    
%     lb0 = log(besseli(0,x)).*(x<700)+(x - log(2*pi*x)/2).*(x>=700) ; 

end