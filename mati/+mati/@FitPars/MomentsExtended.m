function out = MomentsExtended(Moments,degree)
%% This function computes the extended matrix of moments for polynomial interpolation in multiple dimensions.
%
% INPUT: 
%       Moments:  [NxD] where N is the number of samples and D the dimension of the problem (the number of different moments) 
%       degree: 3 is recommended
% OUTPUT: 
%       out: extended matrix of mements for polynomial interpolation in multiple dimensions
% e.g. in 1D this extended matrix equals the Vandermonde matrix
% output = [1 X X^2 ... X^degree]
% -------------------------------------------------------------------------------
% Originally written By: Santiago Coelho
% revised by Junzhong Xu, 20240716
% -------------------------------------------------------------------------------

    N=size(Moments,1);
    N_moments=size(Moments,2);
    % Preparing data points for polynomial fitting
    x_0=ones(N,1);
    if degree>=1
        x_1=Moments;
        X=[x_0 x_1];
    else
        X=x_0;
    end
    if degree>=2
        for current_degree=2:degree
            combinations=nchoosek(1:(N_moments+current_degree-1),current_degree);
            NtotalCombs=size(combinations,1);
            flags=zeros(NtotalCombs,N_moments+current_degree-1);
            sums=zeros(NtotalCombs,N_moments+current_degree-1);
            which=zeros(NtotalCombs,current_degree);
            for ii=1:NtotalCombs
                flags(ii,combinations(ii,:))=1;
                sums(ii,:)=cumsum(~flags(ii,:))+1;
                which(ii,:)=sums(ii,combinations(ii,:));
            end
            Currentx=ones(N,NtotalCombs);
            for ii=1:NtotalCombs
                for jj=1:current_degree
                    current_id=which(ii,jj);
                    Currentx(:,ii)=Currentx(:,ii).*Moments(:,current_id);
                end
            end
            X = [X Currentx] ; 
        end
    end
    % output 
    out = X ;
end