function plot_populationEyeData(dataIn, grouped_choice)

%----------------------------------------------------------------------------
%%%% PLOTTING IRRESPECTIVE OF CHOICE TYPE 
%%%%% GROUPED ACCORDING TO BLOCK NUMBER, DISTRIBUTION TYPE AND CONDITION 
%----------------------------------------------------------------------------
if ~grouped_choice
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

else

%----------------------------------------------------------------------------
%%%% PLOTTING RISKY VS SAFE CHOICES
%%%%% GROUPED ACCORDING TO BLOCK NUMBER AND DISTRIBUTION TYPE  
%----------------------------------------------------------------------------
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

        data2use = dataIn(blockIdx);
        
        allStim_risky = [];
        allStim_safe =[];
        allResp_risky = [];
        allResp_safe = [];

        % only focus on both-high/both-low trials 

        cnd2run = find([data2use.cndIdx] == 2 | [data2use.cndIdx] ==3);
        data2use = data2use(cnd2run);
        
        for ichoice = 1: length(data2use)

            stim_risky = [];
            resp_risky = [];
            stim_safe = [];
            resp_safe = [];

            tmpBehavData = data2use(ichoice).behavData;

            % index trials where risky choices were made 

            riskIdx = find([tmpBehavData.stimulus_choice] == 2 | [tmpBehavData.stimulus_choice] ==4);
            safeIdx = find([tmpBehavData.stimulus_choice] == 1 | [tmpBehavData.stimulus_choice] ==3);

            stim_risky = data2use(ichoice).normStim(riskIdx, :);
            resp_risky = data2use(ichoice).normResp(riskIdx, :);

            stim_safe = data2use(ichoice).normStim(safeIdx, :);
            resp_safe = data2use(ichoice).normResp(safeIdx, :);

            allStim_risky = [allStim_risky; stim_risky];
            allStim_safe  = [allStim_safe; stim_safe];
            allResp_risky = [allResp_risky; resp_risky];
            allResp_safe  = [allResp_safe; resp_safe];

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


    end

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
    

end
    
    saveFilename = ['population_RiskyChoiceSplit_distDivided'];
    print(saveFilename, '-dpng');
    print(saveFilename, '-dpdf');


end