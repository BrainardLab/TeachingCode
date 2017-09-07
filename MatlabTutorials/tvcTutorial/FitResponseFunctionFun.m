function [fitError,predictedThresholds] = FitResponseFunctionFun(fitParms,pedestalIntensities,theThresholds)
%% [fitError,predictedThresholds] = FitResponseFunctionFun(fitParms,pedestalIntensities,theThresholds)
%
% Compute the errors between observed threshold values (theThresholds) and predicted threshold 
% values (predictedThresholds) for a for a given response function with parameters
% fitParms, where fitParms is a 1 x 3 vector with entries [rMax, g, n].  These are the
% parameters needed by the function ComputeResponses.
%
% This function employs PredictThresholds to predict the threshold values
% for a given set of pedestals (pedestalIntensities).
%
% 6/21/06   sra    Wrote it.
% 6/22/06   dhb    Pulled out as function, got rid of globals, cosmetic edits.

%% Input sanity checks
if length(fitParms)~=3
    error('FitParms should have 3 elements corresponding to rMax, g, and n');
end
if length(pedestalIntensities)~=length(theThresholds)
    error('the number of test pedestals must equal the number of observed thresholds');
end

%% Compute error
predictedThresholds = PredictThresholds(pedestalIntensities, fitParms(1), fitParms(2), fitParms(3));
if (any(isinf(predictedThresholds)))
    fitError = 1e6;
else
    squaredDiffs = (log10(theThresholds(:)) - log10(predictedThresholds(:))).^2;
    fitError = sum(squaredDiffs);
end
