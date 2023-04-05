function stimLocked_axisAppearance(axes2run, ytxt, plotTitle)
 % INPUT: 
 % axes2run: axes handles to edit, this may be multiple, in which case ylims are scaled to match  
 % ytxt: text for ylabel 
 % plotTitle: title for plots 

 % *** take into account multiple plots passing through the single function
 % 
 

if length(axes2run)== 2
    [y2plot_min, y2plot_max] = ylimit_adapt(axes2run(1), axes2run(2));
end

for iax = 1: length(axes2run)

    axes(axes2run(iax));
    axis square
    ylim([y2plot_min - 0.05 y2plot_max]);
    xlim([-0.2 0.8]);
    hold on 
    plot([-0.2 0.8], [0.05 0.05], 'k--');
    plot([0 0],[y2plot_min - 0.05 y2plot_max], 'k-');
    xlabel('Time from Stimulus Onset (s)');
    title(plotTitle{iax}, 'FontSize', 14, 'FontWeight', 'bold');
    if length(ytxt) > 1
        ylabel(ytxt{iax});
    else 
        ylabel(ytxt);
    end
set(gca, 'FontName', 'times');
end


end