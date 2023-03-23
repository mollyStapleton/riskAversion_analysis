clear all 
close all 

base_path = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\'];
cd(base_path);

draft_analysis      = 0;
%----------------------------------------------------------------------------
% POPULATION JOBS 
%----------------------------------------------------------------------------

plot_popBehav       = 0;    %plots average and SEM of behaviour across all subjects 

analyse_epochStim   = 0;    % accessing scripts to be used for phasic pupil ~ risk preferences

temporal_regress    = 1;    % performs the temporal regression analyses
%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 041 & 043 removed due to task freezing 
% 032 & 035 eye data removed as they wore glasses 

ptIdx = [{'019', '020', '021', '022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '033', '034', '036', '037', '038',...
    '039', '040', '042', '044', '045', '046', '047', '048', '049'}];

% ptIdx = {'031'};

%---- DRAFT ANALYSIS ----------------------------

if draft_analysis

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);
    analysisDrafting([base_path], fullData_riskAversion)

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

if analyse_epochStim

      cd([base_path 'population_dataAnalysis\']);
      loadAllName = ['fullData_riskAversion.mat'];
      load(loadAllName);

      pupil_stim_analysis([base_path 'population_dataAnalysis\'], fullData_riskAversion);
end


if temporal_regress

    cd([base_path 'population_dataAnalysis\']);
    loadAllName = ['fullData_riskAversion.mat'];
    load(loadAllName);
    pupil_temporal_regress([base_path], fullData_riskAversion);

end



