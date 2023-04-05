function analysisDrafting(base_path, dataIn)

subs                = unique(dataIn.subIdx);
cnd2run             = [2 3];
EV                  = {[50 40 60], [[0 0]; [50 75]; [200 300]]};
data2plot           = [];

% cndIdx              = find(dataIn.cndIdx == cnd2run(1) | dataIn.cndIdx == cnd2run(2) );
% dataIn              = dataIn(cndIdx, :);

for itype = 1:2

    distIdx  = [];
    distIdx  = find(dataIn.distType == itype);
    data2run = [];
    data2run = dataIn(distIdx, :);
    rewSize  = NaN(1, size(data2run, 1));

    for idata = 1: size(data2run, 1)
        if itype == 1 
            % Gaussian Distribution 
            % identify High vs Low rewards in relation to the EV of the
            % condition: cnd [1 2 3]; EV [50 40 60];
            % low reward = 0; high reward = 1;
             tmpEV = [];
             cndIdx = data2run.cndIdx(idata);
             tmpEV  = EV{itype}(cndIdx);

            if data2run.reward(idata) == tmpEV

                rewSize(idata) = NaN;

            elseif data2run.reward(idata) < tmpEV

                rewSize(idata) = 0;

            elseif data2run.reward(idata) > tmpEV

                rewSize(idata) = 1;

            end
   
        else 
            % Bimodal Distribution 
            % identify High vs Low rewards, simply accoridng to whether
            % subjects recieved rewards == to 0 or not 
            % reward == 0 =  0; reward ~= 0 = 1;


            if data2run.reward(idata) == 0

                rewSize(idata) = 0;

            else
                rewSize(idata) = 1;

            end
        end

    end
      
    data2run.rewardSize = rewSize';
    data2plot{itype}    = data2run;
   
end

%----------------------------------------------------
% PLOT PUPIL DERIVATIVE ACCORDING TO REWARD SIZE 
%----------------------------------------------------
% GAUSSIAN PLOT--------------------------------------------

figure(1);
h1 = subplot(1, 2, 1);
h2 = subplot(1, 2, 2);
% h3 = subplot(2, 2, 3);
% h4 = subplot(2, 2, 4);

gcol = [[0.83 0.71 0.98]; [0.62 0.35 0.99]];
bcol = [[0.58 0.99 0.56]; [0.19 0.62 0.14]];
rewardCat = [0 1];

for itype = 1:2

    data2use = [];
    data2use = data2plot{itype};

    if itype == 1 
        col2plot = gcol;
    else 
        col2plot = bcol;
    end

    for icat = 1:2
    
%             if itype == 1 
                axes(h1);
%             else 
%                 axes(h3);
%             end
            
            hold on
            tmpIdx = [];
            tmpIdx = find([data2use.rewardSize] == rewardCat(icat));
            mean_deriv{itype, icat} = nanmean(cell2mat(data2use.stimLocked_deriv(tmpIdx)')');
            SEM_deriv{itype, icat} = nanstd(cell2mat(data2use.stimLocked_deriv(tmpIdx)')')...
                ./sqrt(length(cell2mat(data2use.stimLocked_deriv(tmpIdx)')'));
            timeVec = linspace(-0.2, 0.8, 51);
            plot(timeVec, mean_deriv{itype, icat}, 'linestyle', '--', 'color', col2plot(icat, :), 'Linew', 1.5);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [mean_deriv{itype, icat}  + SEM_deriv{itype, icat} ,...
            fliplr([mean_deriv{itype, icat}  - SEM_deriv{itype, icat} ])];
            fill(x2plot, error2plot, col2plot(icat, :), 'linestyle', 'none');
            alpha(0.25);
        
            mean_stim{itype, icat} = nanmean(cell2mat(data2use.stimLocked_pupil(tmpIdx)')');
            SEM_stim{itype, icat} = nanstd(cell2mat(data2use.stimLocked_pupil(tmpIdx)')')...
                ./sqrt(length(cell2mat(data2use.stimLocked_pupil(tmpIdx)')'));
            timeVec = linspace(-0.2, 0.8, 51);
            plot(timeVec, mean_stim{itype, icat}, 'linestyle', '-', 'color', col2plot(icat, :), 'Linew', 1.5);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [mean_stim{itype, icat}  + SEM_stim{itype, icat}  ,...
            fliplr([mean_stim{itype, icat}  - SEM_stim{itype, icat} ])];
            fill(x2plot, error2plot, col2plot(icat, :), 'linestyle', 'none');
            alpha(0.25);
    
%             if itype == 1 
                axes(h2);
%             else 
%                 axes(h4);
%             end

            hold on
            tmpIdx = [];
            tmpIdx = find(data2use.rewardSize == rewardCat(icat));
            mean_deriv_resp{itype, icat} = nanmean(cell2mat(data2use.respLocked_deriv(tmpIdx)')');
            SEM_deriv_resp{itype, icat} = nanstd(cell2mat(data2use.respLocked_deriv(tmpIdx)')')...
                ./sqrt(length(cell2mat(data2use.respLocked_deriv(tmpIdx)')'));
            timeVec = linspace(0, 3.1, 156);
            plot(timeVec, mean_deriv_resp{itype, icat}, 'linestyle', '--', 'color', col2plot(icat, :), 'Linew', 1.5);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [mean_deriv_resp{itype, icat}  + SEM_deriv_resp{itype, icat} ,...
            fliplr([mean_deriv_resp{itype, icat}  - SEM_deriv_resp{itype, icat} ])];
            fill(x2plot, error2plot, col2plot(icat, :), 'linestyle', 'none');
            alpha(0.25);
        
            mean_stim_resp{itype,icat} = nanmean(cell2mat(data2use.respLocked_pupil(tmpIdx)')');
            SEM_stim_resp{itype,icat} = nanstd(cell2mat(data2use.respLocked_pupil(tmpIdx)')')...
                ./sqrt(length(cell2mat(data2use.respLocked_pupil(tmpIdx)')'));
            timeVec = linspace(0, 3.1, 156);
            plot(timeVec, mean_stim_resp{itype,icat}, 'linestyle', '-', 'color', col2plot(icat, :), 'Linew', 1.5);
            x2plot = [timeVec fliplr(timeVec)];
            error2plot = [mean_stim_resp{itype,icat}  + SEM_stim_resp{itype,icat}  ,...
            fliplr([mean_stim_resp{itype,icat}  - SEM_stim_resp{itype,icat} ])];
            fill(x2plot, error2plot, col2plot(icat, :), 'linestyle', 'none');
            alpha(0.25);
    
    end
end

axes(h1);
hold on
xlim([-0.2 0.8]);
plot([-0.2 0.8], [0 0], 'k--');
[y2plot_min, y2plot_max] = ylimit_adapt(h1, h2);
axes(h1);
ylim([y2plot_min y2plot_max]);
plot([0 0], [y2plot_min y2plot_max], 'k-'); %Stimulus On
xlabel('Time from Stimulus Onset (\it{s})');
ylabel({'Pupil Response'});
title('\fontsize{14} \bfPupil: Stimulus Locked')
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
ylabel({'Pupil Response'});
title('\fontsize{14} \bfPupil: Response Locked')
set(gca, 'FontName', 'times');
% 
% axes(h3);
% hold on
% xlim([-0.2 0.8]);
% plot([-0.2 0.8], [0 0], 'k--');
% [y2plot_min, y2plot_max] = ylimit_adapt(h3, h4);
% axes(h3);
% ylim([y2plot_min y2plot_max]);
% plot([0 0], [y2plot_min y2plot_max], 'k-'); %Stimulus On
% xlabel('Time from Stimulus Onset (\it{s})');
% ylabel({'Pupil Response'});
% % title('\fontsize{14} \bfPupil: Stimulus Locked')
% set(gca, 'FontName', 'times');
% axes(h4);
% hold on
% xlim([0 3.1]);
% hold on 
% plot([0 3.1], [0 0], 'k--');
% ylim([y2plot_min y2plot_max]);
% plot([0.8 0.8],[y2plot_min y2plot_max], 'k-'); %choice indicated
% plot([1.6 1.6], [y2plot_min y2plot_max], 'k-'); %reward feedback
% xlabel('Time from Response Onset (\it{s})');
% ylabel({'Pupil Response'});
% % title('\fontsize{14} \bfPupil: Response Locked')
% set(gca, 'FontName', 'times');
end