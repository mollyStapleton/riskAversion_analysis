figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [5.6303 3.5983 17.6318 15.1765]);
h1 = subplot(2, 2, 1);
h2 = subplot(2, 2, 2);
h3 = subplot(2, 2, 3);
h4 = subplot(2, 2, 4);

subs        = unique(dataIn.subIdx);
binned      = [];
binned_cnd  = [];
binned_type = [];
binned_all  = [];
tmpTable_RT = [];
rt_all      = [];

% analysis on an individual subject basis
for isubject = 1: length(subs)

    subIdx = find(dataIn.subIdx == subs(isubject));
    tmpSub = dataIn(subIdx, :);
    binned = [];

    for itype = 1:2
        tmpData_dist                        = [];
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end

        for icnd = 1:2

            if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
            end
            data2use                            = [];
            dataSplit                           = [];

            distIdx                             = find([tmpSub.distType] == itype);
            dataSplit                           = tmpSub(distIdx, :);

            cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
            data2use                            = dataSplit(cndIdx, :);
            medPupil{isubject}(itype, icnd)     = median(data2use.stim_prtileResp_pupil);

            splitIdx{isubject, itype}{icnd, 1}  = data2use.stim_prtileResp_pupil < medPupil{isubject}(itype, icnd);
            splitIdx{isubject, itype}{icnd, 2}  = data2use.stim_prtileResp_pupil > medPupil{isubject}(itype, icnd);

            tmpData                             = [];
            tmpBin                              = [];
            tmpData                             = data2use(:, [1:9, 14]);

            tmpBin(1: size(tmpData, 1))         = 0;

            tmpBin(splitIdx{isubject, itype}{icnd, 1})    = 1;
            tmpBin(splitIdx{isubject, itype}{icnd, 2})    = 2;

            tmpData.pupilBin                    = tmpBin';

            for ibin = 1:2

                if icnd == 1
                    %                     axes(h1);
                    prop_risky_low{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin));

                    diff_risky_low{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);

                    tmpRT           = [];
                    tmpRT           = tmpData(tmpData.pupilBin == ibin, [1:8]);

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_low{isubject, itype}(icnd, ibin) diff_risky_low{isubject, itype}(icnd, ibin) ibin];
                  
                else
                    %                     axes(h1);
                    prop_risky_high{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin));

                    diff_risky_high{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);

                    tmpRT           = [];
                    tmpRT           = tmpData(tmpData.pupilBin == ibin, [1:8]);
                    
                    tmpTable = [];
                    tmpTable = [subs(isubject) cnd2run(icnd) itype prop_risky_high{isubject, itype}(icnd, ibin) diff_risky_high{isubject, itype}(icnd, ibin) ibin];
                    

                end
                binned   = [binned; tmpTable];
                pupilBinVec = [];
                for irt = 1: size(tmpRT, 1)
                    pupilBinVec(irt) = ibin;
                end
    
                tmpRT.pupilBin  = pupilBinVec';
                tmpTable_RT     = [tmpTable_RT; tmpRT];
            end

            if icnd == 1
                axes(h1);
                hold on
                plot(prop_risky_low{isubject, itype}(icnd, 1), prop_risky_low{isubject, itype}(icnd, 2), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
                axes(h3);
                hold on
                plot(diff_risky_low{isubject, itype}(icnd, 1), diff_risky_low{isubject, itype}(icnd, 2), '^', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            else
                axes(h2);
                hold on
                plot(prop_risky_high{isubject, itype}(icnd, 1), prop_risky_high{isubject, itype}(icnd, 2), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
                axes(h4);
                hold on
                plot(diff_risky_high{isubject, itype}(icnd, 1), diff_risky_high{isubject, itype}(icnd, 2), '^', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            end

            tmpData_dist                        = [tmpData_dist; tmpData];

        end

    end
    binned_all = [binned_all; binned];
    rt_all     = [rt_all; tmpTable_RT];

end


saveFolder = ['stimulus_phasicPupilBins']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

binned_all = array2table(binned_all);
binned_all.Properties.VariableNames = {'SubIdx', 'CndIdx', 'DistType', 'P_Risky', 'Bias_Risky', 'pupilBin'};
% binned_all.DistType_cat = categorical(binned_all.DistType);
risk_pref_glme = fitglme(binned_all, 'P_Risky ~ CndIdx*DistType*pupilBin + (1|SubIdx) + (1| SubIdx:CndIdx:DistType)');
risk_bias_glme = fitglme(binned_all, 'Bias_Risky ~ CndIdx*DistType*pupilBin + (1|SubIdx) + (1| SubIdx:CndIdx:DistType)');
an_1 = anova(risk_pref_glme);
an_2 = anova(risk_bias_glme);
C = dataset2cell(an_1);
anovaWriteTable(C, 'riskPref');
C1 = dataset2cell(an_2);
anovaWriteTable(C1, 'riskbias');

%---------------------------------------------------------
% post hoc tests for CndIdx * DistType interaction 
% P(RISKY)
%---------------------------------------------------------------

cnd_vec = [2 2 3 3];
dist_vec = [1 2 1 2];
post_hoc_vec = [];
for opj=1:length(cnd_vec)  

    Lv1=binned_all.P_Risky(binned_all.CndIdx==cnd_vec(opj) & binned_all.DistType==dist_vec(opj));
    for pqr=opj+1:length(dist_vec)
        Lv2=binned_all.P_Risky(binned_all.CndIdx==cnd_vec(pqr) & binned_all.DistType==dist_vec(pqr));
        [hy,pt,~,stats]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison
        post_hoc_table{opj,pqr-1}=pt;
        post_hoc_vec=[post_hoc_vec pt];
    end
end

[pID,pN] = FDR(post_hoc_vec,0.05);

[h, crit_p, ~, adj_p]=fdr_bh(post_hoc_vec,0.05);

%%%%% now move adjusted p-values back into the table
p_count=1;
for opj=1:length(cnd_vec)-1 %%%% number of clusters
    for pqr=opj+1:length(cnd_vec)
        post_hoc_table{opj,pqr-1}=adj_p(p_count);
        p_count=p_count+1;
    end
end

%---------------------------------------------------------
% post hoc tests for CndIdx * DistType interaction 
% abs(P(RISKY))-0.5
%---------------------------------------------------------------
post_hoc_vec = [];
for opj=1:length(cnd_vec)  

    Lv1=binned_all.Bias_Risky(binned_all.CndIdx==cnd_vec(opj) & binned_all.DistType==dist_vec(opj));
    for pqr=opj+1:length(dist_vec)
        Lv2=binned_all.Bias_Risky(binned_all.CndIdx==cnd_vec(pqr) & binned_all.DistType==dist_vec(pqr));
        [hy,pt,~,stats]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison
        post_hoc_table_bias{opj,pqr-1}=pt;
        post_hoc_vec=[post_hoc_vec pt];
    end
end

[pID,pN] = FDR(post_hoc_vec,0.05);

[h, crit_p, ~, adj_p]=fdr_bh(post_hoc_vec,0.05);

%%%%% now move adjusted p-values back into the table
p_count=1;
for opj=1:length(cnd_vec)-1 %%%% number of clusters
    for pqr=opj+1:length(cnd_vec)
        post_hoc_table_bias{opj,pqr-1}=adj_p(p_count);
        p_count=p_count+1;
    end
end

% correlation between pupil bins within conditions?
% BOTH-LOW - GAUSSIAN
x1 = binned_all.P_Risky(binned_all.CndIdx == 2 & binned_all.pupilBin == 1 & binned_all.DistType == 1);
y1 = binned_all.P_Risky(binned_all.CndIdx == 2 & binned_all.pupilBin == 2 & binned_all.DistType == 1);
[r_g_low, p_g_low] = corr(x1, y1, 'type', 'spearman', 'rows', 'complete');
% BOTH-HIGH - GAUSSIAN
x2 = binned_all.P_Risky(binned_all.CndIdx == 3 & binned_all.pupilBin == 1 & binned_all.DistType == 1);
y2 = binned_all.P_Risky(binned_all.CndIdx == 3 & binned_all.pupilBin == 2 & binned_all.DistType == 1);
[r_g_high, p_g_high] = corr(x2, y2, 'type', 'spearman', 'rows', 'complete');

% BOTH-LOW - BIMODAL
x3 = binned_all.P_Risky(binned_all.CndIdx == 2 & binned_all.pupilBin == 1 & binned_all.DistType == 2);
y3 = binned_all.P_Risky(binned_all.CndIdx == 2 & binned_all.pupilBin == 2 & binned_all.DistType == 2);
[r_b_low, p_b_low] = corr(x3, y3, 'type', 'spearman', 'rows', 'complete');
% BOTH-HIGH - BIMODAL
x4 = binned_all.P_Risky(binned_all.CndIdx == 3 & binned_all.pupilBin == 1 & binned_all.DistType == 2);
y4 = binned_all.P_Risky(binned_all.CndIdx == 3 & binned_all.pupilBin == 2 & binned_all.DistType == 2);
[r_b_high, p_b_high] = corr(x4, y4, 'type', 'spearman', 'rows', 'complete');

figure(2);
set(gcf, 'units', 'centimeters');
% set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])
h5 = subplot(1, 2, 1);
h6 = subplot(1, 2, 2);

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
        end

        
        for ibin = 1:2

            mean_binned{itype}(icnd, ibin) = mean(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            sem_binned{itype}(icnd, ibin)  = std(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));

            mean_diff{itype}(icnd, ibin) = mean(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype));
            sem_diff{itype}(icnd, ibin)  = std(binned_all.Bias_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype))./...
                                                sqrt(length(binned_all.P_Risky(binned_all.CndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.DistType == itype)));
            
            axes(h5);
            hold on
            errorbar(x2plot(ibin), mean_binned{itype}(icnd, ibin),  sem_binned{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            axes(h6);
            hold on 
            errorbar(x2plot(ibin), mean_diff{itype}(icnd, ibin),  sem_diff{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            
        end

    end


end 

axes(h5)
axis square
hold on 
plot([2 2], [0 4], 'k-');
plot([0 4], [0.5 0.5], 'k--');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 1]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
title({'\fontsize{12}Risk Preferences', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

axes(h6);
axis square
hold on 
plot([0 4], [0 0], 'k--');
plot([2 2], [0 0.3], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 0.3]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('abs(P(Risky)-0.5)');
title({'\fontsize{12}Change in Risk Attitude', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');


savefigName = ['average_preferences_bias_newPhasicWindow'];
print(savefigName, '-dpng')

% plots formatting
axes(h1);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-LOW', 'P(Risky)'});
set(gca, 'fontName', 'times');

axes(h2);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-HIGH', 'P(Risky)'});
set(gca, 'fontName', 'times');

axes(h3);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
ylim([0 0.6]);
xlim([0 0.6]);
set(gca, 'XTick', [0:.2:0.6]);
set(gca, 'YTick', [0:.2:0.6]);
x2plot = linspace(0, 0.6);
y2plot = linspace(0, 0.6);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-LOW', 'Difference P(Risky)'});
set(gca, 'fontName', 'times');

axes(h4);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
ylim([0 0.6]);
xlim([0 0.6]);
set(gca, 'XTick', [0:.2:0.6]);
set(gca, 'YTick', [0:.2:0.6]);
x2plot = linspace(0, 0.6);
y2plot = linspace(0, 0.6);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-HIGH', 'Difference P(Risky)'});
set(gca, 'fontName', 'times');

savefigName = ['subject_stimulus_phasic_newPhasicWindow'];
print(savefigName, '-dpng');


figure(3);
set(gcf, 'units', 'centimeters');
% set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
        end

        
        for ibin = 1:2

            mean_RT{itype}(icnd, ibin) = mean(rt_all.RT(rt_all.cndIdx == cnd2run(icnd) & rt_all.pupilBin == ibin & rt_all.distType == itype));
            sem_RT{itype}(icnd, ibin)  = std(rt_all.RT(rt_all.cndIdx == cnd2run(icnd) & rt_all.pupilBin == ibin & rt_all.distType == itype))./...
                                                sqrt(length(rt_all.RT(rt_all.cndIdx == cnd2run(icnd) & rt_all.pupilBin == ibin & rt_all.distType == itype)))
        
            figure(3);
            hold on
            errorbar(x2plot(ibin), mean_RT{itype}(icnd, ibin),  sem_RT{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
           
        end

    end


end 

figure(3);
gca;
axis square
hold on 
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([1.34 1.50]);
plot([2 2], [1.34 1.50], 'k-');
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Reaction Time (s)');
title({'\fontsize{12}Average Reaction Times', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

figure(3);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [11.3877 2.3283 11.0913 9.2710]);
saveFigName = ['reactionTime_pupilBinned'];
print(saveFigName, '-dpng');

rt_glme = fitglme(rt_all, 'RT ~ cndIdx * distType * pupilBin + (1| subIdx) + (1|subIdx:cndIdx:distType)');
an_rt   = anova(rt_glme);
C2      = dataset2cell(an_rt);
anovaWriteTable(C2, 'reactionTime');

%---------------------------------------------------------
% post hoc tests for CndIdx * DistType * pupilBin interaction 
% reaction time 
%---------------------------------------------------------------
cndVec = [2 2 2 2 3 3 3 3];
distVec = [1 1 2 2 1 1 2 2];
pupilVec = [1 2 1 2 1 2 1 2];

post_hoc_vec = [];
for opj=1:length(cndVec)  

    Lv1=rt_all.RT(rt_all.cndIdx==cndVec(opj) & rt_all.distType==distVec(opj) & rt_all.pupilBin == pupilVec(opj));
    for pqr=opj+1:length(cndVec)
        Lv2=rt_all.RT(rt_all.cndIdx==cndVec(pqr) & rt_all.distType==distVec(pqr) & rt_all.pupilBin == pupilVec(pqr));
        [hy,pt,~,stats]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison
        post_hoc_table_rt{opj,pqr-1}=pt;
        post_hoc_vec=[post_hoc_vec pt];
    end
end

[pID,pN] = FDR(post_hoc_vec,0.05);

[h, crit_p, ~, adj_p]=fdr_bh(post_hoc_vec,0.05);

%%%%% now move adjusted p-values back into the table
p_count=1;
for opj=1:length(cndVec)-1 %%%% number of clusters
    for pqr=opj+1:length(cndVec)
        post_hoc_table_rt{opj,pqr-1}=adj_p(p_count);
        p_count=p_count+1;
    end
end

% plot risk preferences as a function of pupil bin between the first and
% second half of the blocks 

t1 = [1:60];
t2 = [61:120];
figure(4);
set(gcf, 'units', 'centimeters');
% set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])
h7 = subplot(1, 2, 1);
h8 = subplot(1, 2, 2);

for icnd = 1:2

     if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
     end

     cndIdx = (dataIn.cndIdx == cnd2run(icnd));
     
     
    for itype = 1:2

        distIdx = (dataIn.distType == itype);

        for it = 1:2

            data2run = [];
            trials2get = find(cndIdx == 1 &  distIdx ==1);
            data2run = dataIn(trials2get, :);
        
            if it == 1 
                trials2find = t1;        
            else 
                trials2find = t2;
            end

            trIdx = find(ismember(data2run.trialNum, trials2find));
            data2split = [];
            data2split = data2run(trIdx, :);
    
            pupilMedian = median(data2split.stim_prtileResp_pupil);
            splitIdx = [];
            splitIdx{1} = find(data2split.stim_prtileResp_pupil < pupilMedian);
            splitIdx{2} = find(data2split.stim_prtileResp_pupil > pupilMedian);

            tmpBin(1: size(data2split, 1))         = 0;

            tmpBin(splitIdx{1})    = 1;
            tmpBin(splitIdx{2})    = 2;

            data2split.pupilBin                    = tmpBin';

            for ibin = 1:2

                if it == 1 
                    axes(h7);
                    hold on 
                else 
                    axes(h7);
                    hold on 
                end
                
                if icnd == 1 
                    t_prop_risky_low{icnd, itype}(it, ibin) = sum(data2split.riskyChoice(data2split.pupilBin == ibin) ==1)./...
                        length(data2split.riskyChoice(data2split.pupilBin == ibin));
        
                    t_diff_risky_low{isubject, itype}(icnd, ibin) = abs(sum(data2split.riskyChoice(data2split.pupilBin == ibin) ==1)./...
                        length(data2split.riskyChoice(data2split.pupilBin == ibin))-0.5);
                else 
                    t_prop_risky_high{icnd, itype}(it, ibin) = sum(data2split.riskyChoice(data2split.pupilBin == ibin) ==1)./...
                        length(data2split.riskyChoice(data2split.pupilBin == ibin));
        
                    t_diff_risky_high{isubject, itype}(icnd, ibin) = abs(sum(data2split.riskyChoice(data2split.pupilBin == ibin) ==1)./...
                        length(data2split.riskyChoice(data2split.pupilBin == ibin))-0.5);

                end

            end




        end

end


end

