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
h3 = subplot(2, 2, 1);
h4 = subplot(2, 2, 2);
h5 = subplot(2, 2, 3);
h6 = subplot(2, 2, 4);

cnd2run = [2 3];

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];

% extract_allTr_pupil(base_path);


for itype = 1:2

    if itype == 1  % gaussian
        col2plot = {[0.83 0.71 0.98], [0.62 0.35 0.99]};
        regress_saveName = 'Gaussian';
    else itype == 2  % bimodal
        col2plot = {[0.58 0.99 0.56], [0.19 0.62 0.14]};
        regress_saveName = 'Bimodal';
    end

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
        % INCLUDE AVERAGE SUM OF BOTH STIMULI SHOWN
        % CALCULATE REWARD PREDICTION ERROR FOR EACH TRIAL
        % reward(t) - stimulusAverage
        %-----------------------------------------------------------------
        distData.avgStimSum(1: size(distData), 1) = NaN;
        distData.RPE(1: size(distData), 1) = NaN;

        for idata = 1: 1: size(distData, 1)

            if distData.cndIdx(idata)== 1 % both-DIFFERENT
                distData.avgStimSum(idata) = 100; % LOW = 40; HIGH = 60;
            elseif distData.cndIdx(idata) == 2 % both-LOW
                distData.avgStimSum(idata) = 80;
            elseif distData.cndIdx(idata) == 3 % both-HIGH
                distData.avgStimSum(idata) = 120;
            end

            if distData.stimChosen(idata) == 1 | distData.stimChosen(idata) == 2
                distData.RPE(idata) = distData.reward(idata) - 40;
            else
                distData.RPE(idata) = distData.reward(idata) - 60;
            end

        end

        %-------------------------------------------------------------
        % identify previous trial information using ALL trials
        %-------------------------------------------------------------

        distData.reward_t1(1: size(distData, 1))        = NaN;
        distData.risk_t1(1: size(distData, 1))          = NaN;
        distData.avgStimSum_t1(1: size(distData, 1))    = NaN;
        distData.RPE_t1(1: size(distData, 1))           = NaN;

        for idata = 2: size(distData, 1)

            distData.reward_t1(idata)        = distData.reward(idata-1);
            distData.risk_t1(idata)          = distData.riskyChoice(idata-1);
            distData.avgStimSum_t1(idata)    = distData.avgStimSum(idata-1);
            distData.RPE_t1(idata)           = distData.RPE(idata-1);


        end

        % deals with bug in one of the trials
        if isubject == 18 & itype ==2
            distData(166, :) = [];
        end

        tp_resp{itype} = [];
        tp_ITI{itype}  = [];

        %-------------------------------------------------------------------
        % collapse data together from both of the risk choice conditions
        %-------------------------------------------------------------------

        data2run = [];
        data2run    = distData;
        tmpData_ITI = array2table(cell2mat([data2run.itiLocked_deriv]')');
        varName = [];
        for itp = 1: size(tmpData_ITI, 2)

            varName{itp} = ['tp_' num2str(itp)];

        end

        tmpData_ITI.Properties.VariableNames = varName;
        ITI_data{itype}{ isubject} = [data2run(:, [1 2 6 9 15:20]) tmpData_ITI];
        tp_ITI{itype}             = [tp_ITI{itype} ; tmpData_ITI];

        regressFilename                 = ['PT' num2str(ptIdx{isubject}) '_' regress_saveName '_regress_ITI_deriv.mat'];

        if ~exist(regressFilename)

            % run regression analysis, store beta coefficients, significance
            % plot average eye trace
            ITI_data{itype}{isubject}(1, :)   = [];
            x                                       = ITI_data{itype}{isubject}(:, [3 5 6]);
            x                                       = zscore(table2array(x)); % standardise units for all regressors
            x                                       = array2table(x);
            x.Properties.VariableNames              = {'reward', 'avgStimSum',...
                'RPE'};
            VarNum                                  = 11: size(ITI_data{itype}{ isubject}, 2);
            mdl                                     = [];

            %-----------------------------------------------------------------------
            % RUN THE REGRESSION MODEL
            %----------------------------------------------------------------------------------
            nRegress        = 3;

            for itp = 1: length(VarNum)
                varName     = [];
                VarName     = ['tp_' num2str(itp)];
                y           = [];
                y           = [ITI_data{itype}{ isubject}(:, VarNum(itp))];
                statData    = [];
                statData    = [y x];
                mdlspec     = [VarName '~ reward + RPE + avgStimSum'];
                mdl{itp}    = fitglm(statData, mdlspec);

                % store relevant coefficient data

                for irn = 1: nRegress

                    b2plot_ITI{itype}{irn}(isubject, itp)  = mdl{itp}.Coefficients.Estimate(irn+1);
                end

            end

            save(regressFilename, 'b2plot_ITI');
        else
            load(regressFilename);
        end


        tmpData_resp = array2table(cell2mat([data2run.respLocked_deriv]')');
        varName = [];
        for itp = 1: size(tmpData_resp, 2)

            varName{itp} = ['tp_' num2str(itp)];

        end

        tmpData_resp.Properties.VariableNames = varName;
        resp_data{itype}{ isubject} = [data2run(:, [1 2 6 9 15:20]) tmpData_resp];
        tp_resp{itype}             = [tp_resp{itype} ; tmpData_resp];

        regressFilename                 = ['PT' num2str(ptIdx{isubject}) '_' regress_saveName '_regress_resp_deriv.mat'];

        if ~exist(regressFilename)
            

            % run regression analysis, store beta coefficients, significance
            % plot average eye trace
            resp_data{itype}{ isubject}(1, :)  = [];
            x                                       = resp_data{itype}{ isubject}(:, [3 5 6]);
            x                                       = zscore(table2array(x)); % standardise units for all regressors
            x                                       = array2table(x);
            x.Properties.VariableNames              = {'reward', 'avgStimSum',...
                'RPE'};
            VarNum                                  = 11: size(resp_data{itype}{ isubject}, 2);
            mdl                                     = [];

            nRegress        = 3;
            for itp = 1: length(VarNum)
                varName     = [];
                VarName     = ['tp_' num2str(itp)];
                y           = [];
                y           = [resp_data{itype}{ isubject}(:, VarNum(itp))];
                statData    = [];
                statData    = [y x];
                mdlspec     = [VarName '~ reward + RPE + avgStimSum'];
                mdl{itp}    = fitglm(statData, mdlspec);

                % store relevant coefficient data

                for irn = 1: nRegress

                    b2plot_resp{itype}{irn}(isubject, itp)  = mdl{itp}.Coefficients.Estimate(irn+1);
                end

            end

            save(regressFilename, 'b2plot_resp');
        else
            load(regressFilename);
        end

    end

% if itype == 2 
        axes(h1);
        hold on
        timeVec = linspace(0, 2.8, 141);
        mean_ITI{itype} = nanmean(table2array(tp_ITI{itype}));
        sem_ITI{itype}  = nanstd(table2array(tp_ITI{itype}))./sqrt(length(table2array(tp_ITI{itype})));
        plot(timeVec, mean_ITI{itype} , '-', 'color', col2plot{2}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [mean_ITI{itype}  + sem_ITI{itype} ,...
            fliplr([mean_ITI{itype}  - sem_ITI{itype} ])];
        fill(x2plot, error2plot, col2plot{2}, 'linestyle', 'none');
        alpha(0.25);

        %--------------------------------------------------
        % regressors plot: ITI
        %--------------------------------------------------
        if itype == 1
            axes(h3);
        else 
            axes(h5);
        end

        hold on
        timeVec = linspace(0, 2.8, 141);
        nRegress = 3;
        regressCol = [1 0 0; 1 0 1; 0 0 1;,...
            0.96 0.65 0; 0.49 0.62 0.49; 0.07 0.62 1];
      
        sigplot    = [0 0.02 0.04 0.06 0.08 0.1];

        for irn = 1: nRegress
            tmpB_ITI = [];
            semB_ITI = [];
            tmpB_ITI = nanmean(b2plot_ITI{itype}{irn});
            semB_ITI = nanstd(b2plot_ITI{itype}{irn})./sqrt(length(b2plot_ITI{itype}{irn}));
            plot(timeVec, tmpB_ITI, 'color', regressCol(irn, :), 'LineWidth', 1.2);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [tmpB_ITI + semB_ITI,...
                fliplr([tmpB_ITI - semB_ITI])];
            fill(x2plot, error2plot, [regressCol(irn, :)], 'linestyle', 'none');
            alpha(0.25);

            [pval_ITI{itype, irn}, ~, ~, ~, ~] =mult_comp_perm_t1(b2plot_ITI{itype}{irn});
            pIdx_ITI{itype, irn}(1: length(pval_ITI{itype, irn})) = NaN;
            pIdx_ITI{itype, irn}(find(pval_ITI{itype, irn} <= 0.05)) = 1;

        end

         y2plot = ylim;

        for irn = 1:nRegress  
                plot(timeVec, [pIdx_ITI{itype, irn}- 1 + (y2plot(1)+y2plot(1)/2)-sigplot(irn)], '.', 'color', [regressCol(irn, :)], 'MarkerSize', 7);
        end


        axes(h2);
        hold on
        timeVec = linspace(0, 3.1, 156);
        mean_resp{itype} = nanmean(table2array(tp_resp{itype}));
        sem_resp{itype}  = nanstd(table2array(tp_resp{itype}))./sqrt(length(table2array(tp_resp{itype})));
        plot(timeVec, mean_resp{itype}, '-', 'color', col2plot{2}, 'LineWidth', 1.2);
        x2plot = [timeVec fliplr(timeVec)];
        error2plot = [mean_resp{itype} + sem_resp{itype},...
            fliplr([mean_resp{itype} - sem_resp{itype}])];
        fill(x2plot, error2plot, col2plot{2}, 'linestyle', 'none');
        alpha(0.25);

        if itype == 1
            axes(h4);
        else 
            axes(h6);
        end
        hold on
        timeVec = linspace(0, 3.1, 156);
        for irn = 1: nRegress
            tmpB_resp = [];
            semB_resp = [];
            tmpB_resp = nanmean(b2plot_resp{itype}{irn});
            semB_resp = nanstd(b2plot_resp{itype}{irn})./sqrt(length(b2plot_resp{itype}{irn}));
            plot(timeVec, tmpB_resp, 'color', regressCol(irn, :), 'LineWidth', 1.2);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [tmpB_resp + semB_resp,...
                fliplr([tmpB_resp - semB_resp])];
            fill(x2plot, error2plot, [regressCol(irn, :)], 'linestyle', 'none');
            alpha(0.25);

            [pval_resp{itype, irn}, ~, ~, ~, ~] =mult_comp_perm_t1(b2plot_resp{itype}{irn});
            pIdx_resp{itype, irn}(1: length(pval_resp{itype, irn})) = NaN;
            pIdx_resp{itype, irn}(find(pval_resp{itype, irn} <= 0.05)) = 1;

        end

        y2plot = ylim;

        for irn = 1:nRegress  
                plot(timeVec, [pIdx_resp{itype, irn}- 1 + (y2plot(1)+y2plot(1)/2)-sigplot(irn)], '.', 'color', [regressCol(irn, :)], 'MarkerSize', 7);
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
ylabel({'Pupil Derivative'});
% ylabel({'Pupil Response' '% Change from Mean'});
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
ylabel({'Pupil Derivative'});
% ylabel({'Pupil Response' '% Change from Mean'});
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
title({'\fontsize{14} \bf GAUSSIAN', 'Pupil: ITI Locked'})
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
title({'\fontsize{14} \bf GAUSSIAN', 'Pupil: Response Locked'})
set(gca, 'fontName', 'times');
axes(h5);
hold on
xlim([0 2.8]);
hold on 
plot([0 2.8], [0 0], 'k--');
[y2plot_min, y2plot_max] = ylimit_adapt(h5, h6);
axes(h5);
ylim([y2plot_min y2plot_max])
hold on
plot([1.5 1.5], [y2plot_min y2plot_max], 'k-'); %fixspot
plot([2 2], [y2plot_min y2plot_max], 'k-');     %stimulus on
xlabel('Time from ITI Start (\it{s})');
ylabel({'\beta Coefficients'});
title({'\fontsize{14} \bf BIMODAL', 'Pupil: ITI Locked'})
set(gca, 'fontName', 'times');
axes(h6);
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
title({'\fontsize{14} \bf BIMODAL', 'Pupil: Response Locked'})
set(gca, 'fontName', 'times');

axes(h3);
    legend({'Reward(t)', '', 'RPE(t)', '', 'SumStim(t)', '', '', '', '', '', '',...
        '', '', '', '', '', ''})
figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [9.0382 1.0795 27.1992 19.6003]);
saveFigname =['fullRegress(t)_bothDist_pupilDeriv'];
cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\stimulus_phasicPupilBins');
print(saveFigname, '-dpng');
% figure(1);
% set(gcf, 'units', 'centimeters');
% set(gcf, 'Position', [0 0 24.6592 10.4775]);
% saveFigname =['bi_regressAnalysis_outcomet1_stimDeriv'];
% print(saveFigname, '-dpng');
% 

end

