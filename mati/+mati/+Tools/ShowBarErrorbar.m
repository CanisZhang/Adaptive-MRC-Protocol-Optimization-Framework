function [hax, hbar, herrorbar] = ShowBarErrorbar(barvalues, errors, varargin) 
%-------------------------------------------------------------------------
% funciton bar_errorbar     overlay errorbars on a bar figure
%
% barvalues and errors 
%   row             # of groups
%   column          # of elements in each group 
%
% varargin input parameters
%   'bar_width'             default = 1
%   'bar_edge_color'        default = 'none'
%   'bar_face_color'        
%   'errorbar_line_width'   default = 2 
%   'errorbar_line_color'   default = 'k'
%   'errorbar_side'         default = 2 ; 1: upper half only; -1: lower half only; 
%   'xticklabel'            default = {'1','2','3',...}
%   'bar_legend'            default = {'1','2','3',...}
% 
% output parameters
%   'hax'           handles of axes
%   'hbar'          handles of bars
%   'herrorbar'     handles of errorbars overlayed on bars
%
% Examples: 
%   barvalues = [100, 98, 75, 85; 75, 80, 55, 60; 120, 110, 80, 90] ; 
%   errors = [10, 12, 8, 9; 9, 11, 13, 10; 14, 15, 16, 15] ; 
%   [hax, hbar, herrorbar] = My_bar_errorbar(barvalues, errors) ; 
%
% ---------------------------------------------------------------------
% Author: Junzhong Xu
% Created: April 13, 2010 (v1.0)
% resived: Aug 23, 2010 (v1.1)
%               20240508, v1.2
%

    %% preliminary
    barvalues = squeeze(barvalues) ; errors = squeeze(errors) ; 
    if ~isequal(size(barvalues),size(errors))
        error('%s: The input barValues and errors have different matrix dimensions!', mfilename)
    end
    
    %% set parameters
    NumGroup = size(barvalues, 1) ; 
    NumElement= size(barvalues, 2) ; 
    
    % set default parameters
    bar_width = 0.8 ; 
    errorbar_line_width = 2 ; 
    errorbar_line_color = 'k' ; 
    errorbar_line_style = 'none' ; 
    errorbar_side = 2 ; 
    
    % set default bar facecolor to gray scale
    flag.bfc = 'n' ; flag.bec = 'n' ; flag.elw = 'n' ; flag.elc = 'n' ; 
    
    fc = linspace(0.8, 0.3, NumElement) ; 
    ec = linspace(0.8, 0.3, NumElement) ; 
    bar_face_color = cell([NumElement,1]) ; 
    bar_edge_color = cell([NumElement,1]) ; 
    for ne = 1:NumElement
        bar_face_color{ne} = [1 1 1].*fc(ne) ; 
        bar_edge_color{ne} = [1 1 1].*ec(ne) ; 
    end
    
    xticklabel = cell(NumGroup, 1) ; 
    for n = 1:NumGroup
        xticklabel(n) = cellstr(num2str(n)) ; 
    end
    
    bar_legend = cell(NumElement, 1) ;
    for n = 1:NumElement
        bar_legend(n) = cellstr(num2str(n)) ; 
    end
    
    % read input parameters
    if (nargin==1)
        error('not enough parameters') ; 
    elseif (nargin==2)
        % do nothing, use all default parameters
    
    elseif (nargin>2)
        Narg = length(varargin);
        if (0.5*Narg==floor(0.5*Narg))
            for I=1:2:Narg-1
                switch lower(varargin{I})
                    case 'bar_width'
                        bar_width = varargin{I+1};
                    case 'bar_face_color'
                        flag.bfc = 'y' ; 
                        bar_face_color = varargin{I+1};
                    case 'bar_edge_color'
                        flag.bec = 'y' ; 
                        bar_edge_color = varargin{I+1};
                    case 'errorbar_line_width'
                        flag.elw = 'y' ; 
                        errorbar_line_width = varargin{I+1};
                    case 'errorbar_line_color'
                        flag.elc = 'y' ; 
                        errorbar_line_color = varargin{I+1};
                    case 'errorbar_side'
                        errorbar_side = varargin{I+1};
                    case 'xticklabel'
                        if length(varargin{I+1}) ~= NumGroup
                            error('number of x tick labels should be the same of rows of barvales') ; 
                        end
                        xticklabel = varargin{I+1} ; 
                    case 'bar_legend'
                        if length(varargin{I+1}) ~= NumElement
                            error('number of legends should be the same of columns of barvales') ; 
                        end
                        bar_legend = varargin{I+1} ; 
                    otherwise
                        error('Unknown keyword');
                end
             end
        else
            error('Optional arguments should given as keyword, value');
        end
    else
        error('Illegal number of input arguments');
    end
    
    % plot bar
    clear hbar 
    if isvector(barvalues) % NumGroup=1: One can use the regular bar() but here provides different colors for each bar
        for ne = 1:NumElement
            hold on
            hbar(ne) = bar(ne, barvalues(ne)) ; 
        end
    else
        hbar = bar(barvalues,bar_width) ; 
    end
    
    % set edgecolor
    if flag.bec == 'y'
        for ne = 1:NumElement
            set(hbar(ne),'edgecolor',bar_edge_color{ne})
        end
    end
    
    % set bar facecolor
    if flag.bfc == 'y'
        for ne = 1:NumElement
            set(hbar(ne), 'facecolor', bar_face_color{ne}) ; 
        end
    end
    
    hold on
    
    % plot errorbar
    herrorbar = hbar ; 
    ymax = 0 ; 
    for n = 1:NumElement
    %     x = get(get(hbar(n),'children'), 'xdata') ; 
    %     x = mean(x([1 3],:)) ; 
        % if verLessThan('matlab', '8.4')
    %         x = hbar(n).XData ; 
        % else
        hbar(n)
        x = hbar(n).XData + hbar(n).XOffset ; 
        % end
        herrorbar(n) = errorbar(x, barvalues(:,n), errors(:,n), errorbar_line_color, 'linestyle', errorbar_line_style, 'linewidth', errorbar_line_width);
        ymax = max([ymax; abs(barvalues(:,n))+abs(errors(:,n))]);
    end
    
    % set errorbar
    if errorbar_side == -1
        for n = 1:NumElement
            set(herrorbar(n),'UData',0)
        end
    elseif errorbar_side == 1
        for n = 1:NumElement
            set(herrorbar(n),'LData',0)
        end
    end
    
    
    % set axis
    % set(gca, 'xticklabel',["Label#1","Label#2","Label#3"]) ; 
    set(gca, 'xticklabel',["45","65","200","400"]) ; 
    
    %legend(hbar, bar_legend)
    hold off
    
    hax = gca ; 

end




