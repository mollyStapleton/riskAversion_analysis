function plot_eye_deriv_fullTrial(dataIn_eye, dataIn_behav, blockNum)

idx = find(dataIn_behav.blockNumber == blockNum);
behav2use = dataIn_behav(idx, :);
xlsx_full = [];


noRespIdx = behav2use.RT==0;
behav2use(noRespIdx, :) = [];

    if blockNum == 1 
        hs = subplot(2, 2, 1);
    elseif blockNum == 2 
        hs = subplot(2, 2, 2);
    elseif blockNum == 3 
        hs = subplot(2, 2, 3);
    elseif blockNum == 4 
        hs = subplot(2, 2, 4);
    end


    %identify condition
    for icnd = 1:3
   
        respMade = [];
        if icnd == 1 
            col2plot = 'k';
        elseif icnd == 2 
            col2plot = 'r';
        elseif icnd == 3 
            col2plot = 'b';
        end

        cndIdx = find(behav2use.cnd_idx == icnd);
        trials2use = behav2use.trialNum(cndIdx);

%         timePupil{icnd} =  NaN(252, length(trials2use));

        for itrial = 1: length(trials2use)

            data2use   = dataIn_eye(trials2use(itrial)).data;
            respIdx = find([data2use(:, 3)] == 25);

            if ~isempty(respIdx)

                timeVec{itrial}  =  (data2use(:, 2) - data2use(respIdx(1), 2));

                % identify zero time points - sometimes there is more than
                % one as the delay time is identical to response 

                findZero = find(timeVec{itrial} == 0);

                if length(findZero) > 1

                    deleteIdx = findZero(findZero ~= respIdx);
                    timeVec{itrial}(deleteIdx) = [];
                    data2use(deleteIdx, :) = [];

                end

                % remove any duplicate time points, for reward on and
                % cumulative reward displayed (event occurs at the same
                % time)
                
                [v, w] = unique(timeVec{itrial}, 'stable' );
                duplicate_indices = setdiff( 1:numel(timeVec{itrial}), w );

                timeVec{itrial}(duplicate_indices) = [];
                data2use(duplicate_indices, :) = [];
                
                [ d, ix ] = min( abs( timeVec{itrial} - -0.2) );
                tmpIdx(1) = ix;
                [ d, ix ] = min( abs( timeVec{itrial} - 0.3) );
                tmpIdx(2) = ix;


                timePupil(:, itrial) = timeVec{itrial}(tmpIdx(1):tmpIdx(2));
                normPupil(:, itrial) = data2use((tmpIdx(1):tmpIdx(2)), 4);
                derivPupil(:, itrial)= data2use((tmpIdx(1):tmpIdx(2)), 5);

            end

        end

        mean_pupil{icnd} = nanmean(normPupil');
        mean_deriv{icnd} = nanmean(derivPupil');
        sem_pupil{icnd} = nanstd(normPupil')./sqrt(length(normPupil)');
        sem_deriv{icnd} = nanstd(derivPupil')./sqrt(length(derivPupil)');

        timeVector = linspace(-2, 3, 251);
        plot(timeVector, mean_pupil{icnd}, 'color', col2plot, 'linew', 1.2);
        hold on 
        plot(timeVector, mean_deriv{icnd}, 'color', col2plot, 'linew', 1.2, 'linestyle', '--');
        x2plot = [timeVector fliplr(timeVector)];
        error2plot = [mean_pupil{icnd}+ sem_pupil{icnd} fliplr([mean_pupil{icnd} - sem_pupil{icnd}])];
        error2plot_deriv = [mean_deriv{icnd} + sem_deriv{icnd} fliplr([mean_deriv{icnd} - sem_deriv{icnd}])];
        fill(x2plot, error2plot_deriv, col2plot, 'linestyle', 'none');
        fill(x2plot, error2plot, col2plot, 'linestyle', 'none');
        alpha(0.25);

    end
    max_mean = nanmax([cell2mat(mean_pupil) cell2mat(mean_deriv)]);
    min_mean = nanmin([cell2mat(mean_pupil) cell2mat(mean_deriv)]);

    hold on
    ylim([min_mean-1.5 max_mean+1.5]);
    y2plot = ylim;
    hold on 
    plot([0 0], [y2plot(1) y2plot(2)], 'k--', 'linew', 1.2);
    xlabel('\bfTime from Respsose Onset (s)');
    ylabel({'Pupil Response', '(% Signal Change)'});
    if behav2use.distType(1) == 1
        title(['\fontsize{14}Block ' num2str(blockNum) ': Gaussian']);
    else  
        title(['\fontsize{14}Block ' num2str(blockNum) ': Bimodal']);
    end


    if blockNum == 1
        legend('Mean: Both Diff', 'Deriv: Both-Diff', '', '', 'Mean: Both-Low', 'Deriv: Both-Low', '', '',...
            'Mean: Both-High', 'Deriv: Both-High', 'location', 'southwest');
    end

    set(gca, 'fontName', 'times');


end
