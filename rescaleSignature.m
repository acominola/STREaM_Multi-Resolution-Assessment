function TenSecSignature = rescaleSignature(initialSignature)

% Rescale signature in order to have 10 second resolution
% Linear behaviour is assumed for unknown time steps.

tStart = 1;
tEnd = initialSignature(end,2) - initialSignature(1,2) +1;

% Existing Data
measuredTimeSteps = initialSignature(:,2) +1;
dataMeasured = initialSignature(:,1);

timeSteps = [0; diff(measuredTimeSteps)];
increments = [0; diff(dataMeasured)];

avgIncrement = increments./timeSteps;

tVector=tStart:tEnd;
rescaledSignature = zeros(1,length(tVector));

% Rescale signature to 10 second resolution
rescaledSignature(measuredTimeSteps) = dataMeasured;

counter = 1;

for i=1:length(rescaledSignature)
    currPos = i;
    if currPos == measuredTimeSteps(counter) && counter < length(measuredTimeSteps)
       counter = counter+1;
    else 
        rescaledSignature(currPos) = rescaledSignature(currPos -1) + avgIncrement(counter);
    end
end

% Aggregating signature values to rescale the signature to 10 seconds
% resolution
TenSecSignature = cumsum(rescaledSignature);
TenSecSignature = [0 diff(TenSecSignature(1:10:end)) 0];

end
