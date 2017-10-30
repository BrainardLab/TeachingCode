function psychofitTutorial
% psychofitTutorial2014
%
% Show basic use of psignifit and Palamedes toolboxes to simulate and
% fit psychophysical data.  Has cases for Y/N and TAFC, and shows 
% both method of constant stimuli and staircase procedures.
%
% This is set up for our local version of psignifit, where the function psi has been
% renamed psigpsi to avoid a name conflict with MATLAB's own psi function.
%
% You need both the psignifit and Palamedes toolboxes on your path, as well
% as the Brainard lab staircase class and the Psychtoolbox.
%
% * [NOTE: DHB - This is a somewhat outdated version, as both psignifit and
%   Palamedes have changed since this was written. And, it does not use
%   mQUESTPlus. Starting to update parts in a new version today, 

% 4/30/09  dhb  Wrote it.
% 10/18/09 dhb  Add some fits with Palamedes, just for grins
% 10/19/09 dhb  Added TAFC example as well as Y/N.  Cleaned up and added comments.
% 10/19/09 dhb  Use staircase class for a TAFC staircase example.
% 5/6/11   dhb  Fix initial guess of slope for Palamedes.  This was inverted, but worked by luck previously.
% 10/31/12 dhb  Fix what is printed out for Y/N staircase threshold.
%          dhb  Y/N thresh defined as 75% point minus 50% point.
%          dhb  Save figures, and a few more lines on the figs.
%          dhb  Add option to simulate adapting bias.
% 11/14/13 dhb  Tune up a bunch of little things.
% 10/21/14 dhb  Added better comments for staircasing stuff.

%% Clear
clear; close all; clear classes;

%% Specify precision as noise of a Gaussian variable
%
% Simulated Y/N experiment is for test bigger or less than 
% comparison.
noiseSd = 0.06;
testStimulus = 100;
nComparisonFit = 100;
adaptingBias = 0;
nComparison = 10;
nSimulate = 40;

%% Staircase type. You can specify either 'quest' or 'standard'. 
staircaseType = 'standard';

%% Simulate Y/N psychometric function and fit.  The cumulative normal is a pretty natural choice
% for y/n psychometric data, and that's what's shown here.
%
% There are lots of variants to the fitting that could be used, in the sense that we could
% allow for lapse rates, etc.  But this form should work pretty well for most purposes.  It's
% always a good idea to plot the fit against the actual data and make sure it is reasonable.
% For staircase data, this requires some binning (not demonstrated here.)
comparisonStimuli = linspace(testStimulus-4*noiseSd,testStimulus+4*noiseSd,nComparison);
comparisonStimuliFit = linspace(testStimulus-4*noiseSd,testStimulus+4*noiseSd,nComparisonFit);
for i = 1:nComparison
    nYes(i) = SimulateProbYes(testStimulus,comparisonStimuli(i),0,noiseSd,nSimulate,adaptingBias); %#ok<AGROW>
end

% PSIGNIFIT
% Fit simulated data, psignifit.  These parameters do a one interval (y/n) fit.  Both lambda (lapse rate) and
% gamma (value for -Inf input) are locked at 0.
fittype = 'c';
pfitdata = [comparisonStimuli', nYes', nSimulate*ones(size(nYes'))];
pfitstruct = pfit(pfitdata,'no plot','matrix_format','xrn', ...
    'shape', fittype, 'n_intervals', 1, 'runs', 0, 'sens', 0, ...
    'compute_stats', 0, 'cuts', [0.5], 'verbose', 0, 'fix_lambda',0,'fix_gamma',0);
probYesFitPsig = psigpsi(fittype, pfitstruct.params.est, comparisonStimuliFit');
psePsig = findthreshold(fittype,pfitstruct.params.est,0.5,'performance');
threshPsig = findthreshold(fittype,pfitstruct.params.est,0.75,'performance') - ...
    findthreshold(fittype,pfitstruct.params.est,0.5,'performance');

% PALAMEDES
% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above.  Some thinking is
% required to initialize the parameters sensibly.  We know that the mean of the cumulative normal should be 
% roughly within the range of the comparison stimuli, so we initialize this to the mean.  The standard deviation
% should be some moderate fraction of the range of the stimuli, so again this is used as the initializer.
PF = @PAL_CumulativeNormal;         % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PFI = @PAL_inverseCumulativeNormal;
paramsFree = [1 1 0 0];             % 1: free parameter, 0: fixed parameter
paramsValues0 = [mean(comparisonStimuli') 1/((max(comparisonStimuli')-min(comparisonStimuli'))/4) 0 0];
options = optimset('fminsearch');   % Type help optimset
options.TolFun = 1e-09;             % Increase required precision on LL
options.Display = 'off';            % Suppress fminsearch messages
lapseLimits = [0 1];                % Limit range for lambda
[paramsValues] = PAL_PFML_Fit(...
    comparisonStimuli',nYes',nSimulate*ones(size(nYes')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probYesFitPal = PF(paramsValues,comparisonStimuliFit');
psePal = PFI(paramsValues,0.5);
threshPal = PFI(paramsValues,0.75)-PFI(paramsValues,0.5);

% Plot of Y/N simulation.  When the red and green overlap (which they do in all my tests), it
% means that psignfit and Palamedes agree.
figure; clf; hold on
plot(comparisonStimuli,nYes/nSimulate,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot([testStimulus testStimulus],[0 1],'b');
plot(comparisonStimuliFit,probYesFitPsig,'r','LineWidth',2);
plot(comparisonStimuliFit,probYesFitPal,'g','LineWidth',1);
plot([psePsig psePsig],[0 1],'r','LineWidth',2);
plot([psePal psePal],[0 1],'g','LineWidth',1);
plot([psePsig psePsig+threshPsig],[0.75 0.75],'r','LineWidth',2);
plot([psePal psePal+threshPal],[0.75 0.75],'g','LineWidth',1);
xlabel('Comparison','FontSize',16);
ylabel('Prob "Yes"','FontSize',16);
title(sprintf('Y/N psychometric function'),'FontSize',16);
xlim([comparisonStimuli(1) comparisonStimuli(end)])
ylim([0 1]);
if (exist('FigureSave','file'))
    FigureSave('PsychoYN',gcf,'pdf');
else
    saveas('gcf','PsychoYN','pdf');
end

% Printout of interesting parameters.
fprintf('Y/N simulated data\n');
fprintf('Psignifit pse: %g, thresh: %g\n',psePsig,threshPsig);
fprintf('Palamedes pse: %g, thresh: %g\n',psePal,threshPal);
fprintf('\n');

%% Do a staircase for a Y/N experiment.  Uses our Staircase class.
% The code below runs three interleaved staircases.
%   For 'quest', three different criterion percent correct values are used.
%   For 'standard', three different up/down rules are used.
% The use of 3 is hard-coded, in the sense that the vector lengths of the
% criterion/up-down vectors must match this number.
%
% The variables maxDelta and minDelta below represent the range of trial values
% that the staircase will range between.
numTrialsPerStaircase = 50;
maxDelta = max(comparisonStimuli)-testStimulus;
minDelta = -maxDelta;

% Initialize staircases.  Initialization is slightly different for 'standard'
% and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
% are required, and this is enforced by the class constructor function.
nInterleavedStaircases = 3;
for k = 1:nInterleavedStaircases
    % Set starting value for the staircase at a random level between
    % min and max.
    initialDelta = (maxDelta-minDelta)*rand(1)+minDelta;
    
    switch(staircaseType)
        case 'standard'
            % The staircase starts at the largest step size and decreases with
            % each reversal.  When it gets to the minimum value in the list, it
            % stays there.
            stepSizes = [maxDelta/2 maxDelta/4 maxDelta/8];
            
            % Set the up/dow rule for each staircase.  N-Up, M-Down means (counterintuitively)
            % that it requires N positive responses to decrease the level and M negative responses
            % to decrease it.  The choices shown here tend to spread the values around the 50-50
            % response point.
            nUps = [1 1 2];
            nDowns = [2 1 1];
            st{k} = Staircase(staircaseType,initialDelta, ...
                'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                'MaxValue', maxDelta, 'MinValue', minDelta);

        case 'quest'
            criterionCorrs = [.4 .5 .6];
            st{k} = Staircase(staircaseType,initialDelta, ...
                'Beta', 2, 'Delta', 0.01, 'PriorSD',1000, ...
                'TargetThreshold', criterionCorrs(k), 'Gamma', 0, ...
                'MaxValue', maxDelta, 'MinValue', minDelta);
    end
end

% Simulate interleaved staircases
for i = 1:numTrialsPerStaircase
    order = Shuffle(1:nInterleavedStaircases);
    for k = 1:nInterleavedStaircases
        comparisonDelta = getCurrentValue(st{order(k)});
        response = SimulateProbYes(testStimulus,testStimulus+comparisonDelta,0,noiseSd,1,adaptingBias);
        st{order(k)} = updateForTrial(st{order(k)},comparisonDelta,response);
    end
end

% Analyze staircase data
valuesStair = []; responsesStair = [];
for k = 1:nInterleavedStaircases
    pseStair(k) = getThresholdEstimate(st{k});
    [valuesSingleStair{k},responsesSingleStair{k}] = getTrials(st{k});
    valuesStair = [valuesStair valuesSingleStair{k}];
    responsesStair = [responsesStair responsesSingleStair{k}];
end
[meanValues,nCorrectStair,nTrialsStair] = GetAggregatedStairTrials(valuesStair,responsesStair,10);

% Fit staircase data using Palamedes
paramsValues0(1) = 0;
paramsValues0(2) = 1/((max(valuesStair) - min(valuesStair))/4); 
[paramsValuesStair] = PAL_PFML_Fit(...
    valuesStair',responsesStair',ones(size(responsesStair')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probYesFitStair = PF(paramsValuesStair,comparisonStimuliFit'-testStimulus);
psePalStair = PFI(paramsValuesStair,0.5);
threshPalStair = PFI(paramsValuesStair,0.75)-PFI(paramsValuesStair,0.5);

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
    plot(xvalues,pseStair(k)*ones(1,numTrialsPerStaircase),colors(k));
end
xlabel('Trial Number','FontSize',16);
ylabel('Level','FontSize',16);
title(sprintf('Y/N staircase plot'),'FontSize',16);

subplot(1,2,2); hold on
plot(meanValues,nCorrectStair./nTrialsStair,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot(comparisonStimuliFit-testStimulus,probYesFitStair,'r','LineWidth',2);
plot([psePalStair psePalStair],[0 0.5],'r','LineWidth',2);
plot([psePalStair psePalStair+threshPalStair],[0.75 0.75],'g','LineWidth',2);
xlabel('Delta Stimulus','FontSize',16);
ylabel('Prob Yes','FontSize',16);
title(sprintf('Y/N staircase psychometric function'),'FontSize',16);
xlim([comparisonStimuli(1)-testStimulus comparisonStimuli(end)-testStimulus])
ylim([0 1]);
if (exist('FigureSave','file'))
    FigureSave('StaircaseYN',gcf','pdf');
else
    saveas(gcf,'StaircaseYN','pdf');
end

fprintf('Staircase simulated data\n');
for k = 1:nInterleavedStaircases
    fprintf('\tY/N staircase %d threshold estimate:  %g\n',k,pseStair(k));
end
fprintf('Palamedes''s threshold estimate from staircase data: %g\n',threshPalStair);
fprintf('\n');

%% Simulate TAFC psychometric function and fit.  Here the Weibull is a more natural functional
% form, and we show its use for both toolboxes.
%
% Unlike Y/N, the most natural x axis for TAFC is the increment of the comparison relative to
% the test, so that a 0 comparison corresponds to chance performance.
%
% As with Y/N simulation above, we don't allow for a lapse rate in this demo. 
comparisonStimuli = linspace(testStimulus,testStimulus+6*noiseSd,nComparison);
comparisonStimuliFit = linspace(testStimulus,testStimulus+6*noiseSd,nComparisonFit);
for i = 1:nComparison
    nCorrect(i) = SimulateTAFC(testStimulus,comparisonStimuli(i),noiseSd,noiseSd,nSimulate,adaptingBias); %#ok<AGROW>
end

% PSIGNIFIT
% Fit simulated data, psignifit.  These parameters do a one interval (y/n) fit.  Both lambda (lapse rate) and
% gamma (value for -Inf input) are locked at 0.
criterionCorr = 0.82;
fittype = 'w';
pfitdata = [comparisonStimuli'-testStimulus, nCorrect', nSimulate*ones(size(nCorrect'))];
pfitstruct = pfit(pfitdata,'no plot','matrix_format','xrn', ...
    'shape', fittype, 'n_intervals', 2, 'runs', 0, 'sens', 0, ...
    'compute_stats', 0, 'cuts', [0.5], 'verbose', 0, 'fix_lambda',0,'fix_gamma',0.5);
probCorrFitPsig = psigpsi(fittype, pfitstruct.params.est, comparisonStimuliFit'-testStimulus);
threshPsig = findthreshold(fittype,pfitstruct.params.est,criterionCorr,'performance');

% PALAMEDES
% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above. Again, some
% thought is required to initialize reasonably.  The threshold parameter is reasonably taken to be in the
% range of the comparison stimuli, where here 0 means that the comparison is the same as the test.  The 
% second parameter should be on the order of 1/2, so we just hard code that.  As with Y/N, really want to 
% plot the fit against the data to make sure it is reasonable in practice.
PF = @PAL_Weibull;                  % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PFI = @PAL_inverseWeibull;
paramsFree = [1 1 0 0];             % 1: free parameter, 0: fixed parameter
paramsValues0 = [mean(comparisonStimuli'-testStimulus) 1/2 0.5 0];
options = optimset('fminsearch');   % Type help optimset
options.TolFun = 1e-09;             % Increase required precision on LL
options.Display = 'off';            % Suppress fminsearch messages
lapseLimits = [0 1];                % Limit range for lambda
[paramsValues] = PAL_PFML_Fit(...
    comparisonStimuli'-testStimulus,nCorrect',nSimulate*ones(size(nYes')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probCorrFitPal = PF(paramsValues,comparisonStimuliFit'-testStimulus);
threshPal = PFI(paramsValues,criterionCorr);

% Plot of TAFC simulation.  When the red and green overlap (which they do in all my tests), it
% means that psignfit and Palamedes agree.
figure; clf; hold on
plot(comparisonStimuli'-testStimulus,nCorrect/nSimulate,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot(comparisonStimuliFit-testStimulus,probCorrFitPsig,'r','LineWidth',2);
plot(comparisonStimuliFit-testStimulus,probCorrFitPal,'g','LineWidth',1);
plot([threshPsig threshPsig],[0 criterionCorr],'r','LineWidth',2);
plot([threshPal threshPal],[0 criterionCorr],'g','LineWidth',1);
xlabel('Delta Stimulus','FontSize',16);
ylabel('Prob Correct','FontSize',16);
title(sprintf('TAFC psychometric function'),'FontSize',16);
xlim([comparisonStimuli(1)-testStimulus comparisonStimuli(end)-testStimulus])
ylim([0 1]);
if (exist('FigureSave','file'))
	FigureSave('PsychoFC',gcf,'pdf');
else
    saveas(gcf,'PsychFC','pdf');
end

% Printout
fprintf('TAFC simulated data\n');
fprintf('Psignifit thresh: %g\n',threshPsig);
fprintf('Palamedes thresh: %g\n',threshPal);
fprintf('\n');

%% Do a staircase for a TAFC experiment.  Uses our Staircase class.
% The code below runs three interleaved staircases.
%   For 'quest', three different criterion percent correct values are used.
%   For 'standard', three different up/down rules are used.
% The use of 3 is hard-coded, in the sense that the vector lengths of the
% criterion/up-down vectors must match this number.
numTrialsPerStaircase = 30;
maxDelta = max(comparisonStimuli)-testStimulus;
minDelta = 0.01;

% Initialize staircases.  Initialization is slightly different for 'standard'
% and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
% are required, and this is enforced by the class constructor function.
%
% The logic for TAFC staircases is similar to Y/N, but we want to set 
% ups/downs or criterionCorr to aim above 50%, whereas in Y/N we typically
% aim at 50%.
nInterleavedStaircases = 3;
for k = 1:nInterleavedStaircases
    % Set starting value for the staircase at a random level between
    % min and max.
    initialDelta = (maxDelta-minDelta)*rand(1)+minDelta;
    switch(staircaseType)
        case 'standard'
            stepSizes = [2*threshPal threshPal threshPal/4];
            nUps = [3 2 3];
            nDowns = [1 1 2];
            st{k} = Staircase(staircaseType,initialDelta, ...
                'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                'MaxValue', maxDelta, 'MinValue', minDelta);

        case 'quest'
            criterionCorrs = [criterionCorr-0.08 criterionCorr criterionCorr+0.08];
            st{k} = Staircase(staircaseType,initialDelta, ...
                'Beta', 2, 'Delta', 0.01, 'PriorSD',1000, ...
                'TargetThreshold', criterionCorrs(k),'Gamma', 0.5, ...
                'MaxValue', maxDelta, 'MinValue', minDelta);
    end
end

% Simulate interleaved staircases
for i = 1:numTrialsPerStaircase
    order = Shuffle(1:nInterleavedStaircases);
    for k = 1:nInterleavedStaircases
        comparisonDelta = getCurrentValue(st{order(k)});
        response = SimulateTAFC(testStimulus,testStimulus+comparisonDelta,noiseSd,noiseSd,1,adaptingBias);
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

% Fit staircase data using Palamedes
[paramsValuesStair] = PAL_PFML_Fit(...
    valuesStair',responsesStair',ones(size(responsesStair')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits);
probCorrFitStair = PF(paramsValuesStair,comparisonStimuliFit'-testStimulus);
threshPalStair = PFI(paramsValuesStair,criterionCorr);

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
plot([threshPalStair threshPalStair],[0 criterionCorr],'r','LineWidth',2);
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

function nYes = SimulateProbYes(responseTest,responseComparison,testSd,comparisonSd,nSimulate,adaptingBias)
% probYes = SimulateProbYes(responseTest,responseComparison,testSd,comparisonSd,nSimulate,adaptingBias)
%
% Simulate out the number of times that the comparison is judged as larger on the response variable
% than the test.  I'm sure there is an analytic solution, but it's a little tricky because we
% allow different standard deviations for the test and comparison noise.
%
% Assume experiment is based on comparison of noisy draws from underlying comparison and test 
% distributions.  You can also think of responseTest as a criterion.  Passing testSd = 0 makes
% the criterion noise free, and other testSd may be thought of as criterial noise.
%
% The parameter adaptingBias is expressed in the same units as the internal response, and is subtracted
% from the comparison response before the decision.  It simulates an adaptive effect.  Typically passed
% as zero.  It could also be regarded as a criterion that is shifted from the standard, if you are
% thinking in TSD terms.
%
% 4/25/09  dhb  Wrote it.

diffNoise = normrnd(0,comparisonSd,nSimulate,1)-normrnd(0,testSd,nSimulate,1);
nYes = length(find(responseComparison-adaptingBias-responseTest+diffNoise > 0));
end

function nCorrect = SimulateTAFC(responseTest,responseComparison,testSd,comparisonSd,nSimulate,adaptingBias)
% probYes = SimulateProbYes(responseTest,responseComparison,testSd, comparisonSd,nSimulate,adaptingBias)
%
% Simulate out the number of times that a TAFC task is done correctly, with judgment greater
% corresponding to greater noisy response. 
%
% The parameter adaptingBias is expressed in the same units as the internal response, and is subtracted
% from the comparison response before the decision.  It simulates an adaptive effect.  Typically passed
% as zero.  This can be a bit weird because the decision rule is coded on the assumption that the 
% comparison is always bigger than the test.
%
% 4/25/09  dhb  Wrote it.

nCorrect = 0;
for i = 1:nSimulate
    responseTestNoise = responseTest+normrnd(0,testSd,1,1);
    responseComparisonNoise = responseComparison+normrnd(0,comparisonSd,1,1)-adaptingBias;
        
    if (responseComparison > responseTest & responseComparisonNoise > responseTestNoise)
        nCorrect = nCorrect+1;
    elseif (responseComparison <= responseTest & responseComparisonNoise <= responseTestNoise)
        nCorrect = nCorrect+1;
    end
end
end
