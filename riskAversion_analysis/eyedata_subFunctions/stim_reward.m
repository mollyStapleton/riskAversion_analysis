function stim_reward(base_path, dataIn)

subs            = unique(dataIn.subIdx);
cnd2run         = [2 3];

rewardCoeff     = [];
riskyCoeff      = [];
reward_pupilCoeff     = [];
risky_pupilCoeff      = [];

% generate matrix for analyses
% matrix with reward and riksy choice info from trial(t) and (t-1)

reward_t1 = nan(size(dataIn, 1), 1);
risky_t1  = nan(size(dataIn, 1), 1);
cnd_t1    = nan(size(dataIn, 1), 1);

glmeData  = dataIn(:, [1:8, 14, 15, 24, 25]);

figure(1);
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [4.3392 0.0212 23.0928 20.6587]);
h1 = subplot(2, 2, 1);
h2 = subplot(2, 2, 2);
h3 = subplot(2, 2, 3);
h4 = subplot(2, 2, 4);

for idata = 2: size(dataIn, 1)

    reward_t1(idata, 1) = dataIn.reward(idata-1);
    risky_t1(idata, 1)  = dataIn.riskyChoice(idata-1);
    cnd_t1(idata, 1)    = dataIn.cndIdx(idata-1);

end

glmeData.reward_t1 = reward_t1;
glmeData.risky_t1  = risky_t1;
glmeData.cnd_t1    = cnd_t1;
stim_deriv_data   = cell(2, 2);
rew_deriv_data    = cell(2, 2);

for isubject = 1: length(subs)
   
    subIdx            = find(glmeData.subIdx == subs(isubject));
    subData{isubject} = glmeData(subIdx, :);

    % perform glme to assess any predictive effect over stimulus-related
    % pupil arousal by the previous trial condition, choice made and reward
    % delivered - split by condition to account for difference in pupil
    % size 

    for itype = 1:2

        if itype == 1
            col2plot = [0.7059 0.4745 0.9882];
%             col2plot_alpha = [0.9255    0.8039    0.9804];
        else
            col2plot = [0.3961 0.9608 0.3647];
%             col2plot_alpha = [ 0.7176    0.9882    0.7020];
        end


        for icnd = 1:2
            
    
            cndIdx = []; cndData = []; prev_beta = []; t_beta_rew = []; t_beta_risk = [];

            cndIdx = find(subData{isubject}.cndIdx == cnd2run(icnd) & subData{isubject}.distType == itype);

            % removal of NaN trials in feedback epoch - error in encoding
            % occurs sometimes 
            cndData = subData{isubject}(cndIdx, :);
            tmpNaN = [];
            tmpNaN = find(~isnan(cndData.feedback_prtileResp_pupil));
            if ~isempty(tmpNaN)
                cndData = subData{isubject}(cndIdx(tmpNaN), :);
            end
            
            % interested in main effects of previous reward and risky
            % choice over stimulus-pupil arousal trial (t) 

            prev_beta = fitglme(cndData,...
                'stim_prtileResp_pupil ~ reward_t1 + risky_t1 + (1|trialNum)');
            
            dataCoeff_t1{isubject}{icnd, itype}       = dataset2cell(prev_beta.Coefficients);
            plotData_t1{isubject}{icnd, itype}        = cell2num(dataCoeff_t1{isubject}{icnd, itype}([3:4], 2));


            [~, ~, t_beta_rew]                        = glmfit(cndData.stim_prtileResp_pupil, cndData.reward, 'normal');            
            plotData_t_rew{isubject}(icnd, itype)     = t_beta_rew.beta(2);
           
            % check no NaN in risky choice 
            
            [~, ~, t_beta_risk] = glmfit(cndData.stim_prtileResp_pupil, cndData.riskyChoice, 'binomial', 'link', 'probit');            
            plotData_t_risk{isubject}(icnd, itype)  = t_beta_risk.beta(2);           
            
            tmpData_reward{icnd}(itype, :)            = [subs(isubject) cnd2run(icnd) itype plotData_t1{isubject}{icnd, itype}(1)];
            tmpData_risk{icnd}(itype, :)              = [subs(isubject) cnd2run(icnd) itype plotData_t1{isubject}{icnd, itype}(2)];
            tmpData_reward_pupil{icnd}(itype, :)      = [subs(isubject) cnd2run(icnd) itype plotData_t_rew{isubject}(icnd, itype)];
            tmpData_risk_pupil{icnd}(itype, :)        = [subs(isubject) cnd2run(icnd) itype plotData_t_risk{isubject}(icnd, itype)];
            
        end

        % REWARD SIZE OR RISKY CHOICE PREDICTED BY STIMULUS PUPIL SIZE (t)?
        for iplot = 1:2


            if iplot == 1 
                axes(h1); % reward pred. by stim pupil arousal
                hold on 
                % plot risky(L) coeff vs risky(H) coeff
                plot([plotData_t_rew{isubject}(1, itype)], [plotData_t_rew{isubject}(2, itype)], '.',...
                'Color', col2plot, 'MarkerSize', 25);

            else 
                axes(h2); % risky choice pred. by stim pupil arousal
                hold on 
                % plot risky(L) coeff vs risky(H) coeff
                plot([plotData_t_risk{isubject}(1, itype)], [plotData_t_risk{isubject}(2, itype)], '.',...
                'Color', col2plot, 'MarkerSize', 25);
            end

           
        end

        % STIMULUS PUPIL PREDICTED BY PREVIOUS TRIAL REWARD OR RISK (t-1)?
        for iplot = 1:2


            if iplot == 1 
                axes(h3); %reward coefficients (t-1)
            else 
                axes(h4); %risky choice coefficients (t-1)
            end

            hold on 
            % plot risky(L) coeff vs risky(H) coeff
            plot([plotData_t1{isubject}{1, itype}(iplot)], [plotData_t1{isubject}{2, itype}(iplot)], '.',...
                'Color', col2plot, 'MarkerSize', 25);

        end

    end
 
     
        rewardCoeff          = [rewardCoeff; cell2mat(tmpData_reward');];
        riskyCoeff           = [riskyCoeff; cell2mat(tmpData_risk')];
        reward_pupilCoeff    = [reward_pupilCoeff; cell2mat(tmpData_reward_pupil');];
        risky_pupilCoeff     = [risky_pupilCoeff; cell2mat(tmpData_risk_pupil')];
          
end

axes(h1);
axis square
xlim([-15 15]);
ylim([-25 25]);
ylabel('Risk(High)');
xlabel('Risk(Low)');
x2plot = linspace(-15, 15);
y2plot = linspace(-25, 25);
hold on 
plot(x2plot, y2plot, 'k-');
title('Main Effect: Reward (t)');
set(gca, 'fontName', 'times');
axes(h2);
axis square
xlim([-0.6 0.6]);
ylim([-0.6 0.6]);
ylabel('Risk(High)');
xlabel('Risk(Low)');
x2plot = linspace(-0.6, 0.6);
hold on 
plot(x2plot, x2plot, 'k-');
title('Main Effect: Risk (t)');
set(gca, 'fontName', 'times');
axes(h3);
axis square
xlim([-0.15 0.15]);
ylim([-0.15 0.15]);
set(gca, 'XTick', [-0.15:.05:0.15]);
set(gca, 'YTick', [-0.15:.05:0.15]);
ylabel('Risk(High)');
xlabel('Risk(Low)');
x2plot = linspace(-0.15, 0.15);
hold on 
plot(x2plot, x2plot, 'k-');
title('Main Effect: Reward (t-1)');
set(gca, 'fontName', 'times');
axes(h4);
axis square
xlim([-4 4]);
ylim([-15 15]);
% set(gca, 'XTick', [-0.15:.05:0.15]);
% set(gca, 'YTick', [-0.15:.05:0.15]);
ylabel('Risk(High)');
xlabel('Risk(Low)');
x2plot = linspace(-4, 4);
y2plot = linspace(-15, 15);
hold on 
plot(x2plot, y2plot, 'k-');
title('Main Effect: Risky Choice (t-1)');
set(gca, 'fontName', 'times');

% test if array of coefficients is significant from 0 
rewardStats = array2table(rewardCoeff);
rewardStats.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'beta'};

riskStats = array2table(riskyCoeff);
riskStats.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'beta'};


rewardStats_pupil = array2table(reward_pupilCoeff);
rewardStats_pupil.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'beta'};

riskStats_pupil = array2table(risky_pupilCoeff);
riskStats_pupil.Properties.VariableNames = {'subIdx', 'cndIdx', 'distIdx', 'beta'};

for icnd = 1:2

    tmpIdx      = [];
    tmpIdx      = find(rewardStats.cndIdx == cnd2run(icnd));
    data2run    = [];
    data2run    = rewardStats(tmpIdx, :);

    [~,rew_p_btDist(icnd),~,rew_STATS_btDist{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)], [data2run.beta(data2run.distIdx == 2)])
    [~,rew_p_gauss(icnd),~,rew_STATS_gauss{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)]);
    [~,rew_p_bimodal(icnd),~,rew_STATS_bimodal{icnd}] = ttest([data2run.beta(data2run.distIdx == 2)]);
    

    tmpIdx      = [];
    tmpIdx      = find(riskStats.cndIdx == cnd2run(icnd));
    data2run    = [];
    data2run    = riskStats(tmpIdx, :);

    [~,risk_p_btDist(icnd),~,risk_STATS_btDist{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)], [data2run.beta(data2run.distIdx == 2)])
    [~,risk_p_gauss(icnd),~,risk_STATS_gauss{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)]);
    [~,risk_p_bimodal(icnd),~,risk_STATS_bimodal{icnd}] = ttest([data2run.beta(data2run.distIdx == 2)]);

    tmpIdx      = [];
    tmpIdx      = find(rewardStats_pupil.cndIdx == cnd2run(icnd));
    data2run    = [];
    data2run    = rewardStats_pupil(tmpIdx, :);

    [~,rewPupil_p_btDist(icnd),~,rewPupil_STATS_btDist{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)], [data2run.beta(data2run.distIdx == 2)])
    [~,rewPupil_p_gauss(icnd),~,rewPupil_STATS_gauss{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)]);
    [~,rewPupil_p_bimodal(icnd),~,rewPupil_STATS_bimodal{icnd}] = ttest([data2run.beta(data2run.distIdx == 2)]);
    
    tmpIdx      = [];
    tmpIdx      = find(riskStats_pupil.cndIdx == cnd2run(icnd));
    data2run    = [];
    data2run    = riskStats_pupil(tmpIdx, :);

    [~,riskPupil_p_btDist(icnd),~,riskPupil_STATS_btDist{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)], [data2run.beta(data2run.distIdx == 2)])
    [~,riskPupil_p_gauss(icnd),~,riskPupil_STATS_gauss{icnd}] = ttest([data2run.beta(data2run.distIdx == 1)]);
    [~,riskPupil_p_bimodal(icnd),~,riskPupil_STATS_bimodal{icnd}] = ttest([data2run.beta(data2run.distIdx == 2)]);
    


end


end
