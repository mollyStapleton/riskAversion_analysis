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
        data = asc2dat(asc);

        % runs through the eyelink event types and returns the timestamp
        % sample for us to retrieve the relevant pupil data in relation to
        % each task encode

        [trl] = riskAversion_trialfun(data.event);

        % returns interpolated data for blinks and other noise transients 
        % newpupil is the interpolated 'clean' data
        figure(2);
        subplot(3, 1, 1)
        plot(data.times, data.pupil, 'color', [0.75 0.75 0.75], 'linew', 1.2);

        % (i) interpolation for missing data and noise transients 
        [newpupil, newXgaze, newYgaze, newblinksmp, nanIdx] = blink_interpolatePM_MS(data, tmpFilename, 1);
        
        figure(2);
        subplot(3, 1, 1)
        hold on 
        plot(data.times, newpupil, 'color', 'g', 'linew', 1.2);
        ylabel({'Interpolated', 'Pupil Series'});
        legend({'Raw Pupil', 'Interpolated'}, 'location', 'northwest');


        % (ii) downsample to 50Hz
        pupil = resample(newpupil, 50, 1000)';
        % timestamps now match those of data.times, so that can be
        % appropriately aligned to pupil samples
        dwnTime  = (0:(length(pupil)-1))./500;

% 
%       % (iii) filtering of data
        [bfilt,afilt] = butter(3, 0.06*(2/50), 'high');   % hi-pass
        pupil = filtfilt(bfilt,afilt, pupil);
        [bfilt,afilt] = butter(3, 6*(2/50), 'low');   % lo-pass
        pupil = filtfilt(bfilt,afilt, pupil);

        subplot(3, 1, 2)
        plot(dwnTime, pupil, 'r', 'linew', 1.2);
        ylabel({'Clean & Downsampled', 'Interpolated'});

        % (iii) percentage signal change (from mean)
        meanPupil = mean(abs(pupil));
        mean_comp_pupil = pupil./meanPupil;
        zmean_pupil = zscore(pupil);
        % (iv) 1st derivative of interpolated pupil series 
        % scaled by sampling rate 
        
        figure(2);
        subplot(3, 1, 3)
        hold on
        deriv_pupil = [0 ([diff(zmean_pupil)]' .*50)];
        hold on 

%         % low pass filter, 3rd order, 2hz cutoff 
%         [bfilt,afilt] = butter(3, 2*(2/50), 'low');   % lo-pass
        deriv_pupil = filtfilt(bfilt, afilt, deriv_pupil);
        plot(dwnTime, deriv_pupil, 'color', 'g', 'linew', 1.2);
       
    
        subplot(3, 1, 3)
        plot(dwnTime, zmean_pupil, 'color', [0.75 0.75 0.75], 'linew', 1.2);
        ylabel({'Pupil Response', '(% Signal Change)'});
        ylim([(min(mean_comp_pupil)-2) (max(mean_comp_pupil)+2)]);
        legend({'Derivative', 'z-score pupil'}, 'location', 'northwest');
      
   
        sgtitle(tmpFilename);

        for itrial = 1: length(trl)

            fullData = [];
            tmpEncodes = trl(itrial).encodes;

            % alter sample encodes so that they match the downsampled time
            % vector
            trl(itrial).encodes(:, 2) = round(trl(itrial).encodes(:, 2).*(50/1000));
    
            for icodes = 2: length(tmpEncodes)-1 %loop over the trial epochs
                tmpData = [];

                diffEncode = (trl(itrial).encodes(icodes+1, 2) - trl(itrial).encodes(icodes, 2));

                % accounts for the fact response and delay are encoded at
                % the same time. 
                if diffEncode > 0
                    encodeAmend = 1;
                else
                    encodeAmend = 0;
                end
                    %pad matrix with NaN
                    tmpData(1: length(trl(itrial).encodes(icodes, 2): trl(itrial).encodes(icodes+1, 2)-encodeAmend), [1:5]) = NaN;
                    
                    % trial number
                    tmpData(:, 1) = itrial; 
                    % time series 
                    tmpData(:, 2) = dwnTime(trl(itrial).encodes(icodes, 2): (trl(itrial).encodes(icodes+1, 2)-encodeAmend));
    
                    % task encodes 
                        for idx = 1: length(trl(itrial).encodes(icodes, 2): (trl(itrial).encodes(icodes+1, 2)-encodeAmend))
            
                            tmpData(idx, 3) = trl(itrial).encodes(icodes,1);
                        end
    
                    % percentage change pupil series 
                    tmpData(:, 4) = mean_comp_pupil(trl(itrial).encodes(icodes, 2): (trl(itrial).encodes(icodes+1, 2)-encodeAmend));
                    % 1st derivative of pupil series 
                    tmpData(:, 5) = deriv_pupil(trl(itrial).encodes(icodes, 2): (trl(itrial).encodes(icodes+1, 2)-encodeAmend));

                

                fullData = [fullData; tmpData];
               
            end
    
            trl(itrial).data = fullData;

        end

    end

end


