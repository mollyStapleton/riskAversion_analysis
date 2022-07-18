function plot_behavData(ptIdx, allData, figSavename)

% plot accuracy P(high average choice| both different cnd)
% 1 = low safe
% 2 = low risky
% 3 = high safe
% 4 = high risky
bin = [1:24:120];
binSize = 24;

figure(1);
f = gcf;
f.Units = 'centimeters';
f.Position = [0.0423 5.6938 40.5342 14.4410];

for blockType = 1:2
    if blockType == 1
        col2plot = 'r'; %gaussian
        x2plot = [1:2];
    elseif blockType == 2
        col2plot = 'b'; %bimodal
        x2plot = [3:4];
    end

    blockIdx = find(allData.distType == blockType);
    tmpBlockData = allData(blockIdx, :);

    % risk preferences across both-high and both-low for all trials
    high_idx_blk    = (tmpBlockData.cnd_idx == 3);
    low_idx_blk     = (tmpBlockData.cnd_idx == 2);

    high_high_blk = find(tmpBlockData.stimulus_choice(high_idx_blk) == 2 ...
        | tmpBlockData.stimulus_choice(high_idx_blk) == 4);

    high_low_blk = find(tmpBlockData.stimulus_choice(low_idx_blk) == 2 ...
        | tmpBlockData.stimulus_choice(low_idx_blk) == 4);

    prop_risk_high_blk   = length(high_high_blk)/sum(high_idx_blk==1);
    prop_risk_low_blk    = length(high_low_blk)/sum(low_idx_blk==1);

    hb = subplot(1, 3, 2) %risk pref. - over trials
    hold on
    bar(x2plot(1), [prop_risk_high_blk], 'FaceColor', col2plot);
    hold on
    bar(x2plot(2), prop_risk_low_blk, 'FaceColor', col2plot, 'FaceAlpha', 0.25);
    title('Risk Choices: All Trials');
    % choice accuracy and risk preferences: trial binned

    for ibin = 1: length(bin)

        tmpBinIdx = find(ismember(tmpBlockData.trialNum, (bin(ibin): (bin(ibin) + binSize -1))));

        % return condition indices of the binned trials
        diffCnd_idx = (tmpBlockData.cnd_idx(tmpBinIdx) == 1);
        high_idx    = (tmpBlockData.cnd_idx(tmpBinIdx) == 3);
        low_idx     = (tmpBlockData.cnd_idx(tmpBinIdx) == 2);


        high_diff = find(tmpBlockData.stimulus_choice(tmpBinIdx(diffCnd_idx)) == 3 ...
            | tmpBlockData.stimulus_choice(tmpBinIdx(diffCnd_idx)) == 4);

        high_high = find(tmpBlockData.stimulus_choice(tmpBinIdx(high_idx)) == 2 ...
            | tmpBlockData.stimulus_choice(tmpBinIdx(high_idx)) == 4);

        high_low = find(tmpBlockData.stimulus_choice(tmpBinIdx(low_idx)) == 2 ...
            | tmpBlockData.stimulus_choice(tmpBinIdx(low_idx)) == 4);

        prop_accuracy(ibin)     = length(high_diff)/sum(diffCnd_idx == 1);
        prop_risk_high(ibin)    = length(high_high)/sum(high_idx==1);
        prop_risk_low(ibin)     = length(high_low)/sum(low_idx==1);

        ht = subplot(1, 3, 1) %choice accuracy - over trials
        plot(ibin, prop_accuracy(ibin), 'o', 'MarkerFaceColor', col2plot, 'MarkerEdgeColor', col2plot, 'linew', 1.2);
        hold on
        xlabel('Trials (Binned)');
        ylabel('P(High|Different)');
        title('Choice Accuracy');

        hh = subplot('Position', [0.7, 0.11, 0.125, 0.81]);
        plot(ibin, prop_risk_high(ibin), 'o', 'MarkerFaceColor', col2plot, 'MarkerEdgeColor', col2plot, 'linew', 1.2);
        hold on
        xlabel('Trials (Binned)');
        ylabel('P(Risky|Both-High)');

        hl = subplot('Position', [0.87 0.11 0.125 0.81]);
        plot(ibin, prop_risk_low(ibin), 'o', 'MarkerFaceColor', col2plot, 'MarkerEdgeColor', col2plot,...
            'linew', 1.2);
        hold on
        alpha(0.25);
        xlabel('Trials (Binned)');
        ylabel('P(Risky|Both-Low)');

    end

    axes(hb);
    set(hb, 'FontName', 'times');
    set(hb, 'XTick', [1 2 3 4]);
    set(hb, 'XTickLabel', {'Both-High', 'Both-Low', 'Both-High', 'Both-Low'});
    set(hb, 'XTickLabelRotation', 45);
    ylim([0 1]);
    axes(ht);
    set(ht, 'FontName', 'times');
    hold on
    plot([1:5], prop_accuracy, col2plot, 'LineWidth', 1.2);
    ylim([0 1]);
    xlim([0 6]);
    axes(hh);
    set(hh, 'FontName', 'times');
    hold on
    plot([1:5], prop_risk_high, col2plot, 'LineWidth', 1.2);
    ylim([0 1]);
    xlim([0 6]);
    title('P(Risky|Both-High): Binned Trials');
    axes(hl)
    set(hl, 'FontName', 'times');
    plot([1:5], prop_risk_low, col2plot, 'LineWidth', 1.2);
    ylim([0 1]);
    xlim([0 6]);
    title('P(Risky|Both-Low): Binned Trials');

end

axes(hb);
lgn = legend({'Gaussian', '', 'Bimodal', ''});
gcf;
print(figSavename, '-dpng');



end
