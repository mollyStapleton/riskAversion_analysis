function [epoch_stim, epoch_choice, epoch_feedback] = plot_eyeData(dataIn_eye, dataIn_behav, blockNum, generate_xlsx_full)

%     subplot(2, 2, blockNum);
idx = find(dataIn_behav.blockNumber == blockNum);
behav2use = dataIn_behav(idx, :);
xlsx_full = [];

noRespIdx = behav2use.RT==0;
behav2use(noRespIdx, :) = [];

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

%     if blockNum == 1
%         hr = subplot(2, 2, 1);
%     elseif blockNum == 2
%         hr = subplot(2, 2, 2);
%     elseif blockNum == 3
%         hr = subplot(2, 2, 3);
%     elseif blockNum == 4
%         hr = subplot(2, 2, 4);
%     end


%identify condition
% for icnd = 1:3

    respMade = [];
%     if icnd == 1
%         col2plot = 'k';
%     elseif icnd == 2
%         col2plot = 'b';
%     elseif icnd == 3
%         col2plot = 'r';
%     end

    cndIdx = find(behav2use.cnd_idx == icnd);
    trials2use = behav2use.trialNum(cndIdx);

    % initialise structures for eye data

    % [-0.5: stim on min: 1s]
    epoch_stim.aligned_pupil{icnd} = NaN(length(trials2use), 76);
    epoch_stim.aligned_timeVec{icnd} = NaN(length(trials2use), 76);
    epoch_stim.preResp_pupil{icnd} = NaN(length(trials2use), 26);
    epoch_stim.prtileResp_pupil{icnd} = NaN(length(trials2use), 1);
    epoch_stim.derivative{icnd} =  NaN(length(trials2use), 76);

    % [-0.2: response: 1s]
    epoch_choice.aligned_pupil{icnd} = NaN(length(trials2use), 76);
    epoch_choice.aligned_timeVec{icnd} = NaN(length(trials2use), 76);
    epoch_choice.preResp_pupil{icnd} = NaN(length(trials2use), 26);
    epoch_choice.prtileResp_pupil{icnd} = NaN(length(trials2use), 1);
    epoch_choice.derivative{icnd} =  NaN(length(trials2use), 76);

    % [-0.2: choiceIndicate: 1.5s]
    epoch_feedback.aligned_pupil{icnd} = NaN(length(trials2use), 86);
    epoch_feedback.aligned_timeVec{icnd} = NaN(length(trials2use), 86);
    epoch_feedback.preResp_pupil{icnd} = NaN(length(trials2use), 106);
    epoch_feedback.prtileResp_pupil{icnd} = NaN(length(trials2use), 1);
    epoch_feedback.derivative{icnd} =  NaN(length(trials2use), 86);

    for iepoch = 1:3

        if iepoch == 1

            alignIdx  = 14; %stimOnMin
            epochStart  = -0.5;
            epochEnd    = 1;
            phasicStart = -0;
            phasicEnd   = 0.5; %500ms from stimOnMin

        elseif iepoch == 2

            alignIdx  = 25; %response
            epochStart  = -0.5;
            epochEnd    = 1;
            phasicStart = -0.5; %500ms before response
            phasicEnd   = 0;

        elseif iepoch == 3

            alignIdx  = 30; %choiceIndicated
            epochStart  = -0.2;
            epochEnd    = 1.5;
            phasicStart = -0.8;
            phasicEnd   = 1.3; %500ms from reward feedback


        end

        for itrial = 1: length(trials2use)

            data2use   = dataIn_eye(trials2use(itrial)).data;
            %single event when button is pressed indicating choice
            respIdx = find([data2use(:, 3)] == 25);

            if ~isempty(respIdx) %only look at trials where a response was made

                if iepoch == 1 || iepoch == 3
                    alignPoint = find([data2use(:, 3) == alignIdx], 1);
                else 
                    alignPoint = find([data2use(:, 3) == alignIdx]);
                end
                aligned_timevec = [];
                aligned_timevec = (data2use(:, 2) - data2use(alignPoint(1), 2));
                % deals with duplicate timestamps
                id = diff(aligned_timevec);
                id = find(id == 0);
                id = id +1;

                aligned_timevec(id) = [];
                data2use(id, :) = [];

                % checks main event in epoch is still in the same
                % place after removal of duplicates
                if iepoch == 1
                    alignPoint = find([data2use(:, 2) == 14], 1); %stimOnMin
                elseif iepoch == 2
                    alignPoint = find([data2use(:, 3) == 25]); %response
                elseif iepoch == 3
                    alignPoint = find([data2use(:, 3) == 30], 1); %choiceIndicated
                end

                normPupil{itrial} = data2use(:, 4);

                %--------------------------------------------------------
                % Z-SCORE PUPIL RESPONSE
                %--------------------------------------------------------------------

                [ d, ix ] = min( abs( aligned_timevec - epochStart) ); % -0.5s
                tmpIdx(1) = ix;
                [ d, ix ] = min( abs( aligned_timevec - epochEnd) );   % + 1s
                tmpIdx(2) = ix;

                
                    checkTrialValidity = length(tmpIdx(1): tmpIdx(2));
                    if checkTrialValidity < 86 && iepoch ==3 
    
                        continue;
    
                    else

                if iepoch == 1
                    % aligned time data and pupil series
                    epoch_stim.aligned_timeVec{icnd}(itrial, :) = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    epoch_stim.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(tmpIdx(1): tmpIdx(2));

                elseif iepoch == 2
                    epoch_choice.aligned_timeVec{icnd}(itrial, :) = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    epoch_choice.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(tmpIdx(1): tmpIdx(2));

                elseif iepoch == 3
                    epoch_feedback.aligned_timeVec{icnd}(itrial, :) = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    epoch_feedback.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(tmpIdx(1): tmpIdx(2));
                end

                %--------------------------------------------------------
                % PHASIC RESPONSE
                %--------------------------------------------------------------------

                [ d, ix ] = min( abs( aligned_timevec - phasicStart) );
                phasicIdx(1) = ix;
                [ d, ix ] = min( abs( aligned_timevec - phasicEnd) );
                phasicIdx(2) = ix;

                

                if iepoch == 1
                    epoch_stim.preResp_pupil{icnd}(itrial, :) = data2use((phasicIdx(1): phasicIdx(2)), 5);
                    % calc 95th percentile of derivative
                    epoch_stim.prtileResp_pupil{icnd}(itrial) = prctile(epoch_stim.preResp_pupil{icnd}(itrial, :), 95);
                    epoch_stim.derivative{icnd}(itrial, :) = data2use((tmpIdx(1): tmpIdx(2)), 5);
                    epoch_stim.trialNum{icnd}(1, itrial) = trials2use(itrial);

                elseif iepoch == 2
                    epoch_choice.preResp_pupil{icnd}(itrial, :) = data2use((phasicIdx(1): phasicIdx(2)), 5);
                    % calc 95th percentile of derivative
                    epoch_choice.prtileResp_pupil{icnd}(itrial) = prctile(epoch_choice.preResp_pupil{icnd}(itrial, :), 95);
                    epoch_choice.derivative{icnd}(itrial, :) = data2use((tmpIdx(1): tmpIdx(2)), 5);
                    epoch_choice.trialNum{icnd}(1, itrial) = trials2use(itrial);

                elseif iepoch == 3
                    epoch_feedback.preResp_pupil{icnd}(itrial, :) = data2use((phasicIdx(1): phasicIdx(2)), 5);
                    % calc 95th percentile of derivative
                    epoch_feedback.prtileResp_pupil{icnd}(itrial) = prctile(epoch_feedback.preResp_pupil{icnd}(itrial, :), 95);
                    epoch_feedback.derivative{icnd}(itrial, :) = data2use((tmpIdx(1): tmpIdx(2)), 5);
                    epoch_feedback.trialNum{icnd}(1, itrial) = trials2use(itrial);

                end

                end
            end

        end
    end

    %----------------------------------------------------------------
    % PLOT: EPOCH_STIMULUS
    %-----------------------------------------------------------------------
    axes(hs);
    hold on
    stim_mean_pupil{icnd} = nanmean(epoch_stim.aligned_pupil{icnd});
    stim_sem_pupil{icnd}  = nanstd(epoch_stim.aligned_pupil{icnd})./sqrt(length(epoch_stim.aligned_pupil{icnd}));

    stim_mean_deriv{icnd} = nanmean(epoch_stim.derivative{icnd});
    stim_sem_deriv{icnd}  = nanstd(epoch_stim.derivative{icnd})./sqrt(length(epoch_stim.derivative{icnd}));

    stimVector = linspace(-0.5, 1, 76);
    plot(stimVector, stim_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
    hold on
    plot(stimVector, stim_mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'lineStyle', '--');
    hold on
    x2plot = [stimVector fliplr(stimVector)];
    error2plot = [stim_mean_pupil{icnd} + stim_sem_pupil{icnd} fliplr([stim_mean_pupil{icnd} - stim_sem_pupil{icnd}])];
    error2plot_deriv = [stim_mean_deriv{icnd} + stim_sem_deriv{icnd} fliplr([stim_mean_deriv{icnd} - stim_sem_deriv{icnd}])];
    fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
    fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
    alpha(0.25);

    %----------------------------------------------------------------
    % PLOT: EPOCH_CHOICE
    %-----------------------------------------------------------------------
    axes(hc);
    hold on
    resp_mean_pupil{icnd} = nanmean(epoch_choice.aligned_pupil{icnd});
    resp_sem_pupil{icnd}  = nanstd(epoch_choice.aligned_pupil{icnd})./sqrt(length(epoch_choice.aligned_pupil{icnd}));

    resp_mean_deriv{icnd} = nanmean(epoch_choice.derivative{icnd});
    resp_sem_deriv{icnd}  = nanstd(epoch_choice.derivative{icnd})./sqrt(length(epoch_choice.derivative{icnd}));

    respVector = linspace(-0.5, 1, 76);
    plot(respVector, resp_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
    hold on
    plot(respVector, resp_mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'lineStyle', '--');
    x2plot = [respVector fliplr(respVector)];
    error2plot = [resp_mean_pupil{icnd} + resp_sem_pupil{icnd} fliplr([resp_mean_pupil{icnd} - resp_sem_pupil{icnd}])];
    error2plot_deriv = [resp_mean_deriv{icnd} + resp_sem_deriv{icnd} fliplr([resp_mean_deriv{icnd} - resp_sem_deriv{icnd}])];
    fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
    fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
    alpha(0.25);


    %----------------------------------------------------------------
    % PLOT: EPOCH_FEEDBACK
    %-----------------------------------------------------------------------
    axes(hf);
    hold on
    feedback_mean_pupil{icnd} = nanmean(epoch_feedback.aligned_pupil{icnd});
    feedback_sem_pupil{icnd}  = nanstd(epoch_feedback.aligned_pupil{icnd})./sqrt(length(epoch_feedback.aligned_pupil{icnd}));

    feedback_mean_deriv{icnd} = nanmean(epoch_feedback.derivative{icnd});
    feedback_sem_deriv{icnd}  = nanstd(epoch_feedback.derivative{icnd})./sqrt(length(epoch_feedback.derivative{icnd}));

    feedbackVector = linspace(-0.2, 1.5, 86);
    plot(feedbackVector, feedback_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
    hold on
    plot(feedbackVector, feedback_mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'lineStyle', '--');
    x2plot = [feedbackVector fliplr(feedbackVector)];
    error2plot = [feedback_mean_pupil{icnd} + feedback_sem_pupil{icnd} fliplr([feedback_mean_pupil{icnd} - feedback_sem_pupil{icnd}])];
    error2plot_deriv = [feedback_mean_deriv{icnd} + feedback_sem_deriv{icnd} fliplr([feedback_mean_deriv{icnd} - feedback_sem_deriv{icnd}])];
    fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
    fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
    alpha(0.25);


% end

max_mean = nanmax([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil) cell2mat(feedback_mean_pupil)]);
min_mean = nanmin([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil) cell2mat(feedback_mean_pupil)]);

figure(1);
set(gcf, 'Units', 'centimeters');
set(gcf, 'position', [0 0 40.6400 20.8703]);

%----------------------------------------------------------------
% EDIT AXES: EPOCH_STIMULUS
%-----------------------------------------------------------------------
axes(hs);
hold on
xlim([-0.5 1]);
ylim([min_mean-1.5 max_mean+1.5]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'g-');
xlabel('\bfTime from Stimulus Onset (s)');
title('\fontsize{12}Stimulus Aligned');
%----------------------------------------------------------------
% EDIT AXES: EPOCH_CHOICE
%-----------------------------------------------------------------------
axes(hc);
hc.YAxis.Visible = 'off';
hold on
ylim([min_mean-1.5 max_mean+1.5]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
plot([1.6 1.6], y2plot, 'k--');
xlim([-0.5 1]);
xlabel('\bfTime from Choice Onset (s)');

if behav2use.distType(1) == 1
    title({['\fontsize{12} \bfBLOCK ' num2str(blockNum) ': ' '\itGaussian'],  '\fontsize{12} \rm \bfChoice Aligned'});
else
        title({['\fontsize{12} \bfBLOCK ' num2str(blockNum) ': ' '\itBimodal'],  '\fontsize{12} \rm\bfChoice Aligned'});
end
%----------------------------------------------------------------
% EDIT AXES: EPOCH_FEEDBACK
%-----------------------------------------------------------------------
axes(hf);
hf.YAxisLocation = 'right';
hold on
ylim([min_mean-1.5 max_mean+1.5]);
y2plot = ylim;
plot([0 0], y2plot, 'k-');
plot([0.8 0.8], y2plot, 'k--');
xlim([-0.2 1.5]);
xlabel('\bfTime from Reward Onset (s)');
title('\fontsize{12}Reward Aligned');



end
