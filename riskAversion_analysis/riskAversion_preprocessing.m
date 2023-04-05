%-----------------------------------------------------------------
%% PREPROCESSING PIPELINE FOR RISK AVERSION STUDY
%-----------------------------------------------------------------------
%%% Author: Dr Molly Stapleton, Bristol University
%%%%%%% Series of preprocessing scripts for pupil and behavioural data collected in response
%%%%%%%%%% to two-forced choiced bimodal/gaussian risky reward choice task 
%-----------------------------------------------------------------------
% Description of each preprocessing ran by each script is shown below in the 
% JOB LIST

clc
clear all 
close all 

%----------------------------------------------------------------
% SET PATH TO WHERE DATA IS STORED 
%-----------------------------------------------------
% *** please note that this path is used in preprocessing for the saving of
% processed data and saving of analysis plots i.e., it is the BASE for
% generation of new folders for saved analyses 
% *****
base_path = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\'];

cd(base_path);

%--------------------------------------------------------------------------
%------------------------------------------------------------------------------
%%%% JOBS LIST
%--------------------------------------------------------------------------
%------------------------------------------------------------------------------

preprocess_behav    = 0;    %takes individual participants data and produces a matrix of all relevant information for analysis.
                            %saves this data within each participants folder
                            %produces and saves a figure of behaviour overview
                            %analysis replicated from Moeller et al., 2021

process_eyelink     = 0;    %raw eye data --> normalised pupil, derivative computed and stored,
                            %for all task encodes

sbr_matrix_gen      = 0;    %returns matrix of total eye blinks during sbr epoch, average time of blinks and subject number

trialData_eyelink   = 0;    %returns matrix of full data for analyse
                            %BEHAVIOUR AND PUPIL

data4TempRegress    = 1;    % returns pupil series and derivative for both ITI locked and RESP locked epochs
                            % data from this script can be used for
                            % pupil_temporal_regress.m
                            
determinePhasicWin  = 0;    %stat analysis of averaged derivative data to determine appropriate window for phasic pupil

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%--- CONCATENATE MATRICES FOR ANALYSES ------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

concat_behav        = 0;                              
concat_all          = 0;

%---------------------------------------------------------------------------------

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];

% ptIdx = {'049'};


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%----- JOB SUBFUNCTIONS: Behaviour ---------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

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
%-------------------------------------------------------------------------
%----- JOB SUBFUNCTIONS: eyelink -----------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

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
           
            if ~exist(loadEyeFilename)
                continue;
            else

                [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       
                cd(process_path);
                load(loadEyeFilename);
                [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 1, 0);       
                cd(process_path);
                loadBehavFilename = ['fullSession_' ptIdx{isubject} '.mat'];
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

if determinePhasicWin

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);

    phasic_win([base_path 'population_dataAnalysis\'], fullData_riskAversion)

end

if data4TempRegress

        [fullData] =  extract_allTr_pupil(base_path);

end


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%----- GENERATE MATRICES FOR ANALYSES  -----------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


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

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if concat_all
fullData_riskAversion = [];
    for isubject = 1: length(ptIdx)

        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);  
        cd([sub_folder 'processed_data/']);
        loadFilename = ['allTr_' num2str(ptIdx{isubject}) '.mat'];
        load(loadFilename);
        
        fullData_riskAversion = [fullData_riskAversion; allTr_data];
    end

        cd([base_path 'population_dataAnalysis\']);
        saveAllName = ['fullData_riskAversion.mat'];
        save(saveAllName, 'fullData_riskAversion');
        
end

if sbr_matrix_gen
    
    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);
    SBR_dataMat(base_path, fullData_riskAversion);
    
end

