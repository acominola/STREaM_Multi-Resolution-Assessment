function [totMean, totMax] = sumTotals(allHouses, ts)

allTotals = [];
nHH = length(allHouses);

for i =1:nHH
    disp(i);
    if ts==1
        allTotals = [allTotals allHouses{1,i}.TOTAL'];
    else
        allTotals = [allTotals allHouses{1,i}.TOTAL];
    end
    if i>1
        allTotals= sum(allTotals,2);
    end
end

totSum = allTotals;
totSumRep = repmat(totSum, 1,ts);
totMean = reshape(totSumRep'./ts,size(totSumRep,1)*size(totSumRep,2),1);
totMax = reshape(totSumRep',size(totSumRep,1)*size(totSumRep,2),1);

end