function ShowDiffusionSignal(pulse, signal, plotType)
%% show dMRI signal curve. A different tdiff has a different color


    %% preliminary
    mati.Tools.SetPlotPars() ; 
    if nargin<3
        plotType = 'marker_line' ; 
    end
    
    tdiffs = unique(pulse.tdiff) ; Ntdiff = length(tdiffs) ; 

    switch lower(plotType)
        case 'marker_line', type = fig_marker_line ; 
        case 'marker_dashline', type = fig_marker_dashLine ; 
        case 'line',            type = fig_line ; 
        case 'dashline',            type = fig_dashLine ; 
        case 'marker',      type = fig_marker ; 
        otherwise,              error('%s: the plotType must be marker_line, marker_dashLine, line, dashLine, or marker',mfilename) ; 
    end

    %% show image
    hold on
    for ntdiff = 1:Ntdiff
        ind = (pulse.tdiff == tdiffs(ntdiff)) ; 
        plot(pulse.b(ind), signal(ind), type(ntdiff),LW,2 )
        strLegend{ntdiff} = sprintf('%0.1f ms', tdiffs(ntdiff)) ; 
    end
    ylim([0 1.2]) ; box on ; xlabel('b [ms/μm^2]') ; ylabel('signal [a.u.]')
    legend(strLegend) 

end