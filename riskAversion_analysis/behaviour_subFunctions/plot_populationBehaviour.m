function plot_populationBehaviour(base_path, dataIn, figSavename)

savePopulationFolder = ['population_dataAnalysis'];
if exist([base_path savePopulationFolder])
    mkdir([base_path savePopulationFolder])
    cd([base_path savePopulationFolder]);
end
cd([base_path savePopulationFolder]);

bin = [1:24:120];
binSize = 24;

figure(1);
f = gcf;
f.Units = 'centimeters';
f.Position = [0.0423 5.6938 40.5342 14.4410];

hb = subplot(1, 3, 2);
hold on

diff_blk_idx        = find([dataIn.cnd_idx] == 1);
tmpDiffBlk          = dataIn(diff_blk_idx, :);
high_choice_diff    = find(tmpDiffBlk.stimulus_choice == 3 | tmpDiffBlk.stimulus_choice ==4);
prop_diff_high      = size(high_choice_diff, 1)./size(tmpDiffBlk, 1);

tmpAccuracy = [];
stats_table_accuracy = [];

tmpPref = [];
stats_table_pref = [];

stats_table_binnedAccuracy = [];

tmpStats = [];
stats_table_timeBinned_risk = [];

ptIdx = unique(dataIn.pt_number);

for blockType = 1:2

    for isubject = 1: length(ptIdx)

        subIdx = find(dataIn.pt_number == (ptIdx(isubject)));
        subData = dataIn(subIdx, :);

        if blockType == 1
            col2plot = [0.7059 0.4745 0.9882]; %gaussian
            x2plot = [1:2];
        elseif blockType == 2
            col2plot = [0.3961 0.9608 0.3647]; %bimodal
            x2plot = [3:4];
        end

        blockIdx = find(subData.distType == blockType);
        tmpBlockData = subData(blockIdx, :);

        % risk preferences across both-high and both-low for all trials

        high_idx_blk    = (tmpBlockData.cnd_idx == 3);
        low_idx_blk     = (tmpBlockData.cnd_idx == 2);

        % risky choice selection in both-high
        high_high_blk = find(tmpBlockData.stimulus_choice(high_idx_blk) == 4);
        % risky choice selection in both-low
        high_low_blk = find(tmpBlockData.stimulus_choice(low_idx_blk) == 2);

        prop_risk_high_blk{blockType}(isubject)   = length(high_high_blk)/sum(high_idx_blk==1);
        prop_risk_low_blk{blockType}(isubject)    = length(high_low_blk)/sum(low_idx_blk==1);

        prop_risky_all{blockType}(isubject)   = (length(high_high_blk) + length(high_low_blk))./ (sum(high_idx_blk==1) + sum(low_idx_blk==1));

        axes(hb)
        hold on
        plot(prop_risk_high_blk{blockType}(isubject), prop_risk_low_blk{blockType}(isubject), '.', 'color',...
            col2plot, 'MarkerSize', 30);

        diff_riskPref{blockType}(isubject) = prop_risk_high_blk{blockType}(isubject) - prop_risk_low_blk{blockType}(isubject);

        tmpPref = [isubject, blockType, prop_risk_high_blk{blockType}(isubject),...
            prop_risk_low_blk{blockType}(isubject), diff_riskPref{blockType}(isubject)];
        stats_table_pref = [stats_table_pref; tmpPref];

        for ibin = 1: length(bin)

            tmpBinIdx = find(ismember(tmpBlockData.trialNum, (bin(ibin): (bin(ibin) + binSize -1))));

            % return condition indices of the binned trials
            % random condition selection ordering will deliver different number
            % of conditions per bin??
            diffCnd_idx = (tmpBlockData.cnd_idx(tmpBinIdx) == 1);
            high_idx    = (tmpBlockData.cnd_idx(tmpBinIdx) == 3);
            low_idx     = (tmpBlockData.cnd_idx(tmpBinIdx) == 2);

            high_diff = find(tmpBlockData.stimulus_choice(tmpBinIdx(diffCnd_idx)) == 3 ...
                | tmpBlockData.stimulus_choice(tmpBinIdx(diffCnd_idx)) == 4);

            high_high = find(tmpBlockData.stimulus_choice(tmpBinIdx(high_idx)) == 2 ...
                | tmpBlockData.stimulus_choice(tmpBinIdx(high_idx)) == 4);

            high_low = find(tmpBlockData.stimulus_choice(tmpBinIdx(low_idx)) == 2 ...
                | tmpBlockData.stimulus_choice(tmpBinIdx(low_idx)) == 4);

            prop_accuracy{blockType}(isubject, ibin)     = length(high_diff)/sum(diffCnd_idx == 1);
            prop_risk_high{blockType}(isubject, ibin)    = length(high_high)/sum(high_idx==1);
            prop_risk_low{blockType}(isubject, ibin)     = length(high_low)/sum(low_idx==1);



            tmpStats = [isubject, blockType, ibin, prop_risk_high{blockType}(isubject, ibin), prop_risk_low{blockType}(isubject, ibin)];
            stats_table_timeBinned_risk = [stats_table_timeBinned_risk; tmpStats];

            tmpAccuracy = [isubject, blockType, ibin, prop_accuracy{blockType}(isubject, ibin)];
            stats_table_accuracy = [stats_table_accuracy; tmpAccuracy];



        end
    end

    mean_risk_high = mean(prop_risk_high_blk{blockType});
    sem_risk_high  = std(prop_risk_high_blk{blockType})./sqrt(length(prop_risk_high_blk{blockType}));
    mean_risk_low = mean(prop_risk_low_blk{blockType});
    sem_risk_low  = std(prop_risk_low_blk{blockType})./sqrt(length(prop_risk_low_blk{blockType}));

    mean_binned_accuracy{blockType} = nanmean(prop_accuracy{blockType});
    sem_binned_accuracy{blockType}  = nanstd(prop_accuracy{blockType})./sqrt(length(prop_accuracy{blockType}));

    mean_binned_high{blockType}     = nanmean(prop_risk_high{blockType});
    sem_binned_high{blockType}  = nanstd(prop_risk_high{blockType})./sqrt(length(prop_risk_high{blockType}));

    mean_binned_low{blockType}     = nanmean(prop_risk_low{blockType});
    sem_binned_low{blockType}  = nanstd(prop_risk_low{blockType})./sqrt(length(prop_risk_low{blockType}));

    mean_risky_all{blockType} = nanmean(prop_risky_all{blockType}');
    sem_risky_all{blockType}  = nanstd(prop_risky_all{blockType}')./sqrt(length(prop_risky_all{blockType}'));

    ht = subplot(1, 3, 1) %choice accuracy - over trials
    hold on
    errorbar(mean_binned_accuracy{blockType}, sem_binned_accuracy{blockType}, 'color', col2plot, 'linew', 1.5);
    hold on
    xlabel('Trials (Binned)');
    ylabel('P(High|Different)');
    title('Choice Accuracy');


    hh = subplot('Position', [0.7, 0.11, 0.125, 0.81]);
    hold on
    errorbar(mean_binned_high{blockType}, sem_binned_high{blockType}, 'color', col2plot, 'linew', 1.5);
    hold on
    xlabel('Trials (Binned)');
    ylabel('P(Risky|Both-High)');

    hl = subplot('Position', [0.87 0.11 0.125 0.81]);
    hold on
    errorbar(mean_binned_low{blockType}, sem_binned_low{blockType}, 'color', col2plot, 'linew', 1.5);
    hold on
    alpha(0.25);
    xlabel('Trials (Binned)');
    ylabel('P(Risky|Both-Low)');

end


figure(2);
plot(prop_risky_all{1}, prop_risky_all{2}, 'k.', 'MarkerSize', 25);
hold on
xlim([0 1]);
ylim([0 1]);
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
hold on
axis square
plot(x2plot, y2plot, 'k-');
plot([0.5 0.5], [0 1], 'k--');
plot([0 1], [0.5 0.5], 'k--');
xlabel('\bf \fontsize{14} \color{red} Gaussian Distribution');
ylabel('\bf \fontsize{14} \color{blue} Bimodal Distribution');
title({'\fontsize{16} P(Risky) across Both-High and Both-Low Conditions', 'Comparison between Distribution Types'});
set(gca, 'FontName', 'times');
[Hall,Pall,CIall,STATSall] = ttest2(prop_risky_all{1}, prop_risky_all{2});
saveFigname_1 = ['riskPreferences_distComp'];
print(saveFigname_1, '-dpng');

%---------------------------------------------------------------------------------
% ANALYSIS(1): sign. difference in accuracy between gaussian and
% bimodal distribution?
%------------------------------------------------------------------------------------------

table2export_2 = array2table(stats_table_accuracy, 'VariableNames', {'subIdx', 'distType', 'binNumber', 'accuracy'});
table2export_2.distType = categorical(table2export_2.distType);
accuracy_glme = fitglme(table2export_2, 'accuracy ~ distType * binNumber + (1|subIdx)', 'DummyVarCoding', 'Effects');
an_accuracy = anova(accuracy_glme);
C = dataset2cell(an_accuracy);
anovaWriteTable(C, 'accuracy');

%----------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------
% ANALYSIS(2): sign difference in risk preferences between the two
% distributions?
%----------------------------------------------------------------------------------


table2export_3 = array2table(stats_table_pref, 'VariableNames', {'subIdx', 'distType', 'riskyHigh', 'riskyLow', 'riskyDiff'});
[Hpref,Ppref,CIpref,STATSpref] = ttest2([table2export_3.riskyDiff(find(table2export_3.distType ==1))],...
    [table2export_3.riskyDiff(find(table2export_3.distType ==2))]);
[Hg,Pg,CIg,STATSg] = ttest([table2export_3.riskyDiff(find(table2export_3.distType ==1))]);
[Hb,Pb,CIb,STATSb] = ttest([table2export_3.riskyDiff(find(table2export_3.distType ==2))]);

table2export_3.distType = categorical(table2export_3.distType);
pref_dist_risky = fitglme(table2export_3, 'riskyDiff ~ distType + (1|subIdx) + (1|subIdx:distType)', 'DummyVarCoding', 'Effects');
an_risky_dist = anova(pref_dist_risky);
C = dataset2cell(an_risky_dist);
anovaWriteTable(C, 'dist_riskPref');

%----------------------------------------------------------------------------------
%----------------------------------------------------------------------------------
% ANALYSIS(3): risk preferences emerge over time in both-high or
% both-low? difference between the two distributions
%----------------------------------------------------------------------------------

table2export_4 = array2table(stats_table_timeBinned_risk, 'VariableNames', {'subIdx', 'distType', 'binNumber',...
    'risky_high', 'risky_low'});
table2export_4.distType = categorical(table2export_4.distType);

pref_glme_high = fitglme(table2export_4, 'risky_high ~ distType * binNumber + (1|subIdx)', 'DummyVarCoding', 'Effects');
pref_glme_high = anova(pref_glme_high);
C = dataset2cell(pref_glme_high);
anovaWriteTable(C, 'pref_risky_high');

pref_glme_low = fitglme(table2export_4, 'risky_low ~ distType * binNumber + (1|subIdx)', 'DummyVarCoding', 'Effects');
an_low = anova(pref_glme_low);
C = dataset2cell(an_low);
anovaWriteTable(C, 'pref_risky_low');

%------------------------------------------------------------------------
%%% AXES APPEARANCE
%-----------------------------------------------------------------------------

axes(hb);
set(hb, 'FontName', 'times');
axis square
xlim([0 1]);
ylim([0 1]);
xlabel('P(Risky|Both-High)');
ylabel('P(Risky|Both-Low)');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
hold on
plot(x2plot, y2plot, 'k-');
plot([0.5 0.5], [0 1], 'k--');
plot([0 1], [0.5 0.5], 'k--');


axes(ht);
set(ht, 'FontName', 'times');
axis square
hold on
%         plot([1:5], prop_accuracy, col2plot, 'LineWidth', 1.2);
ylim([0 1]);
xlim([0 6]);
axes(hh);
set(hh, 'FontName', 'times');
axis square
hold on
%         plot([1:5], prop_risk_high, col2plot, 'LineWidth', 1.2);
ylim([0 1]);
xlim([0 6]);
hold on
plot([0 6], [0.5 0.5], 'k--');
title('P(Risky|Both-High): Binned Trials');
axes(hl)
axis square
set(hl, 'FontName', 'times');
%         plot([1:5], prop_risk_low, col2plot, 'LineWidth', 1.2);
ylim([0 1]);
xlim([0 6]);
hold on
plot([0 6], [0.5 0.5], 'k--');
title('P(Risky|Both-Low): Binned Trials');



gcf;
set(gcf, 'PaperOrientation', 'landscape');
print(figSavename,'-dpng');
print(figSavename,  '-fillpage', '-dpdf')

end
