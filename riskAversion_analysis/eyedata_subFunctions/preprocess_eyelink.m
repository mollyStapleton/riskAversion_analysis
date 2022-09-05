function [trl] = preprocess_eyelink(base_path, ptIdx, blockNum)

    cd([base_path ptIdx]);
    tmpFilename = ['P' ptIdx 'BLK' num2str(blockNum) '.asc'];

    % read in the asc EyeLink file
    if ~exist(tmpFilename)

        disp('Convert .edf to .asc');
       

        return
        
    else 
        asc = read_eyelink_ascNK_AU(tmpFilename);
    
        % create events and data structure, parse asc
        [data, event, blinksmp, saccsmp] = asc2dat(asc);
    
        eyedata = table();

        % mean pupil diameter, computed on a block by block basis
        meanPupil = mean(data.trial{1}(3, :));

    
        plotMe = true;
        newpupil = blink_interpolate(data, blinksmp, plotMe);
        data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:) = newpupil;
    
        eyedata.time = data.time{1}';
        eyedata.pupilSize = data.trial{1}(3, :)';
    
        [trl] = riskAversion_trialfun(event);
    
        for itrial = 1: length(trl)
            fullData = [];
            derivs   = [];
            tmpEncodes = trl(itrial).encodes;
    
            for icodes = 2: length(tmpEncodes)-1 %loop over the trial epochs
                tmpData = [];
                %pad matrix with NaN
                tmpData(1: length(trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)), [1:6]) = NaN;
    
                tmpData(:, 1)       = itrial;
                tmpData(:, 2)       = data.trial{1}(3, (trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)));
                tmpData(:, 3)       = data.trial{1}(3, (trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)))./meanPupil;
                tmpData(:, 4)       = data.time{1}(1, (trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)));   
                tmpDeriv            = diff(tmpData(:, 3));
                tmpDeriv(end +1)    = NaN;
                tmpData(:, 5)       = tmpDeriv;

                for idx = 1: length(trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2))
    
                    tmpData(idx, 6) = trl(itrial).encodes(icodes,1);
                end
    
                fullData = [fullData; tmpData];
               

            end
    
            trl(itrial).data = fullData;
            
            %identify max pupil diameter in trial 
            maxPupil_trl(itrial) = max(trl(itrial).data(1, :));

        end

    end

end


