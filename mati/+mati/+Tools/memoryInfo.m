function memInfo = memoryInfo(varargin)
%% Return memory information about the system. 
% Note that the memory() function works on Windows systems only. The system commands are needed on Linux or Mac systems. This MATLAB function provide a convenient way to provide the information on the system memory. 
%
% ----------------------------------------------------------------------------------------------------------
%  Author: Junzhong Xu, 2024-10-17
% ----------------------------------------------------------------------------------------------------------
% This function is a part of the MATI package 
% Please cite the following references
%   1. 
%   2. 
% ----------------------------------------------------------------------------------------------------------

    %% preliminary
    switch nargin 
        case 0
            memInfo.unit = 'Byte' ; 
        case 1
            switch lower(char(varargin))
                case {'byte', 'bytes'}, memInfo.unit = 'byte' ; 
                case {'kb'},                    memInfo.unit = 'KB' ; 
                case 'mb',                    memInfo.unit = 'MB' ; 
                case 'gb',                    memInfo.unit = 'GB' ; 
                otherwise,             error('mati.Tools.memInfo takes 0 or 1 input argument (memory unit e.g., byte, KB, MB, or GB)')
            end
        otherwise
            error('mati.Tools.memInfo takes 0 or 1 input argument (memory unit e.g., byte, KB, MB, or GB)')
    end

    %% get memory info
    if ispc
        memInfoTemp = memory ; 
        memTotal = memInfoTemp.MaxPossibleArrayBytes ;          % Bytes
        memAvailable = memInfoTemp.MemAvailableAllArrays ;      % Bytes
    elseif isunix        % Linux or Unix
        % The /proc/meminfo default unit is KB
        [~, memTotal] = system('grep MemTotal /proc/meminfo | awk ''{print $2}''') ; 
        [~, memAvailable] = system('grep MemAvailable /proc/meminfo | awk ''{print $2}''') ; 
        memTotal = str2double(memTotal) * 1024 ;                        % Bytes
        memAvailable = str2double(memAvailable) * 1024 ;          % Bytes
    elseif ismac        % Mac
        error('%s: Mac is underdevelopment',mfilename)
    else
        errordlg('Not a PC, or Unix/Linux, or Mac. What kind of system are you using?')
    end

    %% output results
    switch lower(memInfo.unit)
        case 'byte'
            memInfo.memoryTotal = memTotal ;      % Byte
            memInfo.memoryAvailable = memAvailable ;      
        case 'kb'
            memInfo.memoryTotal = memTotal / 1024;      
            memInfo.memoryAvailable = memAvailable / 1024 ;      
        case 'mb'
            memInfo.memoryTotal = memTotal / 1024^2 ;      % Convert memory from Byte to MB 
            memInfo.memoryAvailable = memAvailable / 1024^2 ;     
        case 'gb'
            memInfo.memoryTotal = memTotal / 1024^3 ;      % Convert memory from Byte to GB
            memInfo.memoryAvailable = memAvailable / 1024^3 ;     
    end

end