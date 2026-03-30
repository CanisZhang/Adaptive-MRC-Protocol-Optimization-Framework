function [x, resnorm,ci] = MRI_fit_biexp(x, y, x0, lb, ub)
%% fit biexponential function
% ----------- input parameters ------------------
% x,y : data
% beta0:   initial guess
% lb, ub:  lower and upper bound of parameters
% ----------- output parameters -----------------
% beta(1): D1
% beta(2): D2
% beta(3): f1
% beta(4): M0
% resnorm: residual norm
% ci:      confidence interval


%% fitting
%beta = nlinfit(x,y,@biexp, beta0) ; 
% options=optimset('lsqcurvefit') ; 
options=optimset('Display','off') ; %,...
%     'TolFun',1e-12,'TolX',1e-12,'MaxFunEvals',5000*length(x),'MaxIter',10000) ; 

[x, resnorm,resid,exitflag,output,lambda,jacobian] = lsqcurvefit(@signal, x0, x, y, lb, ub, options) ; 

ci = nlparci(x,resid,'jacobian',jacobian) ; 


function yhat = signal(x, b)
% bi-exponential function
yhat = x(4).*(x(3).*exp(-b.*x(1)) + (1-x(3)).*exp(-b.*x(2))) ; 



