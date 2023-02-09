function phasic_win(base_path, dataIn)
% plots trial averaged derivative pupil series separately for each reward
% distribution 
% collapsed across blocks 
% statistical analysis: timepoint at which derivative significantly differs
% from 0 --> first peak 
% statistical analysis carried out for each of the relevant event epochs 
% windows returned: used for calculation of the phasic pupil response for
% further analyses
% only focus on both-high/both-low trial
cndIdx2run = [2 3];
cndIdx = find([dataIn.cndIdx] == 2 | [dataIn.cndIdx] == 3);
data2use = dataIn(cndIdx, :);

figure(1);
hs = subplot(1, 3, 1);
hc = subplot(1, 3, 2);
hf = subplot(1, 3, 3);
for itype = 1:2
    
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

        epochWin = [0 0.8];

        if iepoch == 1 % stimulus 
            timeVec = linspace(-0.5, 1, 76);
            
        elseif iepoch == 2 % choice 
            timeVec = linspace(-0.2, 1.5, 86);
            
        elseif iepoch == 3 % feedback 
            timeVec = linspace(-0.2, 1.5, 86);

        end

        % index trials where risky vs safe choices were made
        riskIdx     = dataSplit.riskyChoice == 1;
        safeIdx     = dataSplit.riskyChoice ~= 1;
        data2run    = [];
        if iepoch == 1
            stim_risky  = dataSplit.stim_derivative(riskIdx, :);
            stim_safe   = dataSplit.stim_derivative(safeIdx, :);
            % collapse all epoch relevant data
            data2run    = [cell2mat(stim_risky') cell2mat(stim_safe')];

        elseif iepoch == 2 
            choice_risky = dataSplit.choice_derivative(riskIdx, :);
            choice_safe  = dataSplit.choice_derivative(safeIdx, :);
            data2run     = [cell2mat(choice_risky') cell2mat(choice_safe')];

%             allChoice_risky{icnd} = [allChoice_risky; choice_risky];
%             allChoice_safe{icnd}  = [allChoice_safe; choice_safe];

        elseif iepoch == 3
            feedback_risky = dataSplit.feedback_derivative(riskIdx, :);
            feedback_safe = dataSplit.feedback_derivative(safeIdx, :);
            
            feedback_risky(cellfun(@(feedback_risky) any(isnan(feedback_risky)),feedback_risky)) = [];
            feedback_safe(cellfun(@(feedback_safe) any(isnan(feedback_safe)),feedback_safe)) = [];

            data2run   = [cell2mat(feedback_risky') cell2mat(feedback_safe')];


        end

      
        % statistical analyses
        timeIdx    = [];
        timeIdx(1) = find(timeVec == epochWin(1));
        timeIdx(2) = find(timeVec == epochWin(2));
        
        
        % identify data from the epoch specific time window
        data2run   = data2run((timeIdx(1): timeIdx(2)), :)';
        
        grIdx       = [];
        h           = [];

        for itime = 1: size(data2run, 2)
        
            grIdx(itime)        = nanmean(data2run(:, itime)) >= 0;
            [h(itime), ~, ~, ~] = ttest(data2run(:, itime));
        
            meanVal(itime)       = nanmean(data2run(:, itime));
        end

        % identify time window where values greater than 0, if this returns
        % the entire epochWin then apply the secondary restriction
        % criteria: restriction to the first epoch where values are greater
        % than 1

        epochWindow = [];
        epochWindow = linspace(epochWin(1), epochWin(2), size(data2run, 2));

        %identify timestamp for 1st significantly greater than 0 value 
        tmpStampIdx = grIdx == h;
        tmpphasicStart = epochWindow(tmpStampIdx);
        phasicEpoch{itype}(iepoch, 1) = tmpphasicStart(1);

        %identify first peak value
        maxIdx      = max(meanVal(tmpStampIdx));
        maxIdx      = meanVal == maxIdx;

        phasicEpoch{itype}(iepoch, 2) = epochWindow(maxIdx);
        
    end


mean_stim_risky{itype} = nanmean(cell2mat(stim_risky')');
sem_stim_risky{itype}  = nanstd(cell2mat(stim_risky')')./sqrt(length(cell2mat(stim_risky')'));

mean_stim_safe{itype} = nanmean(cell2mat(stim_safe')');
sem_stim_safe{itype}  = nanstd(cell2mat(stim_safe')')./sqrt(length(cell2mat(stim_safe')'));

mean_choice_risky{itype} = nanmean(cell2mat(choice_risky')');
sem_choice_risky{itype}  = nanstd(cell2mat(choice_risky')')./sqrt(length(cell2mat(choice_risky')'));

mean_choice_safe{itype} = nanmean(cell2mat(choice_safe')');
sem_choice_safe{itype}  = nanstd(cell2mat(choice_safe')')./sqrt(length(cell2mat(choice_safe')'));

feedback_risky(cellfun(@(feedback_risky) any(isnan(feedback_risky)),feedback_risky)) = [];
feedback_safe(cellfun(@(feedback_safe) any(isnan(feedback_safe)),feedback_safe)) = [];

mean_resp_risky{itype} = nanmean(cell2mat(feedback_risky')');
sem_resp_risky{itype}  = nanstd(cell2mat(feedback_risky')')./sqrt(length(cell2mat(feedback_risky')'));

mean_resp_safe{itype} = nanmean(cell2mat(feedback_safe')');
sem_resp_safe{itype}  = nanstd(cell2mat(feedback_safe')')./sqrt(length(cell2mat(feedback_safe')'));


%%% plot pupil aligned to stimulus onset
axes(hs);
hold on
stim_timeVec = linspace(-0.5, 1, 76);
plot(stim_timeVec, mean_stim_risky{itype}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_risky{itype} + sem_stim_risky{itype},...
    fliplr([mean_stim_risky{itype}- sem_stim_risky{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(stim_timeVec, mean_stim_safe{itype}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_stim_safe{itype} + sem_stim_safe{itype},...
    fliplr([mean_stim_safe{itype}- sem_stim_safe{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);

%%% plot pupil aligned to choice onset
axes(hc);
hold on
stim_timeVec = linspace(-0.5, 1, 76);
plot(stim_timeVec, mean_choice_risky{itype}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_choice_risky{itype} + sem_choice_risky{itype},...
    fliplr([mean_choice_risky{itype}- sem_choice_risky{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(stim_timeVec, mean_choice_safe{itype}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [stim_timeVec fliplr(stim_timeVec)];
error2plot = [mean_choice_safe{itype} + sem_choice_safe{itype},...
    fliplr([mean_choice_safe{itype}- sem_choice_safe{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);


%%% plot pupil aligned to response feedback
axes(hf);
hold on
resp_timeVec = linspace(-0.2, 1.5, 86);
plot(resp_timeVec, mean_resp_risky{itype}, 'color', col2plot, 'lineStyle', '-', 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_risky{itype} + sem_resp_risky{itype},...
    fliplr([mean_resp_risky{itype}- sem_resp_risky{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);
hold on
plot(resp_timeVec, mean_resp_safe{itype}, 'color', col2plot, 'lineStyle', '--', 'linew', 1.2);
hold on
x2plot = [resp_timeVec fliplr(resp_timeVec)];
error2plot = [mean_resp_safe{itype} + sem_resp_safe{itype},...
    fliplr([mean_resp_safe{itype}- sem_resp_safe{itype}])];
fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
alpha(0.25);

max_stim_safe(itype)= max(max(mean_stim_safe{itype}));
max_stim_risk(itype)= max(max(mean_stim_risky{itype}));
min_stim_safe(itype)= min(min(mean_stim_safe{itype}));
min_stim_risk(itype)= min(min(mean_stim_risky{itype}));

max_resp_safe(itype)= max(max(mean_resp_safe{itype}));
max_resp_risk(itype)= max(max(mean_resp_risky{itype}));
min_resp_safe(itype)= min(min(mean_resp_safe{itype}));
min_resp_risk(itype)= min(min(mean_resp_risky{itype}));


end

% identify phasic pupil window 
for iepoch = 1:3
    %identify overlap between the two distributions 
    winStart(iepoch) = max([phasicEpoch{1}(iepoch, 1) phasicEpoch{2}(iepoch, 1) ]);
    winEnd(iepoch) = max([phasicEpoch{1}(iepoch, 2) phasicEpoch{2}(iepoch, 2) ]);
end

winStart(2) = -0.5;
winEnd(2) = 0;

max_mean = max([max_stim_safe max_stim_risk max_resp_safe max_resp_risk]);
min_mean = min([min_stim_safe min_stim_risk min_resp_safe min_resp_risk]);

axes(hs);
axis square
xlim([-0.5 1]);
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlabel('\bfTime from Stimulus Onset (ms)');
ylabel({'\fontsize{11} \rmPupil Response', '(% Signal Change)'});
title('\fontsize{12}Stimulus Aligned');
hold on 
plot([winStart(1) winEnd(1)], [min_mean-0.1  min_mean-0.1], 'k-', 'linew', 4)
legend({'', '', '', '', '', '', '', '', 'StimOnMIN', 'StimGO', ''}, 'location', 'northwest');
set(gca, 'FontName', 'times');

axes(hc);
axis square
xlim([-0.5 1]);
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlabel('\bfTime from Choice Onset (ms)');
title('\fontsize{12}Choice Aligned');
hold on 
plot([winStart(2) winEnd(2)], [min_mean-0.1  min_mean-0.1], 'k-', 'linew', 4)
legend({'', '', '', '', '', '', '', '', 'Repsonse', 'Delay', ''}, 'location', 'northwest');
set(gca, 'FontName', 'times');


axes(hf);
axis square
set(hf, 'YAxisLocation', 'right');
hold on
ylim([min_mean-0.1 max_mean+0.025]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlim([-0.2 1.5]);
xlabel('\bfTime from Feedback Onset (ms)');
title('\fontsize{12}Feedback Aligned');
hold on 
plot([winStart(3) winEnd(3)], [min_mean-0.1  min_mean-0.1], 'k-', 'linew', 4)
legend({'', '', '', '', '', '', '', '', 'TotalShown', 'StimulusFeedback', ''}, 'location', 'northwest');
set(gca, 'FontName', 'times');

saveFolder = ['stimulus_phasicPupilBins'];
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [4.1275 4.8683 36.0468 12.2767]);

saveFigname = ['derivative_phasicDefined'];
print(saveFigname, '-dpng');

end
