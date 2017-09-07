function [fitError,computedMatches] = FitLinFunction(fitParms,testLuminance,matchedRef)
% [fitError,computedMatches] = FitLinFunction(fitParms,testLuminance,matchedRef)
%
% Compute the errors between observed matches (matchedRef) and predicted matches
% (computedMatches) which are derived based on the simple linear regression model
% in the log-log domain.
%
% Inputs are test luminance and parameters vector fitParms,
% where fitParms is a 1 x 2 vector with entries [a, b].
%
% These are the parameters that are also used in the function ComputeMatches, which
% actually implements the model.
%
% See also: ComputeMatches.
%
% 3/09/10   ar      Adapted from a function Sarah once wrote for the "fitting a line" tutorial
% 3/11/10   dhb, ar Cosmetic.

%% Input sanity checks
if length(fitParms)~=2
    error('FitParms should have 2 elements corresponding to a and b.');
end
if length(testLuminance)~=length(matchedRef)
    error('The number of test luminance measures must equal the number of reflectance matches made.');
end

%% More checks
if (any(find(testLuminance <= 0)) || any(find(matchedRef <= 0)))
    error('Input luminances and input matches must be strictly positive.');
end

%% Compute predictions 
computedMatches = ComputeMatches(testLuminance, fitParms(1), fitParms(2));
if (any(isinf(computedMatches)))
    error('Surprising outcome -- some predictions are plus or minus infinity.\n');
end
fitError=ComputeError(matchedRef, computedMatches);