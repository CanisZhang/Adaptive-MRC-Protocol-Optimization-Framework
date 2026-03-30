function OverlayParmMapOnAnatomy(ImgBase, ImgParm, mask, varargin)
%% function mati.Tools.OverlayParmMapOnAnatomy shows a colorful parametric map on a gray-scale anatomical image
% -----------------------------------------------------------------------
% INPUT: 
%           IMp:  parametric image
%           IMb:  backgroup image
%           mask:  mask to show the colorful parametric map
% OUTPUT:
%           NONE
% --------------------------------------------------------------------------
% Author: Junzhong Xu,  2016-02-22
% --------------------------------------------------------------------------

    warning off ; 

    %% preliminary
    if ~ismatrix(ImgBase) || ~ismatrix(ImgParm) || ~ismatrix(mask)
        error('%s: The input ImgBase, ImgParm, and mask must be 2D matrices')
    end
    % default values
    climBase = [min(ImgBase(:)), max(ImgBase(:))] ; 
    climParm = [min(ImgParm(:)), max(ImgParm(:))] ; 
    colormap_show = 'default' ; 
    ifColorbar = true ; 
    ifNewAxes = true ; 
    ifSmooth = false ; 
    
    % read input parameters
    if (nargin<3)
        error('%s: At least three input arguments (ImgBase, ImgParm, and mask) are needed', mfilename) ; 
    elseif(nargin>3)
        Narg = length(varargin) ; 
        if (0.5*Narg==floor(0.5*Narg))
            for I=1:2:Narg-1
                switch lower(varargin{I})
                    case {'haxes'}       % If use existing axes for the image
                        ifNewAxes = false ; 
                        hAxes = varargin{I+1} ; 
                    case 'climbase'     % set up clim for the base image
                        climBase = varargin{I+1} ; climBase = sort(climBase, 'ascend') ; 
                        ImgBase(ImgBase(:)<climBase(1)) = climBase(1) ; 
                        ImgBase(ImgBase(:)>climBase(2)) = climBase(2) ; 
                    case 'climparm'     % set up the clim for the parametric map
                        climParm = varargin{I+1} ; climParm = sort(climParm, 'ascend') ; 
                    case 'colormap'     % if a user-defined colormap will be used
                        colormap_show = varargin{I+1} ; 
                    case 'colorbar'
                        colorbar_show = varargin{I+1} ; 
                        if strcmp(colorbar_show, 'off')
                            ifColorbar = false ; 
                        end
                    case 'smooth'
                        ifSmooth = true ; 
                        smoothSigma = varargin{I+1} ; 
                    otherwise
                        error('Unknown keyword');
                end
             end
        else
            error('Optional arguments should given as keyword, value');
        end
    end

    if ifNewAxes
        hFig = figure ; hAxes = axes('Parent', hFig) ; 
    end

    %% Show image
    % prepare base image
    ImgBase = ImgBase / climBase(2) ; 
    ImgRGB = ImgBase(:,:, [1 1 1]) ;

    % show colorful parametric map
    if ifSmooth
        ImgParm = imgaussfilt(ImgParm, smoothSigma) ; 
    end
    imshow(ImgParm, 'Parent', hAxes,'border','tight') ; 
    clim(climParm) ; 
    colormap(colormap_show); 
    hold on ; 
    h = imshow(ImgRGB, 'Parent', hAxes,'border','tight') ; 
    set(h, 'AlphaData', ~mask);      % make pixels in the ROI transparent
    
    % colorbar
    if ifColorbar
        colorbar ;     
    end

end  % End
