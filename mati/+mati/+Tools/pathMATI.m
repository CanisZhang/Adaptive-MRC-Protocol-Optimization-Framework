function path = pathMATI()
%% This function returns the installation path of the MATI package

    % get the path of this function file matiFolder()
    pathThis = mfilename('fullpath') ; 
    % get the path of the MATI package
    path = erase(pathThis, fullfile('+Tools','pathMATI')) ; 

end