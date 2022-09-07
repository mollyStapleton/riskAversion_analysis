function plot_eyeData(dataIn_eye, dataIn_behav, blockNum)

%     subplot(2, 2, blockNum);
    idx = find(dataIn_behav.blockNumber == blockNum);
    behav2use = dataIn_behav(idx, :);
    if blockNum == 1 
        hs = axes('position', [0.1 0.6 0.15 0.35]);
        hr = axes('position', [0.3 0.6 0.15 0.35]);
    elseif blockNum == 2 
        hs = axes('position', [0.6 0.6 0.15 0.35]);
        hr = axes('position', [0.8 0.6 0.15 0.35]);
    elseif blockNum == 3 
        hs = axes('position', [0.1 0.1 0.15 0.35]);
        hr = axes('position', [0.3 0.1 0.15 0.35]);
    elseif blockNum == 4 
        hs = axes('position', [0.6 0.1 0.15 0.35]);
        hr = axes('position', [0.8 0.1 0.15 0.35]);
    end


    %identify condition
    for icnd = 1:3
    
        if icnd == 1 
            col2plot = 'k';
        elseif icnd == 2 
            col2plot = 'r';
        elseif icnd == 3 
            col2plot = 'b';
        end

        cndIdx = find(behav2use.cnd_idx == icnd);

          trials2use = behav2use.trialNum(cndIdx);

            for itrial = 1: length(trials2use)
        
                   data2use   = dataIn_eye(trials2use(itrial)).data;
                   
                   %plot pupil diameter over course of a trial with indices for
                   %relevant task epochs
        
                   %single event when button is pressed indicating choice
                   respIdx = find([data2use(:, 6)] == 25);
                   if ~isempty(respIdx) %only look at trials where a response was made 
                       %first timestamp for stim on min time
                       stimOnMinIdx = find([data2use(:, 6) == 14], 1);
                       %first timestamps for stim on when pt allowed to respond 
                       stimOnGoIdx = find([data2use(:, 6) == 15], 1);

                       normPupil{itrial} = data2use(:, 3);

                       %STIMULUS DATA 
                       timeVec_stim{itrial} =  data2use(:, 4) - data2use(stimOnMinIdx(1), 4);

                       stim.aligned_timeVec{icnd}(itrial, :) = timeVec_stim{itrial}(stimOnMinIdx(1) - 500: stimOnMinIdx(1) + 1000);
                       stim.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(stimOnMinIdx(1) - 500: stimOnMinIdx(1) + 1000);

                       % look at 500ms prior to response time 
                       stim.preResp_pupil{icnd}(itrial, :) = normPupil{itrial}(stimOnMinIdx(1)+500: stimOnMinIdx(1));
                       % calc 95th percentile 
                       stim.prtileResp_pupil{icnd}(itrial) = prctile(stim.preResp_pupil{icnd}(itrial, :), 95);

                       
                       %RESPONSE DATA 
                       timeVec_resp{itrial} =  data2use(:, 4) - data2use(respIdx(1), 4);

                       resp.aligned_timeVec{icnd}(itrial, :) = timeVec_resp{itrial}(respIdx(1) - 1000: respIdx(1) + 3100);
                       resp.aligned_pupil{icnd}(itrial, :)   = normPupil{itrial}(respIdx(1) - 1000: respIdx(1) + 3100);

                       % look at 500ms prior to response time 
                       resp.preResp_pupil{icnd}(itrial, :) = normPupil{itrial}(respIdx(1) -500: respIdx(1));
                       % calc 95th percentile 
                       resp.prtileResp_pupil{icnd}(itrial) = prctile(resp.preResp_pupil{icnd}(itrial, :), 95);

                   end
  
%             end
            end

            
            %%% plot pupil aligned to stimulus onset 
            axes(hs);
            hold on
            stim_mean_pupil{icnd} = mean(stim.aligned_pupil{icnd});
            stim_sem_pupil{icnd}  = std(stim.aligned_pupil{icnd})./sqrt(length(stim.aligned_pupil{icnd}));
            
            plot(stim.aligned_timeVec{icnd}(end, :), stim_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
            hold on
            x2plot = [stim.aligned_timeVec{icnd}(end, :) fliplr(stim.aligned_timeVec{icnd}(end, :))];
            error2plot = [stim_mean_pupil{icnd} + stim_sem_pupil{icnd} fliplr([stim_mean_pupil{icnd} - stim_sem_pupil{icnd}])];
            fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
            alpha(0.25);
            
            
            %%% plot pupil aligned to response
            axes(hr);
            hold on
            resp_mean_pupil{icnd} = mean(resp.aligned_pupil{icnd});
            resp_sem_pupil{icnd}  = std(resp.aligned_pupil{icnd})./sqrt(length(resp.aligned_pupil{icnd}));
            
            plot(resp.aligned_timeVec{icnd}(end, :), resp_mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
            hold on
            x2plot = [resp.aligned_timeVec{icnd}(end, :) fliplr(resp.aligned_timeVec{icnd}(end, :))];
            error2plot = [resp_mean_pupil{icnd} + resp_sem_pupil{icnd} fliplr([resp_mean_pupil{icnd} - resp_sem_pupil{icnd}])];
            fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
            alpha(0.25);
          
    end

    max_mean = max([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil)]);
    min_mean = min([cell2mat(resp_mean_pupil) cell2mat(stim_mean_pupil)]);


        figure(1);
        set(gcf, 'Units', 'centimeters');
        set(gcf, 'position', [51.6255 -5.7150 33.8878 26.3948]);

        axes(hs);
        hold on
        xlim([-0.5 1]);
        ylim([min_mean-0.025 max_mean+0.025]);
        y2plot = ylim;
        plot([0 0], y2plot, 'k-');
        plot([0.8 0.8], y2plot, 'g-');
        xlabel('\bfTime from Stimulus Onset (ms)');
        if behav2use.distType(1) == 1
            ylabel({['\fontsize{14} \bfBLOCK ' num2str(blockNum)], '\itGaussian', '\fontsize{11} \rmPupil Response', '(% Signal Change)'});
        else
            ylabel({['\fontsize{14} \bfBLOCK ' num2str(blockNum)], '\itBimodal', '\fontsize{11} \rmPupil Response', '(% Signal Change)'});
        end
        title('\fontsize{12}Stimulus Aligned');

        axes(hr);
        set(hr, 'YAxisLocation', 'right');
        hold on
        ylim([min_mean-0.025 max_mean+0.025]);
        y2plot = ylim;
        plot([0 0], y2plot, 'k-');
        plot([0.8 0.8], y2plot, 'k--');
        plot([1.6 1.6], y2plot, 'k--');
%         if blockNum == 1 
%             legend({'Both Different', '', 'Both-Low', '', 'Both-High'}, 'location', 'southeast');
%         end
        xlim([-1 2.5]);
        xlabel('\bfTime from Response Onset (ms)');
        title('\fontsize{12}Response Aligned');
%         ylabel({'\bfPupil Response', '(% Signal Change)'});

end
