% classificationImageTutorial
%
% Work out classification image analysis for a lighter/darker task.
% I could go read something, but let's just try from first principles.
%
% 7/24/09  dhb  Wrote it.

%% Clear
clear; close all;

%% Define observer.
% The model is simple.  The observer takes a weighted
% sum of N intensities, adds noise, and comparies the result to a 
% criterion. This leads to a 1/0 response.

% Weights
observerWeights = [1 0.1 0.1 0.01 0.01];
observerNoiseSd = 0.1;

%% Stimulus properties, and criterion
% We simulate a series of trials.  On each trial, the intensities of
% different locations are drawn at random around a mean vector.
%
% It's important that the criterion be such that there are a reasonable number
% of both 1 and 0 responses, and that the variation between the two
% isn't dominated by the observer noise.  Otherwise, the experiment
% really doesn't carry information about the weights.  Experimentally
% we'd probably deal with this by running a staircase to drive the test
% and comparison patches towards the point of subjective equality.
%
% Here we'll just set the criterion to be the response to the mean stimulus,
% on the grounds that this is good enough.
meanStimulus = [3 2 7 4 1]';
criterion = observerWeights*meanStimulus;

%% Muck with criterion, to see if it matters
criterionMuckFactor = 1.2;
criterion = criterionMuckFactor*criterion;
    
%% Simulate experiment
% On each trial we perturb the mean stimulus with added noise, compute
% the visual response, add observer noise, and compare to the criterion.
nTrials = 10000;
stimulusNoiseSd = 1;
for i = 1:nTrials
    stimulus(:,i) = normrnd(meanStimulus,stimulusNoiseSd*ones(size(meanStimulus)));
    deterministicVisualResponse(i) = observerWeights*stimulus(:,i);
    noisyVisualResponse(i) = deterministicVisualResponse(i) + normrnd(0,observerNoiseSd);
    if (noisyVisualResponse(i) > criterion)
        observerResponse(i) = 1;
    else
        observerResponse(i) = 0;
    end
end
fprintf('%d of %d trials were ''yes''\n',sum(observerResponse),nTrials);

%% Analyze experiment.
% We want to find estimatedWeights, estimatedCriterion such that
% comparing estimatedWeights*stimulus and comparting to
% estimatedWeights predicts the observed responses.  This is a generalized linear 
% regression problem, so let's solve it that way instead of trying to
% figure out something weird.
%
% By the way, it's immediately clear that you can only get the weights
% up to an unknown scale factor, because you can multiply the weights
% and the criterion by the same scale factor and predict the same
% set of responses.
[regWeights,nil,regStats] = glmfit(stimulus',observerResponse','binomial');
rawCriterion = -regWeights(1);
rawWeights = regWeights(2:end)';

% Since we can only get relative weights, scale to match
freeScale = rawWeights'\observerWeights';
estimatedCriterion = freeScale*rawCriterion;
estimatedWeights = freeScale*rawWeights;

% Print some stuff
fprintf('Observer criterion: %0.2g, estimated as %0.2g\n',criterion,estimatedCriterion);
fprintf('Weights\n');
for i = 1:length(observerWeights)
    fprintf('\tObserver weight %d: %0.2g estimated as %0.2g\n',i,observerWeights(i),estimatedWeights(i));
end
