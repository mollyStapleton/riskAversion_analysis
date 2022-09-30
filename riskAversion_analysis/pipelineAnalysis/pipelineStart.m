%%% RISK AVERSION ANALYSIS PIPELINE:
%%%%%% concatenate relevant data into a single structure 
%%%%%%% 4 behavioural dataOut for each participants 
%%%%%%%%%%%%% 4 .edf files per block 

clear all 
close all 

base_path = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\'];
cd(base_path);

%---------------------------------
% SELECT JOB TO RUN 
%--------------------------------------------

preprocess_behav    = 0;    %takes individual participants data and produces a matrix of all relevant information for analysis. 
                        %saves this data within each participants folder 
                        %produces and saves a figure of behaviour overview 
                        %analysis replicated from Moeller et al., 2021


concat_behav        = 0;    %concatenates each individual participant matrix into a single matrix for population analyses
plot_popBehav       = 0;    %plots average and SEM of behaviour across all subjects 

process_eyelink     = 0;    %raw eye data --> normalised pupil, derivative computed and stored,
                            %for all task encodes

plot_eyelinkData    = 1;    %stimulus and response aligned % signal change, derivative and 95th percentile computed and stored
                            
concact_allData     = 0;    %aligned behavioural and pupil data
plot_popEye         = 0;    %plots for population eye data, different plots can be generated, 
                            %see description for plot_populationEyeData.m
                            %function

%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 
% ptIdx = [{'004', '005', '006', '007', '008', '009','0010','0011',...
%     '0012', '014', '015', '016', '017', '018'}];

ptIdx = {'006'};

%----- JOB SUBFUNCTIONS: Behaviour ---------------------------------------------

if preprocess_behav

for isubject = 1: length(ptIdx)
    close all hidden
    cd([base_path ptIdx{isubject} '\']);
    if ~exist([base_path ptIdx{isubject} '\processed_data\'])
        mkdir([base_path ptIdx{isubject} '\processed_data\']);
        
    end
    
    cd([base_path ptIdx{isubject} '\processed_data\']);
    saveDataFilename = ['fullSession_' ptIdx{isubject} '.mat'];

    if exist(saveDataFilename)

         [allData] = preprocess_behavData(ptIdx{isubject});
%          noRespIdx = ([allData.RT] == 0);
%          allData(noRespIdx, :) = [];

         save(saveDataFilename, 'allData');

    else 

        load(saveDataFilename, 'allData');

    end

        figSavename = [ptIdx{isubject} '_behaviouralOverview'];

        if ~exist(figSavename)

            plot_behavData(ptIdx{isubject}, allData, figSavename);

        end
end
end

%----------------------------------------------------------------------------

if concat_behav
   concatData = [];

    for isubject = 1: length(ptIdx)
    
        noRespIdx = [];
        cd([base_path ptIdx{isubject} '\']);
        if ~exist([base_path ptIdx{isubject} '\processed_data\'])
            mkdir([base_path ptIdx{isubject} '\processed_data\']);
            
        end
        
        cd([base_path ptIdx{isubject} '\processed_data\']);
        dataFilename = ['fullSession_' ptIdx{isubject} '.mat'];
        load(dataFilename);
        
        noRespIdx = ([allData.RT] == 0);
        allData(noRespIdx, :) = [];
        concatData = [concatData; allData];
        
    end

    % save concatenated data file 
    savePopFilename = ['populationBehav.mat'];
    cd([base_path]);
    save(savePopFilename, 'concatData');

    csv_filename = 'population_behav.xlsx';

    writetable(concatData, csv_filename, 'WriteVariableNames', true);

end

%-------------------------------------------------------------------------

if plot_popBehav

    figSavename = ['population_behaviour'];
    plot_populationBehaviour(base_path, ptIdx, figSavename);

end


%----- JOB SUBFUNCTIONS: eyelink ---------------------------------------------

if process_eyelink

    ft_defaults;

for isubject = 1: length(ptIdx)

    cd([base_path ptIdx{isubject} '\']);

    if ~exist([base_path ptIdx{isubject} '\processed_data\'])
        mkdir([base_path ptIdx{isubject} '\processed_data\']);
    end

%     close all hidden

    for iblock = 1:4
        close all hidden
%         figure(iblock)
        % include line to account for the fact not all participants possess
        % eye data 
        cd([base_path ptIdx{isubject}]);
        loadEyeFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '.edf'];

        if ~exist(loadEyeFilename)

            continue;

        else
            cd([base_path ptIdx{isubject} '\processed_data\']);
            saveFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];

            if exist(saveFilename)
    
                [trl] = preprocess_eyelink(base_path, ptIdx{isubject}, iblock);
                cd([base_path ptIdx{isubject} '\processed_data\']);
                save(saveFilename, 'trl');
    
            else
                load(saveFilename, 'trl');
            end
        end
    end
end
end

%------------------------------------------------------------------------------

if plot_eyelinkData
        plot_eyeData_admin;
end

%-------------------------------------------------------------------------------

if concact_allData 

    [pop_normPupil] = concatenate_eyeData(ptIdx, base_path, 1);
    cd([base_path]);
    savePopname = ['population_normEyeData.mat'];
    save(savePopname, 'pop_normPupil');

end

%-------------------------------------------------------------------------------

if plot_popEye

    cd([base_path]);
    loadPopname = ['population_normEyeData.mat'];
    load(loadPopname);
    plot_populationEyeData(pop_normPupil, 2);

end




