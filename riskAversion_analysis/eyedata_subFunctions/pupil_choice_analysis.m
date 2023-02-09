function pupil_choice_analysis(base_path, dataIn)
% median split within trial type 
% trial type: both-high (stimulus combo 3/4 - 4/3) and both-low (stimulus
% combo (1/2 - 2/1)
% median split carried out separately for distribution type but collapsed
% across block numbers 

choice_blockSplit_subject;

saveFolder = ['choice_phasicPupilBins']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);


tmpData_dist    = [];
data2save       = [];
binned          = [];
binned_all      = [];

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [5.6303 3.5983 17.6318 15.1765]);
h1 = subplot(2, 2, 1);
h2 = subplot(2, 2, 2);
h3 = subplot(2, 2, 3);
h4 = subplot(2, 2, 4);

cnd2run = [2 3];

subs = unique(dataIn.subIdx);

% analysis on an individual subject basis
for isubject = 1: length(subs)

    subIdx = find(dataIn.subIdx == subs(isubject));
    tmpSub = dataIn(subIdx, :);
    binned = [];

    for itype = 1:2
        tmpData_dist                        = [];
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end

        for icnd = 1:2

            if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
            end
            data2use                            = [];
            dataSplit                           = [];

            distIdx                             = find([tmpSub.distType] == itype);
            dataSplit                           = tmpSub(distIdx, :);

            cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
            data2use                            = dataSplit(cndIdx, :);
            medPupil{isubject}(itype, icnd)     = median(data2use.stim_prtileResp_pupil);

            splitIdx{isubject, itype}{icnd, 1}  = data2use.choice_prtileResp_pupil < medPupil{isubject}(itype, icnd);
            splitIdx{isubject, itype}{icnd, 2}  = data2use.choice_prtileResp_pupil > medPupil{isubject}(itype, icnd);

            tmpData                             = [];
            tmpBin                              = [];
            tmpData                             = data2use(:, [1:9, 19]);

            tmpBin(1: size(tmpData, 1))         = 0;

            tmpBin(splitIdx{isubject, itype}{icnd, 1})    = 1;
            tmpBin(splitIdx{isubject, itype}{icnd, 2})    = 2;

            tmpData.pupilBin                    = tmpBin';

            for ibin = 1:2

                if icnd == 1
                    %                     axes(h1);
                    prop_risky_low{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin));

                    diff_risky_low{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);

                    tmpTable        = [];
                    tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_low{isubject, itype}(icnd, ibin) diff_risky_low{isubject, itype}(icnd, ibin) ibin];


                else
                    %                     axes(h1);
                    prop_risky_high{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin));

                    diff_risky_high{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);

                    tmpTable = [];
                    tmpTable = [subs(isubject) cnd2run(icnd) itype prop_risky_high{isubject, itype}(icnd, ibin) diff_risky_high{isubject, itype}(icnd, ibin) ibin];
                    

                end

                binned   = [binned; tmpTable];

            end

            if icnd == 1
                axes(h1);
                hold on
                plot(prop_risky_low{isubject, itype}(icnd, 1), prop_risky_low{isubject, itype}(icnd, 2), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
                axes(h3);
                hold on
                plot(diff_risky_low{isubject, itype}(icnd, 1), diff_risky_low{isubject, itype}(icnd, 2), '^', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            else
                axes(h2);
                hold on
                plot(prop_risky_high{isubject, itype}(icnd, 1), prop_risky_high{isubject, itype}(icnd, 2), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
                axes(h4);
                hold on
                plot(diff_risky_high{isubject, itype}(icnd, 1), diff_risky_high{isubject, itype}(icnd, 2), '^', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                    'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            end

            tmpData_dist                        = [tmpData_dist; tmpData];

        end

    end

    binned_all = [binned_all; binned];

end

binned_all = array2table(binned_all);
binned_all.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'propRisky', 'biasRisky', 'pupilBin'};

risk_pref_glme = fitglme(binned_all, 'propRisky ~ cndIdx*distIdx*pupilBin + (1|subIdx) + (1| subIdx:cndIdx:distIdx)');
risk_bias_glme = fitglme(binned_all, 'biasRisky ~ cndIdx*distIdx*pupilBin + (1|subIdx) + (1| subIdx:cndIdx:distIdx)');
an_1 = anova(risk_pref_glme);
an_2 = anova(risk_bias_glme);
C = dataset2cell(an_1);
anovaWriteTable(C, 'riskPref');
C1 = dataset2cell(an_2);
anovaWriteTable(C1, 'riskbias');

% plots formatting
axes(h1);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-LOW', 'P(Risky)'});
set(gca, 'fontName', 'times');

axes(h2);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
plot([0 1], [0.5 0.5], 'k--');
plot([0.5 0.5], [0 1], 'k--');
x2plot = linspace(0, 1);
y2plot = linspace(0, 1);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-HIGH', 'P(Risky)'});
set(gca, 'fontName', 'times');

axes(h3);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
ylim([0 0.6]);
xlim([0 0.6]);
set(gca, 'XTick', [0:.2:0.6]);
set(gca, 'YTick', [0:.2:0.6]);
x2plot = linspace(0, 0.6);
y2plot = linspace(0, 0.6);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-LOW', 'Difference P(Risky)'});
set(gca, 'fontName', 'times');

axes(h4);
hold on
xlabel('LOW Pupil');
ylabel('HIGH Pupil');
ylim([0 0.6]);
xlim([0 0.6]);
set(gca, 'XTick', [0:.2:0.6]);
set(gca, 'YTick', [0:.2:0.6]);
x2plot = linspace(0, 0.6);
y2plot = linspace(0, 0.6);
plot(x2plot, y2plot, 'k-');
title({'\fontsize{12} Both-HIGH', 'Difference P(Risky)'});
set(gca, 'fontName', 'times');

saveFigname = ['choice_phasicPupil_riskPreferences_subjects'];
print(saveFigname, '-dpng');

figure(2);
set(gcf, 'units', 'centimeters');
% set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])
h5 = subplot(1, 2, 1);
h6 = subplot(1, 2, 2);

for itype = 1:2

    if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
    end

    for icnd = 1:2
    
        if icnd == 1
                x2plot = [1 1.5];
            else
                x2plot = [2.5 3];
        end

        
        for ibin = 1:2

            mean_binned{itype}(icnd, ibin) = mean(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype));
            sem_binned{itype}(icnd, ibin)  = std(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype))./...
                                                sqrt(length(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype)));

            mean_diff{itype}(icnd, ibin) = mean(binned_all.biasRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype));
            sem_diff{itype}(icnd, ibin)  = std(binned_all.biasRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype))./...
                                                sqrt(length(binned_all.biasRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype)));
            
            axes(h5);
            hold on
            errorbar(x2plot(ibin), mean_binned{itype}(icnd, ibin),  sem_binned{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            axes(h6);
            hold on 
            errorbar(x2plot(ibin), mean_diff{itype}(icnd, ibin),  sem_diff{itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
            
        end

    end


end 

axes(h5)
axis square
hold on 
plot([2 2], [0 4], 'k-');
plot([0 4], [0.5 0.5], 'k--');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 1]);
set(gca, 'XTickLabel', {'L-LOW', 'L-HIGH', 'H-LOW', 'H-HIGH'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
title({'\fontsize{12}Risk Preferences', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

axes(h6);
axis square
hold on 
plot([0 4], [0 0], 'k--');
plot([2 2], [0 0.3], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 0.3]);
set(gca, 'XTickLabel', {'L-LOW', 'L-HIGH', 'H-LOW', 'H-HIGH'});
set(gca, 'XTickLabelRotation', 45);
ylabel('abs(P(Risky)-0.5)');
title({'\fontsize{12}Change in Risk Attitude', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

saveFigname = ['choice_phasicPupil_riskPreferences'];
print(saveFigname, '-dpng');