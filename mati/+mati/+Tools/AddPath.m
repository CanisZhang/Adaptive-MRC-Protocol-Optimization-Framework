function  flagFolderInPath = AddPath(folderToAdd)
%% add a folder to the path if it is not in the path yet

    % create a cell array with each folder as a cell
    pathCells = strsplit(path(),pathsep) ; 
    
    % search the cell array for your folder_to_search_for
    if any(strcmp(pathCells, folderToAdd))
        % folder is already in the path
        flagFolderInPath = 1 ; 
    else
        % folder is not in the path yet. add path
        flagFolderInPath = 0 ; 
        addpath(folderToAdd) ; 
    end 
end