function [trl] = preprocess_eyelink(ptIdx, blockNum)

    cd([base_path ptIdx{isubject}]);
    tmpFilename = ['P' ptIdx{isubject} 'BLK' num2str(blockNum) '.asc'];

    % read in the asc EyeLink file
    asc = read_eyelink_ascNK_AU(tmpFilename);

    % create events and data structure, parse asc
    [data, event, blinksmp, saccsmp] = asc2dat(asc);

    eyedata = table();

    plotMe = true;
    newpupil = blink_interpolate(data, blinksmp, plotMe);
    data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:) = newpupil;

    eyedata.time = data.time{1}';
    eyedata.pupilSize = data.trial{1}(3, :)';

    [trl] = riskAversion_trialfun(event);

    for itrial = 1: length(trl)
        fullData = [];
        tmpEncodes = trl(itrial).encodes;

        for icodes = 2: length(tmpEncodes)-1 %loop over the trial epochs
            tmpData = [];

            tmpData(1, :) = data.trial{1}(3, (trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)));
            tmpData(2, :) = data.time{1}(1, (trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)));

            for idx = 1: length(trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2))

                tmpData(3, idx) = trl(itrial).encodes(icodes,1);
            end

            fullData = [fullData tmpData];
        end

        trl(itrial).data = fullData;

    end

end


