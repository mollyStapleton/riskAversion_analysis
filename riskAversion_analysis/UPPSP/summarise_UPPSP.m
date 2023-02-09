% load in UPPS-P responses, calculate overall score, subcomponent scores
% stores as matlab matrix for each individual participant 

function summarise_UPPSP

clc
clear all


dataFolder = ['C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\data\UPPS-P'];
datafilename = ['finalData.csv'];
cd(dataFolder);
dataIn  = readmatrix(datafilename);

ptIdx = {'022', '023', '024',...
    '025', '026', '027', '028', '029', '030', '031',...
    '032', '033', '034', '035', '036', '037', '038',...
    '039', '040', '042','044', '045', '046', '047', '048'};

subComp = {'NegativeUrgency', 'LackPerseverance', 'LackPremeditation',...
    'SensationSeeking', 'PositiveUrgency'};
subCompIdx = {[6 18 13 15], [1 4 7 11], [2 5 12 19],...
    [9 14 16 18], [3 10 17 20]};

subComp_dataOut = [];

minScore = 20; % if got 1 on every statement 
maxScore = 80; % 20 * 4;

% return vector of responses made
% 1 - Strongle Agree
% 2 - Somewhat Agree
% 3 - Somewhat Disagree
% 4 - Strongly Disagree

%** some of the subsections are reverse scored **

revScoreIdx = [1 0 0 1 1];

for isub = 1: size(dataIn, 1)

    respVec     = dataIn(isub, (19:end-1));
    tmpData     = zeros(1, 9);
    tmpData(1)  = str2num(ptIdx{isub});

    for isec = 1: 5

        if revScoreIdx(isec) == 1
            scoreEdit = [3 1 -1 -3];
        else
            % alters choice indices to reverse scores
            scoreEdit = [0 0 0 0];
        end

        tmpResp = respVec(subCompIdx{isec}); %choice idx

        for itmp = 1:4

            if tmpResp(itmp) == 1
                tmpScore(itmp) = tmpResp(itmp) + scoreEdit(1);
            elseif tmpResp(itmp) == 2
                tmpScore(itmp) = tmpResp(itmp) + scoreEdit(2);
            elseif tmpResp(itmp) == 3
                tmpScore(itmp) = tmpResp(itmp) + scoreEdit(3);
            elseif tmpResp(itmp) == 4
                tmpScore(itmp) = tmpResp(itmp) + scoreEdit(4);
            end
        end

        tmpData(isec+1) = sum(tmpScore);
        tmpData(7)      = sum(tmpData(2:6));
        tmpData(8)      = tmpData(7)/maxScore *100;   
    end

        if tmpData(8) >= 20 & tmpData(8) <=50
            ul_cat = 0; %low impulsivity
        elseif tmpData(8) >= 50 & tmpData <= 80
            ul_cat = 1; %high impulsivity
        end

        tmpData(9) = ul_cat;

    subComp_dataOut = [subComp_dataOut; tmpData];
    
end

    subComp_dataOut = array2table(subComp_dataOut);
    subComp_dataOut.Properties.VariableNames = {'subIdx', subComp{:}, 'ImpulseScore', 'ImpulsePerc', 'ImpulseType'};

    cd('C:\Users\jf22662\OneDrive - University of Bristol\Documents\GitHub\riskAversion_analysis\riskAversion_analysis\UPPSP\');
    savetableName = ['UPPSP_allScores_uptodate'];
    save(savetableName, 'subComp_dataOut');

end

