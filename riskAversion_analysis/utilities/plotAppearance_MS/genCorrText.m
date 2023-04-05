function [corrText] = genCorrText(rho, pr, dataVec, ax2text, distType)

df = find(~isnan(dataVec));

corrText = ['r_{s}(' num2str(length(df) - 2) ') = ' num2str(rho, '%.2f'),...
    ', p = ' num2str(pr, '%.2f')];

axes(ax2text);
hold on 
y2plot = ylim;
x2plot =xlim;


if distType == 0     %allDists
    text([x2plot(1) + (diff(x2plot)./100)], [y2plot(2) - (diff(y2plot)./30)], corrText, 'color', 'k');
elseif distType == 1 %Gaussian
    text([x2plot(1) + (diff(x2plot)./100)], [y2plot(2) - (diff(y2plot)./30)], corrText, 'color', [0.7059 0.4745 0.9882]);
elseif distType == 2 %Bimodal
    text([x2plot(1) + (diff(x2plot)./100)], [y2plot(2) - (diff(y2plot)./10)], corrText, 'color', [0.3961 0.9608 0.3647]);
end

end
