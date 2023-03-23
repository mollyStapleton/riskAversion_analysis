function sbr_correlations(base_path, dataIn)

%load in sbr data matrix
loadFilename = ['sbr_all_data.mat'];
cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\');
load(loadFilename, 'sbr_all_data');

subs = unique(dataIn.subIdx);
cnd2run = [2 3];

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [8.7207 11.5570 31.4960 8.5778])
h1 = subplot(1, 3, 1);
h2 = subplot(1, 3, 2);
h3 = subplot(1, 3, 3);

allData = [];

for isubject = 1: length(subs);

    tmpSub = [];
    subIdx = dataIn.subIdx == subs(isubject);
    tmpSub = dataIn(subIdx, :);

    sbrIdx = sbr_all_data(:, 1) == subs(isubject);
    
    avgSbr(isubject) = nanmean(sbr_all_data(sbrIdx, 3));
    tmpSave_dist = [];

    if avgSbr(isubject) ~= 0 
        for itype = 1:2
        
            tmpDist = [];
            distIdx = [];
            distIdx = tmpSub.distType == itype;
            
            tmpDist = tmpSub(distIdx, :);
    
            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
                col2plot_alpha = [0.9255    0.8039    0.9804];
            else
                col2plot = [0.3961 0.9608 0.3647];
                col2plot_alpha = [ 0.7176    0.9882    0.7020];
            end
    
            accIdx  = [];
            accIdx  = tmpDist.cndIdx == 1;
            accuracy_rates(isubject, itype) = sum(tmpDist.accChoice(accIdx))./...
                                                length(accIdx == 1);
    
            axes(h1);
            hold on 
            plot(avgSbr(isubject),accuracy_rates(isubject, itype), '.', 'MarkerSize', 30,...
                'color', col2plot_alpha);
    
            tmpSave =[];

            for icnd = 1:2
    
                data2run    = [];
                cndIdx      = tmpDist.cndIdx == cnd2run(icnd);
                data2run    = tmpDist(cndIdx, :);
    
                if icnd == 1 
                    x2plot = [1 1.5 2];
                    prop_risky_low{isubject, itype}(icnd) = sum(data2run.riskyChoice==1)./...
                            length(data2run.riskyChoice);
    
                    axes(h2);
                    hold on 
                    plot(avgSbr(isubject), prop_risky_low{isubject, itype}(icnd), '.', 'MarkerSize', 30,...
                        'color', col2plot_alpha);

                    tmpSave(icnd, :) = [subs(isubject) cnd2run(icnd) itype avgSbr(isubject) accuracy_rates(isubject, itype),...
                        prop_risky_low{isubject, itype}(icnd)];
                else 
                    x2plot = [3 3.5 4];
                    prop_risky_high{isubject, itype}(icnd) = sum(data2run.riskyChoice==1)./...
                            length(data2run.riskyChoice);
                    axes(h3);
                    hold on 
                    plot(avgSbr(isubject), prop_risky_high{isubject, itype}(icnd), '.', 'MarkerSize', 30,...
                        'color', col2plot_alpha);
                    tmpSave(icnd, :) = [subs(isubject) cnd2run(icnd) itype avgSbr(isubject) accuracy_rates(isubject, itype),...
                        prop_risky_high{isubject, itype}(icnd)];
                end           

            end

            tmpSave_dist = [tmpSave_dist; tmpSave];
        
        end 
    end

    allData = [allData; tmpSave_dist];
end

allData = array2table(allData);
allData.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'avgSbr', 'accuracy', 'riskyPref'};
gaussIdx = allData.distIdx == 1;
gauss_allData = allData(gaussIdx, :);
bimodalIdx = allData.distIdx == 2;
bimodal_allData = allData(bimodalIdx, :);

% sbr ~ accuracy rates
axes(h1);
axis square;
xlim([0 50]);
ylim([0.2 0.8]);
hold on 
plot([0 50], [0.5 0.5], 'k--');
xlabel('Spontaneous EBR');
ylabel('Accuracy Rates');

[rho, pr] = corr(gauss_allData.avgSbr, gauss_allData.accuracy, 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h1, 1);
coefficients = polyfit(gauss_allData.avgSbr, gauss_allData.accuracy, 1);
xFit = linspace(min(gauss_allData.avgSbr), max(gauss_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.7059 0.4745 0.9882], 'linew', 2);

[rho, pr] = corr(bimodal_allData.avgSbr, bimodal_allData.accuracy, 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h1, 2);
coefficients = polyfit(bimodal_allData.avgSbr, bimodal_allData.accuracy, 1);
xFit = linspace(min(bimodal_allData.avgSbr), max(bimodal_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.3961 0.9608 0.3647], 'linew', 2);

title('\fontsize{12} \bf sEBR ~ Accuracy');
set(gca, 'fontName', 'times');

% sbr ~ riskPref (both-low)

axes(h2);
axis square 
xlim([0 50]);
ylim([0 1]);
hold on 
plot([0 50], [0.5 0.5], 'k--');
lowCnd_gauss = find(gauss_allData.cndIdx == 2);
highCnd_gauss = find(gauss_allData.cndIdx == 3);
[rho, pr] = corr(gauss_allData.avgSbr(lowCnd_gauss), gauss_allData.riskyPref(lowCnd_gauss), 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h2, 1);
coefficients = polyfit(gauss_allData.avgSbr(lowCnd_gauss), gauss_allData.riskyPref(lowCnd_gauss), 1);
xFit = linspace(min(gauss_allData.avgSbr), max(gauss_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.7059 0.4745 0.9882], 'linew', 2);

lowCnd_bimodal = find(bimodal_allData.cndIdx == 2);
highCnd_bimodal = find(bimodal_allData.cndIdx == 3);
[rho, pr] = corr(bimodal_allData.avgSbr(lowCnd_bimodal), bimodal_allData.riskyPref(lowCnd_bimodal), 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h2, 2);
coefficients = polyfit(bimodal_allData.avgSbr(lowCnd_bimodal), bimodal_allData.riskyPref(lowCnd_bimodal), 1);
xFit = linspace(min(bimodal_allData.avgSbr), max(bimodal_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.3961 0.9608 0.3647], 'linew', 2);
xlabel('Spontaneous EBR');
ylabel('P(Risky|Both-LOW)');
title('\fontsize{12} \bf sEBR ~ P(Risky|Both-LOW)');
set(gca, 'fontName', 'times');


% sbr ~ riskyPref (both-high)
axes(h3);
axis square 
xlim([0 50]);
ylim([0 1]);
hold on 
plot([0 50], [0.5 0.5], 'k--');
[rho, pr] = corr(gauss_allData.avgSbr(highCnd_gauss), gauss_allData.riskyPref(highCnd_gauss), 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h3, 1);
coefficients = polyfit(gauss_allData.avgSbr(highCnd_gauss), gauss_allData.riskyPref(highCnd_gauss), 1);
xFit = linspace(min(gauss_allData.avgSbr), max(gauss_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.7059 0.4745 0.9882], 'linew', 2);
[rho, pr] = corr(bimodal_allData.avgSbr(highCnd_bimodal), bimodal_allData.riskyPref(highCnd_bimodal), 'Type', 'Spearman');
[corrText] = genCorrText(rho, pr, gauss_allData.avgSbr, h3, 2);
coefficients = polyfit(bimodal_allData.avgSbr(highCnd_bimodal), bimodal_allData.riskyPref(highCnd_bimodal), 1);
xFit = linspace(min(bimodal_allData.avgSbr), max(bimodal_allData.avgSbr), 1000);
yFit = polyval(coefficients , xFit);
hold on 
plot(xFit, yFit, '-', 'color', [0.3961 0.9608 0.3647], 'linew', 2);
xlabel('Spontaneous EBR');
ylabel('P(Risky|Both-HIGH)');
title('\fontsize{12} \bf sEBR ~ P(Risky|Both-HIGH)');
set(gca, 'fontName', 'times');

saveFolder = ['sEBR']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

saveFigname = ['accuracy_riskPreferences'];
print(saveFigname, '-dpng');

end
