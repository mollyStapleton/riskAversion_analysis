function [dataOut] = concatenate_eyeData(ptIdx, base_path)

dataOut  = [];

for isubject = 1: length(ptIdx)

    cd([base_path ptIdx{isubject} '\processed_data\']);
    % load in behavioural data 
    behavFilename = ['fullSession_' num2str(ptIdx{isubject}) '.mat'];
    load(behavFilename)

    fullSession = [];

      if exist([base_path ptIdx{isubject} '\processed_norm_eyedata\'])
          
        cd([base_path ptIdx{isubject} '\processed_norm_eyedata\'])
        close all hidden
        

        for iblock = 1:4
            fullMat = [];
            loadStructnameStim = ['P' ptIdx{isubject} 'BLK' num2str(iblock) 'norm_stimEye.mat'];
            loadStructnameResp = ['P' ptIdx{isubject} 'BLK' num2str(iblock) 'norm_respEye.mat'];

            load(loadStructnameStim);
            load(loadStructnameResp);
            tmpMat = struct();
            tmpMat.subIdx = isubject;

            for icnd = 1:3

                % organise relevant behavioural data into matrix
                
                tmpBehavIdx                 = find(allData.cnd_idx == icnd & allData.blockNumber == iblock);

                % remove data where no responses were made
                noRespIdx                   = ([allData.RT(tmpBehavIdx)] == 0);

                % accounts for a glitch in the data that did not record the
                % response in eyelink for this trial 
                if strcmp(ptIdx{isubject}, '015') 
                    noRespIdx(20)                   = 1;
                end

                tmpMat.dist_type            = allData.distType(tmpBehavIdx(1));
             
                tmpMat.behavData            = allData(tmpBehavIdx(~noRespIdx), :);
                
                tmpMat.cndIdx               = icnd;
                tmpMat.blockIdx             = iblock;

                
                % organise eye data into matrix 
                tmpMat.normStim             = normStim.aligned_pupil{icnd}(~noRespIdx, :);
                tmpMat.normResp             = normResp.aligned_pupil{icnd}(~noRespIdx, :);
                tmpMat.prtile_pupil_stim    = normStim.prtileResp_pupil{icnd}(~noRespIdx);
                tmpMat.prtile_pupil_resp    = normResp.prtileResp_pupil{icnd}(~noRespIdx);
                tmpMat.derivative_stim      = normStim.derivative{icnd}(~noRespIdx, :);
                tmpMat.derivative_resp      = normResp.derivative{icnd}(~noRespIdx, :);
                
                fullMat = [fullMat tmpMat];

            end


                fullSession = [fullSession fullMat];
        end
                dataOut = [dataOut fullSession];
            
        else 
            continue;
      end
end

end
