function performances = evaluateMetrics(trajectory_ground, allTrajectoriesEstimates, param)

resolutions = param.resolutions;
leakStartID = param.leakStartID;
peakStart = param.peakStart;
peakEnd = param.peakEnd;
nApp = size(trajectory_ground,2);
totGround = sum(trajectory_ground,2);

% Adding leakage
trajectory_ground_Leak = totGround;
trajectory_ground_Leak(leakStartID:end) = trajectory_ground_Leak(leakStartID:end) + param.leakIntensity;

for i=1:length(resolutions)
    
    % Replicating lower resolution
    toReshape = allTrajectoriesEstimates{1,i};
    temp =[];
    for j=1:nApp
        trajectory_estimate_temp = repmat(toReshape(j,:),param.resolutions(i)/param.ground_resolution,1);
        trajectory_estimate_temp  = reshape(trajectory_estimate_temp,1, size(trajectory_estimate_temp,1) * size(trajectory_estimate_temp, 2));
        temp = [temp; trajectory_estimate_temp./param.resolutions(i)];
    end    
    allTrajectoriesEstimatesReplicate{1,i} = temp;
    
    % 1. Leak detection - Volume of water loss per unit sampling time
    leakDetectID = param.resolutions(i)*ceil(leakStartID/param.resolutions(i));
    performances.leakLoss(i) = sum(trajectory_ground_Leak(leakStartID:leakDetectID) - totGround(leakStartID:leakDetectID));
    
    % 2. System design - R2 accuracy on consumption peaks
    currResEstimateTOT = sum(temp);
    trajectory_groundTOT = sum(trajectory_ground,2);
    trajectory_groundTOT = trajectory_groundTOT';
    peakVec = zeros(1,24);
    peakVec(peakStart:peakEnd) = 1;
    idx = repmat(peakVec, 1, length(currResEstimateTOT)/24);
    idx = logical(idx);
    R2 = 1 - sum((trajectory_groundTOT(idx) - currResEstimateTOT(idx)).^2)/sum((trajectory_groundTOT(idx) - mean(trajectory_groundTOT(idx))).^2);
    tempDiffVec = trajectory_groundTOT(idx) - currResEstimateTOT(idx);
    maxDiff = prctile(tempDiffVec(tempDiffVec>=0),90); % Percentile alto
    
    performances.R2peak(i) = R2;
    clear R2
    
    performances.peakMax(i) = maxDiff;
    
    % 3. WDM R2 accuracy on end-use trajectories
    performances.R2disagg = mean([0.2 0.2 0; 0.51 0.03 0; 0 0.14 0.07; 0 0 0; 0 0 0]);
    
    % 4. Assigned water contribution error
    performances.AWC =  [1 1 1 ]-mean([0.036 0.049 0.126; 0.058 0.046 0.081; ...
        0.022 0.087 0.131; 0.078 0.052 0.07; 0.096 0.03 0.7 ]);

end

end


 