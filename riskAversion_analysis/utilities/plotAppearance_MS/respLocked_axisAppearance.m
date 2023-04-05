function respLocked_axisAppearance(axes2run, ytxt, plotTitle)

if length(axes2run)== 2
    [y2plot_min, y2plot_max] = ylimit_adapt(axes2run(1), axes2run(2));
else
    y2plot = ylim;
    y2plot_min = y2plot(1);
    y2plot_max = y2plot(2);
end

for iax = 1: length(axes2run)

    axes(axes2run(iax));
    axis square
    ylim([y2plot_min - 0.05 y2plot_max]);
    xlim([0 3.1]);
    hold on 
    plot([0 3.1], [0.05 0.05], 'k--');
    plot([0.8 0.8],[y2plot_min - 0.05 y2plot_max], 'k-'); %choice indicated
    plot([1.6 1.6], [y2plot_min - 0.05 y2plot_max], 'k-'); %reward feedback
    xlabel('Time from Response Onset (s)');
    title(plotTitle{iax}, 'FontSize', 14, 'FontWeight', 'bold');
    if length(ytxt) > 1
        ylabel(ytxt{iax});
    else 
        ylabel(ytxt);
    end
set(gca, 'FontName', 'times');
end



end
