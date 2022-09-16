%%%% Sideline script to test Kelly's stats and plots
clear all 
clc 
base_path = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\riskAversion_analysis\riskAversion_analysis\data\'];
cd(base_path);
popFilename = ['populationBehav.mat'];
cd([base_path]);
load(popFilename);
allData = concatData;

%mean overall rt 

rt_mean = mean([concatData.RT]);
rt_sem  = std([concatData.RT]);

for blockType = 1:2


    blockIdx = find(concatData.distType == blockType);
    tmpBlockData = concatData(blockIdx, :);

    noRespIdx = find(tmpBlockData.RT == 0);
    tmpBlockData(noRespIdx, :) = [];

    % risk preferences across both-high and both-low for all trials
    diff_idx_blk    = find(tmpBlockData.cnd_idx == 1);
    high_idx_blk    = find(tmpBlockData.cnd_idx == 3);
    low_idx_blk     = find(tmpBlockData.cnd_idx == 2);

    mean_rt_diff{blockType} = tmpBlockData.RT(diff_idx_blk);
    mean_rt_high{blockType} = tmpBlockData.RT(high_idx_blk);
    mean_rt_low{blockType} = tmpBlockData.RT(low_idx_blk);


    for icnd = 1:3

        if icnd == 1
            data2use = tmpBlockData(diff_idx_blk, :);
        elseif icnd == 2 
            data2use = tmpBlockData(low_idx_blk, :);
        elseif icnd == 3 
            data2use = tmpBlockData(high_idx_blk, :);
        end

        for istim = 1:4

            tmpIdx = find(data2use.stimulus_choice == istim);

            nChoice{blockType}(icnd, istim) = length(tmpIdx);

        end


    end




end

[~, p_diff, ~, stats_diff] = ttest2(mean_rt_diff{1}, mean_rt_diff{2});
[~, p_high, ~, stats_high] = ttest2(mean_rt_high{1}, mean_rt_high{2});
[~, p_low, ~, stats_low] = ttest2(mean_rt_low{1}, mean_rt_low{2});
