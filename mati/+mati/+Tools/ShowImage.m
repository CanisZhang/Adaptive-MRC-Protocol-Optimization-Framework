function ShowImage(IMAG, varargin)
%% show 3D images like montage but with more options
% INPUTS
%       IMAGE:  3D image
%       paired input options: usage e.g., 'clim', [0 1] show images with a color limits from 0 to 1. The followings are examples
%           clim, [0 1]:                        color limits
%           array, [Nim_x, Nim_y]:       the horizontal and vertical number of subimages of the frame
%           xrange, [0 100]:                 x-axis limit
%           yrange, [0 100]:                 y-axis limit
%           n_rot, -1:                           +-1, +-2, ... rotate image 90 degree
%           fliplr, 'y'/'n':                         flip image left-right
%           mask, MASK:                    show images inside the mask only
%           roi, ROI:                             show a ROI contour 
%           roi1, ROI1:                         show a 2nd ROI contour 
%           smooth, 0.5:                       smooth all images using noise_sigma  
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------
%  This function uses a shared Matlab funciton subplot1c.m written by Eran O. Ofek, June 2002,  URL : http://wise-obs.tau.ac.il/~eran/matlab.html
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------
%  Written by Junzhong "JZ" Xu, 202304107
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------

    %% preliminary 
    % convert IMAG to double in case it is a logical array
    IMAG = double(IMAG) ; 
    % check IMAG dimension
    IMAG = squeeze(IMAG) ; 
    if (length(size(IMAG))>3) || (length(size(IMAG))<2)
        error('IMAG dimention wrong! should be either 2 or 3 ') ; 
    end

    % get all dimensions
    [Np, Nv, Ns] = size(IMAG) ;

    % calculate subplot array
    Npic_row = ceil(sqrt(Ns)) ; Npic_col = ceil(Ns / Npic_row) ; 

    % Set deafult parameters
    color_range = [min(IMAG(:)), max(IMAG(:))] ;
    color_roi = 'r' ; 
    color_roi1 = 'g' ; 
    x_range = [1 Np] ; y_range = [1 Nv] ; 
    n_rot = 0 ;     
    flag.overlay = 'n' ; 
    flag.roi = 'n' ; % show boundaries of ROI
    flag.roi1 = 'n' ; % show boundaries of ROI
    flag.mask = 'n' ; % don't show images outside mask
    flag.fliplr = 'n' ; 
    flag.flipud = 'n' ; 
    flag.smooth = 'n' ; 

    % read input parameters
    if (nargin==1)
        % do nothing
    elseif(nargin>2)
        Narg = length(varargin);
        if (0.5*Narg==floor(0.5*Narg))
            for I=1:2:Narg-1
                switch lower(varargin{I})
                    case 'overlay'
                        flag.overlay = 'y' ; 
                        IMparm = varargin{I+1} ; 
                        colorsParm = [min(IMparm(:)), max(IMparm(:))] ;
                    case 'clim'
                        color_range = varargin{I+1} ;
                    case 'climparm'
                        colorsParm = varargin{I+1} ;
                    case 'x_range'
                        x_range = varargin{I+1} ;
                    case 'y_range'
                        y_range = varargin{I+1} ;
                    case 'n_rot'
                        n_rot = varargin{I+1} ; 
                    case 'fliplr'
                        flag.fliplr = varargin{I+1} ; 
                    case 'flipud'
                        flag.flipud = varargin{I+1} ; 
                    case 'array'
                        Npics = varargin{I+1} ; 
                        Npic_row = Npics(1) ; 
                        Npic_col = Npics(2) ; 
                        if Npic_row*Npic_col ~= Ns
                            error('subplot_array row times col is not equal to number of slice') ; 
                        end
                    case 'roi'
                        flag.roi = 'y' ; 
                        ROI = varargin{I+1} ; 
                    case 'roi1'
                        flag.roi1 = 'y' ; 
                        ROI1 = varargin{I+1} ; 
                    case 'mask'
                        flag.mask = 'y' ; 
                        MASK = varargin{I+1} ; 
                    case 'smooth'
                        flag.smooth = 'y' ; 
                        sigma = varargin{I+1} ; 
                    otherwise
                        error('Unknown keyword');
                end
             end
        else
            error('Optional arguments should given as keyword, value');
        end
    end



    %% plot
    clf ; 
    My_subplot(Npic_row, Npic_col, 'gap',[-0.01 0.01],'min',[0.01 0.01],'max',[0.8 0.98]) ; 

    for ns = 1:Ns
        % subimage #
        My_subplot(ns) ; 

        image_show = rot90(IMAG(:,:,ns),n_rot) ; 
        if flag.overlay == 'y' ,         parm_show = rot90(IMparm(:,:,ns),n_rot) ;         end
        if flag.mask == 'y',             mask_show = rot90(MASK(:,:,ns),n_rot) ;         end

        if flag.fliplr == 'y'
            image_show = fliplr(image_show) ; 
            if flag.overlay == 'y' ,         parm_show = fliplr(parm_show) ;         end
            if flag.mask == 'y',             mask_show = fliplr(mask_show) ;         end
        end
        if flag.flipud == 'y'
            image_show = flipud(image_show) ; 
            if flag.overlay == 'y' ,         parm_show = flipud(parm_show) ;         end
            if flag.mask == 'y',             mask_show = flipud(mask_show) ;         end
        end
        if flag.smooth == 'y' 
            image_show = imgaussfilt(image_show, sigma) ; 
        end
        
        if flag.mask == 'y'
            mask_show = rot90(MASK(:,:,ns),n_rot) ; 
            image_show = image_show .* single(mask_show) ; 
        end
        
        % show image
        if flag.overlay ~= 'y'
            imagesc(image_show) ; 
        else
            mati.Tools.OverlayParmsOnAnatomy(image_show, parm_show, mask_show,'climParm', colorsParm)
        end
        
        % set same color axis for all subplots
        clim(color_range) ; 
        xlim(x_range) ; ylim(y_range) ; 
        axis equal
        axis off

        % roi
        if flag.roi(1) == 'y'
            hold on
            roi_show = rot90(ROI(:,:,ns),n_rot) ; 
            if flag.fliplr == 'y'
                roi_show = fliplr(roi_show) ; 
            end
            contour(roi_show,color_roi)
        end
        
        % roi
        if flag.roi1 == 'y'
            hold on
            roi1_show = rot90(ROI1(:,:,ns),n_rot) ; 
            if flag.fliplr == 'y'
                roi1_show = fliplr(roi1_show) ; 
            end
            contour(roi1_show,color_roi1)
        end
    end

    if (Npic_row*Npic_col > Ns)
        for ns=(Ns+1):(Npic_row*Npic_col)
            % subimage #
            My_subplot(ns) ; 

            % show image
            imagesc(rot90(zeros(Np,Nv),n_rot)) ; 
            
            clim(color_range) ; 
            xlim(x_range) ; ylim(y_range) ; 
            axis equal
            axis off
        end
    end

end

function My_subplot(M,N,varargin) 
    %-------------------------------------------------------------------------
    % subplot1 function         An mproved subplot function
    % Input  : - If more than one input argumenst are given,
    %            then the first parameter is the number of rows.
    %            If single input argument is given, then this is the
    %            subplot-number for which to set focus.
    %            This could a scalar or two element vector (I,J).
    %          - Number of columns.
    %          * variable number of parameters
    %            (in pairs: ...,Keywoard, Value,...)
    %           - 'Min'    : X, Y lower position of lowest subplot,
    %                        default is [0.10 0.10].
    %           - 'Max'    : X, Y largest position of highest subplot,
    %                        default is [0.95 0.95].
    %           - 'Gap'    : X,Y gaps between subplots,
    %                        default is [0.01 0.01].
    %           - 'XTickL' : x ticks labels option,
    %                        'Margin' : plot only XTickLabels in the
    %                                   subplot of the lowest  row (default).
    %                        'All'    : plot XTickLabels in all subplots.
    %                        'None'   : don't plot XTickLabels in subplots.
    %           - 'YTickL' : y ticks labels option,
    %                        'Margin' : plot only YTickLabels in the
    %                                   subplot of the lowest  row (defailt).
    %                        'All'    : plot YTickLabels in all subplots.
    %                        'None'   : don't plot YTickLabels in subplots.
    %           -  'FontS'  : axis font size, default is 10.
    %             'XScale' : scale of x axis:
    %                        'linear', default.
    %                        'log'
    %           -  'YScale' : scale of y axis:
    %                        'linear', default.
    %                        'log'
    % Example: 
    %          My_subplot(2,2,'Gap',[0.02 0.08],'Min',[0.15 0.08],'Max',[1 0.99]);
    %          My_subplot(2,3,'Gap',[0.02 0.02],'XTickL','None','YTickL','All','FontS',16);
    %
    % See also : subplot1c.m
    % Tested : Matlab 5.3
    %     By : Eran O. Ofek           June 2002
    %    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
    %-------------------------------------------------------------------------
    MinDef      = [0.10 0.10];
    MaxDef      = [0.95 0.95];
    GapDef      = [0.01 0.01];
    XTickLDef   = 'Margin';  
    YTickLDef   = 'Margin';  
    FontSDef    = 10;
    XScaleDef   = 'linear';
    YScaleDef   = 'linear';

    % set default parameters
    Min    = MinDef;
    Max    = MaxDef;
    Gap    = GapDef;
    XTickL = XTickLDef;
    YTickL = YTickLDef;
    FontS  = FontSDef;
    XScale = XScaleDef;
    YScale = YScaleDef;


    MoveFoc = 0;
    if (nargin==1)
       %--- move focus to subplot # ---
       MoveFoc = 1;
    elseif (nargin==2)
       % do nothing
    elseif (nargin>2)
       Narg = length(varargin);
       if (0.5*Narg==floor(0.5*Narg))

          for I=1:2:Narg-1
             switch lower(varargin{I})
              case 'min'
             Min = varargin{I+1};
              case 'max'
             Max = varargin{I+1};
              case 'gap'
             Gap = varargin{I+1};
              case 'xtickl'
             XTickL = varargin{I+1};
              case 'ytickl'
             YTickL = varargin{I+1};
              case 'fonts'
             FontS = varargin{I+1};
              case 'xscale'
             XScale = varargin{I+1};
              case 'yscale'
             YScale = varargin{I+1};
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



    switch MoveFoc
     case 1
        %--- move focus to subplot # ---
        H    = get(gcf,'Children');
        Ptot = length(H);
        if (length(M)==1),
           M    = Ptot - M + 1; 
        elseif (length(M)==2),
           %--- check for subplot size ---
           Pos1  = get(H(1),'Position');
           Pos1x = Pos1(1);
           for Icheck=2:1:Ptot,
              PosN  = get(H(Icheck),'Position');
              PosNx = PosN(1);
              if (PosNx==Pos1x),
                 NumberOfCol = Icheck - 1;
                 break;
              end
           end
           NumberOfRow = Ptot./NumberOfCol;

           Row = M(1);
           Col = M(2);

           M   = (Row-1).*NumberOfCol + Col;
           M    = Ptot - M + 1; 
        else
           error('Unknown option, undefined subplot index');
        end

        set(gcf,'CurrentAxes',H(M));

     case 0
        %--- open subplots ---

        Xmin   = Min(1);
        Ymin   = Min(2);
        Xmax   = Max(1);
        Ymax   = Max(2);
        Xgap   = Gap(1);
        Ygap   = Gap(2);


        Xsize  = (Xmax - Xmin)./N;
        Ysize  = (Ymax - Ymin)./M;

        Xbox   = Xsize - Xgap;
        Ybox   = Ysize - Ygap;


        Ptot = M.*N;

        Hgcf = gcf;
        clf;
        figure(Hgcf);
        for Pi=1:1:Ptot,
           Row = ceil(Pi./N);
           Col = Pi - (Row - 1)*N;

           Xstart = Xmin + Xsize.*(Col - 1);
           Ystart = Ymax - Ysize.*Row;

    %       subplot(M,N,Pi);
    %       hold on;
           axes('position',[Xstart,Ystart,Xbox,Ybox]);
           %set(gca,'position',[Xstart,Ystart,Xbox,Ybox]);
           set(gca,'FontSize',FontS); 
           box on;
    %        hold on;

           switch XTickL
            case 'Margin'
               if (Row~=M),
                  %--- erase XTickLabel ---
                  set(gca,'XTickLabel',[]);
               end
            case 'All'
               % do nothing
            case 'None'
               set(gca,'XTickLabel',[]);
            otherwise
               error('Unknown XTickL option');
           end

           switch YTickL
            case 'Margin'
               if (Col~=1),
                  %--- erase YTickLabel ---
                  set(gca,'YTickLabel',[]);
               end    
            case 'All'
               % do nothing
            case 'None'
               set(gca,'YTickLabel',[]);
            otherwise
               error('Unknown XTickL option');
           end

           switch XScale
            case 'linear'
               set(gca,'XScale','linear');
            case 'log'
               set(gca,'XScale','log');
            otherwise
           error('Unknown XScale option');
           end

           switch YScale
            case 'linear'
               set(gca,'YScale','linear');
            case 'log'
               set(gca,'YScale','log');
            otherwise
           error('Unknown YScale option');
           end

        end

     otherwise
        error('Unknown MoveFoc option');
    end

end
