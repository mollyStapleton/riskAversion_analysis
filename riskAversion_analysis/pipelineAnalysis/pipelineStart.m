%%% RISK AVERSION ANALYSIS PIPELINE:
%%%%%% concatenate relevant data into a single structure 
%%%%%%% 4 behavioural dataOut for each participants 
%%%%%%%%%%%%% 4 .edf files per block 

clear all 
close all 

base_path = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\riskAversion_analysis\riskAversion_analysis\data\'];
cd(base_path);

% select job to run 

process_behav = 0;
process_eyelink = 1;

ptIdx = [{'001'}, {'004'}];

if process_behav

% possible stimulus combinations 
 stimCombos = [1 3; 1 4; 2 3; 2 4;,...  %% different [1 2 3 4]
              1 2;,...                 %% both low [5]
              3 4;,...                  %% both high  [6]
              3 1; 4 1; 3 2; 4 2;,...  %% different [7 8 9 10]
              2 1;,...                 %% both low [11]
              4 3];                   %% both high  [12]

for isubject = 1: length(ptIdx)

    cd([ptIdx{isubject} '\']);
    if ~exist([base_path ptIdx{isubject} '\processed_data\'])
        mkdir([base_path ptIdx{isubject} '\processed_data\']);
        
    end
    
    cd([base_path ptIdx{isubject} '\processed_data\']);
    saveDataFilename = ['fullSession_' ptIdx{isubject} '.mat'];

    if ~exist(saveDataFilename)

         [allData] = preprocess_behavData(ptIdx{isubject});
         save(saveDataFilename, 'allData');

    else 
        
        load(saveDataFilename, 'allData');
       
        figSavename = [ptIdx{isubject} '_behaviouralOverview'];

        if exist("figSavename")

            plot_behavData(ptIdx{isubject}, allData, figSavename)

        end
    end
end
end

if process_eyelink

    ft_defaults;

for isubject = 1: length(ptIdx)

    cd([ptIdx{isubject} '\']);

    if ~exist([base_path ptIdx{isubject} '\processed_data\'])
        mkdir([base_path ptIdx{isubject} '\processed_data\']);
    end

    cd([base_path ptIdx{isubject} '\processed_data\']);
    for iblock = 1:4

        saveFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];

        if ~exist(saveFilename)

            [trl] = preprocess_eyelink(ptIdx, iblock)
            cd([base_path ptIdx{isubject} '\processed_data\']);
            save(saveFilename, 'trl');

        else
            load(saveFilename, 'trl');
        end
    end
end
end

