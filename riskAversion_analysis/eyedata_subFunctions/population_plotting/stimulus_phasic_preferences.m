subs            = unique(dataIn.subIdx);
binned_all      = [];
binned_R_all    = [];
figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [6.5193 0.0212 10.3082 20.6587])
h1 = subplot(2, 1, 1);
h2 = subplot(2, 1, 2);

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [6.5193 0.0212 10.3082 20.6587])
h3 = subplot(2, 1, 1);
h4 = subplot(2, 1, 2);

for isubject = 1: length(subs)

    subIdx  = find(dataIn.subIdx == subs(isubject));
    tmpSub  = dataIn(subIdx, :);
    binned  = [];
    binnedR = [];
    riskCnd = [];
    riskCnd =  find(tmpSub.cndIdx == 2 | tmpSub.cndIdx == 3);
    tmpSub  = tmpSub(riskCnd, :);

    for itype = 1:2    
        
        tmpData_dist                        = [];
       
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            col2plot_alpha = [0.9255    0.8039    0.9804];
        else
            col2plot = [0.3961 0.9608 0.3647];
            col2plot_alpha = [ 0.7176    0.9882    0.7020];
        end

        tmpDataPref = [];
        allDistIdx  = find(tmpSub.distType == itype);

        dist_baseRiskPref(isubject, itype) =  sum(tmpSub.riskyChoice(allDistIdx) == 1)./length(tmpSub.riskyChoice(allDistIdx));
        
        axes(h4);
        hold on
        plot(itype, dist_baseRiskPref(isubject, itype), '.', 'MarkerSize', 20,...
            'Color', [0.7 0.7 0.7]);


        for icnd = 1:2
            
            riskPrefCnd = [];
            riskPrefCnd = find(tmpSub.cndIdx == cnd2run(icnd));

            baseRiskPref(isubject, icnd) =  sum(tmpSub.riskyChoice(riskPrefCnd) == 1)./length(tmpSub.riskyChoice(riskPrefCnd));

            
            axes(h3);
            if icnd == 1
                hold on 
                plot(1, baseRiskPref(isubject, icnd), '.', 'MarkerSize', 20,...
                        'Color', [0.7 0.7 0.7]);
            else
                hold on 
                plot(2, baseRiskPref(isubject, icnd), '.', 'MarkerSize', 20,...
                        'Color', [0.7 0.7 0.7]);
            end            


            if icnd == 1 
                x2plot = [1 1.5 2];
            else 
                x2plot = [3 3.5 4];
            end
                     
            if isubject == 1

                intercepts(itype, icnd) = 0;
                linear(itype, icnd)     = 0;
                quadratic(itype, icnd)  = 0;

            end

            data2use                                = [];
            dataSplit                               = [];

            distIdx                                 = find([tmpSub.distType] == itype);
            dataSplit                               = tmpSub(distIdx, :);

            cndIdx                                  = dataSplit.cndIdx == cnd2run(icnd);
            data2use                                = dataSplit(cndIdx, :);

         
            tmpData                             = [];
            tmpBin                              = [];
            tmpData                             = data2use(:, [1:9, 14]);

            
            % determine pupil bins 
            % order from smallest to largest 
            B = [];
            I = [];
            [B,I]                               = sort(tmpData.stim_prtileResp_pupil);
            bin2run                             = round(linspace(1, length(B), 4));
           
            binnedPupil_idx                     = [];

            for ibin = 1:3
                % return indices for binned pupil
                binnedPupil_idx{ibin}           = I(bin2run(ibin): bin2run(ibin+1));
                tmpBin                          = [];
                

                if icnd == 1
                    %                     axes(h1);
                    prop_risky_low{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(binnedPupil_idx{ibin})==1)./...
                        length(tmpData.riskyChoice(binnedPupil_idx{ibin}));
                    
                    if  baseRiskPref(isubject, icnd) >= 0.5  % if risk-seeking on average
                        bias_risky_low{isubject, itype}(icnd, ibin) = prop_risky_low{isubject, itype}(icnd, ibin) -0.5;
%                         bias_risky_low{isubject, itype}(icnd, ibin) = prop_risky_low{isubject, itype}(icnd, ibin) -baseRiskPref(isubject, icnd);
                
                    else                                     % if risk-averse on average 
                        bias_risky_low{isubject, itype}(icnd, ibin) = 0.5 - prop_risky_low{isubject, itype}(icnd, ibin) ;
%                         bias_risky_low{isubject, itype}(icnd, ibin) = baseRiskPref(isubject, icnd) - prop_risky_low{isubject, itype}(icnd, ibin) ;
                       
                        
                    end

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_low{isubject, itype}(icnd, ibin) bias_risky_low{isubject, itype}(icnd, ibin) ibin];
                  
                    axes(h1);
                    hold on 
                    plot(x2plot(ibin), prop_risky_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 20,...
                    'Color', col2plot_alpha);

                    axes(h2);
                    hold on 
                    plot(x2plot(ibin), bias_risky_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 20,...
                    'Color', col2plot_alpha);

                else
                    prop_risky_high{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(binnedPupil_idx{ibin})==1)./...
                        length(tmpData.riskyChoice(binnedPupil_idx{ibin}));

                    if  baseRiskPref(isubject, icnd) >= 0.5 % if risk-seeking on average                    
%                         bias_risky_high{isubject, itype}(icnd, ibin) = prop_risky_high{isubject, itype}(icnd, ibin) - baseRiskPref(isubject, icnd);
                        bias_risky_high{isubject, itype}(icnd, ibin) = prop_risky_high{isubject, itype}(icnd, ibin) - 0.5;
                   
                    else % if risk-averse on average 
%                         bias_risky_high{isubject, itype}(icnd, ibin) = baseRiskPref(isubject, icnd) - prop_risky_high{isubject, itype}(icnd, ibin) ;
                        bias_risky_high{isubject, itype}(icnd, ibin) = 0.5 - prop_risky_high{isubject, itype}(icnd, ibin) ;
                      
                   
                    end

                    tmpRT.pupilBin  = tmpBin';

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_high{isubject, itype}(icnd, ibin) bias_risky_high{isubject, itype}(icnd, ibin) ibin];
                  
                    axes(h1);
                    hold on 
                    plot(x2plot(ibin), prop_risky_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 20,...
                    'Color', col2plot_alpha);        

                    axes(h2);
                    hold on 
                    plot(x2plot(ibin), bias_risky_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 20,...
                    'Color', col2plot_alpha);
                  
                end

                binned          = [binned; tmpTable];
                tmpData.pupilBin(binnedPupil_idx{ibin}) = ibin;

            end
               

        % individual fits to proportion of risky choices
        tmpFitData =  [tmpData.trialNum tmpData.riskyChoice tmpData.pupilBin];
        tmpFitData = array2table(tmpFitData);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report{isubject}{itype, icnd}, STATS{isubject}{itype, icnd}, model{isubject}{itype, icnd}]...
            = fitlme_singleVar_sequential(tmpFitData, 0, 0);

        if strcmpi(model{isubject}{itype, icnd}.Name, '(Intercept)')
            intercepts(itype, icnd) = intercepts(itype, icnd)  +1;
        elseif strcmpi(model{isubject}{itype, icnd}.Name, 'x')
            linear(itype, icnd)  = linear(itype, icnd)  +1;
        elseif strcmpi(model{isubject}{itype, icnd}.Name, 'x^2') 
            quadratic(itype, icnd)  = quadratic(itype, icnd)  +1;
        end

        % correlation across risk pref and pupil bins to assess if more or
        % less shifts between risk preferences 
        [rho{isubject}(itype, icnd), pBias{isubject}(itype, icnd)] = corr(tmpData.riskyChoice, tmpData.pupilBin,...
            'Type', 'Spearman');

        end


    end

    binned_all      = [binned_all; binned];
  
end

binned_all = array2table(binned_all);
binned_all.Properties.VariableNames = {'SubIdx', 'CndIdx', 'DistType', 'P_Risky', 'Bias_Risky', 'pupilBin'};

figure(2);
axes(h3);
hold on 
axis square 
xlim([0 3]);
ylim([0 1]);
ylabel('P(Risky)');
xlabel('Risk Preference Condition');
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabel', {'Both-LOW', 'Both-HIGH'});
set(gca, 'XTickLabelRotation', 45);
title({'\fontsize{12} \bf P(Risky)', 'Condition Baseline'});
set(gca, 'FontName', 'Times');
[~, pCnd, ~, StatsCnd] = ttest([binned_all.P_Risky(binned_all.CndIdx == 2)], [binned_all.P_Risky(binned_all.CndIdx == 3)])
hold on 
errorbar(1, nanmean(baseRiskPref(:, 1)), nanstd(baseRiskPref(:, 1)), 'o',...
    'MarkerFaceColor', 'b', 'MarkerSize', 20, 'Color', 'b', 'linew', 1.2);
hold on 
errorbar(2, nanmean(baseRiskPref(:, 2)), nanstd(baseRiskPref(:, 2)), 'o',...
    'MarkerFaceColor', 'r', 'MarkerSize', 20, 'Color', 'r', 'linew', 1.2);
axes(h4);
hold on 
axis square 
xlim([0 3]);
ylim([0 1]);
ylabel('P(Risky)');
xlabel('Reward Distribution Type');
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabel', {'Gaussian', 'Bimodal'});
set(gca, 'XTickLabelRotation', 45);
title({'\fontsize{12} \bf Distribution Type Baseline'});
set(gca, 'FontName', 'Times');
hold on 
errorbar(1, nanmean(dist_baseRiskPref(:, 1)), nanstd(dist_baseRiskPref(:, 1)), 'o',...
    'MarkerFaceColor', [0.7059 0.4745 0.9882], 'MarkerSize', 20, 'Color', [0.7059 0.4745 0.9882], 'linew', 1.2);
hold on 
errorbar(2, nanmean(dist_baseRiskPref(:, 2)), nanstd(dist_baseRiskPref(:, 2)), 'o',...
    'MarkerFaceColor', [0.3961 0.9608 0.3647], 'MarkerSize', 20, 'Color', [0.3961 0.9608 0.3647], 'linew', 1.2);
[~, pDist, ~, StatsDist] = ttest([binned_all.P_Risky(binned_all.DistType == 1)], [binned_all.P_Risky(binned_all.DistType == 2)])


saveFolder = ['stimulus_phasicPupilBins']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);
saveFigname = ['baseline_riskPref_individiualBaselines'];
print(saveFigname, '-dpng');

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            starPoint = [0.9 0.4];
        else
            col2plot = [0.3961 0.9608 0.3647];
            starPoint = [0.1 -0.4];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1 1.5 2];
            else
                x2plot = [3 3.5 4];
        end
     
        for ibin = 1:3

            mean_binned_pref{itype}(icnd, ibin) = mean(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            
            [~,P_binned{itype}(icnd, ibin),~,STATS_binned{itype}(icnd, ibin)] = ttest([binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) &...
                binned_all.pupilBin == ibin & binned_all.DistType == itype)], 0.5);
            
            if P_binned{itype}(icnd, ibin) <= 0.05
                axes(h1);
                hold on 
                plot(x2plot(ibin), starPoint(1), '*', 'MarkerSize', 15, 'Color', col2plot,...
                    'linew', 1.2);
            end

            sem_binned_pref{itype}(icnd, ibin)  = std(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));

            mean_diff{itype}(icnd, ibin) = mean(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            sem_diff{itype}(icnd, ibin)  = std(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));
            

            [~,P_binnedBias{itype}(icnd, ibin),~,STATS_binnedBias{itype}(icnd, ibin)] = ttest([binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) &...
                binned_all.pupilBin == ibin & binned_all.DistType == itype)], 0);
            
             if P_binnedBias{itype}(icnd, ibin) <= 0.05
                axes(h2);
                hold on 
                plot(x2plot(ibin), starPoint(2), '*', 'MarkerSize', 15, 'Color', col2plot,...
                    'linew', 1.2);
            end

            axes(h1);
            hold on
            errorbar(x2plot(ibin), mean_binned_pref{itype}(icnd, ibin),  sem_binned_pref{itype}(icnd, ibin), '.', 'MarkerSize', 40, 'color', col2plot, 'linew', 1.2);
            axes(h2);
            hold on 
            errorbar(x2plot(ibin), mean_diff{itype}(icnd, ibin),  sem_diff{itype}(icnd, ibin), '.', 'MarkerSize', 40, 'color', col2plot, 'linew', 1.2);
            
        end

        % perform linear vs quadratic fit comparisons
        tmpFitData = [];
        tmpFitData = binned_all((binned_all.CndIdx == cnd2run(icnd) & binned_all.DistType == itype), [1, 4, 6]);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report{itype, icnd}, STATS{itype, icnd}, model{itype, icnd}]...
            = fitlme_singleVar_sequential_grouping(tmpFitData, 0, 0);

        if strcmpi(model{itype, icnd}.Name, 'x^2') | strcmpi(model{itype, icnd}.Name, 'x')

            axes(h1);
            if icnd == 1 
                xplot = [1 1.5 2];
            else 
                xplot = [3 3.5 4];
            end


            hold on 
            axes(h1);
            plot(xplot, STATS{itype, icnd}.meanFit, '-', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS{itype, icnd}.CIFitLow, '--', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS{itype, icnd}.CIFitHigh, '--', 'color', col2plot, 'linew', 1.2);

        end

         % perform linear vs quadratic fit comparisons
        tmpFitData = [];
        tmpFitData = binned_all((binned_all.CndIdx == cnd2run(icnd) & binned_all.DistType == itype), [1, 5, 6]);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report_bias{itype, icnd}, STATS_bias{itype, icnd}, model_bias{itype, icnd}]...
        = fitlme_singleVar_sequential_grouping(tmpFitData, 0, 0);

        if strcmpi(model_bias{itype, icnd}.Name, 'x^2') | strcmpi(model_bias{itype, icnd}.Name, 'x')

            axes(h2);
            if icnd == 1 
                xplot = [1 2 3];
            else 
                xplot = [2.5 3.5 4.5];
            end

            hold on 
            axes(h2);
            plot(xplot, STATS_bias{itype, icnd}.meanFit, '-', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_bias{itype, icnd}.CIFitLow, '--', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_bias{itype, icnd}.CIFitHigh, '--', 'color', col2plot, 'linew', 1.2);

        end

    end

end 

axes(h1);
axis square
xlim([0 5]);
% xlim([0 4]);
ylim([0 1]);
% set(gca, 'XTick', [1 1.5 2.5 3])
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
% set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'High-1', 'High-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
hold on 
% plot([2 2], [0 4], 'k-');
plot([2.5 2.5], [0 1], 'k-');
plot([0 5], [0.5 0.5], 'k--');
title('Risk Preference');
set(gca, 'FontName', 'times');
axes(h2);
axis square
xlim([0 5]);
% xlim([0 4]);
ylim([- 0.5 0.5]);
% set(gca, 'XTick', [1 1.5 2.5 3])
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
% set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'High-1', 'High-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Bias P(Risky)');
hold on 
% plot([2 2], [-0.5 0.5], 'k-');
plot([2.5 2.5], [-0.5 0.5], 'k-');
plot([0 5], [0 0], 'k--');
title('Bias Shift P(Risky)');
set(gca, 'FontName', 'times');

saveFigname = ['preference_bias_NEW'];
print(saveFigname, '-dpng');

%---------- STATISTICS ----------------

% SIGNIFICANT DIFFERENCE BETWEEN PUPIL BIN X DIST TYPE 
binnedLOW = binned_all((binned_all.CndIdx == 2), :);
binnedHIGH = binned_all((binned_all.CndIdx == 3), :);

pref_low = fitglme(binnedLOW, 'P_Risky ~ DistType * pupilBin + (1|SubIdx)');
pref_high = fitglme(binnedHIGH, 'P_Risky ~ DistType * pupilBin + (1|SubIdx)');
an_1 = anova(pref_low);
an_2 = anova(pref_high);
C = dataset2cell(an_1);
anovaWriteTable(C, 'riskPref_low');
C1 = dataset2cell(an_2);
anovaWriteTable(C1, 'riskPref_high');

bias_low = fitglme(binnedLOW, 'Bias_Risky ~ DistType * pupilBin + (1|SubIdx)');
bias_high = fitglme(binnedHIGH, 'Bias_Risky ~ DistType * pupilBin + (1|SubIdx)');
an_1 = anova(bias_low);
an_2 = anova(bias_high);
C = dataset2cell(an_1);
anovaWriteTable(C, 'riskBias_low');
C1 = dataset2cell(an_2);
anovaWriteTable(C1, 'riskBias_high');
