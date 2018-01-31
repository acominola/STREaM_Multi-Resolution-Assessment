function peakTime = findMaxCons(totSum)

peakTime = [];
totSum = totSum(:,1);
totSum = reshape(totSum, 360*24, size(totSum,1)/(360*24));
%totSum24h = totSum(1:360:end,:);
maxHour = max(totSum);%24h);
for i=1:length(maxHour)
    positions = find(totSum(:,i)==maxHour(i));
    peakTime = [peakTime, positions + size(totSum,1) * (i-1)];
end
end
