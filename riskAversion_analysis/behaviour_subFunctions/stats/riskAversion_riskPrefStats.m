function riskAversion_riskPrefStats(base_path, dataIn)

bin = [1:24:120];
binSize = 24;
subs = unique(dataIn.pt_number);

stats_table = [];

figure(1);
set(gcf, 'Units', 'centimeters');
set(gcf, 'position', [12.8852 2.7728 23.7755 17.3620]);

ax1 = subplot(2, 2, 1);
ax2 = subplot(2, 2, 2);
ax3 = subplot(2, 2, 3);
ax4 = subplot(2, 2, 4);

for blockType = 1:2
    
    tmpBlock = [];
    
    if blockType == 1  % gaussian
        blockIdx = find([dataIn.distType] == blockType);
        col2plot = [0.7059 0.4745 0.9882];
    else blockType == 2  % bimodal
        blockIdx = find([dataIn.distType] == blockType);
        col2plot = [0.3961 0.9608 0.3647];
    end

    tmpBlock    = dataIn(blockIdx, :);

    for isubject = 1: length(subs)

        tmpSub = [];
        diffIdx = [];

        subIdx = find(tmpBlock.pt_number == subs(isubject));
        tmpSub = tmpBlock(subIdx, :);

        lowIdx = find(tmpSub.cnd_idx == 2);
        highIdx = find(tmpSub.cnd_idx == 3);

        highRisk{blockType}(isubject) = sum(tmpSub.choice_risky(highIdx) == 1)./length(highIdx);
        lowRisk{blockType}(isubject)  = sum(tmpSub.choice_risky(lowIdx) == 1)./length(lowIdx);

        allRisk(blockType, isubject) = (sum(tmpSub.choice_risky(highIdx) == 1) + sum(tmpSub.choice_risky(lowIdx) == 1))./...
                                        (sum(length(highIdx)) + sum(length(lowIdx)));

        for ibin = 1: length(bin)

            tmpBinIdx = [];
            tmpBinIdx = find(ismember(tmpSub.trialNum(lowIdx),  (bin(ibin): (bin(ibin) + binSize -1))));         
            prefLow_binned{blockType}(isubject, ibin) = sum(tmpSub.choice_risky(lowIdx(tmpBinIdx)) == 1)./length(lowIdx(tmpBinIdx));

            tmpBinIdx = [];
            tmpBinIdx = find(ismember(tmpSub.trialNum(highIdx),  (bin(ibin): (bin(ibin) + binSize -1))));         
            prefHigh_binned{blockType}(isubject, ibin) = sum(tmpSub.choice_risky(highIdx(tmpBinIdx)) == 1)./length(highIdx(tmpBinIdx));

            prefAll_binned{blockType}(isubject, ibin) = (sum(tmpSub.choice_risky(lowIdx(tmpBinIdx)) == 1) + sum(tmpSub.choice_risky(highIdx(tmpBinIdx)) == 1))./...
                (length(lowIdx(tmpBinIdx)) + length(highIdx(tmpBinIdx)));

            if tmpSub.blockNumber(1) == 1 
                blockOrder = 0;
            else 
                blockOrder = 1;
            end


            tmpTable(ibin, :) = [ibin, subs(isubject), blockType, blockOrder, prefLow_binned{blockType}(isubject, ibin),...
                prefHigh_binned{blockType}(isubject, ibin) prefAll_binned{blockType}(isubject, ibin)];
        
        end

        stats_table = [stats_table; tmpTable];

        axes(ax3);
        hold on 
        plot(highRisk{blockType}(isubject), lowRisk{blockType}(isubject), 'Marker', 'o', 'MarkerFaceColor', col2plot,...
            'MarkerEdgeColor', col2plot, 'MarkerSize', 7);

    end
    
        mean_low{blockType} = mean(prefLow_binned{blockType});
        sem_low{blockType}  = std(prefLow_binned{blockType})./sqrt(length(prefLow_binned{blockType}));

        axes(ax2);
        hold on
        errorbar(mean_low{blockType}, sem_low{blockType}, 'color', col2plot, 'linew', 1.5);

        mean_high{blockType} = mean(prefHigh_binned{blockType});
        sem_high{blockType}  = std(prefHigh_binned{blockType})./sqrt(length(prefHigh_binned{blockType}));

        axes(ax1);
        hold on
        errorbar(mean_high{blockType}, sem_high{blockType}, 'color', col2plot, 'linew', 1.5);

        mean_all{blockType} = mean(prefAll_binned{blockType});
        sem_all{blockType}  = std(prefAll_binned{blockType})./sqrt(length(prefAll_binned{blockType}));

end

axes(ax4);
hold on
plot(allRisk(1, :), allRisk(2, :), 'k.', 'MarkerSize', 20);


axes(ax1);
hold on 
axis square
xlim([0 6]);
ylim([0 1]);
xlabel('Trials Binned');
ylabel('P(Risky|Both-High)');
title({'\fontsize{12} Risk Preference:', 'Both-High'});
plot([0 6], [0.5 0.5], 'k--');
set(gca, 'FontName', 'times');


axes(ax2);
hold on 
axis square
xlim([0 6]);
ylim([0 1]);
xlabel('Trials Binned');
ylabel('P(Risky|Both-Low)');
title({'\fontsize{12} Risk Preference:', 'Both-Low'});
plot([0 6], [0.5 0.5], 'k--');
set(gca, 'FontName', 'times');


axes(ax3);
hold on 
axis square 
xlim([0 1]);
ylim([0 1]);
xlabel('P(Risky|Both-High)');
ylabel('P(Risky|Both-Low)');
title({'\fontsize{12} Risk Preferences'});
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
set(gca, 'FontName', 'times');


axes(ax4);
hold on 
axis square 
xlim([0 1]);
ylim([0 1]);
xlabel('Gaussian Dist.');
ylabel('Bimodal Dist.');
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
title({'\fontsize{12} Risk Preference', 'Collapsed Across Conditions'});
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
set(gca, 'FontName', 'times');

%-----------------------------------------------
% STATISTICAL COMPARISONS 
%---------------------------------------------------------

stats_table = array2table(stats_table);
stats_table.Properties.VariableNames = {'binNum', 'subIdx', 'distType', 'blockOrder', 'risky_low', 'risky_high', 'risky_all'};
stats_table.distType = categorical(stats_table.distType);
risk_all_stat = fitglme(stats_table, 'risky_all ~ binNum * distType + (1|subIdx) + (1|subIdx:distType)', 'DummyVarCoding', 'Effects');
an_risk_all = anova(risk_all_stat);
Call = dataset2cell(an_risk_all);

risk_low_stat = fitglme(stats_table, 'risky_low ~ binNum * distType  + (1|subIdx) + (1|subIdx:distType)', 'DummyVarCoding', 'Effects');
an_risk_low = anova(risk_low_stat);
Clow = dataset2cell(an_risk_low);

risk_high_stat = fitglme(stats_table, 'risky_high ~ binNum * distType  + (1|subIdx) + (1|subIdx:distType)', 'DummyVarCoding', 'Effects');
an_risk_high = anova(risk_high_stat);
Chigh = dataset2cell(an_risk_high);


% individual t-tests against chance - checking for risk neutrality 

for blockType = 1:2

    if blockType == 1  % gaussian

        col2plot = [0.7059 0.4745 0.9882];
    else blockType == 2  % bimodal

        col2plot = [0.3961 0.9608 0.3647];
    end

    for ibin = 1:5
        data2run = [];
        stats_table.distType = grp2idx(stats_table.distType);
        data2run = stats_table.risky_low(stats_table.binNum == ibin & stats_table.distType == blockType);
        [hlow{blockType}(ibin),plow{blockType}(ibin),~,statslow{blockType, ibin}] = ttest(data2run, 0.5);

        if hlow{blockType}(ibin) == 1 
            axes(ax2);
            if blockType == 1
                plot(ibin, 0.7, '*', 'color', col2plot, 'MarkerSize', 6);
            else 
                plot(ibin, 0.2, '*', 'color', col2plot, 'MarkerSize', 6);
            end
        end

        data2run = [];
        data2run = stats_table.risky_high(stats_table.binNum == ibin & stats_table.distType == blockType);
        [hhigh{blockType}(ibin),phigh{blockType}(ibin),~,statshigh{blockType, ibin}] = ttest(data2run, 0.5);

         if hhigh{blockType}(ibin) == 1 
            axes(ax1);
            if blockType == 1
                plot(ibin, 0.7, '*', 'color', col2plot, 'MarkerSize', 6);
            else 
                plot(ibin, 0.2, '*', 'color', col2plot, 'MarkerSize', 6);
            end
         end

    end
end

    % correlation between risk preferences between both-low and both-high
for blockType = 1:2

    dataLow = [];
    dataHigh = [];

    dataLow     = lowRisk{blockType};
    dataHigh    = highRisk{blockType};
    [rho(blockType),pval(blockType)]  = corr(dataLow',dataHigh', 'type', 'spearman', 'rows', 'complete');

    corrText = ['r_{s}(' num2str(length(dataLow) - 2) ') = ' num2str(rho(blockType), '%.2f'),...
        ', p = ' num2str(pval(blockType), '%.2f')];

    tdata   = dataHigh - dataLow;
    [~,p(blockType),~,stats{blockType}] = ttest(tdata);
    
    ttext = ['p = ' num2str(p(blockType), '%.2f')];

    if blockType == 1 
        col2plot = [0.7059 0.4745 0.9882];
        axes(ax3);
        hold on
        text(0.05, 0.95, corrText, 'color', col2plot);
        text(0.7, 0.15, ttext, 'color', col2plot);
    else 
        col2plot = [0.3961 0.9608 0.3647];
        axes(ax3);
        hold on
        text(0.05, 0.85, corrText, 'color', col2plot);
        text(0.7, 0.08, ttext, 'color', col2plot);
    end
    
end

[rho_all,pval_all]  = corr(allRisk(1, :)', allRisk(2, :)','type', 'spearman');
corrText = ['r_{s}(' num2str(length(allRisk(1, :)) - 2) ') = ' num2str(rho_all, '%.2f'),...
        ', p = ' num2str(pval_all, '%.2f')];
[~,p_all,~,stats_all] = ttest(allRisk(1, :)', allRisk(2, :)');
ttext = ['t(' num2str(stats_all.df) ') = ' num2str(stats_all.tstat, '%.2f') ', p = ' num2str(p_all, '%.2f')];
axes(ax4);
text(0.05, 0.95, corrText);
text(0.05, 0.85, ttext);

saveFolder = ['riskPreference'];
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])
end
cd([base_path '\' saveFolder]);
anovaWriteTable(Call, 'risk_pref_all');
anovaWriteTable(Clow, 'risk_pref_low');
anovaWriteTable(Chigh, 'risk_pref_high');
figsaveName = ['riskPref_population'];
print(figsaveName, '-dpdf');
print(figsaveName, '-dpng');

end
