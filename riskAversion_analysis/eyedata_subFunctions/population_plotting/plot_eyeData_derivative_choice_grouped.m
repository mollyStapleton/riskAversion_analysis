function plot_eyeData_derivative_choice_grouped(dataIn)

for dataType = 1:2

    if dataType == 1 %% Pupil: % change from mean

        col2plot = [0 0 0; 0.75 0.75 0.75]; % black: RISKY | grey: SAFE
        hs = subplot(2, 2, 1);
        hr = subplot(2, 2, 2);

    else

        col2plot = [0.68 0 1;  0.89 0.72 0.98];
        hb = subplot(2, 2, 3);
        ht = subplot(2, 2, 4);

    end

        for itype = 1:2
        
                if itype == 1
                    lin2plot = '-'; %gaussian
                else
                    lin2plot = '--';%bimodal
                end
        
                % identify trials from first block that were gaussian and bimodal
                % separately
        
                blockIdx = find([dataIn.dist_type] ==  itype);
        
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

                    if dataType == 1 
        
                        stim_risky = data2use(ichoice).normStim(riskIdx, :);
                        resp_risky = data2use(ichoice).normResp(riskIdx, :);
            
                        stim_safe = data2use(ichoice).normStim(safeIdx, :);
                        resp_safe = data2use(ichoice).normResp(safeIdx, :);

                    elseif dataType == 2 

                        stim_risky = data2use(ichoice).derivative_stim(riskIdx, :);
                        resp_risky = data2use(ichoice).derivative_resp(riskIdx, :);
            
                        stim_safe = data2use(ichoice).derivative_stim(safeIdx, :);
                        resp_safe = data2use(ichoice).derivative_resp(safeIdx, :);

                    end

                    allStim_risky = [allStim_risky; stim_risky];
                    allStim_safe  = [allStim_safe; stim_safe];
                    allResp_risky = [allResp_risky; resp_risky];
                    allResp_safe  = [allResp_safe; resp_safe];
        
                end
        
                mean_stim_risky{dataType, itype} = nanmean(allStim_risky);
                sem_stim_risky{dataType, itype}   = nanstd(allStim_risky)./sqrt(length(allStim_risky));
        
                mean_stim_safe{dataType, itype}  = nanmean(allStim_safe);
                sem_stim_safe{dataType, itype}  = nanstd(allStim_safe)./sqrt(length(allStim_safe));
        
                mean_resp_risky{dataType, itype}  = nanmean(allResp_risky);
                sem_resp_risky{dataType, itype}  = nanstd(allResp_risky)./sqrt(length(allResp_risky));
        
                mean_resp_safe{dataType, itype}  = nanmean(allResp_safe);
                sem_resp_safe{dataType, itype}   = nanstd(allResp_safe)./sqrt(length(allResp_safe));
        
                %%% plot pupil aligned to stimulus onset
                if dataType == 1 
                    axes(hs);
                else 
                    axes(hb);
                end

                hold on
                stim_timeVec = linspace(-0.5, 1, 1501);
                plot(stim_timeVec, mean_stim_risky{dataType, itype} , 'color', col2plot(1, :), 'lineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [stim_timeVec fliplr(stim_timeVec)];
                error2plot = [mean_stim_risky{dataType, itype}  + sem_stim_risky{dataType, itype} ,...
                    fliplr([mean_stim_risky{dataType, itype} - sem_stim_risky{dataType, itype}])];
                fill(x2plot, error2plot, col2plot(1, :), 'linestyle', 'none');
                alpha(0.25);
                hold on
                plot(stim_timeVec, mean_stim_safe{dataType, itype} , 'color', col2plot(2, :), 'lineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [stim_timeVec fliplr(stim_timeVec)];
                error2plot = [mean_stim_safe{dataType, itype}  + sem_stim_safe{dataType, itype} ,...
                    fliplr([mean_stim_safe{dataType, itype} - sem_stim_safe{dataType, itype} ])];
                fill(x2plot, error2plot, col2plot(2, :), 'linestyle', 'none');
                alpha(0.25);
        
                %%% plot pupil aligned to response
                if dataType == 1 
                    axes(hr);
                else 
                    axes(ht);
                end
                hold on
                resp_timeVec = linspace(-1, 3.1, 4101);
                plot(resp_timeVec, mean_resp_risky{dataType, itype} , 'color',col2plot(1, :), 'lineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [resp_timeVec fliplr(resp_timeVec)];
                error2plot = [mean_resp_risky{dataType, itype}  + sem_resp_risky{dataType, itype} ,...
                    fliplr([mean_resp_risky{dataType, itype} - sem_resp_risky{dataType, itype} ])];
                fill(x2plot, error2plot, col2plot(1, :), 'linestyle', 'none');
                alpha(0.25);
        
                hold on
                plot(resp_timeVec, mean_resp_safe{dataType, itype} , 'color', col2plot(2, :), 'lineStyle', lin2plot, 'linew', 1.2);
                hold on
                x2plot = [resp_timeVec fliplr(resp_timeVec)];
                error2plot = [mean_resp_safe{dataType, itype}  + sem_resp_safe{dataType, itype} ,...
                fliplr([mean_resp_safe{dataType, itype} - sem_resp_safe{dataType, itype} ])];
                fill(x2plot, error2plot, col2plot(2, :), 'linestyle', 'none');
                alpha(0.25);
        
                max_stim_safe(dataType, itype)= max(max(mean_stim_safe{dataType, itype} ));
                max_stim_risk(dataType, itype)= max(max(mean_stim_risky{dataType, itype} ));
                min_stim_safe(dataType, itype)= min(max(mean_stim_safe{dataType, itype} ));
                min_stim_risk(dataType, itype)= min(max(mean_stim_risky{dataType, itype} ));
        
                max_resp_safe(dataType, itype)= max(max(mean_resp_safe{dataType, itype} ));
                max_resp_risk(dataType, itype)= max(max(mean_resp_risky{dataType, itype} ));
                min_resp_safe(dataType, itype)= min(max(mean_resp_safe{dataType, itype} ));
                min_resp_risk(dataType, itype)= min(max(mean_resp_risky{dataType, itype} ));
        
        
            end
end
                max_mean = max([max_stim_safe max_stim_risk max_resp_safe max_resp_risk]);
                min_mean = min([min_stim_safe min_stim_risk min_resp_safe min_resp_risk]);
        
                figure(1);
                set(gcf, 'Units', 'centimeters');
                set(gcf, 'position', [66.8232 0.8678 29.4640 13.2715]);
        
                axes(hs);
                xlim([-0.5 1]);
                ylim([min_mean-0.1 max_mean+0.025]);
                y2plot = ylim;
                plot([0 0], y2plot, 'k-');
                plot([0.8 0.8], y2plot, 'g-');
                xlabel('\bfTime from Stimulus Onset (ms)');
                ylabel([{'\fontsize{14}\rmPupil Response', '(% Signal Change)'}]);
                title('\fontsize{12}Stimulus Aligned');
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
            
        
                saveFilename = ['population_RiskyChoiceSplit_deriv_Norm'];
                print(saveFilename, '-dpng');
                print(saveFilename, '-dpdf');





end