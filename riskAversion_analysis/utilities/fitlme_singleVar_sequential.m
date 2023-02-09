function [stats2report, predictDataMat, STATS, model] = fitlme_singleVar_sequential_grouping(dataMat, plotFit, onlyLinearFit)
% sequentially fit LME to data and compare whether linear or quadratic fit are better
% than constant or linear fit, respectively.
% 
% INPUT:
% dataMat: table with all necessary variables (see table.m)
% Y: string that indicates the response variable, this has to be a column in dataMat
% plotFit: plot the fit of the model, default is 0
%
% OUTPUT:
% stats2report: Vector with 
%     1) loglikelihood of model comparison, 
%     2) delta DF: the difference in degrees of freedom in the models that were compared
%     3) p value of model comparison
% meanFit: the mean fit of the model
% CIFit: the confidence intervals of the model fit
% CIFit: the standard error intervals of the model fit
% STATS: stats on the model, the raw beta values etc. 
%
% Example:
% datamat = table(RT, Subject, Bin, 'VariableNames', {'Y','Subject','Bin'});
% [stats2report, meanFit, CIFit, SEFit, STATS, model] = fitlme_singleVar_sequential(datamat, 0);
%
% Jochem van Kempen, 26/06/2018

if nargin < 2
    plotFit = 0;
end

if ~exist('onlyLinearFit','var')
    onlyLinearFit = 0;
end
% dataMat.Bin = categorical(dataMat.Bin);

lme = fitlme(dataMat,['y ~ 1']);% fit constant
lme2 = fitlme(dataMat,['y ~ x']); % fit linear model
if ~onlyLinearFit
    lme3 = fitlme(dataMat,['y ~ x^2']); % fit quadratic model (this includes the linear model), note this doesn't have orthogonal contrasts!!
end
% compare the model fits
comp1 = compare(lme, lme2, 'CheckNesting',true); % compare linear to constant
if ~onlyLinearFit
    comp2 = compare(lme2, lme3, 'CheckNesting',true); % compare quadratic to linear
else
    comp2.pValue = 1;
end

xData = unique(dataMat.x);
predictDataMat = table((sort(xData, 'ascend')), 'variableNames', {'x'});
% xRange = [min(dataMat.x), max(dataMat.x)];
% xRange = xRange + round([-mean(xRange)/2 mean(xRange)/2]);
% predictDataMat = table((xRange(1):xRange(2))', 'VariableNames', {'x'});

if comp2.pValue < 0.05
    
    [~,~,STATS] = fixedEffects(lme3);
    
    lme3_predict = fitlme(dataMat, ['y ~ x^2']);
    
    [fit, fitCI] = predict(lme3_predict, predictDataMat); % get the fitted values for the new x values
    
    stats2report = [comp2.LRStat(2) comp2.deltaDF(2) comp2.pValue(2)];
    
    STATS = STATS(3,:);

    model = 'quadratic';
    
    %     sort( dataMat
    
%     % perform two-lines approach, needs work. easier to do it in R for now
%     [~,sortX] = sort(dataMat.x);
%     sortDataMat = dataMat;
%     sortDataMat = sortDataMat(sortX,:);
%     
%     medianX = median(sortDataMat.x);
%     idx1 = sortDataMat.x<=medianX;
%     idx2 = sortDataMat.x>medianX;
%     
%     lme_u1 = fitlme(sortDataMat(idx1,:),['y ~ 1 ']);% fit constant
%     lme2_u1 = fitlme(sortDataMat(idx1,:),['y ~ x']); % fit linear model
%     comp_u1 = compare(lme_u1, lme2_u1, 'CheckNesting',true); % compare linear to constant
%     
%     lme_u2 = fitlme(sortDataMat(idx2,:),['y ~ 1 ']);% fit constant
%     lme2_u2 = fitlme(sortDataMat(idx2,:),['y ~ x']); % fit linear model
%     comp_u2 = compare(lme_u2, lme2_u2, 'CheckNesting',true); % compare linear to constant
% 
%     estimates = [lme2_u1.fixedEffects lme2_u2.fixedEffects];
%     if sign(estimates(2,1)) ~= sign(estimates(2,2))
%         
%         
%     end
    
elseif comp1.pValue < 0.05
    
    lme2_predict = fitlme(dataMat, 'y~x');
    [fit, fitCI] = predict(lme2_predict, predictDataMat); % get the fitted values for each subject
    [~,~,STATS] = fixedEffects(lme2);
    stats2report = [comp1.LRStat(2) comp1.deltaDF(2) comp1.pValue(2)];
    STATS = STATS(2,:);
    model = 'linear';
    
else
    
    [~,~,STATS] = fixedEffects(lme);
    stats2report = [comp1.LRStat(2) comp1.deltaDF(2) comp1.pValue(2)];
%     meanFit = [];
%     CIFit = []; SEFit = []; STATS = [];
    model = 'none';
    return
    
end

fit_Y = fit;%reshape(fit, [nSubject,nBin]);% reshape back into subject x Bin
fit_Y_CI1 = fitCI(:,1);%reshape(fitCI(:,1), [nSubject,nBin]);% reshape back into subject x Bin
fit_Y_CI2 = fitCI(:,2);%reshape(fitCI(:,2), [nSubject,nBin]);% reshape back into subject x Bin

meanFit = fit;
CIFit = [1:length(fit) length(fit):-1:1 ; fitCI(:,1)' flip(fitCI(:,2))'];
% SEFit=[];
% SEFit = [1:nBin nBin:-1:1; meanFit - std(fit_Y)/sqrt(nSubject) flip(meanFit + std(fit_Y)/sqrt(nSubject))];

predictDataMat.meanFit = meanFit;
predictDataMat.CIFitLow = fitCI(:,1);
predictDataMat.CIFitHigh = fitCI(:,2);

% 
% if plotFit
%     var2plot = reshape(eval(['dataMat.' y ]), [nSubject,nBin]);
%     figure
%     hold on
%     h = plot(meanFit, 'linewidth', 2);
%     h = patch(CIFit(1,:), CIFit(2,:), h.Color);
%     h.FaceAlpha = 0.3;
%     h.EdgeAlpha = 0.3;
%     h.EdgeColor = [h.FaceColor];
%     plot(mean(var2plot),'.','markersize',15)
end






