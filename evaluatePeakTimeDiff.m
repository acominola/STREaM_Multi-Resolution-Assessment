function peakTimeDiff = evaluatePeakTimeDiff(peakTime)
peakTimeDiff = [];
for i=1:size(peakTime,2)
    tempDiff = abs(peakTime(:,i) - peakTime(:,1));
    peakTimeDiff(i) = mean(tempDiff);
end
end