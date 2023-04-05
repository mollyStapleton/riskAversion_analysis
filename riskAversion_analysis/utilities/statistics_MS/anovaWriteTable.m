function anovaWriteTable(C, tableName)

for no=2:size(C,1)
    eta2p=(C{no,2}*C{no,3})/(C{no,2}*C{no,3}+C{no,4});
    C{no,6}=eta2p;

end

table2save = cell2table(C(2:end, :));
anova_rownames =  {'Terms', 'FStat', 'DF1', 'DF2', 'pValue', 'pETA'};
table2save.Properties.VariableNames = anova_rownames;
saveFilename = ['ANOVA_' tableName '.csv'];
writetable(table2save, saveFilename,'WriteVariableNames', true);



end