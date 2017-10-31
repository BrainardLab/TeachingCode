function psychofitTutorialTAFCStaircase
% psychofitTutorialTAFCStaircase
%
% Show a staircase procedure and illustrate how to aggregate data and fit.
%
% You need the Palamedes toolboxe (1.8.2) and BrainardLabToolbox for this to work.

% 10/30/17 dhb  Separated out and updated.

%% Clear
clear; close all; clear classes;

%% Specify precision as noise of a Gaussian variable
%
% Simulation parameters
noiseSd = 0.06;
testStimulus = 100;
nComparisonFit = 100;
nComparison = 10;
nSimulate = 40;
nComparisonSds = 4;
thresholdCriterionCorrect = 0.75;
baseStepSize = 0.10;

%% Set up stimulus range
comparisonStimuli = linspace(testStimulus,testStimulus+nComparisonSds*noiseSd,nComparison);
comparisonStimuliFit = linspace(testStimulus,testStimulus+nComparisonSds*noiseSd,nComparisonFit);

%% Staircase type. You can specify either 'quest' or 'standard'. 
staircaseType = 'standard';

%% Do a staircase for a TAFC experiment.  Uses our Staircase class.
% The code below runs either 1 or 3 interleaved staircases.
% The use of 1 or 3 is hard-coded, with parameters for each
% set in the switch statement below
nInterleavedStaircases = 3;
maxDelta = max(comparisonStimuli)-testStimulus;
minDelta = 0.01;

% Initialize staircases.  Initialization is slightly different for 'standard'
% and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
% are required, and this is enforced by the class constructor function.
%
% The logic for TAFC staircases is similar to Y/N, but we want to set 
% ups/downs or criterionCorr to aim above 50%, whereas in Y/N we typically
% aim at 50%.
for k = 1:nInterleavedStaircases
    % Set starting value for the staircase at a random level between
    % min and max.
    initialDelta = (maxDelta-minDelta)*3*rand(1)+minDelta;
    switch(staircaseType)
        case 'standard'
            stepSizes = [2*baseStepSize baseStepSize baseStepSize/4];
            switch (nInterleavedStaircases)
                case 1
                    % Parameters for just one staircase
                    numTrialsPerStaircase = 50;
                    nUps = [2];
                    nDowns = [1];
                case 3
                    % Parameters for three interleaved
                    % Can also make the up/down rule vary
                    % across the staircases, to spread trials
                    % a little more.
                    numTrialsPerStaircase = 30; 
                    nUps = [2 2 2];
                    nDowns = [1 1 1];
                otherwise
                    error('Don''t know how to deal with specified number of staircases');
            end
            st{k} = Staircase(staircaseType,initialDelta, ...
                'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                'MaxValue', maxDelta, 'MinValue', minDelta);
        otherwise
            error('Unknown staircase type specified');
    end
end

% Simulate interleaved staircases
for i = 1:numTrialsPerStaircase
    order = Shuffle(1:nInterleavedStaircases);
    for k = 1:nInterleavedStaircases
        comparisonDelta = getCurrentValue(st{order(k)});
        response = SimulateTAFC(testStimulus,testStimulus+comparisonDelta,noiseSd,noiseSd,1);
        st{order(k)} = updateForTrial(st{order(k)},comparisonDelta,response);
    end
end

% Analyze staircase data
valuesStair = []; responsesStair = [];
for k = 1:nInterleavedStaircases
    threshStair(k) = getThresholdEstimate(st{k});
    [valuesSingleStair{k},responsesSingleStair{k}] = getTrials(st{k});
    valuesStair = [valuesStair valuesSingleStair{k}];
    responsesStair = [responsesStair responsesSingleStair{k}];
end
[meanValues,nCorrectStair,nTrialsStair] = GetAggregatedStairTrials(valuesStair,responsesStair,10);

% Palamedes fit
%
% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above. Again, some
% thought is required to initialize reasonably.  The threshold parameter is reasonably taken to be in the
% range of the comparison stimuli, where here 0 means that the comparison is the same as the test.  The 
% second parameter should be on the order of 1/2, so we just hard code that.  As with Y/N, really want to 
% plot the fit against the data to make sure it is reasonable in practice.

% Define what psychometric functional form to fit.
%
% Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PF = @PAL_Weibull;                  

% The first two parameters of the Weibull define its shape.
%
% The third is the guess rate, which determines the value the function
% takes on at x = 0.  For TAFC, this should be locked at 0.5.
%
% The fourth parameter is the lapse rate - the asymptotic performance at 
% high values of x.  For a perfect subject, this would be 0, but sometimes
% subjects have a "lapse" and get the answer wrong even when the stimulus
% is easy to see.  We can search over this, but shouldn't allow it to take
% on unreasonable values.  0.05 as an upper limit isn't crazy.
%
% paramsFree is a boolean vector that determins what parameters get
% searched over. 1: free parameter, 0: fixed parameter
paramsFree = [1 1 0 1];  

% Initial guess.  Setting the first parameter to the middle of the stimulus
% range and the second to 1 puts things into a reasonable ballpark here.
paramsValues0 = [mean(comparisonStimuli'-testStimulus) 1 0.5 0.01];

% This puts limits on the range of the lapse rate
lapseLimits = [0 0.05];

% Set up standard options for Palamedes search
options = PAL_minimize('options');

% Do the search to get the parameters
[paramsValues] = PAL_PFML_Fit(...
    valuesStair',responsesStair',ones(size(responsesStair')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options,'lapseLimits',lapseLimits);

probCorrFitStair = PF(paramsValues,comparisonStimuliFit'-testStimulus);
threshPalStair = PF(paramsValues,thresholdCriterionCorrect,'inverse');

% Figure
stairFig = figure; clf;
colors = ['r' 'g' 'b' 'k' 'y' 'c'];
subplot(1,2,1); hold on
for k = 1:nInterleavedStaircases
    xvalues = 1:numTrialsPerStaircase;
    index = find(responsesSingleStair{k} == 0);
    plot(xvalues,valuesSingleStair{k},[colors(k) '-']);
    plot(xvalues,valuesSingleStair{k},[colors(k) 'o'],'MarkerFaceColor',colors(k),'MarkerSize',6);
    if (~isempty(index))
        plot(xvalues(index),valuesSingleStair{k}(index),[colors(k) 'o'],'MarkerFaceColor','w','MarkerSize',6);
    end
    plot(xvalues,threshStair(k)*ones(1,numTrialsPerStaircase),colors(k));
end
xlabel('Trial Number','FontSize',16);
ylabel('Level','FontSize',16);
title(sprintf('TAFC staircase plot'),'FontSize',16);

subplot(1,2,2); hold on
plot(meanValues,nCorrectStair./nTrialsStair,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot(comparisonStimuliFit-testStimulus,probCorrFitStair,'r','LineWidth',2);
plot([threshPalStair threshPalStair],[0 thresholdCriterionCorrect],'r','LineWidth',2);
xlabel('Delta Stimulus','FontSize',16);
ylabel('Prob Correct','FontSize',16);
title(sprintf('TAFC staircase psychometric function'),'FontSize',16);
xlim([comparisonStimuli(1)-testStimulus comparisonStimuli(end)-testStimulus])
ylim([0 1]);
if (exist('FigureSave','file'))
    FigureSave('StaircaseFC',gcf','pdf');
else
    saveas(gcf','StaircaseFC','pdf');
end

fprintf('Staircase simulated data\n');
for k = 1:nInterleavedStaircases
    fprintf('\tTAFC staircase %d threshold estimate:  %g\n',k,threshStair(k));
end
fprintf('Palamedes''s threshold estimate from staircase data: %g\n',threshPalStair);

end


%% Subfunctions for simulating observer

function nCorrect = SimulateTAFC(responseTest,responseComparison,testSd,comparisonSd,nSimulate)
% nCorrect = SimulateTAFC(responseTest,responseComparison,testSd,comparisonSd,nSimulate)
%
% Simulate out the number of times that a TAFC task is done correctly, with judgment greater
% corresponding to greater noisy response. 
%
% 4/25/09  dhb  Wrote it.

nCorrect = 0;
for i = 1:nSimulate
    responseTestNoise = responseTest+normrnd(0,testSd,1,1);
    responseComparisonNoise = responseComparison+normrnd(0,comparisonSd,1,1);
        
    if (responseComparison > responseTest & responseComparisonNoise > responseTestNoise)
        nCorrect = nCorrect+1;
    elseif (responseComparison <= responseTest & responseComparisonNoise <= responseTestNoise)
        nCorrect = nCorrect+1;
    end
end
end


