function [ M_in, M_ex ] = generalSolution_blochEQ( Ain,Aex,kin,kex,Min0,Mex0,t )
    Q=sqrt((Ain-Aex).^2+4.*kin.*kex);
    R1=(Ain+Aex-Q)/2;
    R2=(Ain+Aex+Q)/2;
    M_in=((Aex-Ain+Q).*Min0+2.*kex.*Mex0)/2./Q.*exp(-R1.*t)+((-Aex+Ain+Q).*Min0-2.*kex.*Mex0)/2./Q.*exp(-R2.*t);
    M_ex=((-Aex+Ain+Q).*Mex0+2.*kin.*Min0)/2./Q.*exp(-R1.*t)+((Aex-Ain+Q).*Mex0-2.*kin.*Min0)/2./Q.*exp(-R2.*t);

    % ind = (kin==0) | (kex==0) ; 
    % M_in(:,ind) = Min0(ind) .* exp(-(Ain(ind) - kin(ind)).*t) ; 
    % M_ex(:,ind) = Mex0(ind) .* exp(-(Aex(ind) - kex(ind)).*t) ; 

        % replaced by jzxu 20240412
    if length(kin)>1
        % M_in(:,find(kin==0)|find(kex==0))=Min0.*exp(-(Ain-kin).*t);
        % M_ex(:,find(kin==0)|find(kex==0))=Mex0.*exp(-(Aex-kex).*t);
        % replaced by jzxu 20240412
        ind = (kin==0) | (kex==0) ; 
        M_in(:,ind) = Min0(ind) .* exp(-(Ain(ind) - kin(ind)).*t) ; 
        M_ex(:,ind) = Mex0(ind) .* exp(-(Aex(ind) - kex(ind)).*t) ; 
    else
        if kin==0 | kex==0
            M_in=Min0.*exp(-(Ain-kin).*t);
            M_ex=Mex0.*exp(-(Aex-kex).*t);
        end        
    end
end