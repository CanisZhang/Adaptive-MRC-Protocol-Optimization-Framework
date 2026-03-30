function OutputMapsNIfTI(fitout, data_nii, dirOutput)
%% This function saves MATI-derived parametric maps to NIfTI images
% INPUTS:
%           fitout: MATI-generated fitted output
%           data_nii: sample NIfTI structure. All saved NIfTI images will follow this NIfTI structure
%           dirOutput: the folder path for save all results
% -----------------------------------------------------------------------------------------------------------------------
% Author: Junzhong Xu, 2024-10-18
% -----------------------------------------------------------------------------------------------------------------------

    %% preliminary
    % prepare a 3D parametric map nifti from the 4D data
    Nx = size(data_nii.img,1) ; Ny = size(data_nii.img,2) ; Nz = size(data_nii.img, 3) ; 
    par_nii = data_nii ; 
    par_nii.img = single(par_nii.img(:,:,:,1)) ; % convert double --> single 
    par_nii.hdr.dime.dim = [3 Nx Ny Nz 1 1 1 1] ;  
    % output nifti datatype is single/float32
    par_nii.hdr.dime.datatype = 16 ; 
    par_nii.hdr.dime.bitpix = 32 ; 
    
    % export parametric maps
    for n=1:length(fitout.mapLabels)
        tmp_nii = par_nii ; 
        varName = fitout.mapLabels(n) ; 
        fileName = fullfile(dirOutput, sprintf('%s.nii.gz',varName)) ; 
        eval(sprintf('tmp_nii.img = single(fitout.%s) ; ', varName)) ; 
        eval(sprintf('save_nii(tmp_nii, ''%s'')', fileName))
    end
    








end