function baseline_analysis(base_path, dataIn)

cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\riskAversion_analysis\riskAversion_analysis\UPPSP\');
loadtableName = ['UPPSP_allScores_uptodate.mat'];
load(loadtableName);

saveFolder = ['baselineAnalyses']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

%------------------------------------------------------------------------
%%% ANALYSIS ON INDIVIDUAL, COLLAPASED ACROSS DISTRIBUTIONS
%%% PERCENT IMPULISVE ~ RISKPREF, BASELINEPUPIL, AROUSAL
%%% RISKPREF ~ BASELINEPUPIL, AROUSAL
%-----------------------------------------------------------------------

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h1 = subplot(1, 3, 1);
h2 = subplot(1, 3, 2);
h3 = subplot(1, 3, 3);

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h4 = subplot(1, 2, 1);
h5 = subplot(1, 2, 2);

subs = unique(dataIn.subIdx);
% % analysis on an individual subject basis
for isubject = 1: length(subs)

    subIdx  = find(dataIn.subIdx == subs(isubject));
    tmpSub  = dataIn(subIdx, :);
    binned  = [];
    binnedR = [];
    riskCnd = [];
    riskCnd =  find(tmpSub.cndIdx == 2 | tmpSub.cndIdx == 3);;
    baseData(isubject, (1: 14)) = NaN;

    baseData(isubject, 10)      =  sum(tmpSub.riskyChoice(riskCnd) == 1)./length(tmpSub.riskyChoice(riskCnd));
    baseData(isubject, 11)      =  nanmean(cell2mat(tmpSub.baseline_raw(riskCnd)));
    baseData(isubject, 12)      =  nanstd(cell2mat(tmpSub.baseline_raw(riskCnd)))./...
        sqrt(length((cell2mat(tmpSub.baseline_raw(riskCnd)))));
    baseData(isubject, 13)      =  nanmean(tmpSub.stim_prtileResp_pupil(riskCnd));
    baseData(isubject, 14)      =  nanstd(tmpSub.stim_prtileResp_pupil(riskCnd))./...
        sqrt(length(tmpSub.stim_prtileResp_pupil(riskCnd)));

    baseData(isubject, 1)       = subs(isubject);
    ptFind                      = find(subComp_dataOut.subIdx == subs(isubject))

    if ~isempty(ptFind)
        baseData(isubject, (2:9)) = table2array(subComp_dataOut(isubject, [2:9]));
    end

    %%% FOR THOSE WITH AN IMPULSE PERCENTAGE SCORE 
    if ~isempty(ptFind)
        axes(h1) %RISK PREF
        hold on 
        plot(baseData(isubject, 7), baseData(isubject, 10), 'k.', 'MarkerSize', 25);
        axes(h2) %BASELINE PUPIL
        hold on 
        plot(baseData(isubject, 7), baseData(isubject, 11), 'k.', 'MarkerSize', 25);
        axes(h3) %STIMULUS PUPIL
        hold on 
        plot(baseData(isubject, 7), baseData(isubject, 13), 'k.', 'MarkerSize', 25);

    end
    
    %plot risk pref against pupil baseline mean
    axes(h4)
    hold on 
    plot(baseData(isubject, 10), baseData(isubject, 11), 'k.', 'MarkerSize', 25);

    %plot risk pref against stimulus 95th percentile ('arousal scalar')
    axes(h5)
    hold on 
    plot(baseData(isubject, 10), baseData(isubject, 13), 'k.', 'MarkerSize', 25);

end

baseData = array2table(baseData);
baseData.Properties.VariableNames = {'subIdx', 'NegativeUrgency', 'LackPerseverance', 'LackPremeditation',...
    'SensationSeeking', 'PositiveUrgency', 'ImpulseScore', 'ImpulsePerc', 'ImpulseType', 'riskPref',...
    'pupilBaseline_mean', 'pupilBaseline_sem', 'pupilStim_mean', 'pupilStim_sem'};

% AXES APPEARANCE
% FIGURE (1)
axes(h1);
title('\fontsize{12} Impulsivity ~ Risk Preference');
xlabel('Impulsivity (%)');
ylabel('Risk Preference');
xlim([10 70]);
ylim([0 1]);
hold on 
plot([50 50], [0 1], 'k--');
plot([10 70], [0.5 0.5], 'k--');
set(gca, 'fontName', 'times');

axes(h2);
title('\fontsize{12} Impulsivity ~ Baseline Pupil');
xlabel('Impulsivity (%)');
ylabel('Baseline Pupil (Average)');
xlim([10 70]);
ylim([-0.8 0]);
hold on 
plot([50 50], [-0.8 0], 'k--');
set(gca, 'fontName', 'times');

axes(h3);
title('\fontsize{12} Impulsivity ~ Stimulus Pupil');
xlabel('Impulsivity (%)');
ylabel('Stimulus 95th Percentile (Average)');
xlim([10 70]);
ylim([0 5]);
hold on 
plot([50 50], [0 5], 'k--');
set(gca, 'fontName', 'times');

% AXES APPEARANCE
% FIGURE (2)
axes(h4);
title('\fontsize{12} Risk Preference ~ Baseline Pupil');
xlabel('Risk Preference');
ylabel('Baseline Pupil (Average)');
xlim([0 1]);
ylim([-0.7 0.3]);
plot([0.5 0.5], [-0.7 0.3], 'k--');
set(gca, 'fontName', 'times');
axes(h5);
title('\fontsize{12} Risk Preference ~ Stimulus Pupil');
xlabel('Risk Preference');
ylabel('Stimulus 95th Percentile (Average)');
xlim([0 1]);
ylim([0 5]);
plot([0.5 0.5], [0 5], 'k--');
set(gca, 'fontName', 'times');

% correlational analyses
[rho,pr] = corr(baseData.ImpulsePerc, baseData.riskPref, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData.ImpulsePerc, h1);

[rho,pr] = corr(baseData.ImpulsePerc, baseData.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData.ImpulsePerc, h2);

[rho,pr] = corr(baseData.ImpulsePerc, baseData.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData.ImpulsePerc, h3);

[rho,pr] = corr(baseData.riskPref, baseData.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData.riskPref, h4);

[rho,pr] = corr(baseData.riskPref, baseData.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData.riskPref, h5);

figure(1);
saveFigname = ['ImpulsivityCorrelations'];
print(saveFigname, '-dpng');
figure(2);
saveFigname = ['PupilCorrelations'];
print(saveFigname, '-dpng');


%------------------------------------------------------------------------
%%% ANALYSIS ON INDIVIDUAL, SPLIT BY DISTRIBUTION TYPE
%%% SCALAR AROUSAL ~ ACCURACY, RISKPREF, RT & RTCV
%-----------------------------------------------------------------------
clf(figure(1));
clf(figure(2));
figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h1 = subplot(1, 3, 1);
h2 = subplot(1, 3, 2);
h3 = subplot(1, 3, 3);

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h4 = subplot(1, 2, 1);
h5 = subplot(1, 2, 2);

%Scalar arousal corr against RT, risk Pref and Accuracy Rates
figure(3);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [61.8702 -1.0372 20.9550 17.6107])
h6 = subplot(2, 2, 1);
h7 = subplot(2, 2, 2);
h8 = subplot(2, 2, 3);
h9 = subplot(2, 2, 4);

for isubject = 1: length(subs)

    subIdx  = find(dataIn.subIdx == subs(isubject));
    tmpSub  = dataIn(subIdx, :);
    binned  = [];
    binnedR = [];
    
    for itype = 1:2
    
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            col2plot_alpha = [0.9255    0.8039    0.9804];
        else
            col2plot = [0.3961 0.9608 0.3647];
            col2plot_alpha = [ 0.7176    0.9882    0.7020];
        end
    
        dataSplit                     = [];

        distIdx                       = find([tmpSub.distType] == itype);
        riskCnd                       = [];
        dataSplit                     = tmpSub(distIdx, :);

        scalar_all(itype, isubject)   = nanmean(dataSplit.stim_prtileResp_pupil);
        riskCnd                       = find(dataSplit.cndIdx == 2 | dataSplit.cndIdx == 3);
        accCnd                        = find(dataSplit.cndIdx == 1);
        scalar_risk(itype, isubject)  = nanmean(dataSplit.stim_prtileResp_pupil(riskCnd));

        riskPref(itype, isubject)     =  sum(dataSplit.riskyChoice(riskCnd) == 1)./length(dataSplit.riskyChoice(riskCnd));
        accuracy(itype, isubject)     =  sum(dataSplit.accChoice(accCnd) == 1)./length(dataSplit.accChoice(accCnd));

        RTs_all(itype, isubject)      = nanmean(dataSplit.RT);
        RTs_risk(itype, isubject)     = nanmean(dataSplit.RT(riskCnd));

        RTCVs_all(itype, isubject)      = nanstd(dataSplit.RT)./nanmean(dataSplit.RT);
        RTCVS_risk(itype, isubject)     = nanstd(dataSplit.RT(riskCnd))./nanmean(dataSplit.RT(riskCnd));

        axes(h6); %scalar ~ accuracy
        hold on 
        plot(scalar_all(itype, isubject), accuracy(itype, isubject), '.', 'color', col2plot, 'MarkerSize', 25);
        axes(h7);
        hold on %scalar ~ riskPref
        plot(scalar_all(itype, isubject), riskPref(itype, isubject), '.', 'color', col2plot, 'MarkerSize', 25);
        axes(h8);
        hold on %scalar ~ RTmean
        plot(scalar_all(itype, isubject), RTs_all(itype, isubject), '.', 'color', col2plot, 'MarkerSize', 25);
        axes(h9);
        hold on 
        plot(scalar_all(itype, isubject), RTCVs_all(itype, isubject), '.', 'color', col2plot, 'MarkerSize', 25);

    end
end

axes(h6);
axis square 
xlim([0 6]);
xlabel('Arousal (Scalar)');
hold on 
plot([0 6], [0.5 0.5], 'k--')
ylabel('P(High|Both-DIFFERENT)');
title('\fontsize{12}Arousal ~ Accuracy');
set(gca, 'Fontname', 'times');
axes(h7);
axis square 
xlim([0 6]);
xlabel('Arousal (Scalar)');
hold on 
plot([0 6], [0.5 0.5], 'k--')
ylabel('P(Risky| [Both-LOW || Both-HIGH])');
title('\fontsize{12}Arousal ~ Risk Preference');
set(gca, 'Fontname', 'times');
axes(h8);
axis square 
xlim([0 6]);
xlabel('Arousal (Scalar)');
hold on 
ylabel('Average RT (secs)');
title('\fontsize{12}Arousal ~ Average RTs');
set(gca, 'Fontname', 'times');
axes(h9);
axis square 
xlim([0 6]);
xlabel('Arousal (Scalar)');
hold on 
plot([0 6], [0.5 0.5], 'k--')
ylabel('RT CVs');
title('\fontsize{12}Arousal ~ RTs CVs');
set(gca, 'Fontname', 'times');

% % correlational analyses
[rho,pr] = corr(scalar_all(1, :)', accuracy(1, :)', 'Type', 'Spearman', 'Rows', 'Complete');
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h6, 1);
[rho,pr] = corr(scalar_all(2, :)', accuracy(2, :)', 'Type', 'Spearman', 'Rows', 'Complete');
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h6, 2);

[rho,pr] = corr(scalar_all(1, :)', riskPref(1, :)', 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h7, 1);
[rho,pr] = corr(scalar_all(2, :)', riskPref(2, :)', 'Type', 'Spearman', 'Rows', 'Complete');
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h7, 2);

[rho,pr] = corr(scalar_all(1, :)', RTs_all(1, :)', 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h8, 1);
[rho,pr] = corr(scalar_all(2, :)', RTs_all(2, :)', 'Type', 'Spearman', 'Rows', 'Complete');
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h8, 2);

[rho,pr] = corr(scalar_all(1, :)', RTCVs_all(1, :)', 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h9, 1);
[rho,pr] = corr(scalar_all(2, :)', RTCVs_all(2, :)', 'Type', 'Spearman', 'Rows', 'Complete');
hold on
corrText =  genCorrText(rho, pr, scalar_all(1, :), h9, 2);


[rho,pr] = corr(baseData_gauss.ImpulsePerc, baseData_gauss.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.ImpulsePerc, h3, 1);
[rho,pr] = corr(baseData_bi.ImpulsePerc, baseData_bi.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.ImpulsePerc, h3, 2);

[rho,pr] = corr(baseData_gauss.riskPref, baseData_gauss.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.riskPref, h4, 1);
[rho,pr] = corr(baseData_bi.riskPref, baseData_bi.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.riskPref, h4, 2);

[rho,pr] = corr(baseData_gauss.riskPref, baseData_gauss.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.riskPref, h5, 1);
[rho,pr] = corr(baseData_bi.riskPref, baseData_bi.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.riskPref, h5, 2);

saveFigname = ['scalarAllTrials_correlations'];
print(saveFigname, '-dpng');

%------------------------------------------------------------------------
%%% ANALYSIS ON INDIVIDUAL, SPLIT BY DISTRIBUTION TYPE
%%% PERCENT IMPULISVE ~ RISKPREF, BASELINEPUPIL, AROUSAL
%%% RISKPREF ~ BASELINEPUPIL, AROUSAL
%-----------------------------------------------------------------------
clf(figure(1));
clf(figure(2));
figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h1 = subplot(1, 3, 1);
h2 = subplot(1, 3, 2);
h3 = subplot(1, 3, 3);

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.0490 22.8176 9.0858])
h4 = subplot(1, 2, 1);
h5 = subplot(1, 2, 2);
for isubject = 1: length(subs)

    subIdx  = find(dataIn.subIdx == subs(isubject));
    tmpSub  = dataIn(subIdx, :);
    binned  = [];
    binnedR = [];
    
    for itype = 1:2
    
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            col2plot_alpha = [0.9255    0.8039    0.9804];
        else
            col2plot = [0.3961 0.9608 0.3647];
            col2plot_alpha = [ 0.7176    0.9882    0.7020];
        end
    
        dataSplit                           = [];

        distIdx                             = find([tmpSub.distType] == itype);
        riskCnd                             = [];
        dataSplit                           = tmpSub(distIdx, :);
        riskCnd                             = find(dataSplit.cndIdx == 2 | dataSplit.cndIdx == 3);
        
        
        baseData_dist{itype}(isubject, (1: 15)) = NaN;
    
        baseData_dist{itype}(isubject, 10)      =  sum(dataSplit.riskyChoice(riskCnd) == 1)./length(dataSplit.riskyChoice(riskCnd));
        baseData_dist{itype}(isubject, 11)      =  nanmean(cell2mat(dataSplit.baseline_raw(riskCnd)));
        baseData_dist{itype}(isubject, 12)      =  nanstd(cell2mat(dataSplit.baseline_raw(riskCnd)))./...
            sqrt(length((cell2mat(dataSplit.baseline_raw(riskCnd)))));
        
        % average 95th percentile across all risk preference trials as a
        % scalar of arousal
        baseData_dist{itype}(isubject, 13)      =  nanmean(dataSplit.stim_prtileResp_pupil(riskCnd));
        baseData_dist{itype}(isubject, 14)      =  nanstd(dataSplit.stim_prtileResp_pupil(riskCnd))./...
            sqrt(length(dataSplit.stim_prtileResp_pupil(riskCnd)));
    
        baseData_dist{itype}(isubject, 1)       = subs(isubject);
        ptFind                      = find(subComp_dataOut.subIdx == subs(isubject))
        baseData_dist{itype}(isubject, 15)      = itype;
    
        if ~isempty(ptFind)
            baseData_dist{itype}(isubject, (2:9)) = table2array(subComp_dataOut(isubject, [2:9]));
        end
    
        %%% FOR THOSE WITH AN IMPULSE PERCENTAGE SCORE 
        if ~isempty(ptFind)
            axes(h1) %RISK PREF
            hold on 
            plot(baseData_dist{itype}(isubject, 7), baseData_dist{itype}(isubject, 10), '.', 'color', col2plot, 'MarkerSize', 25);
            axes(h2) %BASELINE PUPIL
            hold on 
            plot(baseData_dist{itype}(isubject, 7), baseData_dist{itype}(isubject, 11), '.', 'color', col2plot, 'MarkerSize', 25);
            axes(h3) %STIMULUS PUPIL
            hold on 
            plot(baseData_dist{itype}(isubject, 7), baseData_dist{itype}(isubject, 13), '.', 'color', col2plot, 'MarkerSize', 25);
    
        end
        
        %plot risk pref against pupil baseline mean
        axes(h4)
        hold on 
        plot(baseData_dist{itype}(isubject, 10), baseData_dist{itype}(isubject, 11), '.', 'color', col2plot, 'MarkerSize', 25);
    
        %plot risk pref against stimulus 95th percentile ('arousal scalar')
        axes(h5)
        hold on 
        plot(baseData_dist{itype}(isubject, 10), baseData_dist{itype}(isubject, 13), '.', 'color', col2plot, 'MarkerSize', 25);
        
    end

    baseAll = [baseData_dist{1}; baseData_dist{2}];

end

% AXES APPEARANCE
% FIGURE (1)
axes(h1);
title('\fontsize{12} Impulsivity ~ Risk Preference');
xlabel('Impulsivity (%)');
ylabel('Risk Preference');
xlim([10 70]);
ylim([0 1]);
hold on 
plot([50 50], [0 1], 'k--');
plot([10 70], [0.5 0.5], 'k--');
set(gca, 'fontName', 'times');

axes(h2);
title('\fontsize{12} Impulsivity ~ Baseline Pupil');
xlabel('Impulsivity (%)');
ylabel('Baseline Pupil (Average)');
xlim([10 70]);
ylim([-0.8 0]);
hold on 
plot([50 50], [-0.8 0], 'k--');
set(gca, 'fontName', 'times');

axes(h3);
title('\fontsize{12} Impulsivity ~ Stimulus Pupil');
xlabel('Impulsivity (%)');
ylabel('Stimulus 95th Percentile (Average)');
xlim([10 70]);
ylim([0 5]);
hold on 
plot([50 50], [0 5], 'k--');
set(gca, 'fontName', 'times');

% AXES APPEARANCE
% FIGURE (2)
axes(h4);
title('\fontsize{12} Risk Preference ~ Baseline Pupil');
xlabel('Risk Preference');
ylabel('Baseline Pupil (Average)');
xlim([0 1]);
ylim([-0.7 0.3]);
plot([0.5 0.5], [-0.7 0.3], 'k--');
set(gca, 'fontName', 'times');
axes(h5);
title('\fontsize{12} Risk Preference ~ Stimulus Pupil');
xlabel('Risk Preference');
ylabel('Stimulus 95th Percentile (Average)');
xlim([0 1]);
ylim([0 5]);
plot([0.5 0.5], [0 5], 'k--');
set(gca, 'fontName', 'times');

baseData_gauss = array2table(baseData_dist{1});
baseData_gauss.Properties.VariableNames = {'subIdx', 'NegativeUrgency', 'LackPerseverance', 'LackPremeditation',...
    'SensationSeeking', 'PositiveUrgency', 'ImpulseScore', 'ImpulsePerc', 'ImpulseType', 'riskPref',...
    'pupilBaseline_mean', 'pupilBaseline_sem', 'pupilStim_mean', 'pupilStim_sem', 'distType'};
baseData_bi = array2table(baseData_dist{2});
baseData_bi.Properties.VariableNames = {'subIdx', 'NegativeUrgency', 'LackPerseverance', 'LackPremeditation',...
    'SensationSeeking', 'PositiveUrgency', 'ImpulseScore', 'ImpulsePerc', 'ImpulseType', 'riskPref',...
    'pupilBaseline_mean', 'pupilBaseline_sem', 'pupilStim_mean', 'pupilStim_sem','distType'};

% % correlational analyses
[rho,pr] = corr(baseData_gauss.ImpulsePerc, baseData_gauss.riskPref, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.ImpulsePerc, h1, 1);
[rho,pr] = corr(baseData_bi.ImpulsePerc, baseData_bi.riskPref, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.ImpulsePerc, h1, 2);

[rho,pr] = corr(baseData_gauss.ImpulsePerc, baseData_gauss.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.ImpulsePerc, h2, 1);
[rho,pr] = corr(baseData_bi.ImpulsePerc, baseData_bi.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.ImpulsePerc, h2, 2);

[rho,pr] = corr(baseData_gauss.ImpulsePerc, baseData_gauss.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.ImpulsePerc, h3, 1);
[rho,pr] = corr(baseData_bi.ImpulsePerc, baseData_bi.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.ImpulsePerc, h3, 2);

[rho,pr] = corr(baseData_gauss.riskPref, baseData_gauss.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.riskPref, h4, 1);
[rho,pr] = corr(baseData_bi.riskPref, baseData_bi.pupilBaseline_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.riskPref, h4, 2);

[rho,pr] = corr(baseData_gauss.riskPref, baseData_gauss.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_gauss.riskPref, h5, 1);
[rho,pr] = corr(baseData_bi.riskPref, baseData_bi.pupilStim_mean, 'Type', 'Spearman', 'Rows', 'Complete');
axes(h1);
hold on
corrText =  genCorrText(rho, pr, baseData_bi.riskPref, h5, 2);


figure(1);
saveFigname = ['ImpulsivityCorrelations_dist'];
print(saveFigname, '-dpng');
figure(2);
saveFigname = ['PupilCorrelations_dist'];
print(saveFigname, '-dpng');

%GLME analyses
baseAll = array2table(baseAll);
baseAll.Properties.VariableNames = {'subIdx', 'NegativeUrgency', 'LackPerseverance', 'LackPremeditation',...
    'SensationSeeking', 'PositiveUrgency', 'ImpulseScore', 'ImpulsePerc', 'ImpulseType', 'riskPref',...
    'pupilBaseline_mean', 'pupilBaseline_sem', 'pupilStim_mean', 'pupilStim_sem', 'distIdx'};
imp1 = fitglme(baseAll, 'pupilStim_mean ~ ImpulsePerc * distIdx + (1|subIdx) + (1|subIdx:distIdx:ImpulsePerc)');
