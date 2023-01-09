function plot_eyeData_riskPref_x_dist_individual(dataIn, saveLoc)
clf;
% plots the z-score pupil data for each of the three relevant epochs: 
% - stimulus 
% - choice 
% - feedback 
% subplots for each of the 4 blocks 
% plots further split according to distribution type (gaussian VS bimodal)
% and risk preference (risky VS safe)

for blockNum = 1:4

if blockNum == 1
    hs = axes('position', [0.05 0.6 0.12 0.35]);
    hc = axes('position', [0.18 0.6 0.12 0.35]);
    hf = axes('position', [0.31 0.6 0.15 0.35]);
elseif blockNum == 2
    hs = axes('position', [0.55 0.6 0.12 0.35]);
    hc = axes('position', [0.68 0.6 0.12 0.35]);
    hf = axes('position', [0.81 0.6 0.15 0.35]);
elseif blockNum == 3
    hs = axes('position', [0.05 0.1 0.12 0.35]);
    hc = axes('position', [0.18 0.1 0.12 0.35]);
    hf = axes('position', [0.31 0.1 0.15 0.35]);
elseif blockNum == 4
    hs = axes('position', [0.55 0.1 0.12 0.35]);
    hc = axes('position', [0.68 0.1 0.12 0.35]);
    hf = axes('position', [0.81 0.1 0.15 0.35]);
end


% identify trials from first block that were gaussian and bimodal
% separately

blockIdx = find([dataIn.blockNum == blockNum]);
data2use = dataIn(blockIdx, :);

%%%% load in relevant eyedata files

allStim_risky       = [];
allStim_safe        = [];
allChoice_risky     = [];
allChoice_safe      = [];
allFeedback_risky   = [];
allFeedback_safe    = [];

% only focus on both-high/both-low trial
cndIdx2run = [2 3];
cndIdx = find([data2use.cndIdx] == 2 | [data2use.cndIdx] == 3);
data2use = data2use(cndIdx, :);
itype = data2use.distType(1);

    if itype == 1 
        col2plot = [0.7059 0.4745 0.9882];
    else 
        col2plot = [0.3961 0.9608 0.3647];
    end

    distIdx = find([data2use.distType] == itype);
    dataSplit = data2use(distIdx, :);
    
    stim_risky = [];
    resp_risky = [];
    stim_safe = [];
    resp_safe = [];
    
    for iepoch = 1:3
        % index trials where risky vs safe choices were made
        riskIdx = dataSplit.riskyChoice == 1;
        safeIdx = dataSplit.riskyChoice ~= 1;

        if iepoch == 1
            stim_risky = dataSplit.stim_aligned_pupil(riskIdx, :);
            stim_safe = dataSplit.stim_aligned_pupil(safeIdx, :);

%             allStim_risky = [allStim_risky cell2mat(stim_risky)];
%             allStim_safe  = [allStim_safe cell2mat(stim_safe)];

        elseif iepoch == 2 
            choice_risky = dataSplit.choice_aligned_pupil(riskIdx, :);
            choice_safe = dataSplit.choice_aligned_pupil(safeIdx, :);
            
%             allChoice_risky{icnd} = [allChoice_risky; choice_risky];
%             allChoice_safe{icnd}  = [allChoice_safe; choice_safe];

        elseif iepoch == 3
            feedback_risky = dataSplit.feedback_aligned_pupil(riskIdx, :);
            feedback_safe = dataSplit.feedback_aligned_pupil(safeIdx, :);

        end
    end

mean_stim_risky{blockNum}   = nanmean(cell2mat(stim_risky')');
sem_stim_risky{blockNum}    = nanstd(cell2mat(stim_risky')')./sqrt(length(cell2mat(stim_risky')'));

mean_stim_safe{blockNum}    = nanmean(cell2mat(stim_safe')');
sem_stim_safe{blockNum}     = nanstd(cell2mat(stim_safe')')./sqrt(length(cell2mat(stim_safe')'));

mean_choice_risky{blockNum} = nanmean(cell2mat(choice_risky')');
sem_choice_risky{blockNum}  = nanstd(cell2mat(choice_risky')')./sqrt(length(cell2mat(choice_risky')'));

mean_choice_safe{blockNum} = nanmean(cell2mat(choice_safe')');
sem_choice_safe{blockNum}   = nanstd(cell2mat(choice_safe')')./sqrt(length(cell2mat(choice_safe')'));

mean_resp_risky{blockNum}   = nanmean(cell2mat(feedback_risky')');
sem_resp_risky{blockNum}    = nanstd(cell2mat(feedback_risky')')./sqrt(length(cell2mat(feedback_risky')'));

mean_resp_safe{blockNum}    = nanmean(cell2mat(feedback_safe')');
sem_resp_safe{blockNum}     = nanstd(cell2mat(feedback_safe')')./sqrt(length(cell2mat(feedback_safe')'));

if ~isnan(mean_stim_risky{blockNum}) & length(mean_stim_risky{blockNum}) > 2
%%% plot pupil aligned to stimulus onset
axes(hs);
hold on
stim_timeVec = linspace(-0.5, 1, 76);
plot(stim_timeVec, mean_stim_risky{blockNum}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_risky{blockNum} + sem_stim_risky{blockNum},...
    fliplr([mean_stim_risky{blockNum}- sem_stim_risky{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(stim_timeVec, mean_stim_safe{blockNum}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_safe{blockNum} + sem_stim_safe{blockNum},...
    fliplr([mean_stim_safe{blockNum}- sem_stim_safe{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);

%%% plot pupil aligned to choice onset
axes(hc);
hold on
stim_timeVec = linspace(-0.5, 1, 76);
plot(stim_timeVec, mean_choice_risky{blockNum}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_choice_risky{blockNum} + sem_choice_risky{blockNum},...
    fliplr([mean_choice_risky{blockNum}- sem_choice_risky{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(stim_timeVec, mean_choice_safe{blockNum}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_choice_safe{blockNum} + sem_choice_safe{blockNum},...
    fliplr([mean_choice_safe{blockNum}- sem_choice_safe{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);


%%% plot pupil aligned to response feedback
axes(hf);
hold on
resp_timeVec = linspace(-0.2, 1.5, 86);
plot(resp_timeVec, mean_resp_risky{blockNum}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_risky{blockNum} + sem_resp_risky{blockNum},...
    fliplr([mean_resp_risky{blockNum}- sem_resp_risky{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(resp_timeVec, mean_resp_safe{blockNum}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_safe{blockNum} + sem_resp_safe{blockNum},...
    fliplr([mean_resp_safe{blockNum}- sem_resp_safe{blockNum}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);

max_stim_safe = max(max(mean_stim_safe{blockNum}));
max_stim_risk = max(max(mean_stim_risky{blockNum}));
min_stim_safe = min(min(mean_stim_safe{blockNum}));
min_stim_risk = min(min(mean_stim_risky{blockNum}));

max_resp_safe = max(max(mean_resp_safe{blockNum}));
max_resp_risk = max(max(mean_resp_risky{blockNum}));
min_resp_safe = min(min(mean_resp_safe{blockNum}));
min_resp_risk = min(min(mean_resp_risky{blockNum}));

max_mean = max([max_stim_safe max_stim_risk max_resp_safe max_resp_risk]);
min_mean = min([min_stim_safe min_stim_risk min_resp_safe min_resp_risk]);

axes(hs);
xlim([-0.5 1]);
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlabel('\bfTime from Stimulus Onset (ms)');
ylabel({['\fontsize{14} \bfBLOCK ' num2str(blockNum)],'\fontsize{11} \rmPupil Response', '(% Signal Change)'});
title('\fontsize{12}Stimulus Aligned');
if blockNum == 1

    legend({'', '', '', '', 'StimOnMIN', 'StimGO'}, 'location', 'northwest');

end

set(gca, 'FontName', 'times');

axes(hc);
xlim([-0.5 1]);
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlabel('\bfTime from Stimulus Onset (ms)');
title('\fontsize{12}Choice Aligned');
if blockNum == 1
    legend({'', '', '', '', 'Repsonse', 'Delay'}, 'location', 'northwest');
end
set(gca, 'FontName', 'times');


axes(hf);
set(hf, 'YAxisLocation', 'right');
hold on
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlim([-0.2 1.5]);
xlabel('\bfTime from Feedback Onset (ms)');
title('\fontsize{12}Feedback Aligned');
if blockNum == 1
    legend({'', '', '', '', 'TotalShown', 'StimulusFeedback'}, 'location', 'northwest');
end
set(gca, 'FontName', 'times');
end
end

cd([saveLoc]);
figure(1);
set(gcf, 'Units', 'centimeters');
set(gcf, 'position', [53.5093 -3.2385 40.3013 21.0185]);
saveFilename = ['RiskyChoiceSplit_distDivided'];
set(gcf, 'PaperOrientation', 'Landscape')
print(saveFilename,'-dpng');
print(saveFilename, '-bestfit', '-dpdf');


end


