function plot_populationEyeData(dataIn, grouped_choice)

%----------------------------------------------------------------------------
%%%% PLOTTING IRRESPECTIVE OF CHOICE TYPE 
%%%%% GROUPED ACCORDING TO BLOCK NUMBER, DISTRIBUTION TYPE AND CONDITION 
%----------------------------------------------------------------------------
if ~grouped_choice

   plot_eyeData_cnd_blk_grouped(dataIn)

else

    plot_eyeData_cnd_blk_choice_grouped(dataIn)
%----------------------------------------------------------------------------
%%%% PLOTTING RISKY VS SAFE CHOICES
%%%%% GROUPED ACCORDING TO BLOCK NUMBER AND DISTRIBUTION TYPE  
%----------------------------------------------------------------------------

end