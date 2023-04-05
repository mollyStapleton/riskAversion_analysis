function [y2plot_min, y2plot_max] = ylimit_adapt(ax1, ax2)

% identify limits of both axes 

axes(ax1);
ylim1 = ylim;
axes(ax2);
ylim2 = ylim;

y2plot_min = min([ylim1(1) ylim2(1)]);
y2plot_max = max([ylim1(2) ylim2(2)]);

y2plot_min = y2plot_min + y2plot_min/2;
y2plot_max = y2plot_max + y2plot_max/2;

end