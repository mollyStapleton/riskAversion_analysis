tmpData_dist    = [];
data2save       = [];

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])
h1 = subplot(2, 2, 1);
h2 = subplot(2, 2, 2);

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [52.5357 6.3500 25.2518 10.9008])
h3 = subplot(1, 2, 1);
h4 = subplot(1, 2, 2);

cnd2run = [2 3];

for icnd = 1:2

    tmpData_dist                        = [];
    if icnd == 1 
        x2plot = [1 1.5];
    else
        x2plot = [2.5 3];
    end

    for itype = 1:2

        
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
        else
            col2plot = [0.3961 0.9608 0.3647];
        end
    
        data2use                            = [];
        dataSplit                           = [];
       
        distIdx                             = find([dataIn.distType] == itype);
        dataSplit                           = dataIn(distIdx, :);
        
        cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
        data2use                            = dataSplit(cndIdx, :);
        medPupil(itype, icnd)               = median(data2use.stim_prtileResp_pupil);
    
        splitIdx{itype}{icnd, 1}            = data2use.stim_prtileResp_pupil < medPupil(itype, icnd);
        splitIdx{itype}{icnd, 2}            = data2use.stim_prtileResp_pupil > medPupil(itype, icnd);
        
        tmpData                             = [];
        tmpBin                              = [];
        tmpData                             = data2use(:, [1:6, 8:9, 14]);
    
        tmpBin(1: size(tmpData, 1))         = 0;

        tmpBin(splitIdx{itype}{icnd, 1})    = 1;
        tmpBin(splitIdx{itype}{icnd, 2})    = 2;

        tmpData.pupilBin                    = tmpBin';
        tmpData_dist                        = [tmpData_dist; tmpData];

        axes(h1);
        hold on 
        plot(x2plot, medPupil(itype, icnd), 'Marker', 'x', 'Color', col2plot, 'MarkerSize', 10, 'LineWidth', 1.2);

        for ibin = 1:2

            mean_pupilBin{itype}(icnd, ibin)       = mean(tmpData.stim_prtileResp_pupil(tmpData.pupilBin == ibin));
            sem_pupilBin{itype}(icnd, ibin)        = std(tmpData.stim_prtileResp_pupil(tmpData.pupilBin == ibin))./...
                sqrt(length(tmpData.stim_prtileResp_pupil(tmpData.pupilBin == ibin)));
            
            figure(1);
            axes(h2);
            hold on
            errorbar(x2plot(ibin), mean_pupilBin{itype}(icnd, ibin), sem_pupilBin{itype}(icnd, ibin), 'marker', 'o',...
                'MarkerFaceColor', col2plot, 'MarkerEdgeColor', col2plot, 'MarkerSize', 7, 'color', col2plot);
            hold on


            figure(2);
            axes(h3)
            % proportion of risky choices made within each pupil bin
            riskPref_pupilBinned{itype}(icnd, ibin)  = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) == 1)./...
                                                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin));
            plot(x2plot(ibin), riskPref_pupilBinned{itype}(icnd, ibin), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            hold on

            axes(h4)
            % proportion of risky choices made within each pupil bin
            riskBias_pupilBinned{itype}(icnd, ibin)  = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) == 1)./...
                                                        length(tmpData.riskyChoice(tmpData.pupilBin == ibin))) -0.5;
            plot(x2plot(ibin), riskBias_pupilBinned{itype}(icnd, ibin), 'o', 'MarkerFaceColor', col2plot, 'linew', 1.2,...
                'MarkerEdgeColor', col2plot, 'MarkerSize', 10);
            hold on
        end

    end
        
        data2save                           = [data2save; tmpData_dist];
end


saveFolder = ['stimulus_phasicPupilBins'];
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

axes(h1)
axis square
hold on 
plot([2 2], [0 4], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 4]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Median Pupil Diameter');
title('\fontsize{12}Median Pupil Diameter');
set(gca, 'FontName', 'times');

axes(h2);
axis square
hold on 
plot([2 2], [0 4], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 4]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Average Pupil Diameter');
title({'\fontsize{12}Average Pupil Diameter', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

savefigName = ['pupilSplit_visual'];
print(savefigName, '-dpng');


figure(2);
axes(h3)
axis square
hold on 
plot([0 4], [0.5 0.5], 'k--');
plot([2 2], [0 1], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 1]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
ylabel('Proportion of Risky Choices');
title({'\fontsize{12}Proportion of Risky Choice', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');
axes(h4);
axis square
hold on 
plot([0 4], [0 0], 'k--');
plot([2 2], [0.2 -0.2], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([-0.2 0.2]);
set(gca, 'XTickLabel', {'LOW-1', 'LOW-2', 'HIGH-1', 'HIGH-2'});
set(gca, 'XTickLabelRotation', 45);
title({'\fontsize{12}Change in Risk Attitude', 'Within Pupil Bins'});
set(gca, 'FontName', 'times');

savefigName = ['pupilSplit_riskyChoice'];
print(savefigName, '-dpng');

riskPupil  =  fitglme(data2save, 'riskyChoice ~ pupilBin*cndIdx*distType + (1|subIdx) + (1|subIdx:distType)');
C = anova(riskPupil);
C = dataset2cell(C);
anovaWriteTable(C, 'stimPhasic_risk');
