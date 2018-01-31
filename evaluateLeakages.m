function waterLoss = evaluateLeakages(allHouses, ts)

nHH = length(allHouses);

for i=1:nHH-1
    currHouse = allHouses{1,i};
    
    % Evaluate maximum volume of each appliance
    appNames = fieldnames(currHouse);
    maxVol = [];
    
    for j=1:length(appNames)-1
        currApp = appNames{j};
        disp(currApp);
        maxVol(j) = max(currHouse.(currApp));
    end
    
    % Sampling max leakage value
    leakMax = maxVol(randi(j));
    
    % Sampling leakage start time
    leakStart = randi(length(currHouse.TOTAL)-ts(end));
    
    % Sampling leakage transient type
    leakTransientT = randi(4);
    
    % Sampling leakage transient end
    if leakTransientT==1
        leakTransientD =0;
    else
        leakTransientD = randi([leakStart, length(currHouse.TOTAL)-1]) - leakStart;
    end
    
    lossTimeSeries = zeros(size(currHouse.TOTAL));
    switch leakTransientT
        
        case 1 % no transient
            lossTimeSeries(leakStart:end) = leakMax;
            
        case 2  % linear transient
            tLinear = 1:1:leakTransientD;
            lossLinear = leakMax/leakTransientD*tLinear;
            lossTimeSeries(leakStart:leakStart+leakTransientD-1) = lossLinear;
            
        case 3  % parabolic transient
            tParabolic = 1:1:leakTransientD;
            x=[0 leakTransientD*0.5 leakTransientD];
            y=[0 leakMax/3 leakMax];
            c=polyfit(x,y,2);
            lossParabolic=c(1)*tParabolic.^2+c(2)*tParabolic;
            lossTimeSeries(leakStart:leakStart+leakTransientD-1) = lossParabolic;
            
        case 4  % exponential transient
            tExp = 1:1:leakTransientD;
            x=[0 leakTransientD*0.7 leakTransientD]';
            y=[0 leakMax/4 leakMax]';
            f=fit(x,y,'exp1','StartPoint',[0,0]);
            lossExp=f.a*exp(f.b*tExp);
            lossTimeSeries(leakStart:leakStart+leakTransientD-1) = lossExp;
    end
    lossTimeSeries(leakStart+leakTransientD:end) = leakMax;
    
    for samplingRes=1:length(ts)
        waterLoss(i,samplingRes) = sum(lossTimeSeries(leakStart:leakStart + ts(samplingRes)));
    end
end
waterLoss = mean(waterLoss);

end