function [trl] = riskAversion_trialfun(event)

value   = {event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).value};
sample  = [event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).sample];

% identify TRIALID events, should == 120 for a full block 
tstart_sample = [event(find(strcmp('20', {event.type}))).sample]';
tstart_value  = {event(find(~cellfun(@isempty,strfind({event.value},'20')))).value};

tend_sample = [event(find(strcmp('21', {event.type}))).sample]';
tend_value  = {event(find(~cellfun(@isempty,strfind({event.value},'21')))).value};
trl           = [];

for itrial = 1: length(tstart_sample)

    newTrl = [];
    trlbeg = find([event.sample] == tstart_sample(itrial));
    trlend = find([event.sample] == tend_sample(itrial));
    
    % returns all samples from message specified trial start and end
    % encodes
    if length(trlbeg) == 1
        allTr  = [event(trlbeg(1): max(trlend)).sample];
    else
        allTr  = [event(trlbeg(2): max(trlend)).sample];
    end

       
    newTrl.trialID = itrial;

    if length(trlbeg) == 1
        eventIdx = (trlbeg(1): max(trlend));
    else 
        eventIdx = (trlbeg(2): max(trlend));
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
