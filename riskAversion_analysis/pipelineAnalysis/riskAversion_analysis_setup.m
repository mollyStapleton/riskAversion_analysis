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
%----------------------------------------------------------------------------
% SINGLE SUBJECT JOBS 
%----------------------------------------------------------------------------
preprocess_behav    = 0;    %takes individual participants data and produces a matrix of all relevant information for analysis.
                            %saves this data within each participants folder
                            %produces and saves a figure of behaviour overview
                            %analysis replicated from Moeller et al., 2021

process_eyelink     = 0;    %raw eye data --> normalised pupil, derivative computed and stored,
                            %for all task encodes

subject_inclusion   = 0;    %returns indices of subjects to be included in analyses

trialData_eyelink   = 0;    %returns matrix of full data for analyse
                            %BEHAVIOUR AND PUPIL
                            
%----------------------------------------------------------------------------
% POPULATION JOBS 
%----------------------------------------------------------------------------

concat_behav        = 0;                              
plot_popBehav       = 0;    %plots average and SEM of behaviour across all subjects 

concat_all          = 1;

%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 041 & 043 removed due to task freezing 
% 032 & 035 eye data removed as they wore glasses 

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047'}];

% ptIdx = {'039'};

%----- JOB SUBFUNCTIONS: Behaviour ---------------------------------------------

if preprocess_behav

    if subject_inclusion 
        sub2include = [];
    end

for isubject = 1: length(ptIdx)
    close all hidden
    [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 1, 0);
    
    saveDataFilename = ['fullSession_' ptIdx{isubject} '.mat'];
    cd(process_path);

    if  ~exist(saveDataFilename)

         cd(raw_path);        
         [allData] = preprocess_behavData(ptIdx{isubject});
         cd(process_path);
         save(saveDataFilename, 'allData');

    else 
        load(saveDataFilename, 'allData');
    end

        figSavename = [ptIdx{isubject} '_behaviouralOverview'];

        if ~exist(figSavename)
            [subAccuracy] = plot_behavData(ptIdx{isubject}, allData, figSavename);
        end

        if subject_inclusion 
            subAccuracy = [str2num(ptIdx{isubject}) subAccuracy];
            sub2include = [sub2include; subAccuracy];

        end

end
end

%-------------------------------------------------------------------------
%-----------------------------------------------------------------------------

if concat_behav

    allTr_allSubjects = [];

for isubject = 1: length(ptIdx)

     [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 1, 0);
     loadDataFilename = ['fullSession_' ptIdx{isubject} '.mat'];
     cd(process_path);
     load(loadDataFilename);
    
     allTr_allSubjects = [allTr_allSubjects; allData];
   

end
    
    saveFilename = ['allTr_allSubjects.mat'];
    cd(base_path);
    save(saveFilename, 'allTr_allSubjects');

end

%-------------------------------------------------------------------------
%-----------------------------------------------------------------------------

if plot_popBehav
    
    cd(base_path);

    figSavename = ['populationBehaviour'];
    loadDataFilename = ['allTr_allSubjects.mat'];
    load(loadDataFilename);

    plot_populationBehaviour(base_path, allTr_allSubjects, figSavename);

end


%----- JOB SUBFUNCTIONS: eyelink ---------------------------------------------

if process_eyelink

    ft_defaults;

for isubject = 1: length(ptIdx)
       
    for iblock = 1:4

        close all hidden
        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       
        cd(raw_path);
        loadEyeFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '.edf'];

        if ~exist(loadEyeFilename)

            continue;

        else
            
            cd(process_path);
            saveFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];
            figsavename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_processedPupil'];

            if ~exist(saveFilename)
    
                [trl] = preprocess_eyelink(raw_path, ptIdx{isubject}, iblock);
                cd(process_path);
                save(saveFilename, 'trl');
                gcf;
                print(figsavename, '-dpng');
    
            else
%                 load(saveFilename, 'trl');
            end
        end
    end
end
end


if trialData_eyelink

    for isubject = 1: length(ptIdx)
        
        allTr_data = [];   

        for iblock = 1:4
            [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       
            cd(process_path);

            loadEyeFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];    
            loadBehavFilename = ['fullSession_' num2str(ptIdx{isubject}) '.mat'];

            if ~exist(loadEyeFilename)
                continue;
            else

                [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       
                cd(process_path);
                load(loadEyeFilename);
                [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 1, 0);       
                cd(process_path);
                load(loadBehavFilename);
                [allTr] = trialExtraction_eyeData(trl, allData, ptIdx{isubject}, iblock);
            end
                if strcmp(ptIdx{isubject}, '008') && iblock == 3
                    allTr(1, :) = [];
                end
                    [allTr_data] = [allTr_data; allTr];
        end


    cd([sub_folder '\processed_data\']);
    saveFilename = ['allTr_' num2str(ptIdx{isubject}) '.mat'];
    save(saveFilename, "allTr_data");
                     
    end
end

if concat_all
fullData_riskAversion = [];
    for isubject = 1: length(ptIdx)

        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);  
        cd([sub_folder 'processed_data/']);
        loadFilename = ['allTr_' num2str(ptIdx{isubject}) '.mat'];
        load(loadFilename);

        fullData_riskAversion = [fullData_riskAversion; allTr_data]
    end


end


