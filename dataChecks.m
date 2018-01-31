set(0,'DefaultFigureWindowStyle','docked')

addpath(genpath('/Users/ACo/GitRepo/sh2o/SyntheticGenerator/v0.3/'));
load database.mat

app = fieldnames(database.UseFrequencies);
numApp = length(app);
HHsize = 6;

%% ::: Durations vs Volumes
customizedFigureOpen;
for nApp = 1:numApp
    currApp = app{nApp};
    for currHHsize = 1:HHsize
        subplot(HHsize,numApp, nApp+(numApp)*(currHHsize-1)); scatter(database.UseFrequencies.(currApp).EventDuration{1,currHHsize}, database.UseFrequencies.(currApp).EventVolume{1,currHHsize});
        titleName = sprintf([currApp '-HH%d'], currHHsize);
        title(titleName);
    end
end
suptitle('Durations VS Volumes');

%% ::: Durations vs Starting time
customizedFigureOpen;
for nApp = 1:numApp
    currApp = app{nApp};
    for currHHsize = 1:HHsize
        if length(database.UseFrequencies.(currApp).EventDuration{1,currHHsize}) == length(database.UseFrequencies.(currApp).EventStartTime{1,currHHsize})
            subplot(HHsize,numApp, nApp+(numApp)*(currHHsize-1)); scatter(database.UseFrequencies.(currApp).EventStartTime{1,currHHsize}, database.UseFrequencies.(currApp).EventDuration{1,currHHsize});
            titleName = sprintf([currApp '-HH%d'], currHHsize);
            title(titleName);
        end
    end
end

%% ::: Durations vs HHsize
customizedFigureOpen;
iterator = 0;

for nApp = 1:numApp
    currApp = app{nApp};
    tempLim =0;
    iterator = iterator +1;
    temp1 = [];
    temp2 = [];
    for currHHsize = 1:HHsize
        temp1 = [temp1; database.UseFrequencies.(currApp).EventDuration{1,currHHsize}];
        temp2 = [temp2; ones(length(database.UseFrequencies.(currApp).EventDuration{1,currHHsize}),1).*currHHsize];
        if prctile(database.UseFrequencies.(currApp).EventDuration{1,currHHsize},98) > tempLim
            tempLim = prctile(database.UseFrequencies.(currApp).EventDuration{1,currHHsize},98);
        end
    end
    subplot(3,4,iterator); h=boxplot(temp1, temp2);
    set(h(7,:),'Visible','off');
    ylim([0, tempLim]);
    xlabel('Hhousehold size');
    ylabel('Event duration [10 s]');
    titleName = sprintf(currApp);
    title(titleName);
end
suptitle('House Size VS Durations');

%% ::: Volumes vs HHsize
customizedFigureOpen;
iterator = 0;
temp1 = [];
temp2 = [];
for nApp = 1:numApp
    tempLim =0;
    currApp = app{nApp};
    iterator = iterator +1;
    temp1 = [];
    temp2 = [];
    for currHHsize = 1:HHsize
        temp1 = [temp1; database.UseFrequencies.(currApp).EventVolume{1,currHHsize}];
        temp2 = [temp2; ones(length(database.UseFrequencies.(currApp).EventVolume{1,currHHsize}),1).*currHHsize];
        if prctile(database.UseFrequencies.(currApp).EventVolume{1,currHHsize},99) > tempLim
            tempLim = prctile(database.UseFrequencies.(currApp).EventVolume{1,currHHsize},99);
        end
    end
    subplot(3,4,iterator); h=boxplot(temp1, temp2);
    set(h(7,:),'Visible','off');
    ylim([0, tempLim]);
    xlabel('Hhousehold size');
    ylabel('Event volume [Liters]');
    titleName = sprintf(currApp);
    title(titleName);
end
suptitle('House Size VS Volumes');

%% ::: Check on the distribution of the number of events per day (CW and DW)
customizedFigureOpen;
subplot(2,2,1);
for currHHsize = 1:HHsize
    ecdf(database.UseFrequencies.StClothesWasher.NumberOfEventsPerDay{1,currHHsize});hold on;
    temp(1,currHHsize) = max(database.UseFrequencies.StClothesWasher.NumberOfEventsPerDay{1,currHHsize});%>1)./length(database.UseFrequencies.StClothesWasher.NumberOfEventsPerDay{1,currHHsize});
end
title('ECDF of number of events per day - St CW');

subplot(2,2,2);
for currHHsize = 1:HHsize
    ecdf(database.UseFrequencies.HEClothesWasher.NumberOfEventsPerDay{1,currHHsize});hold on;
    temp(2,currHHsize) = max(database.UseFrequencies.HEClothesWasher.NumberOfEventsPerDay{1,currHHsize});%./length(database.UseFrequencies.HEClothesWasher.NumberOfEventsPerDay{1,currHHsize});
end
title('ECDF of number of events per day - HE CW');

subplot(2,2,3);
for currHHsize = 1:HHsize
    ecdf(database.UseFrequencies.StDishwasher.NumberOfEventsPerDay{1,currHHsize});hold on;
    temp(3,currHHsize) = max(database.UseFrequencies.StDishwasher.NumberOfEventsPerDay{1,currHHsize});%./length(database.UseFrequencies.StDishwasher.NumberOfEventsPerDay{1,currHHsize});
end
title('ECDF of number of events per day - St DW');

subplot(2,2,4);
for currHHsize = 1:HHsize
    ecdf(database.UseFrequencies.HEDishwasher.NumberOfEventsPerDay{1,currHHsize});hold on;
    temp(4,currHHsize) = max(database.UseFrequencies.HEDishwasher.NumberOfEventsPerDay{1,currHHsize});%./length(database.UseFrequencies.HEDishwasher.NumberOfEventsPerDay{1,currHHsize});
end
title('ECDF of number of events per day - HE DW');


%% Goodness of fitted probabilities
for nApp = 1:numApp
    customizedFigureOpen;
    currApp = app{nApp};
    statisticFeaturesF = fieldnames(database.UseFrequencies.(currApp));
    statisticFeaturesP = fieldnames(database.UseProbabilities.(currApp));
    for currStat=1:length(statisticFeaturesP)
        for currHHsize =1:HHsize
            % Generate random samples
            temp=[];
            if currStat < 3
                for nSamples = 1:500
                    temp(nSamples,:) = random(database.UseProbabilities.(currApp).(statisticFeaturesP{currStat,1}){1,currHHsize}{1,1});
                end
                subplot(length(statisticFeaturesF),HHsize,currHHsize + HHsize*(currStat-1));
                ecdf(temp); hold on; ecdf(database.UseFrequencies.(currApp).(statisticFeaturesF{currStat,1}){1,currHHsize});
                legend('Model', 'Data');
                title(statisticFeaturesF{currStat,1});
            else
                for nSamples = 1:500
                    temp(nSamples,:) = random(database.UseProbabilities.(currApp).(statisticFeaturesP{currStat,1}){1,currHHsize});
                end
                temp = round(exp(temp));
                subplot(length(statisticFeaturesF),HHsize,currHHsize + HHsize*(currStat-1));
                ecdf(temp(:,1)); hold on; ecdf(database.UseFrequencies.(currApp).(statisticFeaturesF{currStat ,1}){1,currHHsize});
                legend('Model', 'Data');
                title(statisticFeaturesF{currStat,1});
                subplot(length(statisticFeaturesF),HHsize,currHHsize + HHsize*(currStat));
                ecdf(temp(:,2)); hold on; ecdf(database.UseFrequencies.(currApp).(statisticFeaturesF{currStat +1 ,1}){1,currHHsize});
                legend('Model', 'Data');
                title(statisticFeaturesF{currStat + 1,1});
            end
        end
    end
   suptitle(currApp);
end
