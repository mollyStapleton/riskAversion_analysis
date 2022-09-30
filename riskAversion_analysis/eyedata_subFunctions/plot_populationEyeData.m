function plot_populationEyeData(dataIn, plotType)

%------------------------------------------------------------------------------------
%*** ALL SUBFUNCTIONS PLOT DATA SEPARATELY FOR DISTRIBUTION TYPE  ***
%--------------------------------------------------------------------------------
for iplot = 1: length(plotType)

    if plotType(iplot) == 1

        % plotType = 1;
        %----------------------------------------------------------------------------
        %%%% PLOTTING IRRESPECTIVE OF CHOICE TYPE
        %%%%% GROUPED ACCORDING TO BLOCK NUMBER, DISTRIBUTION TYPE AND CONDITION
        %----------------------------------------------------------------------------
        plot_eyeData_cnd_blk_grouped(dataIn);
    
    elseif plotType(iplot) == 2
        % plotType = 2;
        %----------------------------------------------------------------------------
        %%%% PLOTTING RISKY VS SAFE CHOICES
        %%%%% GROUPED ACCORDING TO BLOCK NUMBER AND DISTRIBUTION TYPE
        %----------------------------------------------------------------------------
        plot_eyeData_cnd_blk_choice_grouped(dataIn);


    elseif plotType(iplot) == 3
        %----------------------------------------------------------------------------
        %%%% PLOTTING RISKY VS SAFE CHOICES
        %%%%% COLLAPSED ACROSS ALL BLOCKS, DERIVATIVE AND %SIGNAL CHANGE
        %%%%% PLOTTED
        %----------------------------------------------------------------------------
        % plotType = 3;
        plot_eyeData_derivative_choice_grouped(dataIn)
end

end