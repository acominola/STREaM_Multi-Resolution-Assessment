function allHousesOut_aggregate = aggregateResolution(allHousesOut, ts)

% Aggregate 10-second sampling resolution time series to a desired
% resolution
nHH = length(allHousesOut);

for i=1:nHH-1 % For each household
    disp(i);
    currHouse = allHousesOut{1,i};    
    appNames = fieldnames(currHouse);
    nApp = length(appNames);
    
    % Converting data to matrix
    fineData = [];
    for currApp =1:nApp
        currName = appNames{currApp};
        fineData = [fineData, currHouse.(currName)'];
    end
    
    aggregateData = cumsum(fineData);
    aggregateData = aggregateData(ts:ts:end,:);
    aggregateData = [zeros(1,size(aggregateData,2)); aggregateData];
    aggregateData = diff(aggregateData);
    
    allHousesOut_aggregate{1,i} = table2struct(array2table(aggregateData,'VariableNames', appNames),'ToScalar',true);
end