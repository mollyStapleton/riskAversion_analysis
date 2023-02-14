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

trialData_eyelink   = 1;

plot_sessionEye     = 0;  
plot_riskPref_eye   = 0;

plot_eyelinkData    = 0;    %stimulus and response aligned % signal change, derivative and 95th percentile computed and stored
                            
concact_allData     = 0;    %aligned behavioural and pupil data
plot_popEye         = 0;    %plots for population eye data, different plots can be generated, 
                            %see description for plot_populationEyeData.m
                            %function

%-----------------------------------------------------------------------

% 004, 0010, 0011, 0012: only behaviour data 
% 
% ptIdx = [{'004', '005', '006', '007', '008', '009','0010','0011',...
%  '0012', '014', '015', '016', '017', '018', '019', '020', '021', '022',...
%     '023', '024', '025', '026', '027'}];

ptIdx = {'005'};

%----- JOB SUBFUNCTIONS: Behaviour ---------------------------------------------

if preprocess_behav

for isubject = 1: length(ptIdx)
    close all hidden

    saveDataFilename = ['fullSession_' ptIdx{isubject} '.mat'];

    if  ~exist(saveDataFilename)

        cd([base_path '\' ptIdx{isubject} '\raw_data\behav\']);
        
         [allData] = preprocess_behavData(ptIdx{isubject});
         data_setPath(base_path, ptIdx{isubject}, 1, 0);
         save(saveDataFilename, 'allData');

    else 

        data_setPath(base_path, ptIdx{isubject}, 1, 0);
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
    
        data_setPath(base_path, ptIdx{isubject});
        noRespIdx = [];
              
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
       
    for iblock = 1:4

        close all hidden
        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       
        cd(raw_path);
        loadEyeFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '.edf'];

        if ~exist(loadEyeFilename)

            continue;

        else
            
            saveFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];
            figsavename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_processedPupil'];

            if ~exist(saveFilename)
    
                [trl] = preprocess_eyelink(base_path, ptIdx{isubject}, iblock);
                cd(process_path);
                save(saveFilename, 'trl');
                gcf;
                print(figsavename, '-dpng');
    
            else
                load(saveFilename, 'trl');
            end
        end
    end
end
end


if trialData_eyelink

    for isubject = 1: length(ptIdx)
        
        allTr_data = [];
        [sub_folder, raw_path, process_path] = data_setPath(base_path, ptIdx{isubject}, 0, 1);       

        for iblock = 1:4

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
                [allTr] = trialExtraction_eyeData(trl, allData, isubject, iblock);
            end
                
                [allTr_data] = [allTr_data; allTr];
        end

                saveFilename = ['allData_processed_PT' num2str(ptIdx{isubject}) '.mat'];
                save(saveFilename, "allData");
    end



end

%------------------------------------------------------------------------------

if plot_sessionEye
    for isubject = 1: length(ptIdx)
        tmpBlock = [];
        cd([base_path ptIdx{isubject} '\processed_data\']);
        close all hidden
        check_if_eye = ['P' ptIdx{isubject} 'BLK1_extracted.mat'];

        if exist(check_if_eye)

            if ~exist([base_path ptIdx{isubject} '\processed_norm_eyedata\'])
                mkdir([base_path ptIdx{isubject} '\processed_norm_eyedata\']);
            end

            for iblock = 1:4

                cd([base_path ptIdx{isubject} '\processed_data\']);
                loadFilename = ['P' ptIdx{isubject} 'BLK' num2str(iblock) '_extracted.mat'];
                behavFilename = ['fullSession_' num2str(ptIdx{isubject}) '.mat'];

                if ~exist(loadFilename)
                    continue;
                else
                    load(loadFilename);
                    load(behavFilename);
                    [epoch_stim, epoch_choice, epoch_feedback] = plot_eyeData(trl, allData, iblock, 1);

                    savefilename_stim = [num2str(ptIdx{isubject}) '_blk' num2str(iblock) '_allPupil_epochStim'];
                    save(savefilename_stim, 'epoch_stim');
                    savefilename_stim = [num2str(ptIdx{isubject}) '_blk' num2str(iblock) '_allPupil_epochChoice'];
                    save(savefilename_stim, 'epoch_choice');
                    savefilename_stim = [num2str(ptIdx{isubject}) '_blk' num2str(iblock) '_allPupil_epochFeedback'];
                    save(savefilename_stim, 'epoch_feedback');
                end
            end

            cd([base_path ptIdx{isubject} '\processed_norm_eyedata\']);
            figsavename = [num2str(ptIdx{isubject}) '_fullSession_z_deriv_pupil'];
            gcf;
            print(figsavename, '-dpng');
        end

    end

end

if plot_riskPref_eye

    for isubject = 1: length(ptIdx)
        tmpBlock = [];
        cd([base_path ptIdx{isubject} '\processed_data\']);
        close all hidden

        check_if_eye = ['P' ptIdx{isubject} 'BLK1_extracted.mat'];

        if exist(check_if_eye)

            if ~exist([base_path ptIdx{isubject} '\processed_norm_eyedata\'])
                mkdir([base_path ptIdx{isubject} '\processed_norm_eyedata\']);
            end

            for iblock = 1:4

                cd([base_path ptIdx{isubject} '\processed_data\']);
                behavFilename = ['fullSession_' num2str(ptIdx{isubject}) '.mat'];
                load(behavFilename);
                plot_eyeData_cnd_blk_choice_grouped(allData, iblock, ptIdx{isubject});

                
            end
        end
    end
end

       



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




