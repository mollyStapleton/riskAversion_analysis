function [p] = ttest_posthoc_comparison_2lvl(dataIn, lvlofInterest, var1_idx, var2_idx)

for opj=1:length(var1_idx)  

    
    Lv1=cell2mat(dataIn(lvlofInterest(:, 1)==var1_idx(opj) & lvlofInterest(:, 2)==var2_idx(opj))')';

    for pqr=opj+1:length(var2_idx)
        Lv2=cell2mat(dataIn(lvlofInterest(:, 1)==var1_idx(pqr) & lvlofInterest(:, 2)==var2_idx(pqr))')';    
        p{opj*pqr} = NaN;
        [~,p{opj*pqr},~,~]=ttest2(Lv1,Lv2);  % ttest for pairwise comparison

    end
end

tmpIdx = find(~cellfun(@isempty,p));
p      = p(tmpIdx);

end
