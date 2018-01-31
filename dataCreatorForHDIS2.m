clear
clc
close all

set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('/home/cominola/STREaM'));

% Setting resolutions
ts = [1 6 30 90 360 8640]; % 10s 1m 5m 15m 60m
appNamesToSave={'BME', 'CDE', 'CWE', 'DNE',  'DWE', 'EBE', 'WHE'};
timeInit=1333263600; % Useful for saving in AMPds format
calibrationRatio = 0.5;
num10SecPerDay = 6*60*24;

% Selecting houses positions
HHpositions = [1    57   283   359   451   489];

%%
for i=6:6%length(ts)
    disp(i)
    fileName = sprintf('allHousesOut_aggregate_%d.mat', ts(i));
    allHouses = importdata(fileName);
    appNames = fieldnames(allHouses{1,1});
    allData = struct;
    allDataCal = struct;
    allDataVal = struct;
    
    nHH = length(allHouses);
    
    for currHouse =1:length(HHpositions)
        for j =1: length(appNames)
            currApp = appNames{j};
            houseCounter =0;
            disp(HHpositions(currHouse));
            temp = allHouses{1,HHpositions(currHouse)}.(currApp);
            positions = allHouses{1,HHpositions(currHouse)}.TOTAL >0;
            temp = temp(positions);
            tempCal = temp(1:round(length(temp)/2)); % Select half period available
            tempVal = temp(round(length(temp)/2)+1:end); % Select remianing half period available
            
            if ts(i)==1
                allDataCal.(currApp) = tempCal';
                allDataVal.(currApp) = tempVal';
            else
                allDataCal.(currApp) = tempCal;
                allDataVal.(currApp) = tempVal;
            end
            %allHouses{1,currHouse}.(currApp) = [];
            clear temp tempCal tempVal
            
            allData.(currApp) = [allDataCal.(currApp); allDataVal.(currApp)];
        end
        timeFin=timeInit+60*(length(allData.TOTAL))-1;
        TS=[timeInit:60:timeFin]';
        success = saveAMPdsFormat2(allData, TS, ts(i), appNames, appNamesToSave, calibrationRatio, HHpositions(currHouse));
    end
    clear allHouses
end
