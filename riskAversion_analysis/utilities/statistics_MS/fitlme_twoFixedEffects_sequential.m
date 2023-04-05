function [stats2report, STATS, model] = fitlme_twoFixedEffects_sequential(dataMat)

% FUNCTION IS ADAPTED FROM fitlme_singleVar_sequential.m
% AUTHORED BY: Jochem van Kempen
% PRESENT FUNCTION ADAPTED BY: Molly Stapleton 

% INPUT: 
%       dataMat: groupingVariable, fixedEffects1, fixedEffects2, fixedEffects3, responseVariable 

% MIXED EFFECTS MODELS IMPLEMENTED 
% Models produce both main effects and interaction effects 

% RANDOM EFFECTS
% (1|g1) -----> sessionNumber is the grouping variable - requires a random intercept to
% provide an individual baseline value each recording day 

% (1|g1:x1) -----> accounts for two measures of the response variable in the same
% recording session

%-------------------------------------------------------------------------------


lme = fitlme(dataMat,['y ~ 1 + (1|g1)']);% fit constant
lme2 = fitlme(dataMat,['y~x1*x2 + (1|g1)']); % fit linear model
lme3 = fitlme(dataMat,['y~x1*x2^2 + (1|g1)']); % fit quadratic model (this includes the linear model), note this doesn't have orthogonal contrasts!!

% compare the model fits

comp1 = compare(lme, lme2, 'CheckNesting',true); % compare linear to constant

comp2 = compare(lme2, lme3, 'CheckNesting',true); % compare quadratic to linear



% xRange = [min(dataMat.x), max(dataMat.x)];
% xRange = xRange + round([-mean(xRange)/2 mean(xRange)/2]);
% predictDataMat = table((xRange(1):xRange(2))', 'VariableNames', {'x'});

if comp2.pValue < 0.05
    
    [~,~,STATS] = fixedEffects(lme3);
    
%     [fit, fitCI] = predict(lme3, predictDataMat); % get the fitted values for the new x values
    
    stats2report = [comp2.LRStat(2) comp2.deltaDF(2) comp2.pValue(2)];
    
    STATS = STATS(3,:);

    model = 'quadratic';
    
    
elseif comp1.pValue < 0.05
%     [fit, fitCI] = predict(lme2, predictDataMat); % get the fitted values for each subject
    [~, ~, STATS.linear] = fixedEffects(lme2);
    stats2report = [comp1.LRStat(2) comp1.deltaDF(2) comp1.pValue(2)];
%     STATS = STATS(2,:);
    model = 'linear';
else
    stats2report = [comp1.LRStat(2) comp1.deltaDF(2) comp1.pValue(2)];
    meanFit = [];
    CIFit = []; SEFit = []; STATS = [];
    model = 'none';
    
    [~, ~, STATS.linear] = fixedEffects(lme2);
    [~, ~, STATS.quad]   = fixedEffects(lme3);
    return
end


end

