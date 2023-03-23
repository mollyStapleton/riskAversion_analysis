function riskAversion_accuracyStats(base_path, dataIn)

bin = [1:24:120];
binSize = 24;
subs = unique(dataIn.pt_number);

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [28.0035 0.0212 10.7315 20.6587]);
ax1 = subplot(2, 1, 1);
ax2 = subplot(2, 1, 2);

stats_table = [];

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
        
        diffIdx     = find([tmpSub.cnd_idx] == 1);

        % return idx for block specific both-different conditions
        avgAcc{blockType}(isubject) = sum(tmpSub.choice_high(diffIdx)==1)./length(diffIdx);

        for ibin = 1: length(bin)
            tmpBinIdx = [];
            tmpBinIdx = find(ismember(tmpSub.trialNum(diffIdx),  (bin(ibin): (bin(ibin) + binSize -1))));
            acc_binned{blockType}(isubject, ibin) = sum(tmpSub.choice_high(diffIdx(tmpBinIdx)) == 1)./length(diffIdx(tmpBinIdx));

            tmpTable(ibin, :) = [ibin, subs(isubject), blockType, acc_binned{blockType}(isubject, ibin)];
        
        end

        stats_table = [stats_table; tmpTable];

    end
        mean_acc{blockType} = mean(acc_binned{blockType});
        sem_acc{blockType}  = std(acc_binned{blockType})./sqrt(length(acc_binned{blockType}));
        axes(ax1);
        hold on
        errorbar(mean_acc{blockType}, sem_acc{blockType}, 'color', col2plot, 'linew', 1.5);

        mean_bar(blockType) = mean(avgAcc{blockType});
        sem_bar(blockType)  = std(avgAcc{blockType})./sqrt(length(avgAcc{blockType}));
        axes(ax2);
        hold on
        [hb(blockType), hberr(blockType)] = barwitherr(sem_bar(blockType), mean_bar(blockType));
        hb(blockType).FaceColor = col2plot;
        hb(blockType).EdgeColor = col2plot;
        hb(blockType).XData = blockType;
        hberr(blockType).XData = blockType;
        hberr(blockType).LineWidth = 1.2;
end

axes(ax1);
hold on
axis square
xlabel('Trials (Binned)');
ylabel('P(High|Both-Different)');
xlim([0 6]);
ylim([0 1]);
plot([0 6], [0.5 0.5], 'k--');
set(gca, 'FontName', 'times');

axes(ax2);
hold on
axis square
ylim([0 1]);
set(gca, 'XTick',  [1 2]);
set(gca, 'XTickLabel', {'Gaussian', 'Bimodal'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Average Choice Accuracy');
set(gca, 'FontName', 'times');
sgtitle('\fontsize{14} \bfChoice Accuracy', 'FontName', 'times');
 
% perform statistics 
stats_table = array2table(stats_table);
stats_table.Properties.VariableNames = {'binNum', 'subIdx', 'distType', 'binnedAcc'};

[H,P,CI,STATS] = ttest(stats_table.binnedAcc(stats_table.distType == 1 ),...
    stats_table.binnedAcc(stats_table.distType == 2 ));


stats_table.distType = categorical(stats_table.distType);
pref_dist_acc = fitglme(stats_table, 'binnedAcc ~ binNum * distType + (1|subIdx)', 'DummyVarCoding', 'Effects');
an_acc_dist = anova(pref_dist_acc);
C = dataset2cell(an_acc_dist);

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
        data2run = stats_table.binnedAcc(stats_table.binNum == ibin & stats_table.distType == blockType);
        [h{blockType}(ibin),p{blockType}(ibin),~,stats{blockType, ibin}] = ttest(data2run, 0.5);

        if h{blockType}(ibin) == 1 
            axes(ax1);
            if blockType == 1
                plot(ibin, 0.85, '*', 'color', col2plot, 'MarkerSize', 6);
            else 
                plot(ibin, 0.45, '*', 'color', col2plot, 'MarkerSize', 6);
            end
        end

    end
end



saveFolder = ['accuracy'];
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);
anovaWriteTable(C, 'dist_accuracy');

figsaveName = ['accuracy_population'];
set(gcf, 'paperOrientation', 'landscape');
print(figsaveName, '-dpdf');
print(figsaveName, '-dpng');


end