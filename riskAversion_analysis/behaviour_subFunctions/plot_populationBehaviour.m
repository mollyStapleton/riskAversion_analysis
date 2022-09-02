function plot_populationBehaviour(base_path, ptIdx, figSavename)

   
    popFilename = ['populationBehav.mat'];
    cd([base_path]);
    load(popFilename);
    allData = concatData;

    bin = [1:24:120];
    binSize = 24;
   
    figure(1);
    f = gcf;
    f.Units = 'centimeters';
    f.Position = [0.0423 5.6938 40.5342 14.4410];
       
    for blockType = 1:2

        for isubject = 1: length(ptIdx)
            
            subIdx = find(allData.pt_number == str2num(ptIdx{isubject}));
            subData = allData(subIdx, :);
            
                if blockType == 1
                    col2plot = 'r'; %gaussian
                    x2plot = [1:2];
                elseif blockType == 2
                    col2plot = 'b'; %bimodal
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
        
                prop_risk_high_blk(isubject)   = length(high_high_blk)/sum(high_idx_blk==1);
                prop_risk_low_blk(isubject)    = length(high_low_blk)/sum(low_idx_blk==1);
    

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
        
                prop_accuracy(isubject, ibin)     = length(high_diff)/sum(diffCnd_idx == 1);
                prop_risk_high(isubject, ibin)    = length(high_high)/sum(high_idx==1);
                prop_risk_low(isubject, ibin)     = length(high_low)/sum(low_idx==1);
        
               
            end
        end

        mean_risk_high = mean(prop_risk_high_blk);
        sem_risk_high  = std(prop_risk_high_blk)./sqrt(length(prop_risk_high_blk));
        mean_risk_low = mean(prop_risk_low_blk);
        sem_risk_low  = std(prop_risk_low_blk)./sqrt(length(prop_risk_low_blk));
        
        hb = subplot(1, 3, 2);
        hold on 
        [hBar_one, hError_one] = barwitherr(sem_risk_high, mean_risk_high,'FaceColor', col2plot);
        hBar_one.XData = x2plot(1);
        hError_one.XData = x2plot(1);
        hError_one.LineWidth      = 1;
        hold on 
        [hBar_two, hError_two] = barwitherr(sem_risk_low, mean_risk_low,'FaceColor', col2plot, 'FaceAlpha', 0.25);
        hBar_two.XData = x2plot(2);
        hError_two.XData = x2plot(2);
        hError_two.LineWidth      = 1;

        mean_binned_accuracy{ibin} = mean(prop_accuracy);
        sem_binned_accuracy{ibin}  = std(prop_accuracy)./sqrt(length(prop_accuracy));

        mean_binned_high{ibin}     = mean(prop_risk_high);
        sem_binned_high{ibin}  = std(prop_risk_high)./sqrt(length(prop_risk_high));

        mean_binned_low{ibin}     = mean(prop_risk_low);
        sem_binned_low{ibin}  = std(prop_risk_low)./sqrt(length(prop_risk_low));

        ht = subplot(1, 3, 1) %choice accuracy - over trials
        errorbar(mean_binned_accuracy{ibin}, sem_binned_accuracy{ibin}, 'color', col2plot, 'linew', 1.5);
        hold on
        xlabel('Trials (Binned)');
        ylabel('P(High|Different)');
        title('Choice Accuracy');

        hh = subplot('Position', [0.7, 0.11, 0.125, 0.81]);
        errorbar(mean_binned_high{ibin}, sem_binned_high{ibin}, 'color', col2plot, 'linew', 1.5);
        hold on
        xlabel('Trials (Binned)');
        ylabel('P(Risky|Both-High)');

        hl = subplot('Position', [0.87 0.11 0.125 0.81]);
        errorbar(mean_binned_low{ibin}, sem_binned_low{ibin}, 'color', col2plot, 'linew', 1.5);
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
%         plot([1:5], prop_accuracy, col2plot, 'LineWidth', 1.2);
        ylim([0 1]);
        xlim([0 6]);
        axes(hh);
        set(hh, 'FontName', 'times');
        hold on
%         plot([1:5], prop_risk_high, col2plot, 'LineWidth', 1.2);
        ylim([0 1]);
        xlim([0 6]);
        title('P(Risky|Both-High): Binned Trials');
        axes(hl)
        set(hl, 'FontName', 'times');
%         plot([1:5], prop_risk_low, col2plot, 'LineWidth', 1.2);
        ylim([0 1]);
        xlim([0 6]);
        title('P(Risky|Both-Low): Binned Trials');




    axes(hb);
    set(hb, 'FontName', 'times');
    set(hb, 'XTick', [1 2 3 4]);
    set(hb, 'XTickLabel', {'Both-High', 'Both-Low', 'Both-High', 'Both-Low'});
    set(hb, 'XTickLabelRotation', 45);
    ylim([0 1]);
    axes(hb);
    lgn = legend({'Gaussian', '', '', '', 'Bimodal'});
    gcf;
    print(figSavename, '-dpng');

end
