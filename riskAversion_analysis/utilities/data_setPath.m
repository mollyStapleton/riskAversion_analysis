function [sub_folder, raw_path, process_path] = data_setPath(base_path, subjectIdx, behavFlag, eyeFlag)
% directs path to correct participant folder

if behavFlag == 1
    noRespIdx = [];

    sub_folder      = [base_path subjectIdx '\'];
    raw_path        = [base_path subjectIdx '\raw_data\behav\'];
    process_path    = [base_path subjectIdx '\processed_data\behav\'];
    
    if ~exist([base_path subjectIdx '\processed_data\behav\'])
        mkdir([base_path subjectIdx '\processed_data\behav']);

    end

    
end 


if eyeFlag == 1

    sub_folder      = [base_path subjectIdx '\'];
    raw_path        = [base_path subjectIdx '\raw_data\eye\'];
    process_path    = [base_path subjectIdx '\processed_data\eye\'];

    if ~exist([base_path subjectIdx '\raw_data\eye'])
        mkdir([base_path subjectIdx '\processed_data\eye\']);

    end
    
end
