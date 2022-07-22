function [trl] = riskAversion_trialfun(event)



value   = {event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).value};
sample  = [event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).sample];

% identify TRIALID events, should == 120 for a full block 
tstart_sample = [event(find(strcmp('20', {event.type}))).sample]';
tstart_value  = {event(find(~cellfun(@isempty,strfind({event.value},'20')))).value};
trl           = [];

for itrial = 1: length(tstart_sample)-1

    newTrl = [];
    trlbeg = find([event.sample] == tstart_sample(itrial));
    trlend = find([event.sample] == tstart_sample(itrial+1));
    
    % returns all samples from message specified trial start and end
    % encodes
    if length(trlbeg) == 1
        allTr  = [event(trlbeg(1): trlend(1)-1).sample];
    else
        allTr  = [event(trlbeg(2): trlend(1)-1).sample];
    end

       
    newTrl.trialID = itrial;

    if length(trlbeg) == 1
        eventIdx = (trlbeg(1): trlend(1)-1);
    else 
        eventIdx = (trlbeg(2): trlend(1)-1);
    end

    for iencode = 1: length(eventIdx)
        
        if ~isempty(str2num(event(eventIdx(iencode)).type))
            newTrl.encodes(iencode, 1) = str2num(event(eventIdx(iencode)).type);
            newTrl.encodes(iencode, 2) = allTr(iencode);
        end

    end
    
    trl = [trl newTrl];


end


end
