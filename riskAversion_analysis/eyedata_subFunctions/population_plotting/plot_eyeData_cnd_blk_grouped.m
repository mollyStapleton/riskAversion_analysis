function plot_eyeData_cnd_blk_grouped(dataIn)

 for iblock = 1: 4
    
        if iblock == 1
            hs = axes('position', [0.1 0.6 0.15 0.35]);
            hr = axes('position', [0.3 0.6 0.15 0.35]);
        elseif iblock == 2
            hs = axes('position', [0.6 0.6 0.15 0.35]);
            hr = axes('position', [0.8 0.6 0.15 0.35]);
        elseif iblock == 3
            hs = axes('position', [0.1 0.1 0.15 0.35]);
            hr = axes('position', [0.3 0.1 0.15 0.35]);
        elseif iblock == 4
            hs = axes('position', [0.6 0.1 0.15 0.35]);
            hr = axes('position', [0.8 0.1 0.15 0.35]);
        end
    
        for itype = 1:2
    
            if itype == 1
                lin2plot = '-';
            else
                lin2plot = '--';
            end
    
            % identify trials from first block that were gaussian and bimodal
            % separately
    
            blockIdx = find([dataIn.blockIdx] == iblock & [dataIn.dist_type] ==  itype);
    
            % plot separately for each condition
    
            for icnd = 1:3
    
                if icnd == 1
                    col2plot = 'k';
                elseif icnd == 2
                    col2plot = 'r';
                elseif icnd == 3
                    col2plot = 'b';
                end
    
                cndIdx = find([dataIn(blockIdx).cndIdx] == icnd);
                data2use = dataIn(blockIdx(cndIdx));
    
                tmp_allStim = [];
                tmp_allResp = [];
                for isession = 1: length(data2use)
    
                    tmpMat_stim = data2use(isession).normStim;
                    tmpMat_resp = data2use(isession).normResp;
    
                    tmp_allStim = [tmp_allStim; tmpMat_stim];
                    tmp_allResp = [tmp_allResp; tmpMat_resp];
                end
    
                allPupil_stim{iblock, itype}{icnd} = tmp_allStim;
                allPupil_resp{iblock, itype}{icnd} = tmp_allResp;
    
    
                %%% plot pupil aligned to stimulus onset
                axes(hs);
                hold on
                stim_mean_pupil{iblock, itype}{icnd} = mean( allPupil_stim{iblock, itype}{icnd});
                stim_sem_pupil{iblock, itype}{icnd}  = std( allPupil_stim{iblock, itype}{icnd})./sqrt(length(allPupil_stim{iblock, itype}{icnd}));
    
                stim_timeVec = linspace(-0.5, 1, 1501);
                plot(stim_timeVec, stim_mean_pupil{iblock, itype}{icnd}, 'color', col2plot, 'lineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [stim_timeVec fliplr(stim_timeVec)];
                error2plot = [stim_mean_pupil{iblock, itype}{icnd} + stim_sem_pupil{iblock, itype}{icnd},...
                    fliplr([stim_mean_pupil{iblock, itype}{icnd} - stim_sem_pupil{iblock, itype}{icnd}])];
                fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
                alpha(0.25);
    
    
                %%% plot pupil aligned to response
                axes(hr);
                hold on
                resp_mean_pupil{iblock, itype}{icnd} = mean(allPupil_resp{iblock, itype}{icnd});
                resp_sem_pupil{iblock, itype}{icnd}  = std(allPupil_resp{iblock, itype}{icnd})./sqrt(length(allPupil_resp{iblock, itype}{icnd}));
    
                resp_timeVec = linspace(-1, 3.1, 4101);
                plot(resp_timeVec, resp_mean_pupil{iblock, itype}{icnd}, 'color', col2plot, 'LineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [resp_timeVec fliplr(resp_timeVec)];
                error2plot = [resp_mean_pupil{iblock, itype}{icnd} + resp_sem_pupil{iblock, itype}{icnd},...
                    fliplr([resp_mean_pupil{iblock, itype}{icnd} - resp_sem_pupil{iblock, itype}{icnd}])];
                fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
                alpha(0.25);
    
                
            end
    
            max_type_stim(itype)= max(max(cell2mat(stim_mean_pupil{iblock, itype}))); 
            max_type_resp(itype)= max(max(cell2mat(resp_mean_pupil{iblock, itype}))); 
            min_type_stim(itype)= min(min(cell2mat(stim_mean_pupil{iblock, itype}))); 
            min_type_resp(itype)= min(min(cell2mat(resp_mean_pupil{iblock, itype}))); 
        end
    
        max_mean = max([max_type_stim max_type_resp]);
        min_mean = min([min_type_stim min_type_resp]);
    
        figure(1);
    %     set(gcf, 'Units', 'centimeters');
    %     set(gcf, 'position', [51.6255 -5.7150 33.8878 26.3948]);
    
        axes(hs);
        hold on
        xlim([-0.5 1]);
        ylim([min_mean-0.025 max_mean+0.025]);
        y2plot = ylim;
        plot([0 0], y2plot, 'k-');
        plot([0.8 0.8], y2plot, 'g-');
        xlabel('\bfTime from Stimulus Onset (ms)');
        ylabel({['\fontsize{14} \bfBLOCK ' num2str(iblock)],'\fontsize{11} \rmPupil Response', '(% Signal Change)'});
        title('\fontsize{12}Stimulus Aligned');
        if iblock == 1
            legend({'G: Both-Different', '', 'G: Both-Low', '', 'G: Both-High',...
                '', 'B: Both-Different', '', 'B: Both-Low', '', 'Both-High'}, 'location', 'northwest');
        end
        set(gca, 'FontName', 'times');
    
        axes(hr);
        set(hr, 'YAxisLocation', 'right');
        hold on
        ylim([min_mean-0.025 max_mean+0.025]);
        y2plot = ylim;
        plot([0 0], y2plot, 'k-');
        plot([0.8 0.8], y2plot, 'k-.');
        plot([1.6 1.6], y2plot, 'k--');
        xlim([-1 2.5]);
        xlabel('\bfTime from Response Onset (ms)');
        title('\fontsize{12}Response Aligned');
        set(gca, 'FontName', 'times');

        
    end

    saveFilename = ['population_allChoices_distDivided'];
    print(saveFilename, '-dpng');
    print(saveFilename, '-dpdf');

end