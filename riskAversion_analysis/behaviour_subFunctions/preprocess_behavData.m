function [allData] = preprocess_behavData(ptIdx)

allData = table();

tmpFiles = dir;
tmpBlockNum = ([tmpFiles.bytes]) ~=0;


for iblock = 1:sum(tmpBlockNum==1)

    tmpData = table();
    tmpFilename = ['PT_' ptIdx '_BLK' num2str(iblock) '.mat'];
    load(tmpFilename);

    %retrieve relevant info
    tmpData.pt_number           = dataOut.ptID';
    tmpData.pt_gender           = dataOut.ptGender';
    %         tmpData.pt_age            = dataOut.ptAge;
    tmpData.blockNumber         = dataOut.blockNum';
    tmpData.trialNum            = dataOut.trialNum';
    tmpData.distType            = dataOut.distType';
    tmpData.stim_l              = dataOut.stim_left';
    tmpData.stim_r              = dataOut.stim_right';
    tmpData.chosen_dir          = dataOut.choice';

    for itrial = 1: length(dataOut.choice)

        if ~isempty(dataOut.choice(itrial))

            if (dataOut.choice(itrial) == 1) % RIGHT

                tmpData.stimulus_choice(itrial) = dataOut.stim_right(itrial);

            elseif (dataOut.choice(itrial) == 2) % LEFT

                tmpData.stimulus_choice(itrial) = dataOut.stim_left(itrial);

            end

            stimShown(1, 1) = dataOut.stim_right(itrial);
            stimShown(1, 2) = dataOut.stim_left(itrial);

            if [sum(stimShown) >= 4 && sum(stimShown) <= 6]
                tmpData.cnd_idx(itrial) = 1;  %both different
            elseif sum(stimShown) == 3
                tmpData.cnd_idx(itrial) = 2;  %both low
            elseif sum(stimShown) == 7
                tmpData.cnd_idx(itrial) = 3;  %both high
            end

        end
    end

    tmpData.RT                  = dataOut.RT';
    tmpData.reward_obtained     = dataOut.reward';

    allData = [allData; tmpData];
end
end
