function peakTime = findMaxConsTime(totMean, ts)

peakTime = [];

for j=1:length(ts)
    peakTimeTemp = [];
    totSum = totMean(:,j);
    totSum = reshape(totSum, 360*24, size(totSum,1)/(360*24));
    %totSum24h = totSum(1:360:end,:);
    maxHour = max(totSum);%24h);
    for i=1:length(maxHour)
        positions = find(totSum(:,i)==maxHour(i));
        positions = positions(end);
        peakTimeTemp = [peakTimeTemp; positions + size(totSum,1) * (i-1)];
    end
    peakTime = [peakTime, peakTimeTemp];
end
end