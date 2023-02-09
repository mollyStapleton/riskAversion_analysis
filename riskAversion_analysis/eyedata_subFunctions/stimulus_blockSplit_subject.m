figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [61.8278 2.8152 23.5162 11.6628]);
h1 = subplot(1, 2, 1);
h2 = subplot(1, 2, 2);

binned          = [];
binned_all      = [];
binned_both     = [];

subs        = unique(dataIn.subIdx);

t1 = [1:60];
t2 = [61:120];

for it = 1:2
    % split full data set into first and second halves of blocks

    if it == 1
        trials2find = t1;
    else
        trials2find = t2;
    end

    trIdx = [];
    trIdx = find(ismember(dataIn.trialNum, trials2find));

    data2use = dataIn(trIdx, :);

    for isubject = 1: length(subs)

        subIdx = find(data2use.subIdx == subs(isubject));
        tmpSub = data2use(subIdx, :);
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
                
                dataSplit                           = [];

                distIdx                             = find([tmpSub.distType] == itype);
                dataSplit                           = tmpSub(distIdx, :);

                cndIdx                              = dataSplit.cndIdx == cnd2run(icnd);
                data2run                            = dataSplit(cndIdx, :);
                medPupil{it, isubject}(itype, icnd)     = median(data2run.stim_prtileResp_pupil);

                splitIdx{it}{isubject, itype}{icnd, 1}  = data2run.stim_prtileResp_pupil < medPupil{it, isubject}(itype, icnd);
                splitIdx{it}{isubject, itype}{icnd, 2}  = data2run.stim_prtileResp_pupil > medPupil{it, isubject}(itype, icnd);

                tmpData                             = [];
                tmpBin                              = [];
                tmpt                                = [];
                tmpData                             = data2run(:, [1:9, 14]);

                tmpBin(1: size(tmpData, 1))         = 0;

                tmpBin(splitIdx{it}{isubject, itype}{icnd, 1})    = 1;
                tmpBin(splitIdx{it}{isubject, itype}{icnd, 2})    = 2;

                tmpData.pupilBin                    = tmpBin';
                
                tmpt(1: size(tmpData, 1))           = it;
                tmpData.blockSplit                  = tmpt';

                 for ibin = 1:2
        
                        if icnd == 1
                                          
                            prop_risky_low{it}{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                                length(tmpData.riskyChoice(tmpData.pupilBin == ibin));
        
                            diff_risky_low{it}{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                                length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);
        
                            tmpRT           = [];
                            tmpRT           = tmpData(tmpData.pupilBin == ibin, [1:8]);
        
                            tmpTable        = [];
                            tmpTable        = [subs(isubject) cnd2run(icnd) itype prop_risky_low{it}{isubject, itype}(icnd, ibin) diff_risky_low{it}{isubject, itype}(icnd, ibin) ibin it];
                          
        
                            
                            
        
                        else
                           
                            prop_risky_high{it}{isubject, itype}(icnd, ibin) = sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                                length(tmpData.riskyChoice(tmpData.pupilBin == ibin));
        
                            diff_risky_high{it}{isubject, itype}(icnd, ibin) = abs(sum(tmpData.riskyChoice(tmpData.pupilBin == ibin) ==1)./...
                                length(tmpData.riskyChoice(tmpData.pupilBin == ibin))-0.5);
        
                            tmpRT           = [];
                            tmpRT           = tmpData(tmpData.pupilBin == ibin, [1:8]);
                            
                            tmpTable = [];
                            tmpTable = [subs(isubject) cnd2run(icnd) itype prop_risky_high{it}{isubject, itype}(icnd, ibin) diff_risky_high{it}{isubject, itype}(icnd, ibin) ibin it];
                            
        
                        end
                        binned   = [binned; tmpTable];
                        pupilBinVec = [];

                 end
    
                tmpData_dist                        = [tmpData_dist; tmpData];
    
            end
    
        end

        binned_all = [binned_all; binned];
    end

end

binned_all = array2table(binned_all);
binned_all.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'propRisky', 'riskBias', 'pupilBin', 'blockSplit'};

for it = 1:2

    if it == 1 
        axes(h1);
    else 
        axes(h2);
    end

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
    
                mean_binned{it, itype}(icnd, ibin) = mean(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it));
                sem_binned{it, itype}(icnd, ibin)  = std(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it))./...
                                                    sqrt(length(binned_all.propRisky(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it)));
   
      
                hold on
                errorbar(x2plot(ibin), mean_binned{it, itype}(icnd, ibin),  sem_binned{it, itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
             
            end
    
        end
    
    end 
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
plot([0 4], [0.5 0.5], 'k--');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 1]);
set(gca, 'XTickLabel', {'L-LOW', 'L-HIGH', 'H-LOW', 'H-HIGH'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
title({'\fontsize{12}Risk Preferences: 1st Half of Block'});
set(gca, 'FontName', 'times');
axes(h2)
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
title({'\fontsize{12}Risk Preferences: 2nd Half of Block'});
set(gca, 'FontName', 'times');

saveFigname = ['blockSplit_riskPreferences'];
print(saveFigname, '-dpng');

figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [61.8278 2.8152 23.5162 11.6628]);
h3 = subplot(1, 2, 1);
h4 = subplot(1, 2, 2);
for it = 1:2

    if it == 1 
        axes(h3);
    else 
        axes(h4);
    end

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
    
                mean_bias_binned{it, itype}(icnd, ibin) = mean(binned_all.riskBias(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it));
                sem_bias_binned{it, itype}(icnd, ibin)  = std(binned_all.riskBias(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it))./...
                                                    sqrt(length(binned_all.riskBias(binned_all.cndIdx == cnd2run(icnd) & binned_all.pupilBin == ibin & binned_all.distIdx == itype & binned_all.blockSplit == it)));
   
      
                hold on
                errorbar(x2plot(ibin), mean_bias_binned{it, itype}(icnd, ibin),  sem_bias_binned{it, itype}(icnd, ibin), '.', 'MarkerSize', 35, 'color', col2plot, 'linew', 1.2);
             
            end
    
        end
    
    end 
end

axes(h3)
axis square
hold on 
plot([2 2], [0 4], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 0.3]);
set(gca, 'XTickLabel', {'L-LOW', 'L-HIGH', 'H-LOW', 'H-HIGH'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
title({'\fontsize{12}Risk Attitude Shift: 1st Half of Block'});
set(gca, 'FontName', 'times');
axes(h4)
axis square
hold on 
plot([2 2], [0 4], 'k-');
xlim([0 4]);
set(gca, 'XTick', [1 1.5 2.5 3]);
ylim([0 0.3]);
set(gca, 'XTickLabel', {'L-LOW', 'L-HIGH', 'H-LOW', 'H-HIGH'});
set(gca, 'XTickLabelRotation', 45);
ylabel('P(Risky)');
title({'\fontsize{12}Risk Attitude Shift: 2nd Half of Block'});
set(gca, 'FontName', 'times');

saveFigname = ['blockSplit_riskShift'];
print(saveFigname, '-dpng');