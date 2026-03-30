function [ p1, p0] = FitLinear_1voxel(x, y)
%% fit a linear relationship  y = p0 + p1 * x

    p = polyfit(x(:), squeeze(y(:)), 1) ; 

    %% output
    p1 = p(1) ; 
    p0 = p(2) ; 

end