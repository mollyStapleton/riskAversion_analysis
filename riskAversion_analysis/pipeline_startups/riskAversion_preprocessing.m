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
preprocess_behav    = 0;    %takes individual participants data and produces a matrix of all relevant information for analysis.
                            %saves this data within each participants folder
                            %produces and saves a figure of behaviour overview
                            %analysis replicated from Moeller et al., 2021

process_eyelink     = 0;    %raw eye data --> normalised pupil, derivative computed and stored,
                            %for all task encodes

sbr_matrix_gen      = 1;    %returns matrix of total eye blinks during sbr epoch, average time of blinks and subject number

subject_inclusion   = 0;    %returns indices of subjects to be included in analyses

trialData_eyelink   = 0;    %returns matrix of full data for analyse
                            %BEHAVIOUR AND PUPIL
determinePhasicWin  = 0;    %stat analysis of averaged derivative data to determine appropriate window for phasic pupil 