function analysisDrafting(base_path, dataIn)

subs = unique(dataIn.subIdx);
sbr_all_data = [];

for isubject = 1: length(subs)

     [sub_folder, raw_path, process_path] = data_setPath(base_path, ['0' num2str(subs(isubject))], 0, 1);
     cd(raw_path);
     tmpData  = [];

     for iblock = 1:3

         sbr_filename = ['SBRblock_' num2str(iblock) '.mat'];
         load(sbr_filename);

         tmpNum = length(sbr_blinks);
         tmpAvgTime = nanmean(sbr_blinks(:, 2) - sbr_blinks(:, 1));
         
         tmpData(iblock, :) = [subs(isubject) iblock tmpNum tmpAvgTime];
           
     end

     sbr_all_data = [sbr_all_data; tmpData];

end

saveFilename = ['sbr_all_data.mat'];
cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\population_dataAnalysis\');
save(saveFilename, 'sbr_all_data');

end
