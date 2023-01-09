function [allTr] = trialExtraction_eyeData(dataIn_eye, dataIn_behav, subIdx, blockNum)

% function returns structures for epochs of interest: stimulus, choice and
% feedback
% trial by trial extraction of relevant z-score activity, derivative
% activity, 95th percentile phasic arousal value, pre epoch relevant event
% baseline

allTr = table;

idx = find(dataIn_behav.blockNumber == blockNum);
behav2use = dataIn_behav(idx, :);
xlsx_full = [];

% noRespIdx = behav2use.RT==0;
% behav2use(noRespIdx, :) = [];
trials2use = behav2use.trialNum;
tmpPupil = struct();

%initalise variables for behav data 
if strcmp(subIdx, '008') && blockNum == 3

    trials2use(1) = [];
    behav2use(1, :) = [];

end
% 
% if strcmp(subIdx, '039') && blockNum == 1 
%     dataIn_eye(:, 83) = [];
%     behav2use(83, :)  = [];
%     trials2use(83)

tmpBehav.subIdx((1:length(trials2use)), 1)      = str2num(subIdx);
tmpBehav.trialNum((1:length(trials2use)), 1)    = trials2use;
tmpBehav.blockNum((1:length(trials2use)), 1)    = blockNum;
tmpBehav.distType((1:length(trials2use)), 1)    = behav2use.distType;
tmpBehav.cndIdx((1:length(trials2use)), 1)      = behav2use.cnd_idx;
tmpBehav.reward((1:length(trials2use)), 1)      = behav2use.reward_obtained;
tmpBehav.RT((1:length(trials2use)), 1)          = behav2use.RT;
tmpBehav.riskyChoice((1:length(trials2use)), 1) = behav2use.choice_risky;
tmpBehav.accChoice((1:length(trials2use)), 1)   = behav2use.choice_high;


for itrial = 1: length(trials2use)

    tmpPupil.baseline_raw = [];

tmpPupil.stim_aligned_pupil = [];
tmpPupil.stim_aligned_timeVec = [];
tmpPupil.stim_preResp_pupil = [];
tmpPupil.stim_prtileResp_pupil = [];
tmpPupil.stim_derivative =  [];

% [-0.2: response: 1s]
tmpPupil.choice_aligned_pupil = [];
tmpPupil.choice_aligned_timeVec = [];
tmpPupil.choice_preResp_pupil = [];
tmpPupil.choice_prtileResp_pupil = [];
tmpPupil.choice_derivative =  [];

% [-0.2: choiceIndicate: 1.5s]
tmpPupil.feedback_aligned_pupil = [];
tmpPupil.feedback_aligned_timeVec = [];
tmpPupil.feedback_preResp_pupil= [];
tmpPupil.feedback_prtileResp_pupil = [];
tmpPupil.feedback_derivative =  [];

    for iepoch = 1:4

        if iepoch == 1

            alignIdx  = 14; %stimOnMin
            epochStart  = -0.5;
            epochEnd    = 1;
            phasicStart = -0;
            phasicEnd   = 0.6; %500ms from stimOnMin

        elseif iepoch == 2

            alignIdx  = 25; %response
            epochStart  = -0.5;
            epochEnd    = 1;
            phasicStart = -0.5; %500ms before response
            phasicEnd   = 0;

        elseif iepoch == 3

            alignIdx  = 30; %choiceIndicated
            epochStart  = -0.2;
            epochEnd    = 1.5;
            phasicStart = -0.8;
            phasicEnd   = 1.3; %500ms from reward feedback
        elseif iepoch == 4 
            alignIdx  = 40; %ITI start
            epochStart  = 0;
            epochEnd    = 1.5; %ITI end
       
        end

        data2use   = dataIn_eye(trials2use(itrial)).data;
        
        %single event when button is pressed indicating choice
        respIdx = find([data2use(:, 3)] == 25);
        nonRespIdx(itrial) = 0;

        if ~isempty(respIdx) %only look at trials where a response was made

            if iepoch == 1 || iepoch == 3 || iepoch == 4 
                alignPoint = find([data2use(:, 3) == alignIdx], 1);
            else
                alignPoint = find([data2use(:, 3) == alignIdx]);
            end
            aligned_timevec = [];
            aligned_timevec = (data2use(:, 2) - data2use(alignPoint(1), 2));
            % deals with duplicate timestamps
            id = diff(aligned_timevec);
            id = find(id == 0);
            id = id +1;

            aligned_timevec(id) = [];
            data2use(id, :) = [];

            % checks main event in epoch is still in the same
            % place after removal of duplicates
            if iepoch == 1
                alignPoint = find([data2use(:, 2) == 14], 1); %stimOnMin
            elseif iepoch == 2
                alignPoint = find([data2use(:, 3) == 25]); %response
            elseif iepoch == 3
                alignPoint = find([data2use(:, 3) == 30], 1); %choiceIndicated
            end

            normPupil{itrial} = data2use(:, 4);

            %--------------------------------------------------------
            % Z-SCORE PUPIL RESPONSE
            %--------------------------------------------------------------------

            [ d, ix ] = min( abs( aligned_timevec - epochStart) ); % -0.5s
            tmpIdx(1) = ix;
            [ d, ix ] = min( abs( aligned_timevec - epochEnd) );   % + 1s
            tmpIdx(2) = ix;


            checkTrialValidity = length(tmpIdx(1): tmpIdx(2));
            if checkTrialValidity < 86 && iepoch ==3

                tmpPupil.feedback_preResp_pupil = NaN;
                % calc 95th percentile of derivative
                tmpPupil.feedback_prtileResp_pupil= NaN;
                tmpPupil.feedback_derivative = NaN;

                continue;

            else

                if iepoch == 1
                    % aligned time data and pupil series
                    tmpPupil.stim_aligned_timeVec = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    tmpPupil.stim_aligned_pupil = normPupil{itrial}(tmpIdx(1): tmpIdx(2));

                elseif iepoch == 2
                    tmpPupil.choice_aligned_timeVec = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    tmpPupil.choice_aligned_pupil = normPupil{itrial}(tmpIdx(1): tmpIdx(2));

                elseif iepoch == 3
                    tmpPupil.feedback_aligned_timeVec = aligned_timevec(tmpIdx(1): tmpIdx(2));
                    tmpPupil.feedback_aligned_pupil = normPupil{itrial}(tmpIdx(1): tmpIdx(2));
                elseif iepoch == 4 
                    tmpPupil.baseline_raw = normPupil{itrial}(tmpIdx(1): tmpIdx(2));
                end

                %--------------------------------------------------------
                % PHASIC RESPONSE
                %--------------------------------------------------------------------
                if iepoch == 1 || iepoch == 2 || iepoch == 3
                    [ d, ix ] = min( abs( aligned_timevec - phasicStart) );
                    phasicIdx(1) = ix;
                    [ d, ix ] = min( abs( aligned_timevec - phasicEnd) );
                    phasicIdx(2) = ix;
    
                    if iepoch == 1
                        tmpPupil.stim_preResp_pupil= data2use((phasicIdx(1): phasicIdx(2)), 5);
                        % calc 95th percentile of derivative
                        tmpPupil.stim_prtileResp_pupil  = prctile(tmpPupil.stim_preResp_pupil, 95);
                        tmpPupil.stim_derivative  = data2use((tmpIdx(1): tmpIdx(2)), 5);
    
                    elseif iepoch == 2
                        tmpPupil.choice_preResp_pupil = data2use((phasicIdx(1): phasicIdx(2)), 5);
                        % calc 95th percentile of derivative
                        tmpPupil.choice_prtileResp_pupil= prctile(tmpPupil.choice_preResp_pupil, 95);
                        tmpPupil.choice_derivative = data2use((tmpIdx(1): tmpIdx(2)), 5);
    
                    elseif iepoch == 3
                        tmpPupil.feedback_preResp_pupil = data2use((phasicIdx(1): phasicIdx(2)), 5);
                        % calc 95th percentile of derivative
                        tmpPupil.feedback_prtileResp_pupil= prctile(tmpPupil.feedback_preResp_pupil, 95);
                        tmpPupil.feedback_derivative = data2use((tmpIdx(1): tmpIdx(2)), 5);
              
                    end
                end

            end
        else 
            nonRespIdx(itrial) = 1;
            continue;
            
        end
       

    end

    if ~isempty(tmpPupil.stim_aligned_pupil)
      allTr = [allTr; struct2table(tmpPupil, 'AsArray', 1)];
    else 
        continue;
    end

end

if size(behav2use, 1) ~= size(allTr, 1)
    tmpBehav = struct2table(tmpBehav);
    nonRespIdx = logical(nonRespIdx);
    tmpBehav(nonRespIdx, :) = [];
    allTr = [tmpBehav allTr];
else
    
    allTr = [struct2table(tmpBehav) allTr];

end


end
