function error=ComputeError(observedValues, predictedValues)
% function error=ComputeMinError(actualValues, predictedValues)
%
%  Computes error by taking the deviations of predicted from observed values at every trial. 
%  To be fair to the model, we have to do a parameter search so that it
%  minimizes deviations from each trial and not the mean matches over
%  trials, because that provides the minimal error.
%
%  3/11/2010   ar       Wrote it.  
%  3/15/10     dhb, ar  Compute RMSE instead.

nTrials=size(observedValues,2);
for i=1:nTrials;
    squaredDiffs(:,i) = (log10(observedValues(:,i)) - log10(predictedValues(:))).^2; %#ok<AGROW>
end

% Compute root mean squared error
error = sqrt(mean(squaredDiffs(:)));

end
