function [fullData] =  extract_allTr_pupil(base_path)

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];

for isubject = 1: length(ptIdx)

    fullData = [];

    for iblock = 1:4

        allTr = table;

        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 1, 0);
        cd(process_path);
        loadBehavFilename = ['fullSession_' num2str(ptIdx{isubject}) '.mat'];
        load(loadBehavFilename);

        idx = find(allData.blockNumber == iblock);
        behav2use = allData(idx, :);
        xlsx_full = [];

        % noRespIdx = behav2use.RT==0;
        % behav2use(noRespIdx, :) = [];
        trials2use = behav2use.trialNum;
        tmpPupil = struct();

        %initalise variables for behav data
        if strcmp(ptIdx{isubject}, '008') && iblock == 3

            trials2use(1) = [];
            behav2use(1, :) = [];

        end

        tmpBehav = [];
        tmpBehav.subIdx((1:length(trials2use)), 1)      = str2num(ptIdx{isubject});
        tmpBehav.trialNum((1:length(trials2use)), 1)    = trials2use;
        tmpBehav.blockNum((1:length(trials2use)), 1)    = iblock;
        tmpBehav.distType((1:length(trials2use)), 1)    = behav2use.distType;
        tmpBehav.cndIdx((1:length(trials2use)), 1)      = behav2use.cnd_idx;
        tmpBehav.reward((1:length(trials2use)), 1)      = behav2use.reward_obtained;
        tmpBehav.RT((1:length(trials2use)), 1)          = behav2use.RT;
        tmpBehav.riskyChoice((1:length(trials2use)), 1) = behav2use.choice_risky;
        tmpBehav.accChoice((1:length(trials2use)), 1)   = behav2use.choice_high;

        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);
        cd(process_path);
        loadEyeFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];

        if ~exist(loadEyeFilename)
            continue;
        else

            [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);
            cd(process_path);
            load(loadEyeFilename);

        end

        itiIdx_start = 40;
        itiWin       = 2.8;
        
        respIdx_start = 25;
        respWin       = 3.1;

        for itrial = 1: length(trials2use)

            tmpPupil.itiLocked_pupil = [];
            tmpPupil.itiLocked_deriv = [];
            tmpPupil.respLocked_pupil = [];
            tmpPupil.respLocked_deriv = [];

            data2use   = trl(trials2use(itrial)).data;

           alignPoint_start    = find([data2use(:, 3)] == respIdx_start);
           nonRespIdx(itrial)  = 0;

            if ~isempty(alignPoint_start) %only look at trials where a response was made
                
                %-----------------------------------------------
                %%% RESPONSE LOCKED ACTIVITY: 3.1S FROM RESPONSE
                %-------------------------------------------------------
                aligned_timevec = [];
                aligned_timevec = (data2use(:, 2) - data2use(alignPoint_start(1), 2));
                id = diff(aligned_timevec);
                id = find(id == 0);
                id = id +1;

                aligned_timevec(id) = [];
                data2use(id, :) = [];
                d = [];
                ix = [];
                [ d, ix ] = min( abs( aligned_timevec - respWin) ); 
                resp_start = find(aligned_timevec == 0);
                resp_end = ix;
                
                normPupil{itrial} = data2use(:, 4);
                derivPupil{itrial} = data2use(:, 5);

                tmpPupil.respLocked_pupil = normPupil{itrial}(resp_start: resp_end);
                tmpPupil.respLocked_deriv = derivPupil{itrial}(resp_start: resp_end);   

                %-----------------------------------------------
                %%% ITI LOCKED ACTIVITY: 2.8S FROM ITI START
                %-------------------------------------------------------
                alignPoint_start      = find([data2use(:, 3)] == itiIdx_start);
                
                aligned_timevec = [];
                aligned_timevec = (data2use(:, 2) - data2use(alignPoint_start(1), 2));
                id = diff(aligned_timevec);
                id = find(id == 0);
                id = id +1;

                aligned_timevec(id) = [];
                data2use(id, :) = [];
                iti_start = 1;
                [ d, ix ] = min( abs( aligned_timevec - itiWin) ); 
                iti_end   = ix;

                tmpPupil.itiLocked_pupil = normPupil{itrial}(iti_start: iti_end);
                tmpPupil.itiLocked_deriv = derivPupil{itrial}(iti_start: iti_end);

            else
                nonRespIdx(itrial) = 1;
                continue;

            end

            if ~isempty(tmpPupil.itiLocked_pupil)
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

        fullData = [fullData; allTr];
    end

    saveFilename = ['P' ptIdx{isubject} '_fullPupilSeries.mat'];
    save(saveFilename, 'fullData');
end

end
