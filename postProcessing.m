clear
clc
close all

set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('/Users/ACo/GitRepo/sh2o/SyntheticGenerator/v0.3/'));

% Setting resolutions
ts = [1 6 30 90 360 8640]; % 10s 1m 5m 15m 60m

% Setting the seed
rng(1);

%% Downsampling high sampling frequency time series

load allHousesOut.mat

for i=1:length(ts)
    if ts(i) >1
        temp =  aggregateResolution(allHousesOut, ts(i));
    end
    
    switch ts(i)
        case 1 % 10 sec
            allHousesOut_aggregate_1 = allHousesOut;
        case 6 % 1 min
            allHousesOut_aggregate_6 =temp;
        case 30 % 5 min
            allHousesOut_aggregate_30 =temp;
        case 90 % 15 min
            allHousesOut_aggregate_90 =temp;
        case 360 % 1 hour
            allHousesOut_aggregate_360 =temp;
        case 8640 % 1 day
            allHousesOut_aggregate_8640 =temp;
    end
    fileName = sprintf('allHousesOut_aggregate_%d.mat', ts(i));
    varName = sprintf('allHousesOut_aggregate_%d', ts(i));
    save(fileName, varName);
end

%% Evaluating metrics
nHH = 500;%length(allHousesOut);
nDays = 365;

% --- 1.Normalized leak volume
% load allHousesOut_aggregate_1.mat
% waterLoss = evaluateLeakages(allHousesOut_aggregate_1, ts);
% save waterLoss.mat waterLoss

load waterLoss.mat
normWaterLoss = log(waterLoss)./max(log(waterLoss));

% --- 2.Assigned end-use water contribution accuracy
load WCEmean.mat
WCEmean = 100-WCEmean.*100;
normWCEmean = (WCEmean - min(WCEmean))./(max(WCEmean)- min(WCEmean));

load RMSEmean.mat
RMSEmean = RMSEmean;
normRMSEmean = RMSEmean./max(RMSEmean);

% --- 3.Consumption peak at different resolutions
% for i=1:length(ts)
%     fileName = sprintf('allHousesOut_aggregate_%d.mat', ts(i));
%     load(fileName);
%     varName = sprintf('allHousesOut_aggregate_%d', ts(i));
%     [totMean(:,i), totMax(:,i)] = sumTotals(eval(varName), ts(i));
%     clearvars -except totMean totMax ts i
% end

load totMean500.mat
peakTime = findMaxCons(totMean);
totMeanPeak = totMean(peakTime(:),:);

peakRMSEmean = evaluateRMSE(totMeanPeak);
normPeakRMSEmean = peakRMSEmean./max(peakRMSEmean);

% --- 3b. Consumption peak time delay at different resolutions ::: ADDED FOR Review R1

load totMean500.mat
peakTime = findMaxConsTime(totMean, ts);
peakTime = peakTime.*10;
peakTimeDiff = evaluatePeakTimeDiff(peakTime)./60;
normPeakTimeDiff = log(peakTimeDiff)./max(log(peakTimeDiff));

% --- 4.Normalized daily data size per household (Gb);
bytesPerFloat = 4*2; % Assumption: each float is 4 bytes
num10SecPerDay = 6*60*24;
dataPointsPerDay = (ones(size(ts)).*num10SecPerDay)./ts;
MBytesPerDay = dataPointsPerDay.*bytesPerFloat.*nDays./(10^6);%./(10^9).*nHH;
normMBytesPerDay = (log(MBytesPerDay)-min(log(MBytesPerDay)))./(max(log(MBytesPerDay))-min(log(MBytesPerDay)));

% --- 5.Commercial availability of meter
commercialAvailability = zeros(size(ts));
commercialAvailability(ts>6) = 1;

% Grouping all metrics and final representation
allMetricsNorm = [ normWCEmean; 1- normRMSEmean; 1- normWaterLoss; 1 - normPeakRMSEmean; 1-normPeakTimeDiff; 1- normMBytesPerDay; commercialAvailability];
allMetrics = [WCEmean; RMSEmean; waterLoss;  peakRMSEmean; peakTimeDiff; MBytesPerDay; commercialAvailability];

figure;
set (gcf, 'DefaultTextFontName', 'Verdana', ...
    'DefaultTextFontSize', 14, ...
    'DefaultAxesFontName', 'Verdana', ...
    'DefaultAxesFontSize', 14, ...
    'DefaultLineMarkerSize', 10);

imagesc(allMetricsNorm);

textStrings = num2str(allMetrics(:),2);  % Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:size(allMetricsNorm,2), 1:size(allMetricsNorm,1));   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
    'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(allMetricsNorm(:) > midValue,1,3);  %# Choose white or black for the
%#   text color of the strings so
%#   they can be easily seen over
%#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors


colormap(flipud(bone));

c=colorbar('southoutside');
set(c,'YTick',0:1:1);
set(c,'YTickLabel', []);
hXLabel = xlabel(c, 'Low performance                                                                                High performance');
%set(hYLabel,'Rotation',90);

%set(gca,'YTick', 1:1:4,'YTickLabel',{'Normalized avoided leak volume','Flow peak estimation accuracy','Assigned water contribution accuracy', 'Average R2 on end-use disaggregation'});
xlabel('Data sampling resolution');
set(gca,'XTick', 1:1:6,'XTickLabel',{'10 s','1 min','5 min','15 min','60 min','1 d'});
%set(gca,'YTick', 1:1:6,'YTickLabel',{'End-use disaggregation\newline                AAWCA [%]', 'End-use disaggregation\newline                ANRMSE [-]','                                     Leakage detection\newline                              AWL [liters/household]','   Peak demand estimation\newline                      APDEE [%]', '                                                Data storage\newline                        DS [bytes/(household*year)]','Commercial availability\newline                        CA [-]'});
set(gca,'YTick', 1:1:7,'YTickLabel',{'Appliance Contribution Accuracy [%]', 'Appliance RMSE [-]','Average Water Loss [L/(household \times y)]','Peak Estimation Error [%]', 'Peak Estimation Time Gap [min]','Data storage [MB/(household \times y)]','Commercial availability [Yes/No]'});
title('Multi-resolution comparative assessment');


