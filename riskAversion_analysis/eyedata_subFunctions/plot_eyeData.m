function [normStim, normResp, xlsx_full] = plot_eyeData(dataIn_eye, dataIn_behav, blockNum, generate_xlsx_full)

%     subplot(2, 2, blockNum);
idx = find(dataIn_behav.blockNumber == blockNum);
behav2use = dataIn_behav(idx, :);
xlsx_full = [];

% noRespIdx = behav2use.RT==0;
% behav2use(noRespIdx, :) = [];

%     if blockNum == 1 
%         hs = axes('position', [0.1 0.6 0.15 0.35]);
%         hr = axes('position', [0.3 0.6 0.15 0.35]);
%     elseif blockNum == 2 
%         hs = axes('position', [0.6 0.6 0.15 0.35]);
%         hr = axes('position', [0.8 0.6 0.15 0.35]);
%     elseif blockNum == 3 
%         hs = axes('position', [0.1 0.1 0.15 0.35]);
%         hr = axes('position', [0.3 0.1 0.15 0.35]);
%     elseif blockNum == 4 
%         hs = axes('position', [0.6 0.1 0.15 0.35]);
%         hr = axes('position', [0.8 0.1 0.15 0.35]);
%     end

    if blockNum == 1 
        hr = subplot(2, 2, 1);
    elseif blockNum == 2 
        hr = subplot(2, 2, 2);
    elseif blockNum == 3 
        hr = subplot(2, 2, 3);
    elseif blockNum == 4 
        hr = subplot(2, 2, 4);
    end


    %identify condition
    for icnd = 1:3
   
        respMade = [];
        if icnd == 1 
            col2plot = 'k';
        elseif icnd == 2 
            col2plot = 'r';
        elseif icnd == 3 
            col2plot = 'b';
        end

        cndIdx = find(behav2use.cnd_idx == icnd);
        trials2use = behav2use.trialNum(cndIdx);

        % initialise structures for eye data 

        stim.aligned_pupil{icnd} = NaN(length(trials2use), 181);
        stim.aligned_timeVec{icnd} = NaN(length(trials2use),181);
        stim.preResp_pupil{icnd} = NaN(length(trials2use), 26);
        stim.prtileResp_pupil{icnd} = NaN(length(trials2use), 1);
        stim.derivative{icnd} =  NaN(length(trials2use), 181);

        resp.aligned_pupil{icnd} = NaN(length(trials2use), 197);
        resp.aligned_timeVec{icnd} = NaN(length(trials2use), 197);
        resp.preResp_pupil{icnd} = NaN(length(trials2use), 26);
        resp.prtileResp_pupil{icnd} = NaN(length(trials2use), 1);
        resp.derivative{icnd} =  NaN(length(trials2use), 197);

            for itrial = 1: length(trials2use)
        
                   data2use   = dataIn_eye(trials2use(itrial)).data;
                   
                   %single event when button is pressed indicating choice
                   respIdx = find([data2use(:, 3)] == 25);

                   if ~isempty(respIdx) %only look at trials where a response was made 
                       %first timestamp for stim on min time
                       stimOnMinIdx = find([data2use(:, 3) == 14], 1);
                       %first timestamps for stim on when pt allowed to respond 
                       stimOnGoIdx = find([data2use(:, 3) == 15], 1);

                       normPupil{itrial} = data2use(:, 4);

                       %STIMULUS DATA 
                       timeVec_stim{itrial}  =  (data2use(:, 2) - data2use(stimOnMinIdx(1), 2));
                       % -1.5 to 2s around stimulus onset
                       tmp_idx_stim          = find(timeVec_stim{1}>= -1.5 & timeVec_stim{1}<=2);

                       stim.aligned_timeVec{icnd}(itrial, :) = timeVec_stim{itrial}(tmp_idx_stim);
                       stim.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(tmp_idx_stim);

                       % look at 500ms prior to response time 
                       stim.preResp_pupil{icnd}(itrial, :) = normPupil{itrial}(stimOnMinIdx(1): stimOnMinIdx(1)+25);
                       % calc 95th percentile 
                       stim.prtileResp_pupil{icnd}(itrial) = prctile(stim.preResp_pupil{icnd}(itrial, :), 95);
                       stim.derivative{icnd}(itrial, :) = data2use(tmp_idx_stim, 5);
                       
                       %RESPONSE DATA 
                       timeVec_resp{itrial} =  data2use(:, 2) - data2use(respIdx(1), 2);

                       % -2 to 3s after response onset 
                       tmp_idx_resp          = find(timeVec_resp{1}>= -2 & timeVec_stim{1}<=3);

                       resp.aligned_timeVec{icnd}(itrial, :) = timeVec_resp{itrial}(tmp_idx_resp);
                       resp.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(tmp_idx_resp);

                       % look at 500ms prior to response time 
                       resp.preResp_pupil{icnd}(itrial, :) = normPupil{itrial}(respIdx(1) -25: respIdx(1));
                       % calc 95th percentile 
                       resp.prtileResp_pupil{icnd}(itrial) = prctile(resp.preResp_pupil{icnd}(itrial, :), 95);
                       resp.derivative{icnd}(itrial, :) = data2use(tmp_idx_resp, 5);

                       if generate_xlsx_full 
                           behav2use.stimPhasic(trials2use(itrial)) = stim.prtileResp_pupil{icnd}(itrial);
                           behav2use.respPhasic(trials2use(itrial)) = resp.prtileResp_pupil{icnd}(itrial);
                       end


                   end
  
%             end
            end

            
            %%% plot pupil aligned to stimulus onset 
%             axes(hs);
%             hold on
%             stim_mean_pupil{icnd} = nanmean(stim.aligned_pupil{icnd});
%             stim_sem_pupil{icnd}  = nanstd(stim.aligned_pupil{icnd})./sqrt(length(stim.aligned_pupil{icnd}));
% 
%             stim_mean_deriv{icnd} = nanmean(stim.derivative{icnd});
%             stim_sem_deriv{icnd}  = nanstd(stim.derivative{icnd})./sqrt(length(stim.derivative{icnd}));
% 
%             stimVector = linspace(-0.5, 1.0, 76);
%             plot(stimVector, stim_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
%             hold on 
%             plot(stimVector, stim_mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'lineStyle', '--');
%             hold on
%             x2plot = [stimVector fliplr(stimVector)];
%             error2plot = [stim_mean_pupil{icnd} + stim_sem_pupil{icnd} fliplr([stim_mean_pupil{icnd} - stim_sem_pupil{icnd}])];
%             error2plot_deriv = [stim_mean_deriv{icnd} + stim_sem_deriv{icnd} fliplr([stim_mean_deriv{icnd} - stim_sem_deriv{icnd}])];
%             fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
%             fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
%             alpha(0.25);
%             
%             
            %%% plot pupil aligned to response
            axes(hr);
            hold on
            resp_mean_pupil{icnd} = nanmean(resp.aligned_pupil{icnd});
            resp_sem_pupil{icnd}  = nanstd(resp.aligned_pupil{icnd})./sqrt(length(resp.aligned_pupil{icnd}));

            resp_mean_deriv{icnd} = nanmean(resp.derivative{icnd});
            resp_sem_deriv{icnd}  = nanstd(resp.derivative{icnd})./sqrt(length(resp.derivative{icnd}));

            respVector = linspace(-2, 3, 197);
            plot(respVector, resp_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
            hold on 
            plot(respVector, resp_mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'lineStyle', '--');
            x2plot = [respVector fliplr(respVector)];
            error2plot = [resp_mean_pupil{icnd} + resp_sem_pupil{icnd} fliplr([resp_mean_pupil{icnd} - resp_sem_pupil{icnd}])];
            error2plot_deriv = [resp_mean_deriv{icnd} + resp_sem_deriv{icnd} fliplr([resp_mean_deriv{icnd} - resp_sem_deriv{icnd}])];
            fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
            fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
            alpha(0.25);
          
    end

%     max_mean = nanmax([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil)]);
%     min_mean = nanmin([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil)]);

    max_mean = nanmax([cell2mat(resp_mean_pupil)]);
    min_mean = nanmin([cell2mat(resp_mean_pupil)]);


        figure(1);
        set(gcf, 'Units', 'centimeters');
        set(gcf, 'position', [51.6255 -5.7150 33.8878 26.3948]);

%         axes(hs);
%         hold on
%         xlim([-0.5 1]);
%         ylim([min_mean-1.5 max_mean+1.5]);
%         y2plot = ylim;
%         plot([0 0], y2plot, 'k-');
%         plot([0.8 0.8], y2plot, 'g-');
%         xlabel('\bfTime from Stimulus Onset (ms)');
%         if behav2use.distType(1) == 1
%             ylabel({['\fontsize{14} \bfBLOCK ' num2str(blockNum)], '\itGaussian', '\fontsize{11} \rmPupil Response', '(% Signal Change)'});
%         else
%             ylabel({['\fontsize{14} \bfBLOCK ' num2str(blockNum)], '\itBimodal', '\fontsize{11} \rmPupil Response', '(% Signal Change)'});
%         end
%         title('\fontsize{12}Stimulus Aligned');

        axes(hr);
        set(hr, 'YAxisLocation', 'right');
        hold on
        ylim([min_mean-1.5 max_mean+1.5]);
        y2plot = ylim;
        plot([0 0], y2plot, 'k-');
        plot([0.8 0.8], y2plot, 'k--');
        plot([1.6 1.6], y2plot, 'k--');
%         if blockNum == 1 
%             legend({'Both Different', '', 'Both-Low', '', 'Both-High'}, 'location', 'southeast');
%         end
        xlim([-2 3]);
        xlabel('\bfTime from Response Onset (ms)');
        title('\fontsize{12}Response Aligned');
%         ylabel({'\bfPupil Response', '(% Signal Change)'});

        normStim = stim;
        normResp = resp;
        
        if generate_xlsx_full 
            
            xlsx_full = [xlsx_full; behav2use];
        end



end
