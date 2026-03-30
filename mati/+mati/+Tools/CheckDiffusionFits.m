function CheckDiffusionFits(model, data, fitout, nz, nim)
%% check fits pixel-wisely

    %% preliminary
    if nargin<3, nz = 1 ; nim = 1 ; end
    if nargin<4, nim = 1 ; end

    hFig = figure ; clf ; 
    set(hFig,'unit','inch') ; set(hFig, 'position',[11 6 12 4])
    hsp1 = subplot(1,3,1) ;     hsp2 = subplot(1,3,2) ;     hsp3 = subplot(1,3,3) ; 
    
    %% left panel for parametric map
    axes(hsp1) ; 
    mati.Tools.OverlayParmMapOnAnatomy(data.img(:,:,nz,nim), fitout.d(:,:,nz), data.mask(:,:,nz),'hAxes',hsp1,'colormap','default')
    fitParms = zeros([length(model.parmsLabels),1]) ; 
    while 1
        % subplot(1,3,1)
        axes(hsp1)
        title(["Pick one pixel inside ROI ... ","The middle or right click to stop. "]) 
        [indx,indy,b] = ginput(1) ; 
        if (b~= 1)
            % middle or right click to stop checking single pixel
            break;
        end
        nx = round(indy) ; 
        ny = round(indx) ; 
        impixelinfo 

        % raw signal
        cla(hsp2)
        hsp2 = subplot(1,3,2) ; 
        mati.Tools.ShowDiffusionSignal(model.pulse, squeeze(data.img(nx,ny, nz,:)) ,'marker_dashLine')
        % mati.Tools.ShowDiffusionSignal(acqPulse, squeeze(data.img(nx,ny, nz,:)) ,'marker_dashLine')
        set(hsp2, 'yscale', 'log', 'ylim', [0 max(squeeze(data.img(nx,ny, nz,:)))]) ; axis auto ; 
        title('Raw signal')

        try
            % show fits on the right panel
            cla(hsp3) ; 
            hsp3 = subplot(1,3,3) ; 
            hold on
            signal = squeeze(fitout.data.img(nx,ny, nz,:)) ; 
            % acquired signal
            mati.Tools.ShowDiffusionSignal(model.pulse, signal,'marker')
            % fitted signal
            titleString = sprintf('Voxel#(%d,%d,%d): \n',nx,ny,nz) ; 
            for nParm = 1:length(model.parmsLabels)
                fitParms(nParm) = fitout.(model.parmsLabels(nParm))(nx,ny,nz) ; 
                titleString = [titleString, sprintf('%s=%.2f, ',model.parmsLabels(nParm), fitParms(nParm))] ; 
            end
            mati.Tools.ShowDiffusionSignal(model.pulse, model.FcnSignal(fitParms, model) ,'line')
            set(hsp3, 'yscale', 'log', 'ylim', [0 1.1]) ; 
            title(titleString)
        catch
            warning('Please pick a point insdie the ROI!')
        end
        
    end



end