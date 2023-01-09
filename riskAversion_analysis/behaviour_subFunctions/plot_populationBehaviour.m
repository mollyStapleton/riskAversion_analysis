function plot_populationBehaviour(base_path, dataIn)

savePopulationFolder = ['population_dataAnalysis'];
if exist([base_path savePopulationFolder])
    mkdir([base_path savePopulationFolder])
    cd([base_path savePopulationFolder]);
end
cd([base_path savePopulationFolder]);

% accuracy analysis 

riskAversion_accuracyStats([base_path savePopulationFolder], dataIn);

% risk preference analysis 

riskAversion_riskPrefStats([base_path savePopulationFolder], dataIn);

end
