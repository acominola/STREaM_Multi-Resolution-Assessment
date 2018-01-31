function peakMRSEmean = evaluateRMSE(totMeanPeak)
for i =1:size(totMeanPeak,2)
    peakMRSEmean(i) = (mean(abs(totMeanPeak(:,1) - totMeanPeak(:,i))./totMeanPeak(:,1)).*100);
end
end