
subs        = unique(dataIn.subIdx);
binned      = [];
binned_cnd  = [];
binned_type = [];
binned_all  = [];
tmpTable_RT = [];
rt_all      = [];
binned_R_all     = [];
binned_acc_all   = [];
figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h1 = subplot(1, 3, 1);
h2 = subplot(1, 3, 2);
h3 = subplot(1, 3, 3)

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h4 = subplot(1, 2, 1);
h5 = subplot(1, 2, 2);

nFits.intercepts = cell(2, 2);
nFits.linear     = cell(2, 2);
nFits.quadratic  = cell(2, 2);

figure(3);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h7 = subplot(1, 2, 1);
h8 = subplot(1, 2, 2);

figure(4);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h9 = subplot(1, 2, 1);
h10 = subplot(1, 2, 2);

% analysis on an individual subject basis
for isubject = 1: length(subs)

    subIdx = find(dataIn.subIdx == subs(isubject));
    tmpSub = dataIn(subIdx, :);
    binned = [];
    binnedR = [];
    riskCnd = [];
    riskCnd =  find(tmpSub.cndIdx == 2 & 3);
    baseRiskPref(isubject) =  sum(tmpSub.riskyChoice(riskCnd) == 1)./length(tmpSub.riskyChoice(riskCnd));

    for itype = 1:2

      
        tmpData_dist                        = [];
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            col2plot_alpha = [0.9255    0.8039    0.9804];
        else
            col2plot = [0.3961 0.9608 0.3647];
            col2plot_alpha = [ 0.7176    0.9882    0.7020];
        end

        for icnd = 1:2

            if isubject == 1

                nFits.intercepts{itype, icnd} = 0;
                nFits.linear{itype, icnd}     = 0;
                nFits.quadratic{itype, icnd}  = 0;

            end
            data2use                            = [];
            dataSplit                           = [];

            if icnd == 1 
                x2plot = [1 1.5 2];
            else 
                x2plot = [3 3.5 4];
            end


            distIdx                             = find([tmpSub.distType] == itype);
            dataSplit                           = tmpSub(distIdx, :);

            cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
            data2use                            = dataSplit(cndIdx, :);


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

                    
                    if prop_risky_low{isubject, itype}(icnd, ibin) >= 0.5 % if risk-seeking on average
                        bias_risky_low{isubject, itype}(icnd, ibin) = prop_risky_low{isubject, itype}(icnd, ibin) -0.5;
%                         baselineChange_low{isubject, itype}(icnd, ibin) = baseRiskPref(isubject) - prop_risky_low{isubject, itype}(icnd, ibin);
                    
                    else % if risk-averse on average 
                        bias_risky_low{isubject, itype}(icnd, ibin) = 0.5 - prop_risky_low{isubject, itype}(icnd, ibin) ;
                    end

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_low{isubject, itype}(icnd, ibin) bias_risky_low{isubject, itype}(icnd, ibin) ibin];
                  
                    axes(h4);
                    hold on 
                    plot(x2plot(ibin), prop_risky_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
                    'Color', col2plot_alpha);

                    axes(h7);
                    hold on 
                    plot(x2plot(ibin), bias_risky_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
                    'Color', col2plot_alpha);

%                     if baseRiskPref >= 0.5
%                         axes(h9);
%                         hold on 
%                         plot(x2plot(ibin), baselineChange_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
%                         'Color', col2plot_alpha);   
% 
%                     else
%                         axes(h10);
%                         hold on 
%                         plot(x2plot(ibin), baselineChange_low{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
%                         'Color', col2plot_alpha);
%                     end

                else
                    prop_risky_high{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(binnedPupil_idx{ibin})==1)./...
                        length(tmpData.riskyChoice(binnedPupil_idx{ibin}));

%                     baselineChange_high{isubject, itype}(icnd, ibin) = baseRiskPref(isubject) - prop_risky_high{isubject, itype}(icnd, ibin);

                    if prop_risky_high{isubject, itype}(icnd, ibin) >= 0.5 % if risk-seeking on average
                        bias_risky_high{isubject, itype}(icnd, ibin) = prop_risky_high{isubject, itype}(icnd, ibin) -0.5;
                    else % if risk-averse on average 
                        bias_risky_high{isubject, itype}(icnd, ibin) = 0.5 - prop_risky_high{isubject, itype}(icnd, ibin) ;
                    end

                    tmpRT.pupilBin  = tmpBin';

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_high{isubject, itype}(icnd, ibin) bias_risky_high{isubject, itype}(icnd, ibin) ibin];
                  
                    axes(h4);
                    hold on 
                    plot(x2plot(ibin), prop_risky_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
                    'Color', col2plot_alpha);        

                    axes(h7);
                    hold on 
                    plot(x2plot(ibin), bias_risky_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
                    'Color', col2plot_alpha);

%                      if baseRiskPref >= 0.5
%                         axes(h9);
%                         hold on 
%                         plot(x2plot(ibin), baselineChange_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
%                         'Color', col2plot_alpha);   
% 
%                     else
%                         axes(h10);
%                         hold on 
%                         plot(x2plot(ibin), baselineChange_high{isubject, itype}(icnd, ibin), '.', 'MarkerSize', 30,...
%                         'Color', col2plot_alpha);
%                     end 
                  
                end

                binned          = [binned; tmpTable];
                tmpData.pupilBin(binnedPupil_idx{ibin}) = ibin;

            end
               
            % subject independant correlation between pupil bin and risky
            % choices

            [r{isubject}(icnd, itype), p{isubject}(icnd, itype)] = corr(tmpData.pupilBin,...
                                                                    tmpData.riskyChoice, 'type', 'spearman');

            
            if p{isubject}(icnd, itype) <= 0.05
                
                faceCol = col2plot;
            else 

                faceCol = [1 1 1];
            end

            if icnd == 1 
                axes(h1);
                hold on 
                plot(isubject, r{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);

                tmpR = [];
                tmpR = [subs(isubject) cnd2run(icnd) itype r{isubject}(icnd, itype) p{isubject}(icnd, itype)];

            else  
                axes(h2);
                hold on 
                plot(isubject, r{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);

                tmpR = [];
                tmpR = [subs(isubject) cnd2run(icnd) itype r{isubject}(icnd, itype) p{isubject}(icnd, itype)];


            end
            
            binnedR          = [binnedR; tmpR];


        % individual fits to proportion of risky choices
        tmpFitData =  [tmpData.trialNum tmpData.riskyChoice tmpData.pupilBin];
        tmpFitData = array2table(tmpFitData);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report{isubject}{itype, icnd}, STATS{isubject}{itype, icnd}, model{isubject}{itype, icnd}]...
            = fitlme_singleVar_sequential(tmpFitData, 0, 0);

        if strcmpi(model{isubject}{itype, icnd}.Name, '(Intercept)')
            nFits.intercepts{itype, icnd} = nFits.intercepts{itype, icnd}  +1;
        elseif strcmpi(model{isubject}{itype, icnd}.Name, 'x')
            nFits.linear{itype, icnd}  = nFits.linear{itype, icnd}  +1;
        elseif strcmpi(model{isubject}{itype, icnd}.Name, 'x^2') 
            nFits.quadratic{itype, icnd}  = nFits.quadratic{itype, icnd}  +1;
        end

        if strcmpi(model{isubject}{itype, icnd}.Name, 'x^2') | strcmpi(model{isubject}{itype, icnd}.Name, 'x')

            axes(h4);
            if icnd == 1 
                xplot = [1 1.5 2];
            else 
                xplot = [3 3.5 4];
            end


            hold on 
            axes(h4);
            plot(xplot, STATS{isubject}{itype, icnd}.meanFit, '-', 'color', col2plot_alpha, 'linew', 1);

            end
        end
    end

    binned_R_all    = [binned_R_all; binnedR];
    binned_all      = [binned_all; binned];
  
end

axes(h9);
axis square
xlim([0 5]);
ylim([-0.6 0.6]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
ylabel({'\fontsize{12}Change from Baseline', 'Risk Preference'});
hold on 
plot([2.5 2.5], [-0.6 0.6], 'k-');
plot([0 5], [0 0], 'k--');
title({'Baseline', 'Risk-Seeking'});
set(gca, 'FontName', 'times');
axes(h10);
axis square
xlim([0 5]);
ylim([-0.6 0.6]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
ylabel({'Change from Baseline', 'Risk Preference'});
hold on 
plot([2.5 2.5], [-0.6 0.6], 'k-');
plot([0 5], [0 0], 'k--');
title({'\fontsize{12}Baseline', 'Risk-Averse'});
set(gca, 'FontName', 'times');

binned_all = array2table(binned_all);
binned_all.Properties.VariableNames = {'SubIdx', 'CndIdx', 'DistType', 'P_Risky', 'Bias_Risky', 'pupilBin'};

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1 1.5 2];
            else
                x2plot = [3 3.5 4];
        end

        
        for ibin = 1:3

            mean_binned_pref{itype}(icnd, ibin) = mean(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            sem_binned_pref{itype}(icnd, ibin)  = std(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));

            mean_diff{itype}(icnd, ibin) = mean(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            sem_diff{itype}(icnd, ibin)  = std(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));
            
            axes(h5);
            hold on
            errorbar(x2plot(ibin), mean_binned_pref{itype}(icnd, ibin),  sem_binned_pref{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            axes(h8);
            hold on 
            errorbar(x2plot(ibin), mean_diff{itype}(icnd, ibin),  sem_diff{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            
        end

        % perform linear vs quadratic fit comparisons
        tmpFitData = [];
        tmpFitData = binned_all((binned_all.CndIdx == cnd2run(icnd) & binned_all.DistType == itype), [1, 4, 6]);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report{itype, icnd}, STATS{itype, icnd}, model{itype, icnd}]...
            = fitlme_singleVar_sequential_grouping(tmpFitData, 0, 0);

        if strcmpi(model{itype, icnd}.Name, 'x^2') | strcmpi(model{itype, icnd}.Name, 'x')

            axes(h5);
            if icnd == 1 
                xplot = [1 2 3];
            else 
                xplot = [2.5 3.5 4.5];
            end


            hold on 
            axes(h5);
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

            axes(h8);
            if icnd == 1 
                xplot = [1 2 3];
            else 
                xplot = [2.5 3.5 4.5];
            end


            hold on 
            axes(h8);
            plot(xplot, STATS_bias{itype, icnd}.meanFit, '-', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_bias{itype, icnd}.CIFitLow, '--', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_bias{itype, icnd}.CIFitHigh, '--', 'color', col2plot, 'linew', 1.2);

        end

    end

end 


axes(h4);
axis square
xlim([0 5]);
ylim([0 1]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
hold on 
plot([2.5 2.5], [0 1], 'k-');
plot([0 5], [0.5 0.5], 'k--');
title('Risk Preference');
set(gca, 'FontName', 'times');

axes(h5);
axis square
xlim([0 5]);
ylim([0 1]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
hold on 
ylabel('P(Risky)');
plot([2.5 2.5], [0 1], 'k-');
plot([0 5], [0.5 0.5], 'k--');
title('Risk Preference');
set(gca, 'FontName', 'times');

axes(h7);
axis square
xlim([0 5]);
ylim([0 0.6]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
hold on 
plot([2.5 2.5], [0 0.6], 'k-');
% plot([0 5], [0.5 0.5], 'k--');
title('Risk Bias Shift');
set(gca, 'FontName', 'times');

axes(h8);
axis square
xlim([0 5]);
ylim([0.10 0.28]);
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'Low-1', 'Low-2', 'Low-3', 'High-1', 'High-2', 'High-3'});
set(gca, 'XTickLabelRotation', 45);
hold on 
ylabel('P(Risky)');
plot([2.5 2.5], [0.10 0.80], 'k-');
% plot([0 5], [0.5 0.5], 'k--');
title('Risk Bias Shift');
set(gca, 'FontName', 'times');



axes(h1);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Both-LOW');
set(gca, 'FontName', 'times');

axes(h2);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Both-HIGH');
set(gca, 'FontName', 'times');

% average correlation coefficients across subjects 
binned_R_all = array2table(binned_R_all);
binned_R_all.Properties.VariableNames = {'SubIdx', 'CndIdx', 'DistType', 'R', 'P'};

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1];
            else
                x2plot = [2];
        end

        

            mean_binned(itype, icnd) = nanmean(binned_R_all.R(binned_R_all.CndIdx == cnd2run(icnd) & binned_R_all.DistType == itype));
            sem_binned(itype, icnd)  = nanstd(binned_R_all.R(binned_R_all.CndIdx == cnd2run(icnd) & binned_R_all.DistType == itype))./...
                                                sqrt(length(binned_R_all.R(binned_R_all.CndIdx == cnd2run(icnd) & binned_R_all.DistType == itype)));

  
            axes(h3);
            hold on
            errorbar(x2plot, mean_binned(itype, icnd),  sem_binned(itype, icnd),...
                '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
       
    
    end
    
end 

axes(h3);
axis square
xlim([0 3]);
ylim([-0.1 0.1]);
hold on 
plot([0 3], [0 0], 'k--');
plot([1.5 1.5], [-0.1 0.1], 'k-');
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabels', {'Both-LOW', 'BOTH-HIGH'});
ylabel('\bfAverage r_{s}');
title('Average r_{s}_ (pupilBin ~ RiskyChoice)')
set(gca, 'FontName', 'times');

% ttest within condition to test for difference in correlations between
% distribution types 

lowR = binned_R_all((binned_R_all.CndIdx == 2), :);
highR = binned_R_all((binned_R_all.CndIdx == 3), :);

[~, pLow, ~, statsLow] = ttest(lowR.R(lowR.DistType ==1), lowR.R(lowR.DistType ==2));
[~, phigh, ~, statsHigh] = ttest(highR.R(highR.DistType ==1), highR.R(highR.DistType ==2));

saveFolder = ['stimulus_phasicPupilBins']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

saveFigname = ['correlations_preferences'];
print(saveFigname, '-dpng');


lowData = binned_all((binned_all.CndIdx == 2), :);
highData = binned_all((binned_all.CndIdx == 3), :);

pref_low = fitglme(lowData, 'P_Risky ~ DistType*pupilBin + (1|SubIdx) + (1| SubIdx:DistType)');
pref_high = fitglme(highData, 'P_Risky ~ DistType*pupilBin + (1|SubIdx)');
an_1 = anova(pref_low);
an_2 = anova(pref_high);
C = dataset2cell(an_1);
anovaWriteTable(C, 'riskPref_low');
C1 = dataset2cell(an_2);
anovaWriteTable(C1, 'riskPref_high');

pupilVector = [1 1 2 2 3 3];
distVector  = [1 2 1 2 1 2];
post_hoc_vec = [];

for opj=1:length(pupilVector)  

    Lv1=highData.Bias_Risky(highData.pupilBin==pupilVector(opj) & highData.DistType==distVector(opj));
    for pqr=opj+1:length(pupilVector)
        Lv2=highData.Bias_Risky(highData.pupilBin==pupilVector(pqr) & highData.DistType==distVector(pqr));
        [hy,pt,~,stats]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison
        post_hoc_table_bias{opj,pqr-1}=pt;
        post_hoc_vec=[post_hoc_vec pt];
    end
end

[pID,pN] = FDR(post_hoc_vec,0.05);

[h, crit_p, ~, adj_p]=fdr_bh(post_hoc_vec,0.05);

%%%%% now move adjusted p-values back into the table
p_count=1;
for opj=1:length(pupilVector)-1 %%%% number of clusters
    for pqr=opj+1:length(pupilVector)
        post_hoc_table_bias{opj,pqr-1}=adj_p(p_count);
        p_count=p_count+1;
    end
end

bias_low = fitglme(lowData, 'Bias_Risky ~ DistType*pupilBin + (1|SubIdx) + (1| SubIdx:DistType)');
bias_high = fitglme(highData, 'Bias_Risky ~ DistType*pupilBin + (1|SubIdx) + (1| SubIdx:DistType)');
an_3 = anova(bias_low);
an_4 = anova(bias_high);
C2 = dataset2cell(an_3);
anovaWriteTable(C2, 'riskbias_low');
C3 = dataset2cell(an_4);
anovaWriteTable(C3, 'riskbias_high');




saveFigname = ['pupilBinned3_riskAttitudes'];
print(saveFigname, '-dpng');


figure(3);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h6 = subplot(1, 3, 1);
h7 = subplot(1, 3, 2);
h8 = subplot(1, 3, 3)

binned_acc_r = [];
% plot accuracy rates as a function of pupil bin
cnd2run = 1;
for isubject = 1: length(subs)

    subIdx = find(dataIn.subIdx == subs(isubject));
    tmpSub = dataIn(subIdx, :);
    binned_acc = [];
    binnedRacc = [];

    for itype = 1:2
        tmpData_dist                        = [];
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end

        for icnd = 1:1
            
            data2use                            = [];
            dataSplit                           = [];

            distIdx                             = find([tmpSub.distType] == itype);
            dataSplit                           = tmpSub(distIdx, :);

            cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
            data2use                            = dataSplit(cndIdx, :);


            tmpData                             = [];
            tmpBin                              = [];
            tmpData                             = data2use(:, [1:7, 9, 14]);

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
%                 tmpBin(1: binSize)              = ibin;

             
                    %                     axes(h1);
                    prop_acc{isubject, itype}(icnd, ibin) = sum(tmpData.accChoice(binnedPupil_idx{ibin})==1)./...
                        length(tmpData.accChoice(binnedPupil_idx{ibin}));

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_acc{isubject, itype}(icnd, ibin) ibin];
                    binned_acc          = [binned_acc; tmpTable];

                    tmpData.pupilBin(binnedPupil_idx{ibin}) = ibin;

            end

            [r_acc{isubject}(icnd, itype), p_acc{isubject}(icnd, itype)] = corr(tmpData.pupilBin,...
                tmpData.accChoice, 'type', 'spearman');

            if p_acc{isubject}(icnd, itype) <= 0.05

                faceCol = col2plot;
            else

                faceCol = [1 1 1];
            end

            if itype == 1 
                axes(h7)
                hold on 
                plot(isubject, r_acc{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);
            else 
                axes(h8)
                hold on 
                plot(isubject, r_acc{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);
            end
            
            tmpR = [];
            tmpR = [subs(isubject) cnd2run(icnd) itype r_acc{isubject}(icnd, itype) p_acc{isubject}(icnd, itype)];

        end

             binnedRacc          = [binnedRacc; tmpR];
    end 

    
  
    binned_acc_all = [binned_acc_all; binned_acc];
    binned_acc_r   = [binned_acc_r; binnedRacc];
end

binned_acc_all = array2table(binned_acc_all);
binned_acc_all.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'acc', 'pupilBin'};

axes(h7);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Gaussian');
set(gca, 'FontName', 'times');

axes(h8);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Bimodal');
set(gca, 'FontName', 'times');

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end


        for ibin = 1:3

            mean_acc(itype, ibin) = mean(binned_acc_all.acc(binned_acc_all.pupilBin == ibin & binned_acc_all.distIdx == itype));
            sem_acc(itype, ibin)  = std(binned_acc_all.acc(binned_acc_all.pupilBin == ibin & binned_acc_all.distIdx == itype))./...
                                                sqrt(length(binned_acc_all.acc(binned_acc_all.pupilBin == ibin & binned_acc_all.distIdx == itype)));

            axes(h6);
            hold on
            errorbar(ibin, mean_acc(itype, ibin),  sem_acc(itype, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
          
        end


        % perform linear vs quadratic fit comparisons
        tmpFitData = [];
        tmpFitData = binned_acc_all((binned_acc_all.distIdx == itype), [1, 4, 5]);
        tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
        [stats2report_acc{itype}, STATS_acc{itype}, model_acc{itype}]...
            = fitlme_singleVar_sequential_grouping(tmpFitData, 0, 0);

        if strcmpi(model_acc{itype}.Name, 'x^2') | strcmpi(model_acc{itype}.Name, 'x')

            axes(h6); 
            xplot = [1 2 3];
            hold on 
            axes(h6);
            plot(xplot, STATS_acc{itype}.meanFit, '-', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_acc{itype}.CIFitLow, '--', 'color', col2plot, 'linew', 1.2);
            plot(xplot, STATS_acc{itype}.CIFitHigh, '--', 'color', col2plot, 'linew', 1.2);

        end



    end

    accglme = fitglme(binned_acc_all, 'acc~pupilBin*distIdx + (1|subIdx)');
    an_acc = anova(accglme);
    CC = dataset2cell(an_acc);
    anovaWriteTable(CC, 'accuracy');

    figure(3);
    axis square
    xlim([0 4]);
    set(gca, 'XTick', [1 2 3]);
    ylim([0.4 0.9]);
    ylabel({'\bfAverage', 'P(High|Both-Different)'});
    xlabel('\bfPupil Bin');
    title('\bfPupil Modulation of Accuracy');
    set(gca, 'FontName', 'times');

    saveFigname = ['accuracy_pupilBinned'];
    print(saveFigname, '-dpng');

figure(4);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h9 = subplot(1, 3, 1);
h10 = subplot(1, 3, 2);
h11 = subplot(1, 3, 3)

binned_rt_r = [];
binned_rt_all = [];
% plot accuracy rates as a function of pupil bin
cnd2run = [1];

for isubject = 1: length(subs)

    subIdx = find(dataIn.subIdx == subs(isubject));
    tmpSub = dataIn(subIdx, :);
    binned_rt = [];
    binnedRrt = [];

    for itype = 1:2
        tmpData_dist                        = [];
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end

        for icnd = 1:1
            
            data2use                            = [];
            dataSplit                           = [];

            distIdx                             = find([tmpSub.distType] == itype);
            dataSplit                           = tmpSub(distIdx, :);

            cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
            data2use                            = dataSplit(cndIdx, :);


            tmpData                             = [];
            tmpBin                              = [];
            tmpData                             = data2use(:, [1:7, 9, 14]);

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

                tmpRT                           = tmpData(:, [1, 4, 5, 7, 9]);
                tmpBin(1: size(tmpRT, 1))       = ibin;
                tmpRT.pupilBin                  = tmpBin';

                binned_rt                       = [binned_rt; tmpRT];

                tmpData.pupilBin(binnedPupil_idx{ibin}) = ibin;
            end

            [r_rt{isubject}(icnd, itype), p_rt{isubject}(icnd, itype)] = corr(tmpData.pupilBin,...
                tmpData.RT, 'type', 'spearman');

            if p_rt{isubject}(icnd, itype) <= 0.05

                faceCol = col2plot;
            else

                faceCol = [1 1 1];
            end

            if itype == 1 
                axes(h10)
                hold on 
                plot(isubject, r_rt{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);
            else 
                axes(h11)
                hold on 
                plot(isubject, r_rt{isubject}(icnd, itype), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', col2plot,...
                    'MarkerFaceColor', faceCol, 'linew', 1.5);
            end

            tmpR = [];
            tmpR = [subs(isubject) cnd2run(icnd) itype r_rt{isubject}(icnd, itype) p_rt{isubject}(icnd, itype)];
        end

            binnedRrt          = [binnedRrt; tmpR];
    end 

    
  
    binned_rt_all = [binned_rt_all; binned_rt];
    binned_rt_r   = [binnedRrt; binnedRacc];
end

binned_rt_all.Properties.VariableNames = {'g1', 'x1', 'x3', 'y', 'x4', 'x2'};

axes(h10);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Gaussian');
set(gca, 'FontName', 'times');

axes(h11);
axis square
xlabel('\bfSubject');
ylabel('\bfr_{s}');
hold on 
xlim([0 26]);
plot([0 26], [0 0], 'k--');
title('Bimodal');
set(gca, 'FontName', 'times');

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end


        for ibin = 1:3

            mean_rt(itype, ibin) = mean(binned_rt_all.y(binned_rt_all.x2 == ibin & binned_rt_all.x1 == itype));
            sem_rt(itype, ibin)  = std(binned_rt_all.y(binned_rt_all.x2 == ibin & binned_rt_all.x1 == itype))./...
                                                sqrt(length(binned_rt_all.y(binned_rt_all.x2 == ibin & binned_rt_all.x1 == itype)));

            axes(h9);
            hold on
            errorbar(ibin, mean_rt(itype, ibin),  sem_rt(itype, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
          
        end


        % perform linear vs quadratic fit comparisons
%         tmpFitData = [];
%         tmpFitData = binned_rt_all((binned_rt_all.x1 == itype), [1, 4, 6]);
%         tmpFitData.Properties.VariableNames = {'g1', 'y', 'x'};
%         [stats2report_rt{itype}, STATS_rt{itype}, model_rt{itype}]...
%             = fitlme_singleVar_sequential_grouping(tmpFitData, 0, 0);
% 
%         if strcmpi(model_rt{itype}.Name, 'x^2') | strcmpi(model_rt{itype}.Name, 'x')
% 
%             axes(h9); 
%             xplot = [1 2 3];
%             hold on 
%             axes(h9);
%             plot(xplot, STATS_rt{itype}.meanFit, '-', 'color', col2plot, 'linew', 1.2);
%             plot(xplot, STATS_rt{itype}.CIFitLow, '--', 'color', col2plot, 'linew', 1.2);
%             plot(xplot, STATS_rt{itype}.CIFitHigh, '--', 'color', col2plot, 'linew', 1.2);
% 
%         end



    end

    rtglme = fitglme(binned_rt_all, 'y~x2*x1 + (1|g1)');
    rt_acc = anova(rtglme);
    Crt = dataset2cell(rt_acc);
    anovaWriteTable(Crt, 'rt');

    figure(4);
    axis square
    xlim([0 4]);
    set(gca, 'XTick', [1 2 3]);
    ylim([1.30 1.45]);
    ylabel({'\bfAverage Reaction Times (s)'});
    xlabel('\bfPupil Bin');
    title('\bfPupil Modulation of RTs');
    set(gca, 'FontName', 'times');

    saveFigname = ['rt_pupilBinned'];
    print(saveFigname, '-dpng');


