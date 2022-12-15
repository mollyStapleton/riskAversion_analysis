function plot_eyeData_cnd_blk_grouped_population(dataIn, blockNum)


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

blockIdx = find([dataIn.blockNumber == blockNum]);
data2use = dataIn(blockIdx, :);


%%%% load in relevant eyedata files

loadfilename_stim = [num2str(subIdx) '_blk' num2str(blockNum) '_allPupil_epochStim'];
load(loadfilename_stim, 'epoch_stim');
loadfilename_stim = [num2str(subIdx) '_blk' num2str(blockNum) '_allPupil_epochChoice'];
load(loadfilename_stim, 'epoch_choice');
loadfilename_stim = [num2str(subIdx) '_blk' num2str(blockNum) '_allPupil_epochFeedback'];
load(loadfilename_stim, 'epoch_feedback');

allStim_risky       = [];
allStim_safe        = [];
allChoice_risky     = [];
allChoice_safe      = [];
allFeedback_risky   = [];
allFeedback_safe    = [];

cndIdx2run = [2 3];
% only focus on both-high/both-low trials
for icnd = 1:2

    cnd2run = find([data2use.cnd_idx] == cndIdx2run(icnd));
    data2use = data2use(cnd2run, :);

    stim_risky = [];
    resp_risky = [];
    stim_safe = [];
    resp_safe = [];

    
    for iepoch = 1:3
        % index trials where risky vs safe choices were made
        riskIdx = data2use.trialNum(find([data2use.stimulus_choice] == 2 | [data2use.stimulus_choice] ==4));
        safeIdx = data2use.trialNum(find([data2use.stimulus_choice] == 1 | [data2use.stimulus_choice] ==3));

        if iepoch == 1 
            struct2use = epoch_stim;
        elseif iepoch == 2 
            struct2use = epoch_choice;
        elseif iepoch ==3 
            struct2use = epoch_feedback;
        end

        riskIdx = ismember(struct2use.trialNum{cndIdx2run(icnd)}, riskIdx);
        safeIdx = ismember(struct2use.trialNum{cndIdx2run(icnd)}, safeIdx);

        if iepoch == 1
            stim_risky = struct2use.aligned_pupil{cndIdx2run(icnd)}(riskIdx, :);
            stim_safe = struct2use.aligned_pupil{cndIdx2run(icnd)}(safeIdx, :);

            allStim_risky{icnd} = [allStim_risky; stim_risky];
            allStim_safe{icnd}  = [allStim_safe; stim_safe];

        elseif iepoch == 2 
            choice_risky = struct2use.aligned_pupil{cndIdx2run(icnd)}(riskIdx, :);
            choice_safe = struct2use.aligned_pupil{cndIdx2run(icnd)}(safeIdx, :);
            
            allChoice_risky{icnd} = [allChoice_risky; choice_risky];
            allChoice_safe{icnd}  = [allChoice_safe; choice_safe];

        elseif iepoch == 3
            feedback_risky = struct2use.aligned_pupil{cndIdx2run(icnd)}(riskIdx, :);
            feedback_safe = struct2use.aligned_pupil{cndIdx2run(icnd)}(safeIdx, :);

            allFeedback_risky{icnd} = [allFeedback_risky; feedback_risky];
            allFeedback_safe{icnd}  = [allFeedback_safe; feedback_safe]; 

        end
    end
end


mean_stim_risky{iblock, itype} = nanmean(allStim_risky);
sem_stim_risky{iblock, itype}  = nanstd(allStim_risky)./sqrt(length(allStim_risky));

mean_stim_safe{iblock, itype} = nanmean(allStim_safe);
sem_stim_safe{iblock, itype}  = nanstd(allStim_safe)./sqrt(length(allStim_safe));

mean_resp_risky{iblock, itype} = nanmean(allResp_risky);
sem_resp_risky{iblock, itype}  = nanstd(allResp_risky)./sqrt(length(allResp_risky));

mean_resp_safe{iblock, itype} = nanmean(allResp_safe);
sem_resp_safe{iblock, itype}  = nanstd(allResp_safe)./sqrt(length(allResp_safe));

%%% plot pupil aligned to stimulus onset
axes(hs);
hold on
stim_timeVec = linspace(-0.5, 1, 1501);
plot(stim_timeVec, mean_stim_risky{iblock, itype}, 'color', 'k', 'lineStyle', lin2plot, 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_risky{iblock, itype} + sem_stim_risky{iblock, itype},...
    fliplr([mean_stim_risky{iblock, itype}- sem_stim_risky{iblock, itype}])];
fill(x2plot, error2plot, 'k', 'linestyle', 'none');
alpha(0.25);
hold on
plot(stim_timeVec, mean_stim_safe{iblock, itype}, 'color', [0.75 0.75 0.75], 'lineStyle', lin2plot, 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_safe{iblock, itype} + sem_stim_safe{iblock, itype},...
    fliplr([mean_stim_safe{iblock, itype}- sem_stim_safe{iblock, itype}])];
fill(x2plot, error2plot, [0.75 0.75 0.75], 'linestyle', 'none');
alpha(0.25);

%%% plot pupil aligned to response
axes(hr);
hold on
resp_timeVec = linspace(-1, 3.1, 4101);
plot(resp_timeVec, mean_resp_risky{iblock, itype}, 'color', [0 0 0 1], 'lineStyle', lin2plot, 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_risky{iblock, itype} + sem_resp_risky{iblock, itype},...
    fliplr([mean_resp_risky{iblock, itype}- sem_resp_risky{iblock, itype}])];
fill(x2plot, error2plot, 'k', 'linestyle', 'none');
alpha(0.25);

hold on
plot(resp_timeVec, mean_resp_safe{iblock, itype}, 'color', [0.75 0.75 0.75 1], 'lineStyle', lin2plot, 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_safe{iblock, itype} + sem_resp_safe{iblock, itype},...
    fliplr([mean_resp_safe{iblock, itype}- sem_resp_safe{iblock, itype}])];
fill(x2plot, error2plot, [0.75 0.75 0.75], 'linestyle', 'none');
alpha(0.25);

max_stim_safe(itype)= max(max(mean_stim_safe{iblock, itype}));
max_stim_risk(itype)= max(max(mean_stim_risky{iblock, itype}));
min_stim_safe(itype)= min(max(mean_stim_safe{iblock, itype}));
min_stim_risk(itype)= min(max(mean_stim_risky{iblock, itype}));

max_resp_safe(itype)= max(max(mean_resp_safe{iblock, itype}));
max_resp_risk(itype)= max(max(mean_resp_risky{iblock, itype}));
min_resp_safe(itype)= min(max(mean_resp_safe{iblock, itype}));
min_resp_risk(itype)= min(max(mean_resp_risky{iblock, itype}));

max_mean = max([max_stim_safe max_stim_risk max_resp_safe max_resp_risk]);
min_mean = min([min_stim_safe min_stim_risk min_resp_safe min_resp_risk]);

figure(1);
set(gcf, 'Units', 'centimeters');
set(gcf, 'position', [10.2870 0.8255 29.7392 19.3093]);

axes(hs);
xlim([-0.5 1]);
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'g-');
xlabel('\bfTime from Stimulus Onset (ms)');
ylabel({['\fontsize{14} \bfBLOCK ' num2str(iblock)],'\fontsize{11} \rmPupil Response', '(% Signal Change)'});
title('\fontsize{12}Stimulus Aligned');
if iblock == 1

    legend({'G: Risky', '', 'G: Safe', '', 'B: Risky', '', 'B: Safe'}, 'location', 'northwest');

end

set(gca, 'FontName', 'times');

axes(hr);
set(hr, 'YAxisLocation', 'right');
hold on
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k-.');
plot([1.6 1.6], y2plot, 'k--');
xlim([-1 2.5]);
xlabel('\bfTime from Response Onset (ms)');
title('\fontsize{12}Response Aligned');
set(gca, 'FontName', 'times');


saveFilename = ['population_RiskyChoiceSplit_distDivided'];
print(saveFilename, '-dpng');
print(saveFilename, '-dpdf');

end

