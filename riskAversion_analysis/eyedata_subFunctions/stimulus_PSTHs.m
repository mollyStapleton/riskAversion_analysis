function stimulus_PSTHs(base_path, dataIn)

cnd2run = [2 3];
subs = unique(dataIn.subIdx);
ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];
iti_timeVec = linspace(0, 2.8, 141);

figure(1);
h1 = subplot(1, 2, 1);
h2 = subplot(1, 2, 2);

% PLOT GAUSSIAN DERIVATIVE AND PUPIL FOR LOW VS HIGH REWARD CONDITIONS
for isubject = 1: length(subs)

    [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);
    cd(process_path);
    loadFilename = ['P' ptIdx{isubject} '_fullPupilSeries.mat'];
    load(loadFilename, 'fullData');

    distIdx = [];
    distIdx = find(fullData.distType == 1);

    for icnd = 1:2


        lowcol = {[0.9255 0.8039 0.9804], [0.58 0.99 0.56]};

        highcol = {[0.62 0.35 0.99], [0.19 0.62 0.14]};
        

        cndIdx      = [];
        cndIdx      = find(fullData.cndIdx(distIdx) == cnd2run(icnd));
        data2use    = fullData(cndIdx, :);

        if isubject == 18
            data2use(25, :) = [];
        end

        data2plot{icnd}(isubject, :)   = nanmean(cell2mat(data2use.itiLocked_deriv')');
        hold on 
        if icnd == 1 
            axes(h1);
            hold on
            plot(iti_timeVec, data2plot{icnd}(isubject, :), 'color', lowcol{1}, 'LineWidth', 1);
        else 
            axes(h2);
            hold on
            plot(iti_timeVec, data2plot{icnd}(isubject, :), 'color', lowcol{1}, 'LineWidth', 1);
        end
    

    if isubject == 27

       data2plot_mean{icnd} = nanmean(data2plot{icnd});
       if icnd == 1 
           hold on 
           axes(h1);
           hold on 
           plot(iti_timeVec, data2plot_mean{icnd} , 'color', highcol{1}, 'linewidth', 2);
       else
           hold on 
           axes(h2);
           hold on 
           plot(iti_timeVec, data2plot_mean{icnd} , 'color', highcol{1}, 'linewidth', 2);
       end

    end

    end

end

axes(h1);
axis square;
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
title({'\fontsize{14} \bfPupil: ITI Locked', 'Both-LOW'});
set(gca, 'FontName', 'times');
axes(h2);
axis square;
hold on
xlim([0 2.8]);
plot([0 2.8], [0 0], 'k--');
[y2plot_min, y2plot_max] = ylimit_adapt(h1, h2);
axes(h2);
ylim([y2plot_min y2plot_max]);
plot([1.5 1.5], [y2plot_min y2plot_max], 'k-'); %fixspot
plot([2 2], [y2plot_min y2plot_max], 'k-');     %stimulus on
xlabel('Time from ITI Start (\it{s})');
ylabel({'Pupil Derivative'});
% ylabel({'Pupil Response' '% Change from Mean'});
title({'\fontsize{14} \bfPupil: ITI Locked', 'Both-HIGH'});
set(gca, 'FontName', 'times');

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [12.8852 4.2333 24.5586 15.9015]);
saveFigname =['GAUSS_cndSplit_pupilDeriv'];
cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\stimulus_phasicPupilBins');
print(saveFigname, '-dpng');


resp_timeVec = linspace(0, 3.1, 156);

figure(2);
h3 = subplot(1, 2, 1);
h4 = subplot(1, 2, 2);
data2plot =[];

% PLOT GAUSSIAN DERIVATIVE AND PUPIL FOR LOW VS HIGH REWARD CONDITIONS
for isubject = 1: length(subs)

    [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);
    cd(process_path);
    loadFilename = ['P' ptIdx{isubject} '_fullPupilSeries.mat'];
    load(loadFilename, 'fullData');

    distIdx = [];
    distIdx = find(fullData.distType == 1);

    for icnd = 1:2


        lowcol = {[0.9255 0.8039 0.9804], [0.58 0.99 0.56]};

        highcol = {[0.62 0.35 0.99], [0.19 0.62 0.14]};
        

        cndIdx      = [];
        cndIdx      = find(fullData.cndIdx(distIdx) == cnd2run(icnd));
        data2use    = fullData(cndIdx, :);

        if isubject == 18
            data2use(25, :) = [];
        end

        data2plot{icnd}(isubject, :)   = nanmean(cell2mat(data2use.respLocked_deriv')');
        hold on 
        if icnd == 1 
            axes(h3);
            hold on
            plot(resp_timeVec, data2plot{icnd}(isubject, :), 'color', lowcol{1}, 'LineWidth', 1);
        else 
            axes(h4);
            hold on
            plot(resp_timeVec, data2plot{icnd}(isubject, :), 'color', lowcol{1}, 'LineWidth', 1);
        end
    

    if isubject == 27

       data2plot_mean_resp{icnd} = nanmean(data2plot{icnd});
       if icnd == 1 
           hold on 
           axes(h3);
           hold on 
           plot(resp_timeVec, data2plot_mean_resp{icnd} , 'color', highcol{1}, 'linewidth', 2);
       else
           hold on 
           axes(h4);
           hold on 
           plot(resp_timeVec, data2plot_mean_resp{icnd} , 'color', highcol{1}, 'linewidth', 2);
       end

    end

    end

end

axes(h3);
axis square
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
title({'\fontsize{14} \bf GAUSSIAN', 'Pupil: Response Locked', 'Both-LOW'});
set(gca, 'fontName', 'times');
axes(h4);
axis square
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
title({'\fontsize{14} \bf GAUSSIAN', 'Pupil: Response Locked', 'Both-HIGH'});
set(gca, 'fontName', 'times');


figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [12.8852 4.2333 24.5586 15.9015]);
saveFigname =['GAUSS_cndSplit_respLocked_pupilDeriv'];
cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\stimulus_phasicPupilBins');
print(saveFigname, '-dpng');

end
