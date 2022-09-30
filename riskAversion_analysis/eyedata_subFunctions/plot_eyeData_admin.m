fullMatrix = [];
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
        
                            %%%%% EYE DATA PLOTTING FUNCTION 
%                             [normStim, normResp, xlsx_full] = plot_eyeData(trl, allData, iblock, 1);
                              plot_eye_deriv_fullTrial(trl, allData, iblock);
    
                            cd([base_path ptIdx{isubject} '\processed_norm_eyedata\']);
        
                            structSaveName_stim = ['P' ptIdx{isubject} 'BLK' num2str(iblock) 'norm_stimEye.mat'];
                            structSaveName_resp = ['P' ptIdx{isubject} 'BLK' num2str(iblock) 'norm_respEye.mat'];
        
                            save(structSaveName_stim, 'normStim');
                            save(structSaveName_resp, 'normResp');

                        end
% 
%             if ~isempty(xlsx_full)
%         
%                 tmpBlock = [tmpBlock; xlsx_full];
%         
%             end
            end

            if exist(loadFilename)
                figSavename = ['normPupilDiam_riskyAvTrials_pt' num2str(ptIdx{isubject})];
                print(figSavename, '-dpng');
            end
        else 
            continue;
        end
%         
%         if ~isempty(xlsx_full)
%          
%             fullMatrix = [fullMatrix; tmpBlock];
%         end

        end

%         if ~isempty(fullMatrix)
%             cd([base_path]);
%             csv_filename = 'population_behav_phasicArousal.xlsx';
%             writetable(fullMatrix, csv_filename, 'WriteVariableNames', true);
%         end