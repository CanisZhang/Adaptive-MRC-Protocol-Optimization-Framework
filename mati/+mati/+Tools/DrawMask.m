function mask = DrawMask(img)
%% manually draw mask/ROI from an 2D or 3D image
    % to prevent img is complex
    img = abs(img) ; 

    %% preliminary
    [Nx,Ny,Nz,Nim] = size(img) ; 
    if Nx == 1 || Ny == 1 
        warndlg(sprintf('%s: The input image has the1st or 2nd dimension as 1. Set the mask covers all input image pixels.',mfilename))
        mask = true([Nx,Ny,Nz]) ; 
        return ; 
    end

    %% draw ROI
    mask = false([Nx,Ny,Nz]) ; 
    hfigs = gobjects([3,1]) ; 
    hfigs(1) = figure ; hfigs(1).Units = 'inches' ; hfigs(1).Position = [0.5    6     5.5     4.5] ; 
    hfigs(2) = figure ; hfigs(2).Units = 'inches' ; hfigs(2).Position = [6       6     5.5     4.5] ; 
    hfigs(3) = figure ; hfigs(3).Units = 'inches' ; hfigs(3).Position = [12     6     5.5     4.5] ; 
    nim0 = 1 ; 
    set(0,'CurrentFigure',hfigs(1)) ; mati.Tools.ShowImage(img(:,:,:,nim0))
    choosing = true ; 
    while choosing
        if Nim==1
            waitfor(warndlg(sprintf('%s: The input image has only one volume. You have to draw ROI mask using this image volume anyway',mfilename))) ;  
            nim= nim0 ; 
        else
            choosing_nim = true ; 
            nim = Nim ; % show a different volume
            while choosing_nim
            set(0,'CurrentFigure',hfigs(2)) ; mati.Tools.ShowImage(img(:,:,:,nim))
                answer = questdlg('For the three new opened windows, the left windows shows the image volume#1 (typically b=0) and the middle window shows a diffusion-weighted image volume. Can you identify the ROI (e.g., tumor) clearly by comparing volume#1 and the current diffusion-weighted volume?', 'Identify the ROI', 'Yes','No: Show me the previous DWI volume','No: Show me the next DWI volume','Yes') ; 
                switch answer
                    case 'Yes'
                        choosing_nim = false ; 
                    case 'No: Show me the previous DWI volume'
                        nim  = nim - 1 ; 
                        if nim==0,   nim = Nim ;   end
                    case 'No: Show me the next DWI volume'
                        nim = nim + 1 ; 
                        if nim>Nim,   nim = 1 ; end
                end
            end
        end
    
        %% Draw ROI
        answer = inputdlg({'ROI mask starts at slice #','ROI mask ends at slice #'},'ROI may not appear on all slices. Enter the slice number range for drawing ROI mask', [1 40],{'1',num2str(Nz)}) ; 
        set(0,'CurrentFigure',hfigs(3)) 
        nzStart = str2num(answer{1}) ; nzEnd = str2num(answer{2}) ; 
        for nz=nzStart:nzEnd
            imagesc(img(:,:,nz,nim)) ; 
            title(sprintf('slice #%d/%d: Please draw ROI mask on this slice...',nz,Nz))
            mask(:,:,nz) = roipoly ; 
        end
    
        %% final check ROIs
        % Show ROIs
        set(0,'CurrentFigure',hfigs(1))
        mati.Tools.ShowImage(img(:,:,:,1),'roi',mask)
        if nim~=nim0
            set(0,'CurrentFigure',hfigs(2))
            mati.Tools.ShowImage(img(:,:,:,nim),'roi',mask)
        end
        % OK with the ROIs
        answer = questdlg('Are you OK with the ROI mask?', 'Menu', 'Yes: Let''s move on!','No: I wanna redraw ROI', 'Yes: Let''s move on!') ; 
        switch answer
            case 'Yes: Let''s move on!'
                choosing = false ; 
                close(hfigs(1)) ; close(hfigs(2)) ; close(hfigs(3))
            case 'No: I wanna redraw ROI'
                answer = questdlg('Are you sure to redraw ROI. All existing ROIs will be lost!', 'Menu', 'Yes','Yes', 'No') ; 
                switch answer
                    case 'Yes'
                        % close current DrawMask
                        choosing = false ; 
                        close(hfigs(1)) ; close(hfigs(2)) ; close(hfigs(3))
                        % restart DrawMask()
                        mask = mati.Tools.DrawMask(img) ; 
                    case 'No'
                        msgbox('OK. The ROI mask will be used.')
                end
        end

    end % End of while choosing

end % End of function
