function CheckMicrostructuralDMRIMap(fitout, parmToCheck)
%% Check parametric maps


    %%
    switch parmToCheck
        case 'vin'
            map = fitout.vin *100 ; climShow = [0 100] ; varName = 'vin' ; varUnit =  '[%]' ; 
        case 'd'
            map = fitout.d ; climShow = [0 30] ;  varName = 'd' ; varUnit = '[μm]' ; 
        case 'Dex'
            map = fitout.Dex ; climShow = [0 3] ;  varName = 'Dex' ; varUnit = '[μm^2/ms]' ; 
        case 'Din'
            map = fitout.Din ; climShow = [0 3] ;  varName = 'Din' ; varUnit = '[μm^2/ms]' ; 
        case 'betaex'
            map = fitout.betaex ; climShow = [0 max(parms.fitpars.fitopts.dictionary.betaex)] ; varName = 'betaex' ; varUnit='[μm^2]' ; 
        case 'kin'
            map = fitout.kin ; climShow = [0 max(parms.fitpars.fitopts.dictionary.kin)] ;  varName = 'kin' ; varUnit = '[ms^(-1)]' ; 
        case 'ADC1'
            map = fitout.ADC1 ; climShow = [0 3] ;  varName = sprintf('ADC1(tdiff=%.2fms)',fitout.ADCpulse.tdiff(1)) ; varUnit = '[μm^2/ms]' ; 
        case 'ADC2'
            map = fitout.ADC2 ; climShow = [0 3] ;  varName = sprintf('ADC2(tdiff=%.2fms)',fitout.ADCpulse.tdiff(2)) ; varUnit = '[μm^2/ms]' ; 
        case 'ADC3'
            map = fitout.ADC3 ; climShow = [0 3] ;  varName = sprintf('ADC3(tdiff=%.2fms)',fitout.ADCpulse.tdiff(3)) ; varUnit = '[μm^2/ms]' ; 
        case 'rho'
            map = fitout.rho * 1e6 ; climShow = [0 1000] ;  varName = 'ρ' ; varUnit = '[million cells / cc]' ; 
        case 'cellularity'
            map = fitout.cellularity * 1e6 ; climShow = [0 1000] ;  varName = 'cellularity' ; varUnit = '[thousand cells / mm^2]' ; 
        case 'cellularity_index'
            map = fitout.cellularity_index *1e3 ; climShow = [0 100] ;  varName = 'cellularity_index' ; varUnit = '[ /mm)]' ; 
        case 'DADC21'
            map = fitout.DADC21 ; climShow = [0 1] ;  varName = sprintf('ΔADC21=ADC2(%.2fms) - ADC1(%.2fms)', fitout.ADCpulse.tdiff(2), fitout.ADCpulse.tdiff(1)) ; varUnit = '[μm^2/ms]' ; 
        case 'DADC32'
            map = fitout.DADC32 ; climShow = [0 1] ;  varName = sprintf('ΔADC32=ADC3(%.2fms) - ADC2(%.2fms)', fitout.ADCpulse.tdiff(3), fitout.ADCpulse.tdiff(2)) ; varUnit = '[μm^2/ms]' ; 
        case 'DADC31'
            map = fitout.DADC31 ; climShow = [0 1] ;  varName = sprintf('ΔADC31=ADC3(%.2fms) - ADC1(%.2fms)', fitout.ADCpulse.tdiff(3), fitout.ADCpulse.tdiff(1)) ; varUnit = '[μm^2/ms]' ; 
        case 'DDR'
            map = fitout.DDR ; climShow = [0 20] ;  varName = sprintf('DDR') ; varUnit = '[μm^2]' ; 
        otherwise
            errordlg('%s: The parmToCheck %s is not coded yet', mfilename, parmToCheck) ; 
    end

    %% show parametric map
    hfigs(1) = figure('Name', varName) ; hfigs(1).Units = 'inches' ; hfigs(1).Position = [0.5    6     5.5     4.5] ; 
    mati.Tools.ShowImage(map, 'clim', climShow)
    impixelinfo ; 

    hfigs(2) = figure('Name', sprintf('histogram of %s of the whole ROI', varName)) ; hfigs(2).Units = 'inches' ; hfigs(2).Position = [6       6     5.5     4.5] ; 
    metric = map(fitout.data.mask) ; 
    hax = histogram(metric,'Normalization','probability') ; 
    title(sprintf('ROI-averaged %s = %.2f %s',varName, mean(metric), varUnit)) ; 
    xlabel(sprintf('%s %s', varName, varUnit)) ; ylabel('probability') ; 



end
