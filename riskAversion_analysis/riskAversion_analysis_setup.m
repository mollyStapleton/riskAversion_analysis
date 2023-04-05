%-----------------------------------------------------------------
%% ANALYSIS PIPELINE FOR RISK AVERSION STUDY
%-----------------------------------------------------------------------
%%% Author: Dr Molly Stapleton, Bristol University
%%%%%%% Batch analysis for pupil and behavioural data collected in response
%%%%%%%%%% to two-forced choiced bimodal/gaussian risky reward choice task 
%-----------------------------------------------------------------------
% Description of each analysis ran by each script is shown below in the 
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
draft_analysis          = 1;    % mainly in use for drafting analyses through the pipeline

% ----------------------------- BEHAVIOUR -------------------------------------------
plot_popBehav           = 0;    % plots average and SEM of behaviour across all subjects: 
                                % this includes plotting of choice accuracy and
                                % risk preference behaviour 

%------------------------------ PUPIL & BEHAVIOUR --------------------------
%%%%%% ANALYSIS SPECIFIC TO THE STIMULUS EPOCHS 
pupilStim_overview      = 0;    % returns statistical overview of pupil activity around the stimulus epoch 
pupilStim_phasicRisk    = 0;    % perform 3 bin split of phasic stimulus aligned pupil activity and compares
                                % this to subjects risk preferences and
                                % bias of choices
pupilStim_timeSeries    = 0;

temporal_regress        = 0;    % performs the temporal regression analyses
%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 041 & 043 removed due to task freezing 
% 032 & 035 eye data removed as they wore glasses 

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];


if draft_analysis

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['allSubjects_fullPupilSeries.mat'];
    load(loadAllName);
%     analysisDrafting([base_path], allSubData)
    deriv_pupil_rewardSplit([base_path], allSubData);

end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%----- JOB SUBFUNCTIONS: Behaviour ---------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

if plot_popBehav
    
    cd(base_path);

    figSavename = ['populationBehaviour'];
    loadDataFilename = ['allTr_allSubjects.mat'];
    load(loadDataFilename);
    plot_populationBehaviour(base_path, allTr_allSubjects);

end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%----- JOB SUBFUNCTIONS: eyelink ---------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

if pupilStim_overview

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);
      stimulus_overview(base_path, fullData_riskAversion); 
end

if pupilStim_phasicRisk

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);
      stimulus_phasic_preferences(base_path, fullData_riskAversion); 
end

if pupilStim_timeSeries
      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);
      stimulus_PSTHs(base_path, fullData_riskAversion); 
end

if temporal_regress

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);
    pupil_temporal_regress([base_path], fullData_riskAversion);

end



