%%% RISK AVERSION ANALYSIS PIPELINE:
%%% pre process of both behavioural and eye data 
%%% concatenates all data into a single structure 
%%% series of scripts to run plots/stats/analysis etc 
%%% *** see jobs list and accompanying descriptions ***

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
determinePhasicWin  = 0;    %stat analysis of averaged derivative data to determine appropriate window for phasic pupil 
%----------------------------------------------------------------------------
% POPULATION JOBS 
%----------------------------------------------------------------------------

concat_behav        = 0;                              
plot_popBehav       = 0;    %plots average and SEM of behaviour across all subjects 

concat_all          = 0;
plot_cndEyeData     = 0;

analyse_epochBase   = 1;
analyse_epochStim   = 0;
analyse_epochChoice = 0;
analyse_previousChoice = 0;
%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 041 & 043 removed due to task freezing 
% 032 & 035 eye data removed as they wore glasses 

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048'}];

% ptIdx = {'031'};

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

    if  exist(saveDataFilename)

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

    plot_populationBehaviour(base_path, allTr_allSubjects);

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

if determinePhasicWin

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);

    phasic_win([base_path 'population_dataAnalysis\'], fullData_riskAversion)

end


if concat_all
fullData_riskAversion = [];
    for isubject = 1: length(ptIdx)

        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);  
        cd([sub_folder 'processed_data/']);
        loadFilename = ['allTr_' num2str(ptIdx{isubject}) '.mat'];
        load(loadFilename);
        
%         clf;
%         plot_eyeData_riskPref_x_dist_individual(allTr_data, process_path);

        fullData_riskAversion = [fullData_riskAversion; allTr_data];
    end

        cd([base_path 'population_dataAnalysis\']);
        saveAllName = ['fullData_riskAversion.mat'];
        save(saveAllName, 'fullData_riskAversion');
        
end


if plot_cndEyeData

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      % plot z-score pupil and derivative for both high and both low
      % conditions, split according to risk preferences 
      
      plot_eyeData_riskPref_x_dist_population(fullData_riskAversion);
%       plot_derivData_riskPref_x_dist_population(fullData_riskAversion);
      
%       plot_binnedPhasic_riskPref_x_dist_population(fullData_riskAversion);

end

if analyse_epochBase

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      baseline_analysis([base_path 'population_dataAnalysis\'], fullData_riskAversion);
end

if analyse_epochStim

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      pupil_stim_analysis([base_path 'population_dataAnalysis\'], fullData_riskAversion);
end
if analyse_epochChoice

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      pupil_choice_analysis([base_path 'population_dataAnalysis\'], fullData_riskAversion);
end

if analyse_previousChoice

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      pupil_prevChoice_analysis([base_path 'population_dataAnalysis\'], fullData_riskAversion);


end

