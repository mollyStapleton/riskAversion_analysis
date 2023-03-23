function pupil_temporal_regress(base_path, dataIn)


% predictor names 
% {'reward', 'reward_t1', 'riskyChoice', 'risk_t1', 'outcome',
% 'outcome_t1'};
% t1 = t-1
cd(base_path);

figure(1);
h1 = subplot(1, 2, 1);
h2 = subplot(1, 2, 2);

figure(2);
h3 = subplot(1, 2, 1);
h4 = subplot(1, 2, 2);

cnd2run = [2 3];

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];

% extract_allTr_pupil(base_path);


for itype = 1:2

    if itype == 1  % gaussian
        col2plot = {[0.83 0.71 0.98], [0.62 0.35 0.99]};
    else itype == 2  % bimodal
        col2plot = {[0.58 0.99 0.56], [0.19 0.62 0.14]};
    end

for icnd = 1:2

    for isubject = 1: length(ptIdx)

        ITI_data{itype, isubject} = [];
        resp_data{itype, isubject} = [];


        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);
        cd(process_path);
        loadFilename = ['P' ptIdx{isubject} '_fullPupilSeries.mat'];
        load(loadFilename, 'fullData');

        distIdx = [];
        distIdx = find(fullData.distType == itype);

        distData = fullData(distIdx, :);

        %-------------------------------------------------------------
        % identify previous trial information using ALL trials
        %-------------------------------------------------------------

        distData.reward_t1(1: size(distData, 1)) = NaN;
        distData.risk_t1(1: size(distData, 1)) = NaN;
        distData.outcome(1: size(distData, 1)) = NaN;
        distData.outcome_t1(1: size(distData, 1)) = NaN;

        if itype ==2
            for idata = 1: size(distData, 1)

                if distData.reward(idata) ~= 0
                    distData.outcome(idata) = 1;
                else
                    distData.outcome(idata) = 0;
                end
            end
        end

        for idata = 2: size(distData, 1)

            distData.reward_t1(idata) = distData.reward(idata-1);
            distData.risk_t1(idata)   = distData.riskyChoice(idata-1);

            if itype == 2
                distData.outcome_t1(idata) = distData.outcome(idata-1);
            end

        end

        % deals with bug in one of the trials
        if isubject == 18 & itype ==2
            distData(166, :) = [];
        end

        tp_resp{itype, icnd} = [];
        tp_ITI{itype, icnd}  = [];

        cndIdx = [];
        cndIdx = find(distData.cndIdx == cnd2run(icnd));

        data2run = [];
        data2run = distData(cndIdx, :);

        tmpData_ITI = array2table(cell2mat([data2run.itiLocked_deriv]')');
        varName = [];
        for itp = 1: size(tmpData_ITI, 2)

            varName{itp} = ['tp_' num2str(itp)];

        end

        tmpData_ITI.Properties.VariableNames = varName;
        ITI_data{itype}{icnd, isubject} = [data2run(:, [1:9 14:17]) tmpData_ITI];
        tp_ITI{itype, icnd}             = [tp_ITI{itype, icnd} ; tmpData_ITI];
        % run regression analysis, store beta coefficients, significance
        % plot average eye trace
        x           = ITI_data{itype}{icnd, isubject}(:, [1 2 6 8 10 11 12 13]);
        VarNum      = 14: size(ITI_data{itype}{icnd, isubject}, 2);
        b           = [];

        for itp = 1: length(VarNum)
            varName = [];
            VarName = ['tp_' num2str(itp)];
            y       = [];
            y       = [ITI_data{itype}{icnd, isubject}(:, VarNum(itp))];

            [b{itp},~,~]                   = glmfit(x.reward, table2array(y));

            b2plot_ITI{itype, icnd}(isubject, itp)  = b{itp}(2);

        end

        tmpData_resp = array2table(cell2mat([data2run.respLocked_deriv]')');
        varName = [];
        for itp = 1: size(tmpData_resp, 2)

            varName{itp} = ['tp_' num2str(itp)];

        end

        tmpData_resp.Properties.VariableNames = varName;
        resp_data{itype, icnd}{isubject} = [data2run(:, [1:9 14:17]) tmpData_resp];

        tp_resp{itype, icnd}             = [tp_resp{itype, icnd}; tmpData_resp];
        %       resp_data{itype} = [resp_data{itype}; tmpData_resp];
        %
        % run regression analysis, store beta coefficients, significance
        % plot average eye trace
        x           = resp_data{itype, icnd}{isubject}(:, [1 2 6 8 10 11 12 13]);
        VarNum      = 14: size(resp_data{itype, icnd}{isubject}, 2);
        b{itype}    = [];

        for itp = 1: length(VarNum)
            varName = [];
            VarName = ['tp_' num2str(VarNum(itp))];
            y       = [];
            y       = [resp_data{itype, icnd}{isubject}(:, VarNum(itp))];

            [b{itp},~,~]                    = glmfit(x.reward, table2array(y));

            b2plot_resp{itype, icnd}(isubject, itp)   = b{itp}(2);

        end
    end

% if itype == 2 
        axes(h1);
        hold on
        timeVec = linspace(0, 2.8, 141);
        mean_ITI{itype, icnd} = nanmean(table2array(tp_ITI{itype, icnd}));
        sem_ITI{itype, icnd}  = nanstd(table2array(tp_ITI{itype, icnd}))./sqrt(length(table2array(tp_ITI{itype, icnd})));
        plot(timeVec, mean_ITI{itype, icnd} , '-', 'color', col2plot{icnd}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [mean_ITI{itype, icnd}  + sem_ITI{itype, icnd} ,...
            fliplr([mean_ITI{itype, icnd}  - sem_ITI{itype, icnd} ])];
        fill(x2plot, error2plot, col2plot{icnd}, 'linestyle', 'none');
        alpha(0.25);
        axes(h3);
        hold on
        timeVec = linspace(0, 2.8, 141);
        tmpB_ITI = [];
        semB_ITI = [];
        tmpB_ITI = nanmean(b2plot_ITI{itype, icnd} );
        semB_ITI = nanstd(b2plot_ITI{itype, icnd} )./sqrt(length(b2plot_ITI{itype, icnd} ));
        plot(timeVec, tmpB_ITI, '-', 'color', col2plot{icnd}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [tmpB_ITI + semB_ITI,...
            fliplr([tmpB_ITI - semB_ITI])];
        fill(x2plot, error2plot, col2plot{icnd}, 'linestyle', 'none');
        alpha(0.25);


        axes(h2);
        hold on
        timeVec = linspace(0, 3.1, 156);
        mean_resp{itype, icnd} = nanmean(table2array(tp_resp{itype, icnd}));
        sem_resp{itype, icnd}  = nanstd(table2array(tp_resp{itype, icnd}))./sqrt(length(table2array(tp_resp{itype, icnd})));
        plot(timeVec, mean_resp{itype, icnd}, '-', 'color', col2plot{icnd}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [mean_resp{itype, icnd} + sem_resp{itype, icnd},...
            fliplr([mean_resp{itype, icnd} - sem_resp{itype, icnd}])];
        fill(x2plot, error2plot, col2plot{icnd}, 'linestyle', 'none');
        alpha(0.25);

        axes(h4);
        hold on
        timeVec = linspace(0, 3.1, 156);
        tmpB_resp = [];
        semB_resp = [];
        tmpB_resp = nanmean(b2plot_resp{itype, icnd});
        semB_resp = nanstd(b2plot_resp{itype, icnd})./sqrt(length(b2plot_resp{itype, icnd}));
        plot(timeVec, tmpB_resp, '-', 'color', col2plot{icnd}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [tmpB_resp + semB_resp,...
            fliplr([tmpB_resp - semB_resp])];
        fill(x2plot, error2plot, col2plot{icnd}, 'linestyle', 'none');
        alpha(0.25);

        [pval_ITI{itype, icnd}, ~, ~, ~, ~] =mult_comp_perm_t1(b2plot_ITI{itype, icnd});
        for ibeta = 1: length(b2plot_ITI{itype, icnd})

            [H(ibeta),P(ibeta)] = ttest(b2plot_ITI{itype, icnd}(:, ibeta));
        end

        axes(h3);
        pIdx_ITI{itype, icnd}(1: length(pval_ITI{itype, icnd})) = NaN;
        pIdx_ITI{itype, icnd}(find(pval_ITI{itype, icnd} <= 0.05)) = 1;
        hold on;
        timeVec = linspace(0, 2.8, 141);

            if itype == 1
                y2plot = ylim;
                plot(timeVec, [pIdx_ITI{itype, icnd}- 1 + (y2plot(1)+y2plot(1)/2)], '.', 'color', col2plot{icnd}, 'MarkerSize', 7);
            else
                y2plot = ylim;
                plot(timeVec, [pIdx_ITI{itype, icnd}- 1 + (y2plot(1)+y2plot(1)/2)], '.', 'color', col2plot{icnd}, 'MarkerSize', 7);
            end

        axes(h4);
        [pval_resp{itype, icnd}, ~, ~, ~, ~]=mult_comp_perm_t1(b2plot_resp{itype, icnd}, 5000, 0, 0.05);
        pIdx_resp{itype, icnd}(1: length(pval_resp{itype, icnd})) = NaN;
        pIdx_resp{itype, icnd}(find(pval_resp{itype, icnd} <= 0.05)) = 1;hold on;
        timeVec = linspace(0, 3.1, 156);

            if itype == 1
                y2plot = ylim;
                plot(timeVec, [pIdx_resp{itype, icnd}- 1 + (y2plot(1)+y2plot(1)/2)], '.', 'color', col2plot{icnd}, 'MarkerSize', 7);
            else
                y2plot = ylim;
                plot(timeVec, [pIdx_resp{itype, icnd} - 1 + (y2plot(1)+y2plot(1)/2)], '.', 'color', col2plot{icnd}, 'MarkerSize', 7);
            end
     

%         end

    end
end

axes(h1);
hold on
xlim([0 2.8]);
plot([0 2.8], [0 0], 'k--');
[y2plot_min, y2plot_max] = ylimit_adapt(h1, h2);
axes(h1);
ylim([y2plot_min y2plot_max]);
plot([1.5 1.5], [y2plot_min y2plot_max], 'k-'); %fixspot
plot([2 2], [y2plot_min y2plot_max], 'k-');     %stimulus on
xlabel('Time from ITI Start (\it{s})');
ylabel({'Pupil Response' '% Change from Mean'});
title('\fontsize{14} \bfPupil: ITI Locked')
set(gca, 'FontName', 'times');
axes(h2);
hold on
xlim([0 3.1]);
hold on 
plot([0 3.1], [0 0], 'k--');
ylim([y2plot_min y2plot_max]);
plot([0.8 0.8],[y2plot_min y2plot_max], 'k-'); %choice indicated
plot([1.6 1.6], [y2plot_min y2plot_max], 'k-'); %reward feedback
xlabel('Time from Response Onset (\it{s})');
ylabel({'Pupil Response' '% Change from Mean'});
title('\fontsize{14} \bfPupil: Response Locked')
set(gca, 'FontName', 'times');

axes(h3);
hold on
xlim([0 2.8]);
hold on 
plot([0 2.8], [0 0], 'k--');
[y2plot_min, y2plot_max] = ylimit_adapt(h3, h4);
axes(h3);
ylim([y2plot_min y2plot_max])
hold on
plot([1.5 1.5], [y2plot_min y2plot_max], 'k-'); %fixspot
plot([2 2], [y2plot_min y2plot_max], 'k-');     %stimulus on
xlabel('Time from ITI Start (\it{s})');
ylabel({'\beta Coefficients'});
title('\fontsize{14} \bfPupil: ITI Locked')
set(gca, 'fontName', 'times');
axes(h4);
hold on
xlim([0 3.1]);
hold on 
plot([0 3.1], [0 0], 'k--');
y2plot = ylim;
ylim([y2plot_min y2plot_max]);
hold on
hold on
plot([0.8 0.8], [y2plot_min y2plot_max], 'k-'); %fixspot
plot([1.6 1.6], [y2plot_min y2plot_max], 'k-');     %stimulus on
xlabel('Time from Response Onset (\it{s})');
ylabel({'\beta Coefficients'});
title('\fontsize{14} \bfPupil: Response Locked')
set(gca, 'fontName', 'times');

% figure(2);
% set(gcf, 'units', 'centimeters');
% set(gcf, 'Position', [0 0 24.6592 10.4775]);
% saveFigname =['bi_beta_coefficients_outcomet1_stimDeriv'];
% cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\stimulus_phasicPupilBins');
% print(saveFigname, '-dpng');
% figure(1);
% set(gcf, 'units', 'centimeters');
% set(gcf, 'Position', [0 0 24.6592 10.4775]);
% saveFigname =['bi_regressAnalysis_outcomet1_stimDeriv'];
% print(saveFigname, '-dpng');
% 

end

