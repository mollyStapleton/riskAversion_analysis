function [behavData, eyeData] = dataAdmin_retrieve(base_path, subjectIdx, behavFlag, eyeFlag)
% directs path to correct participant folder

    if behavFlag == 1 
        noRespIdx = [];
        cd([base_path ptIdx{isubject} '\']);
        if ~exist([base_path subjectIdx '\processed_data\'])
            mkdir([base_path subjectIdx '\processed_data\']);
            
        end

        cd([base_path ptIdx{isubject} '\processed_data\']);

    end


end
