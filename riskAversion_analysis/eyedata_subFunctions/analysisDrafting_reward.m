function analysisDrafting(base_path, dataIn)

cnd2run         = [2 3];

data2plot_risk       = cell(2, 2);
data2plot_deriv_risk =  cell(2, 2);
data2plot_safe       = cell(2, 2);
data2plot_deriv_safe =  cell(2, 2);
timeVec         = linspace(-0.5, 1, 76);

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [6.5193 0.0212 20.1507 20.6587]);
h1 = subplot(2, 2, 1);
h2 = subplot(2, 2, 2);
h3 = subplot(2, 2, 3);
h4 = subplot(2, 2, 4);

for icnd = 1:2

    for itype = 1:2

        trIdx = [];
        trIdx = find([dataIn.cndIdx == cnd2run(icnd)] & [dataIn.distType == itype]);

        riskVec = [];
        riskVec = dataIn.riskyChoice(trIdx);

        data2plot_risk{icnd, itype} = [data2plot_risk{icnd, itype}; cell2mat(dataIn.stim_aligned_pupil(trIdx(riskVec == 1))')'];
        data2plot_deriv_risk{icnd, itype} = [data2plot_deriv_risk{icnd, itype}; cell2mat(dataIn.stim_derivative(trIdx(riskVec == 1))')'];
        
        data2plot_safe{icnd, itype} = [data2plot_safe{icnd, itype}; cell2mat(dataIn.stim_aligned_pupil(trIdx(riskVec == 0))')'];
        data2plot_deriv_safe{icnd, itype} = [data2plot_deriv_safe{icnd, itype}; cell2mat(dataIn.stim_derivative(trIdx(riskVec == 0))')'];

            if itype == 1                   
                   col2plot_alpha = [0.7059 0.4745 0.9882];
            else 
                    col2plot_alpha = [0.3961 0.9608 0.3647]
            end
        

        if icnd == 1
            axes(h1); %both-LOW: z score 
            hold on
        else 
            axes(h3); %both-HIGH: z score 
            hold on
        end
        plot(timeVec, nanmean(data2plot_risk{icnd, itype}), '-', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(data2plot_risk{icnd, itype})./sqrt(length(data2plot_risk{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(data2plot_risk{icnd, itype}) + tmpSem,...
            fliplr([nanmean(data2plot_risk{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);
        hold on 
        plot(timeVec, nanmean(data2plot_safe{icnd, itype}), '--', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(data2plot_safe{icnd, itype})./sqrt(length(data2plot_safe{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(data2plot_safe{icnd, itype}) + tmpSem,...
            fliplr([nanmean(data2plot_safe{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);

        if icnd == 1
            axes(h2); %both-LOW: derivative 
            hold on
        else 
            axes(h4); %both-HIGH: derivative 
            hold on
        end
        
        plot(timeVec, nanmean(data2plot_deriv_risk{icnd, itype}), '-', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(data2plot_deriv_risk{icnd, itype})./sqrt(length(data2plot_deriv_risk{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(data2plot_deriv_risk{icnd, itype}) + tmpSem,...
            fliplr([nanmean(data2plot_deriv_risk{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);                 
        
        plot(timeVec, nanmean(data2plot_deriv_safe{icnd, itype}), '--', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(data2plot_deriv_safe{icnd, itype})./sqrt(length(data2plot_deriv_safe{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(data2plot_deriv_safe{icnd, itype}) + tmpSem,...
            fliplr([nanmean(data2plot_deriv_safe{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);
        hold on
    end

end


axes(h1);
title({' \fontsize{16} \bfzScore Pupil', '\fontsize{12} Both-LOW'});
ylabel({'Pupil Response', '(% Response Change)'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-0.5 0.5]);
hold on 
plot([0 0], [-0.5 0.5], 'k-');
hold on 
plot([0.8 0.8], [-0.5 0.5], 'k-');
set(gca, 'FontName', 'times');

axes(h3);
title({'\fontsize{12} \bfBoth-HIGH'});
ylabel({'Pupil Response', '(% Response Change)'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-0.5 0.5]);
hold on 
plot([0 0], [-0.5 0.5], 'k-');
hold on 
plot([0.8 0.8], [-0.5 0.5], 'k-');
set(gca, 'FontName', 'times');

axes(h2);
title({' \fontsize{16} \bfPupil Derivative', '\fontsize{12} Both-LOW'});
ylabel({'Time Derivative'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-1 1.5]);
hold on 
plot([0 0], [-1 1.5], 'k-');
hold on 
plot([0.8 0.8], [-1 1.5], 'k-');
set(gca, 'FontName', 'times');
axes(h4);
title({'\fontsize{12} \bf Both-HIGH'});
ylabel({'Time Derivative'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-1 1.5]);
hold on 
plot([0 0], [-1 1.5], 'k-');
hold on 
plot([0.8 0.8], [-1 1.5], 'k-');
set(gca, 'FontName', 'times');

% generate average pupil zScore for each subject from 0-0.8s from stim
% onset 
subs = unique(dataIn.subIdx);
figure(2);
meanStats = [];
for isubject = 1: length(subs)
    subIdx  = [];
    subIdx  = find(dataIn.subIdx == subs(isubject));
    subData = dataIn(subIdx, :);
    tmpCnd   = [];

    for icnd = 1:2

        if icnd == 1 
            x2plot = [1 1.5; 2 2.5];
        else 
            x2plot = [3.5 4; 4.5 5];
        end

        for itype = 1:2

            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
                col2plot_alpha = [0.9255    0.8039    0.9804];
            else
                col2plot = [0.3961 0.9608 0.3647];
                col2plot_alpha = [ 0.7176    0.9882    0.7020];
            end

            trIdx = [];
            trIdx = find([subData.cndIdx == cnd2run(icnd)] & [subData.distType == itype]);
    
            riskVec = [];
            riskVec = subData.riskyChoice(trIdx);

            tmpData = [];
            tmpData = cell2mat(subData.stim_aligned_pupil(trIdx(riskVec == 1))')';
            if ~isempty(tmpData)
                meanPupil_risk{icnd, itype}(isubject) = nanmean(nanmean(tmpData(:, [26:66])));
            else 
                meanPupil_risk{icnd, itype}(isubject) = NaN;
            end
            
            tmpData = [];
            tmpData = cell2mat(subData.stim_aligned_pupil(trIdx(riskVec ~= 1))')';
            if ~isempty(tmpData)
                meanPupil_safe{icnd, itype}(isubject) = nanmean(nanmean(tmpData(:, [26:66])));
            else 
                meanPupil_safe{icnd, itype}(isubject) = NaN;
            end

            figure(2);
            hold on 
            plot(x2plot(itype,1), meanPupil_risk{icnd, itype}(isubject), '.', 'color', col2plot_alpha,...
                'MarkerSize', 25);
            plot(x2plot(itype,2), meanPupil_safe{icnd, itype}(isubject), '.', 'color', col2plot_alpha,...
                'MarkerSize', 25);
            hold on

            if isubject == 27

                allMean_risk(icnd, itype) = nanmean(meanPupil_risk{icnd, itype});
                allMean_safe(icnd, itype) = nanmean(meanPupil_safe{icnd, itype});

                allSEM_risk(icnd, itype) = nanstd(meanPupil_risk{icnd, itype})./sqrt(length(meanPupil_risk{icnd, itype}));
                allSEM_safe(icnd, itype) = nanstd(meanPupil_safe{icnd, itype})./sqrt(length(meanPupil_safe{icnd, itype}));

                hold on 
                errorbar(x2plot(itype, 1), allMean_risk(icnd, itype), allSEM_risk(icnd, itype), 's',...
                    'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color',col2plot, 'linew', 1.2);
            
                 errorbar(x2plot(itype, 2), allMean_safe(icnd, itype), allSEM_safe(icnd, itype), 's',...
                    'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color', col2plot, 'linew', 1.2);
                hold on
            end

            tmpStats{itype} = [subs(isubject) cnd2run(icnd) itype 1 meanPupil_risk{icnd, itype}(isubject);
                subs(isubject) cnd2run(icnd) itype 2 meanPupil_safe{icnd, itype}(isubject)];
        end

            tmpCnd           = [tmpCnd; cell2mat(tmpStats')];
    end
            meanStats        = [meanStats; tmpCnd];
end

figure(2);
xlim([0 6]);
ylim([-2.5 1]);
set(gca, 'XTick', [1 1.5 2 2.5 3.5 4 4.5 5]);
set(gca, 'XTickLabelRotation', 45);
set(gca, 'XTickLabel', {'LOW-Risky', 'LOW-Safe', 'LOW-Risky', 'LOW-Safe', 'HIGH-Risky', 'HIGH-Safe', 'HIGH-Risky', 'HIGH-Safe'})
hold on 
plot([3 3], [-2.5 1], 'k-');
ylabel({'Average Pupil Response', '(% Response Change)'});
set(gca, 'FontName', 'times');

meanStats = array2table(meanStats);
meanStats.Properties.VariableNames = {'subIdx', 'cndIdx', 'distType', 'riskysafe', 'pupil'};
dataLow = meanStats(meanStats.cndIdx == 2, :);
dataHigh = meanStats(meanStats.cndIdx ==3, :);

tmpNan  = isnan(dataLow.pupil);
dataLow = dataLow(~tmpNan, :);

saveFolder = ['stimulus_phasicPupilBins']; 
if ~exist([base_path '\population_dataAnalysis\' saveFolder])
    mkdir([base_path '\population_dataAnalysis\' saveFolder])    
end
cd([base_path '\population_dataAnalysis\' saveFolder]);
filename = 'dataLow_averagePupil_riskyChoice.csv';
writetable(dataLow, filename);
filename = 'dataHigh_averagePupil_riskyChoice.csv';
writetable(dataHigh, filename);

figure(1);
saveFigname = ['stimulus_RiskyChoice_psth'];
print(saveFigname, '-dpng');
figure(2);
saveFigname = ['stimulus_RiskyChoice_avg'];
print(saveFigname, '-dpng');

%%% assess effects of previous choice on the relative pupil diameter %%%
% generate matrix for analyses
% matrix with reward and riksy choice info from trial(t) and (t-1)

reward_t1 = nan(size(dataIn, 1), 1);
risky_t1  = nan(size(dataIn, 1), 1);
cnd_t1    = nan(size(dataIn, 1), 1);
avgPupil  = nan(size(dataIn, 1), 1);

glmeData  = dataIn(:, [1:8, 11]);

for idata = 2: size(dataIn, 1)

    reward_t1(idata, 1) = dataIn.reward(idata-1);
    risky_t1(idata, 1)  = dataIn.riskyChoice(idata-1);
    cnd_t1(idata, 1)    = dataIn.cndIdx(idata-1);
  
end

glmeData.reward_t1 = reward_t1;
glmeData.risky_t1  = risky_t1;
glmeData.cnd_t1    = cnd_t1;

for idata = 1: size(dataIn, 1)

    avgPupil(idata, 1) = nanmean([dataIn.stim_aligned_pupil{idata}(26:66)]);

end

glmeData.avgPupilSize = avgPupil;
figure(6);
hold on 
h7 = subplot(1, 2, 1);
h8 = subplot(1, 2, 2);

coeffData = [];
for isubject = 1: length(subs)

    subIdx = find(glmeData.subIdx == subs(isubject));
    subData = glmeData(subIdx, :);

    tmpStats = cell(1, 2);

    for itype = 1:2

            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
                col2plot_alpha = [0.9255    0.8039    0.9804];
            else
                col2plot = [0.3961 0.9608 0.3647];
                col2plot_alpha = [ 0.7176    0.9882    0.7020];
            end

            for icnd = 1:2

                trIdx = [];
                trIdx = find([subData.cndIdx == cnd2run(icnd)] & [subData.distType == itype]);
        
                tmpData = [];
                tmpData = subData(trIdx, :);
    
                fit = fitglm(tmpData, 'avgPupilSize ~ riskyChoice + risky_t1');
                coeff2plot{icnd} = fit.Coefficients.Estimate(2:3);

            end

            axes(h7);
            hold on 
            plot(coeff2plot{1}(1), coeff2plot{2}(1), '.', 'Color', col2plot,...
                'MarkerSize', 25);
            axes(h8);
            hold on 
            plot(coeff2plot{1}(2), coeff2plot{2}(2), '.', 'Color', col2plot,...
                'MarkerSize', 25);

            tmpStats{itype} = [subs(isubject) 2 itype coeff2plot{1}(1) coeff2plot{1}(2);,...
                subs(isubject) 3 itype coeff2plot{2}(1) coeff2plot{2}(2)];
    end
    coeffData = [coeffData; cell2mat(tmpStats')];

    if isubject == 27

        % ttest: beta coeff > 0 for risky(t)
       [~, p_low_g, ~, stats_low_g] = ttest(coeffData(coeffData(:, 2)==2 & coeffData(:, 3) ==1, 4));
       [~, p_low_b, ~, stats_low_b] = ttest(coeffData(coeffData(:, 2)==2 & coeffData(:, 3) ==2, 4));
       [~, p_high_g, ~, stats_high_g] = ttest(coeffData(coeffData(:, 2)==3 & coeffData(:, 3) ==1, 4));
       [~, p_high_b, ~, stats_high_b] = ttest(coeffData(coeffData(:, 2)==3 & coeffData(:, 3) ==2, 4));
       % ttest: beta coeff > 0 for risky(t-1)
       [~, p_low_gt1, ~, stats_low_gt1] = ttest(coeffData(coeffData(:, 2)==2 & coeffData(:, 3) ==1, 5));
       [~, p_low_bt1, ~, stats_low_bt1] = ttest(coeffData(coeffData(:, 2)==2 & coeffData(:, 3) ==2, 5));
       [~, p_high_gt1, ~, stats_high_gt1] = ttest(coeffData(coeffData(:, 2)==3 & coeffData(:, 3) ==1, 5));
       [~, p_high_bt1, ~, stats_high_bt1] = ttest(coeffData(coeffData(:, 2)==3 & coeffData(:, 3) ==2, 5));


    end

end

coeffData = array2table(coeffData);
coeffData.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'risk_t', 'risk_t1'};

lowCoeffs = coeffData(coeffData.cndIdx ==2, :);
highCoeffs = coeffData(coeffData.cndIdx ==3, :);

axes(h7);
axis square 
xlim([-2 1.5]);
ylim([-2 1.5]);
x2plot = linspace(-2, 1.5);
hold on 
plot(x2plot, x2plot, 'k-');
hold on 
plot([0 0], [-2 1.5], 'k--');
plot([-2 1.5], [0 0], 'k--');
xlabel('\fontsize{12} \bfBoth-LOW');
ylabel('\fontsize{12} \bfBoth-HIGH');
title('\fontsize{14} \bf RiskyChoice(t)');
set(gca, 'FontName', 'times');
axes(h8);
axis square 
xlim([-2 2]);
ylim([-2 2]);
x2plot = linspace(-2, 2);
hold on 
plot(x2plot, x2plot, 'k-');
hold on 
plot([0 0], [-2 2], 'k--');
plot([-2 2], [0 0], 'k--');
xlabel('\fontsize{12} \bfBoth-LOW');
ylabel('\fontsize{12} \bfBoth-HIGH');
title('\fontsize{14} \bf RiskyChoice(t-1)');
set(gca, 'FontName', 'times');

glmeData_2save = glmeData(:, [1:8, 10:13]);
fileName = ['stim_pupilSize_prevChoice.csv'];
writetable(glmeData_2save, fileName, 'Delimiter', ',', 'WriteVariableNames', 1);

figName = ['coeffs_presentPrevious_riskyChoice']
print(figName, '-dpng');

t1_data2plot_risk = cell(2, 2);
t1_data2plot_safe = cell(2, 2);
figure(3);
set(gcf, 'Units', 'Centimeters');
h5 = subplot(2, 1, 1);
h6 = subplot(2, 1, 2);

for icnd = 1:2

    for itype = 1:2

        trIdx = [];
        trIdx = find([glmeData.cndIdx == cnd2run(icnd)] & [glmeData.distType == itype]);

        % indices for previous risky choice
        riskVec = [];
        riskVec = glmeData.risky_t1(trIdx);

        t1_data2plot_risk{icnd, itype} = [t1_data2plot_risk{icnd, itype}; cell2mat(glmeData.stim_aligned_pupil(trIdx(riskVec == 1))')'];        
        t1_data2plot_safe{icnd, itype} = [t1_data2plot_safe{icnd, itype}; cell2mat(glmeData.stim_aligned_pupil(trIdx(riskVec == 0))')'];

            if itype == 1                   
                   col2plot_alpha = [0.7059 0.4745 0.9882];
            else 
                    col2plot_alpha = [0.3961 0.9608 0.3647]
            end
        

        if icnd == 1
            axes(h5); %both-LOW: z score 
            hold on
        else 
            axes(h6); %both-HIGH: z score 
            hold on
        end

        plot(timeVec, nanmean(t1_data2plot_risk{icnd, itype}), '-', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(t1_data2plot_risk{icnd, itype})./sqrt(length(t1_data2plot_risk{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(t1_data2plot_risk{icnd, itype}) + tmpSem,...
            fliplr([nanmean(t1_data2plot_risk{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);
        hold on 
        plot(timeVec, nanmean(t1_data2plot_safe{icnd, itype}), '--', 'color', col2plot_alpha, 'linew', 2);
        tmpSem = [];
        tmpSem = nanstd(t1_data2plot_safe{icnd, itype})./sqrt(length(t1_data2plot_safe{icnd, itype}));
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [nanmean(t1_data2plot_safe{icnd, itype}) + tmpSem,...
            fliplr([nanmean(t1_data2plot_safe{icnd, itype})- tmpSem])];
        fill(x2plot, error2plot, col2plot_alpha, 'linestyle', 'none');
        alpha(0.25);
      
    end

end

axes(h5);
axis square
title({' \fontsize{16} \bfzScore Pupil', '\fontsize{12} Both-LOW'});
ylabel({'Pupil Response', '(% Response Change)'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-0.8 0.5]);
hold on 
plot([0 0], [-0.8 0.5], 'k-');
hold on 
plot([0.8 0.8], [-0.8 0.5], 'k-');
set(gca, 'FontName', 'times');

axes(h6);
axis square
title({'\fontsize{12} \bfBoth-HIGH'});
ylabel({'Pupil Response', '(% Response Change)'});
xlabel('Time from Stimulus Onset (\its)');
hold on 
ylim([-0.8 0.5]);
hold on 
plot([0 0], [-0.8 0.5], 'k-');
hold on 
plot([0.8 0.8], [-0.8 0.5], 'k-');
set(gca, 'FontName', 'times');

figure(4);
t1_meanStats = [];

for isubject = 1: length(subs)

    subIdx  = [];
    subIdx  = find(glmeData.subIdx == subs(isubject));
    subData = glmeData(subIdx, :);
    tmpCnd   = [];

    for icnd = 1:2

        if icnd == 1 
            x2plot = [1 1.5; 2 2.5];
        else 
            x2plot = [3.5 4; 4.5 5];
        end

        for itype = 1:2

            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
                col2plot_alpha = [0.9255    0.8039    0.9804];
            else
                col2plot = [0.3961 0.9608 0.3647];
                col2plot_alpha = [ 0.7176    0.9882    0.7020];
            end

            trIdx = [];
            trIdx = find([subData.cndIdx == cnd2run(icnd)] & [subData.distType == itype]);
    
            riskVec = [];
            riskVec = subData.risky_t1(trIdx);

            tmpData = [];
            tmpData = cell2mat(subData.stim_aligned_pupil(trIdx(riskVec == 1))')';
            if ~isempty(tmpData)
                t1_meanPupil_risk{icnd, itype}(isubject) = nanmean(nanmean(tmpData(:, [26:66])));
            else 
                t1_meanPupil_risk{icnd, itype}(isubject) = NaN;
            end
            
            tmpData = [];
            tmpData = cell2mat(subData.stim_aligned_pupil(trIdx(riskVec ~= 1))')';
            if ~isempty(tmpData)
                t1_meanPupil_safe{icnd, itype}(isubject) = nanmean(nanmean(tmpData(:, [26:66])));
            else 
                t1_meanPupil_safe{icnd, itype}(isubject) = NaN;
            end

            figure(4);
            hold on 
            plot(x2plot(itype,1), t1_meanPupil_risk{icnd, itype}(isubject), '.', 'color', col2plot_alpha,...
                'MarkerSize', 25);
            plot(x2plot(itype,2), t1_meanPupil_safe{icnd, itype}(isubject), '.', 'color', col2plot_alpha,...
                'MarkerSize', 25);
            hold on

            if isubject == 27

                t1_allMean_risk(icnd, itype) = nanmean(t1_meanPupil_risk{icnd, itype});
                t1_allMean_safe(icnd, itype) = nanmean(t1_meanPupil_safe{icnd, itype});

                t1_allSEM_risk(icnd, itype) = nanstd(t1_meanPupil_risk{icnd, itype})./sqrt(length(t1_meanPupil_risk{icnd, itype}));
                t1_allSEM_safe(icnd, itype) = nanstd(t1_meanPupil_safe{icnd, itype})./sqrt(length(t1_meanPupil_safe{icnd, itype}));

                hold on 
                errorbar(x2plot(itype, 1), t1_allMean_risk(icnd, itype), t1_allSEM_risk(icnd, itype), 's',...
                    'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color',col2plot, 'linew', 1.2);
            
                 errorbar(x2plot(itype, 2), t1_allMean_safe(icnd, itype), t1_allSEM_safe(icnd, itype), 's',...
                    'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color', col2plot, 'linew', 1.2);
                hold on
            end

            tmpStats{itype} = [subs(isubject) cnd2run(icnd) itype 1 t1_meanPupil_risk{icnd, itype}(isubject);
                subs(isubject) cnd2run(icnd) itype 2 t1_meanPupil_safe{icnd, itype}(isubject)];
        end

            tmpCnd           = [tmpCnd; cell2mat(tmpStats')];
    end
            t1_meanStats        = [t1_meanStats; tmpCnd];
end

figure(4);
xlim([0 6]);
ylim([-1.5 1]);
set(gca, 'XTick', [1 1.5 2 2.5 3.5 4 4.5 5]);
set(gca, 'XTickLabelRotation', 45);
set(gca, 'XTickLabel', {'LOW-Risky', 'LOW-Safe', 'LOW-Risky', 'LOW-Safe', 'HIGH-Risky', 'HIGH-Safe', 'HIGH-Risky', 'HIGH-Safe'})
hold on 
plot([3 3], [-1.5 1], 'k-');
ylabel({'Average Pupil Response', '(% Response Change)'});
set(gca, 'FontName', 'times');


figure(5);
for icnd = 1:2

     if icnd == 1 
            x2plot = [1 1.5; 2 2.5];
        else 
            x2plot = [3.5 4; 4.5 5];
     end

    for itype = 1:2

            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
               
            else
                col2plot = [0.3961 0.9608 0.3647];
               
            end

            hold on
            errorbar(x2plot(itype, 1), allMean_risk(icnd, itype), allSEM_risk(icnd, itype), 'o',...
                'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color',col2plot, 'linew', 1.2);

            errorbar(x2plot(itype, 2), allMean_safe(icnd, itype), allSEM_safe(icnd, itype), 'o',...
                'MarkerFaceColor', col2plot, 'MarkerSize', 12, 'Color', col2plot, 'linew', 1.2);
                   hold on
            errorbar(x2plot(itype, 1), t1_allMean_risk(icnd, itype), t1_allSEM_risk(icnd, itype), 'o',...
                'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', col2plot,'MarkerSize', 12,...
                'Color',col2plot, 'linew', 1.2);

            errorbar(x2plot(itype, 2), t1_allMean_safe(icnd, itype), t1_allSEM_safe(icnd, itype), 'o',...
                'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', col2plot, 'MarkerSize', 12,...
                'Color', col2plot, 'linew', 1.2);



    end
end

figure(5);
xlim([0 6]);
ylim([-0.8 0]);
set(gca, 'XTick', [1 1.5 2 2.5 3.5 4 4.5 5]);
set(gca, 'XTickLabelRotation', 45);
set(gca, 'XTickLabel', {'LOW-Risky', 'LOW-Safe', 'LOW-Risky', 'LOW-Safe', 'HIGH-Risky', 'HIGH-Safe', 'HIGH-Risky', 'HIGH-Safe'})
hold on 
plot([3 3], [-0.8 0], 'k-');
ylabel({'Average Pupil Response', '(% Response Change)'});
legend({'Gaussian(t)', '', 'Gaussian(t-1)', '', 'Bimodal(t)', '', 'Bimodal(t-1)'}, 'location', 'southwest');
title({'\fontsize{12} \bf Influence of Risky Choices on Pupil Diameter', 'Present and Previous Choices'});
set(gca, 'FontName', 'times');

saveFigname = ['pupilSize_present_prevRisk'];
print(saveFigname, '-dpng');


end


