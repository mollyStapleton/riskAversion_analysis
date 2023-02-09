figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [5.6303 9.6308 24.5534 9.1440]);
h1 = subplot(1, 2, 1);
h2 = subplot(1, 2, 2);


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

            tmpData_risk                             = [];
            tmpBin                              = [];
            tmpData_risk                             = data2use(:, [1:9, 14]);

            tmpBin(1: size(tmpData_risk, 1))         = 0;

            tmpBin(splitIdx{isubject, itype}{icnd, 1})    = 1;
            tmpBin(splitIdx{isubject, itype}{icnd, 2})    = 2;

            tmpData_risk.pupilBin                    = tmpBin';

            for ibin = 1:2

                if icnd == 1

                    tmpRT           = [];
                    tmpRT           = tmpData_risk(tmpData_risk.pupilBin == ibin, [1:8]);

                    sub_mean_RT{isubject}(icnd, ibin) = mean(tmpRT.RT);

                else

                    tmpRT           = [];
                    tmpRT           = tmpData_risk(tmpData_risk.pupilBin == ibin, [1:8]);
                   
                    sub_mean_RT{isubject}(icnd, ibin) = mean(tmpRT.RT);

                end

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
          
            else
               axes(h2);
               hold on 
            end

            plot(sub_mean_RT{isubject}(icnd, 1), sub_mean_RT{isubject}(icnd, 2), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
        end

    end

    rt_all     = [rt_all; tmpTable_RT];

end

saveFolder = ['stimulus_phasicPupilBins'];
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

% plots formatting
axes(h1);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
xlim([1 2]);
ylim([1 2]);
x2plot = linspace(1, 2);
y2plot = linspace(1, 2);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-LOW'});
set(gca, 'fontName', 'times');

axes(h2);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
xlim([1 2]);
ylim([1 2]);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-HIGH'});
set(gca, 'fontName', 'times');

savefigName = ['subject_stimulus_phasic_RT'];
print(savefigName, '-dpng');

figure(2);
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
        
            figure(2);
            hold on
            errorbar(x2plot(ibin), mean_RT{itype}(icnd, ibin),  sem_RT{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
           
        end

    end


end 

figure(2);
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

figure(2);
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

% plot RTs for condition x distribution type x risky choice 
figure(3);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [11.3877 2.3283 11.0913 9.2710]);

for icnd = 1:2

    if icnd == 1
        x2plot = [1 1.5];
    else
        x2plot = [2.5 3];
    end

    cndIdx = find(rt_all.cndIdx == cnd2run(icnd));
    cnd_data = rt_all(cndIdx, :);

    for itype = 1:2

        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end


        distIdx  = find(cnd_data.distType == itype);
        data2run = [];
        data2run = cnd_data(distIdx, :);
    
        riskyIdx = [];
        safeIdx = [];
    
        riskyIdx = find(data2run.riskyChoice == 1);
        safeIdx  = find(data2run.riskyChoice ~= 1);

    
        mean_RT_risk(icnd, itype) = mean(data2run.RT(riskyIdx));
        sem_RT_risk(icnd, itype)  = std(data2run.RT(riskyIdx))./sqrt(length(data2run.RT(riskyIdx)));

        mean_RT_safe(icnd, itype) = mean(data2run.RT(safeIdx));
        sem_RT_safe(icnd, itype)  = std(data2run.RT(safeIdx))./sqrt(length(data2run.RT(safeIdx)));

        figure(3);
        hold on 
        errorbar(x2plot(1), mean_RT_risk(icnd, itype),  sem_RT_risk(icnd, itype), '.',...
            'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
        errorbar(x2plot(2), mean_RT_safe(icnd, itype),  sem_RT_safe(icnd, itype), '.',...
            'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
           

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
set(gca, 'XTickLabel', {'LOW-Risky', 'LOW-Safe', 'HIGH-Risky', 'HIGH-Safe'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Reaction Time (s)');
title({'\fontsize{12}Average Reaction Times', 'Risk Preferences'});
set(gca, 'FontName', 'times');
figure(3);
saveFigName = ['reactionTime_riskPref'];
print(saveFigName, '-dpng');
print(saveFigName, '-dpdf');

rtrisk_glme     = fitglme(rt_all, 'RT ~ cndIdx * distType * riskyChoice + (1| subIdx) + (1|subIdx:cndIdx:distType)');
an_rt_risk      = anova(rtrisk_glme);
C3              = dataset2cell(an_rt_risk);
anovaWriteTable(C3, 'reactionTime_riskPref');

cndVec = [2 2 2 2 3 3 3 3];
distVec = [1 1 2 2 1 1 2 2];
riskVec = [0 1 0 1 0 1 0 1];

post_hoc_vec = [];
for opj=1:length(cndVec)  

    Lv1=rt_all.RT(rt_all.cndIdx==cndVec(opj) & rt_all.distType==distVec(opj) & rt_all.riskyChoice == riskVec(opj));
    for pqr=opj+1:length(cndVec)
        Lv2=rt_all.RT(rt_all.cndIdx==cndVec(pqr) & rt_all.distType==distVec(pqr) & rt_all.riskyChoice == riskVec(pqr));
        [hy,pt,~,stats]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison
        post_hoc_table_RTRisk{opj,pqr-1}=pt;
        post_hoc_vec=[post_hoc_vec pt];
    end
end

[pID,pN] = FDR(post_hoc_vec,0.05);

[h, crit_p, ~, adj_p]=fdr_bh(post_hoc_vec,0.05);

%%%%% now move adjusted p-values back into the table
p_count=1;
for opj=1:length(distVec)-1 %%%% number of clusters
    for pqr=opj+1:length(distVec)
        post_hoc_table_RTRisk{opj,pqr-1}=adj_p(p_count);
        p_count=p_count+1;
    end
end

%------------------------------------------------------------
% trial binned RTs between both reward distributions %
%------------------------------------------------------------
bin = [1:24:120];
binSize = 24;
figure(4);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [5.6303 9.6308 24.5534 9.1440]);
h3 = subplot(1, 2, 1);
h4 = subplot(1, 2, 2);
data2keep = [];

for icnd = 1:2

        cndIdx = find(rt_all.cndIdx == cnd2run(icnd));
        cnd_data = rt_all(cndIdx, :);
        if icnd == 1 
            marker2use = 'o';
            marker2size = 10;

        else 
            marker2use = '.';
            marker2size = 35;
        end


    for itype = 1:2

        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            axes(h3);
        else
            col2plot = [0.3961 0.9608 0.3647];
            axes(h4);
        end

        distIdx  = find(cnd_data.distType == itype);
        data2run = [];
        data2run = cnd_data(distIdx, :);
    
        riskyIdx = [];
        safeIdx = [];
    
        riskyIdx = find(data2run.riskyChoice == 1);
        safeIdx  = find(data2run.riskyChoice ~= 1);

        for ibin = 1: length(bin)

             tmpBinIdx = [];
             tmpBinIdx = find(ismember(data2run.trialNum(riskyIdx),  (bin(ibin): (bin(ibin) + binSize -1))));         
             risky_binned{icnd, itype}{ibin} = data2run.RT(riskyIdx(tmpBinIdx));
          
             tmpData_risk = data2run(riskyIdx(tmpBinIdx), :);
             tmpData_risk.timeBin(1: length(riskyIdx(tmpBinIdx))) = ibin;

             tmpBinIdx = [];
             tmpBinIdx = find(ismember(data2run.trialNum(safeIdx),  (bin(ibin): (bin(ibin) + binSize -1))));         
             safe_binned{icnd, itype}{ibin} = data2run.RT(safeIdx(tmpBinIdx)); 

             tmpData_safe = data2run(safeIdx(tmpBinIdx), :);
             tmpData_safe.timeBin(1: length(safeIdx(tmpBinIdx))) = ibin;

             sem2plot = [];
             sem2plot = std(risky_binned{icnd, itype}{ibin})./sqrt(length(risky_binned{icnd, itype}{ibin}));
             hold on 
             errorbar(ibin, mean(risky_binned{icnd, itype}{ibin}), sem2plot, marker2use,...
            'MarkerSize', marker2size, 'color', col2plot, 'linew', 1.2);
             sem2plot = [];
             sem2plot = std(safe_binned{icnd, itype}{ibin})./sqrt(length(safe_binned{icnd, itype}{ibin}));
             hold on 
             errorbar(ibin, mean(safe_binned{icnd, itype}{ibin}), sem2plot, marker2use,...
            'MarkerSize', marker2size, 'color', col2plot, 'linew', 1.2);

             data2keep = [data2keep; tmpData_risk; tmpData_safe];

        end
  
        mean2plot = [];
        mean2plot = cellfun(@mean, risky_binned{icnd, itype});
        hold on 
        plot([1:5], mean2plot, '-', 'color', col2plot, 'linew', 1.2);
        mean2plot = [];
        mean2plot = cellfun(@mean, safe_binned{icnd, itype});
        hold on 
        plot([1:5], mean2plot, '--', 'color', col2plot, 'linew', 1.2);

    end
   
end

axes(h3);
hold on 
axis square
xlim([0 6]);
ylim([1.25 1.8]);
xlabel('Trials Binned');
ylabel('Reaction Time (s)');
title({'\fontsize{12} RT: Gaussian'});
set(gca, 'FontName', 'times');

axes(h4);
hold on 
axis square
xlim([0 6]);
ylim([1.25 1.8]);
xlabel('Trials Binned');
ylabel('Reaction Time (s)');
title({'\fontsize{12} RT: Bimodal'});
set(gca, 'FontName', 'times');



