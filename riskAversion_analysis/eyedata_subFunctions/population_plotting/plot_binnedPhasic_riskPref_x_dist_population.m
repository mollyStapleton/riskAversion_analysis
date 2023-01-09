function plot_binnedPhasic_riskPref_x_dist_population(dataIn)

for blockNum = 1:4


blockIdx = find([dataIn.blockNum == blockNum]);
data2use = dataIn(blockIdx, :);

% only focus on both-high/both-low trial
cndIdx2run = [2 3];
cndIdx = find([data2use.cndIdx] == 2 | [data2use.cndIdx] == 3);
data2use = data2use(cndIdx, :);

for itype = 1:2

    if itype == 1 
        col2plot = [0.7059 0.4745 0.9882];
    else 
        col2plot = [0.3961 0.9608 0.3647];
    end

    distIdx = find([data2use.distType] == itype);
    dataSplit = data2use(distIdx, :);
    

    for iepoch = 1:3

        if iepoch == 1 
            phasic2use = dataSplit.stim_prtileResp_pupil;
        elseif iepoch ==2 
            phasic2use = dataSplit.choice_prtileResp_pupil;
        elseif iepoch == 3
            phasic2use = dataSplit.feedback_prtileResp_pupil;
        end
        
        %perform median split of pupil and retrieve indices
        medianPupil(iepoch)     = median(phasic2use);
        lowIndices              = find(phasic2use <= medianPupil);
        highIndices             = find(phasic2use >= medianPupil);

        % calculate pupil quintiles 
%         [B,I]   = sort(phasic2use);
%         nSample = round(length(B)/5);
%         nBins   = round(linspace(1, nSample, 5));
%         

        
    end


end


end
