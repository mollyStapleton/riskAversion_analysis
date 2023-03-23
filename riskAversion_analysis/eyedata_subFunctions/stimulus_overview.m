subs    = unique(dataIn.subIdx);
cnd2run = [2 3];

statsData                   = [];
phasicStim_z                = cell(1, 3);
phasicStim_deriv            = cell(1, 3);
phasicDist_stim_deriv       = cell(1, 2);
phasicDist_stim_z           = cell(1, 2);
phasicStim_cndDist_z        = cell(3, 2);
phasicStim_cndDist_deriv    = cell(3, 2);

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [6.5193 0.0212 10.3082 20.6587])
h3 = subplot(2, 1, 1);
h4 = subplot(2, 1, 2);
figure(2);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [6.5193 0.0212 10.3082 20.6587])
h1 = subplot(2, 1, 1);
h2 = subplot(2, 1, 2);

mdl = fitglme(dataIn, 'stim_prtileResp_pupil ~ cndIdx * distType + (1|subIdx) + (1|subIdx:cndIdx:distType)');

for isubject = 1: length(subs)

    subIdx  = [];
    tmpSub  = [];

    subIdx  = find(dataIn.subIdx == subs(isubject));
    tmpSub  = dataIn(subIdx, :);
    
    tmpDist = [];
    tmpDiff = [];

    for icnd = 1:3

        cndIdx = [];
        cndIdx = find(tmpSub.cndIdx == icnd);

        phasicStim(isubject, icnd) = nanmean(tmpSub.stim_prtileResp_pupil(cndIdx));
        axes(h3);
        hold on
        plot(icnd, phasicStim(isubject, icnd), 'o', 'MarkerEdgeColor',...
            [0.7 0.7 0.7], 'MarkerSize', 10, 'LineWidth', 1.5);

        phasicStim_z{icnd}                = [phasicStim_z{icnd}; cell2mat(tmpSub.stim_aligned_pupil(cndIdx)')'];
        phasicStim_deriv{icnd}            = [phasicStim_deriv{icnd}; cell2mat(tmpSub.stim_derivative(cndIdx)')'];

        for itype = 1:2


            if itype == 1
                col2plot = [0.7059 0.4745 0.9882];
            else
                col2plot = [0.3961 0.9608 0.3647];
            end

            distIdx = find(tmpSub.distType == itype);

            phasicDist_stim(isubject, itype) = nanmean(tmpSub.stim_prtileResp_pupil(distIdx));

            phasicDist_stim_z{itype} = [phasicDist_stim_z{itype};  cell2mat(tmpSub.stim_aligned_pupil(distIdx)')'];
            phasicDist_stim_deriv{itype} = [phasicDist_stim_deriv{itype};  cell2mat(tmpSub.stim_derivative(distIdx)')'];
            axes(h4);
            hold on 
            plot(itype, phasicDist_stim(isubject, itype), 'o',...
            'MarkerEdgeColor', col2plot, 'MarkerSize', 10, 'LineWidth', 1.5);

        end

        if icnd ~= 1

            for itype = 1:2

               if itype == 1
                    col2plot = [0.7059 0.4745 0.9882];
               else
                    col2plot = [0.3961 0.9608 0.3647];
               end
                cndIdx = [];
                cndIdx = find(tmpSub.cndIdx == icnd & tmpSub.distType == itype);
               
                phasicStim_cndDist{isubject}(icnd, itype) = nanmean(tmpSub.stim_prtileResp_pupil(cndIdx));               
                phasicStim_diff{isubject}(icnd, itype) = phasicStim_cndDist{isubject}(icnd, itype) - phasicStim(isubject, icnd);

                phasicStim_cndDist_z{icnd, itype}      = [phasicStim_cndDist_z{icnd, itype} ; cell2mat(tmpSub.stim_aligned_pupil(cndIdx)')'];
                phasicStim_cndDist_deriv{icnd, itype}   = [phasicStim_cndDist_deriv{icnd, itype} ; cell2mat(tmpSub.stim_derivative(cndIdx)')'];

                tmpDist = [tmpDist; phasicStim_cndDist{isubject}(icnd, itype)'];
                tmpDiff = [tmpDiff; phasicStim_diff{isubject}(icnd, itype)'];
            end

          
        end

    end

    axes(h1);
    hold on 
    %Gaussian
    plot([phasicStim_cndDist{isubject}(2, 1)], [phasicStim_cndDist{isubject}(3, 1)], 'o',...
        'MarkerEdgeColor', [0.7059 0.4745 0.9882], 'MarkerSize', 10, 'LineWidth', 1.5);
    %Bimodal
    plot([phasicStim_cndDist{isubject}(2, 2)], [phasicStim_cndDist{isubject}(3, 2)], 'o',...
        'MarkerEdgeColor', [0.3961 0.9608 0.3647], 'MarkerSize', 10, 'LineWidth', 1.5);


    axes(h2);
    hold on 
    %Gaussian
    plot([phasicStim_diff{isubject}(2, 1)], [phasicStim_diff{isubject}(3, 1)], 'o',...
        'MarkerEdgeColor', [0.7059 0.4745 0.9882], 'MarkerSize', 10, 'LineWidth', 1.5);
    %Bimodal
    plot([phasicStim_diff{isubject}(2, 2)], [phasicStim_diff{isubject}(3, 2)], 'o',...
        'MarkerEdgeColor', [0.3961 0.9608 0.3647], 'MarkerSize', 10, 'LineWidth', 1.5);

   allData   = [tmpDist; tmpDiff];
   subID(1:4)= subs(isubject);
   statsData = [statsData; tmpDist, tmpDiff, [2 3 2 3]', [1 1 2 2]', subID'];

end

saveFolder = ['stimulus_phasicPupilBins']; 
if ~exist([base_path '\' saveFolder])
    mkdir([base_path '\' saveFolder])    
end
cd([base_path '\' saveFolder]);

statsData = array2table(statsData);
statsData.Properties.VariableNames = {'phasic_raw', 'phasic_diff', 'cndIdx', 'distIdx', 'subIdx'};
axes(h3);
axis square
xlim([0 4]);
ylim([0 6]);
xlabel('\fontsize{12} \bfCondition Type');
ylabel({'\fontsize{12} \bfPhasic Pupil' ,'(Stimulus Onset)'});
set(gca, 'XTick', [1 2 3]);
set(gca, 'XTickLabel', {'DIFFERENT', 'LOW', 'HIGH'});
title({'\fontsize{16} \bf Average Phasic Arousal across', 'Mean Condition Types'});
set(gca, 'fontname', 'times');

mean_cond = mean(phasicStim);
sem_cond  = std(phasicStim)./sqrt(length(phasicStim));

hold on 
[hbar herrorbar] = barwitherr(sem_cond, mean_cond, 'EdgeColor', [0 0 0], 'FaceColor', [1 1 1],...
    'FaceAlpha', 0, 'linew', 1.2);

axes(h4);
axis square
xlim([0 3]);
ylim([0 6]);
xlabel('\fontsize{12} \bfCondition Type');
ylabel({'\fontsize{12} \bfPhasic Pupil' ,'(Stimulus Onset)'});
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabel', {'Gaussian', 'Bimodal'});
title({'\fontsize{16} \bf Average Phasic Arousal across', 'Distribution Types'});
set(gca, 'fontname', 'times');

cndDist = cell2mat(phasicStim_cndDist);
mean_dist = nanmean(cndDist');
sem_dist  = std(cndDist')./sqrt(length(cndDist'));

hold on 
[hbar herrorbar] = barwitherr(sem_dist(2), mean_dist(2), 'EdgeColor', [0.7059 0.4745 0.9882], 'FaceColor', [1 1 1],...
    'FaceAlpha', 0, 'linew', 1.2);
hbar.XData = 1;
herrorbar.XData = 1;
hold on
[hbar herrorbar] = barwitherr(sem_dist(3), mean_dist(3), 'EdgeColor', [0.3961 0.9608 0.3647], 'FaceColor', [1 1 1],...
    'FaceAlpha', 0, 'linew', 1.2);
hbar.XData = 2;
herrorbar.XData = 2;

saveFigname = ['arousalOverview_cndDist'];
print(saveFigname, '-dpng');

axes(h1);
axis square
ylim([0 6]);
xlim([0 6]);
xlabel('\fontsize{12} \bfBoth-LOW');
ylabel('\fontsize{12} \bfBoth-HIGH');
x2plot = linspace(0, 6);
hold on 
plot(x2plot, x2plot, 'k-');
title({'\fontsize{16} \bf Average Phasic Arousal' 'Risk Conditions'});
set(gca, 'fontname', 'times');
axes(h2);
axis square
ylim([-0.6 0.6]);
xlim([-0.6 0.6]);
xlabel('\fontsize{12} \bfBoth-LOW');
ylabel('\fontsize{12} \bfBoth-HIGH');
x2plot = linspace(-0.6, 0.6);
hold on 
plot(x2plot, x2plot, 'k-');
title({'\fontsize{16} \bf Average Arousal Difference', 'to Condition Baseline'});
set(gca, 'fontname', 'times');
hold on 
plot([-0.6 0.6], [0 0], 'k--');
plot([0 0], [-0.6 0.6], 'k--');


saveFigname = ['arousalOverview_riskCndDists'];
print(saveFigname, '-dpng');


figure(3);
hc = subplot(1, 3, 1);
hd = subplot(1, 3, 2);
hcd = subplot(1, 3, 3);
hold on 
zMean.cnd = cell(1, 3);
zMean.cnd_sem = cell(1, 3);

zDeriv.cnd = cell(1, 3);
zDeriv.cnd_sem = cell(1, 3);

timeVec = linspace(-0.5, 1, 76);
for icnd = 1:3

   
    zMean.cnd{icnd} = nanmean(phasicStim_z{icnd});
    zMean.cnd_sem{icnd} = nanstd(phasicStim_z{icnd})./sqrt(length(phasicStim_z{icnd}));

    zDeriv.cnd{icnd} = nanmean(phasicStim_deriv{icnd});
    zDeriv.cnd_sem{icnd} = nanstd(phasicStim_deriv{icnd})./sqrt(length(phasicStim_deriv{icnd}));

    axes(hc);
    hold on
    if icnd == 1 
        plot(timeVec, zMean.cnd{icnd}, 'k-', 'LineWidth', 1.5);
        plot(timeVec, zDeriv.cnd{icnd}, 'k--', 'LineWidth', 1.5);
    elseif icnd == 2
        plot(timeVec, zMean.cnd{icnd}, 'b-', 'LineWidth', 1.5);
         plot(timeVec, zDeriv.cnd{icnd}, 'b--', 'LineWidth', 1.5);
    elseif icnd == 3 
        plot(timeVec, zMean.cnd{icnd}, 'r-', 'LineWidth', 1.5);
         plot(timeVec, zDeriv.cnd{icnd}, 'r--', 'LineWidth', 1.5);
    end

    for itype = 1:2

       
        zMean.dist{itype} = nanmean(phasicDist_stim_z{itype});
        zMean.dist_sem{itype} = nanstd(phasicDist_stim_z{itype})./sqrt(length(phasicDist_stim_z{itype}));

        zDeriv.dist{itype} = nanmean(phasicDist_stim_deriv{itype});
        zDeriv.dist_sem{itype} = nanstd(phasicDist_stim_deriv{itype})./sqrt(length(phasicDist_stim_deriv{itype}));

        axes(hd);
        hold on 
        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
            plot(timeVec, zMean.dist{itype}, '-', 'color', col2plot, 'LineWidth', 1.5);
            plot(timeVec, zDeriv.dist{itype}, '--', 'color', col2plot, 'LineWidth', 1.5);
        else
            col2plot = [0.3961 0.9608 0.3647];
            plot(timeVec, zMean.dist{itype}, '-', 'color', col2plot, 'LineWidth', 1.5);
            plot(timeVec, zDeriv.dist{itype}, '--', 'color', col2plot, 'LineWidth', 1.5);
        end

        zMean.cndDist{icnd, itype} = nanmean(phasicStim_cndDist_z{icnd, itype});
        zMean.cndDist_sem{icnd, itype} = nanstd(phasicStim_cndDist_z{icnd, itype})./sqrt(length(phasicStim_cndDist_z{icnd, itype}));

        zDeriv.cndDist{icnd, itype} = nanmean(phasicStim_cndDist_deriv{icnd, itype});
        zDeriv.cndDist_sem{icnd, itype} = nanstd(phasicStim_cndDist_deriv{icnd, itype})./sqrt(length(phasicStim_cndDist_deriv{icnd, itype}));

        
        axes(hcd);
        hold on 
        if itype == 1
            if icnd == 2
                col2plot = [0.9255    0.8039    0.9804];
            elseif icnd == 3 
                col2plot = [0.7059 0.4745 0.9882];
            end
            plot(timeVec, zMean.cndDist{icnd, itype}, '-', 'color', col2plot, 'LineWidth', 1.5);
            plot(timeVec, zDeriv.cndDist{icnd, itype}, '--', 'color', col2plot, 'LineWidth', 1.5);
           
        else

            if icnd == 2
                col2plot =  [ 0.7176    0.9882    0.7020];
            elseif icnd == 3 
                col2plot = [0.3961 0.9608 0.3647]
            end
           
            plot(timeVec, zMean.cndDist{icnd, itype}, '-', 'color', col2plot, 'LineWidth', 1.5);
            plot(timeVec, zDeriv.cndDist{icnd, itype}, '--', 'color', col2plot, 'LineWidth', 1.5);
        end
        
    end

end

axes(hc);
axis square
xlim([-0.5 1]);
ylim([-0.5 1]);
hold on 
plot([0 0], [-0.5 1], 'k-');
plot([0.8 0.8], [-0.5 1], 'k-');
hold on 
plot([0.3 0.56], [-0.5 -0.5], '-', 'color', [0.7 0.7 0.7], 'linew', 3)
legend({'Both-DIFF', '', 'Both-LOW', '', 'Both-HIGH'}, 'location', 'northwest');
title('\fontsize{12} \bfConditions');
ylabel('Pupil Response');
set(gca, 'FontName', 'times');
axes(hd);
axis square
xlim([-0.5 1]);
ylim([-0.5 1]);
hold on 
plot([0 0], [-0.5 1], 'k-');
plot([0.8 0.8], [-0.5 1], 'k-');
hold on 
plot([0.3 0.56], [-0.5 -0.5], '-', 'color', [0.7 0.7 0.7], 'linew', 3)
legend({'Gaussian', '', 'Bimodal', ''}, 'location', 'northwest');
ylabel('Pupil Response');
title('\fontsize{12} \bf Distributions - ALL Conditions');
set(gca, 'FontName', 'times');
axes(hcd);
axis square
xlim([-0.5 1]);
ylim([-0.5 1]);
hold on 
plot([0 0], [-0.5 1], 'k-');
plot([0.8 0.8], [-0.5 1], 'k-');
hold on 
plot([0.3 0.56], [-0.5 -0.5], '-', 'color', [0.7 0.7 0.7], 'linew', 3);
ylabel('Pupil Response');
xlabel('Time From Stimulus Onset (s)');
title('\fontsize{12} \bf Distributions - RISK Conditions');
set(gca, 'FontName', 'times');

figure(3);
set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [12.8852 3.4078 25.0455 16.7270]);
saveFigname = 'pupilResponse_z_deriv';
print(saveFigname, '-dpng');
% statistics 
dataLow = statsData((statsData.cndIdx == 2), :);
dataHigh = statsData((statsData.cndIdx == 3), :);






