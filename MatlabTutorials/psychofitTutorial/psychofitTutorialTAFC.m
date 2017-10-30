function psychofitTutorialTAFC
% psychofitTutorialTAFC
%
% Show basic use of Palamedes toolboxes to simulate and
% fit psychophysical data, TAFC, for method of constant stimuli.
%
% You need the Palamedes toolboxe (1.8.2) for this to work.

% 04/30/09 dhb  Broke out from 2014 version and updated.

%% Clear
clear; close all;

%% Specify precision as noise of a Gaussian variable
%
% Simulation parameters
noiseSd = 0.06;
testStimulus = 100;
nComparisonFit = 100;
nComparison = 10;
nSimulate = 40;
nComparisonSds = 4;

%% Simulate TAFC psychometric function and fit.  Here the Weibull is a more natural functional
% form, and we show its use for both toolboxes.
%
% The most natural x axis for TAFC is the increment of the comparison relative to
% the test, so that a 0 comparison corresponds to chance performance.
comparisonStimuli = linspace(testStimulus,testStimulus+nComparisonSds*noiseSd,nComparison);
comparisonStimuliFit = linspace(testStimulus,testStimulus+nComparisonSds*noiseSd,nComparisonFit);
for i = 1:nComparison
    nCorrect(i) = SimulateTAFC(testStimulus,comparisonStimuli(i),noiseSd,noiseSd,nSimulate); %#ok<AGROW>
end

% Palamedes fit
%
% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above. Again, some
% thought is required to initialize reasonably.  The threshold parameter is reasonably taken to be in the
% range of the comparison stimuli, where here 0 means that the comparison is the same as the test.  The 
% second parameter should be on the order of 1/2, so we just hard code that.  As with Y/N, really want to 
% plot the fit against the data to make sure it is reasonable in practice.

% Initialize
thresholdCriterionCorrect = 0.75;
paramsFree     = [1 1 0 1];
PF = @PAL_Weibull;                  % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PFI = @PAL_inverseWeibull;

% The first two parameters define the shape of teh Weibull function.
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
    comparisonStimuli'-testStimulus,nCorrect',nSimulate*ones(size(nCorrect')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options,'lapseLimits',lapseLimits);

%% Make a smooth curve with the parameters
probCorrFitPal = PF(paramsValues,comparisonStimuliFit'-testStimulus);

%% Invert psychometric function to find threshold
threshPal = PF(paramsValues,thresholdCriterionCorrect,'inverse');

%% Plot of TAFC simulation
%
% The plot shows the simulated data, the fit, and the threshold from the
% fit.
figure; clf; hold on
plot(comparisonStimuli'-testStimulus,nCorrect/nSimulate,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot(comparisonStimuliFit-testStimulus,probCorrFitPal,'g','LineWidth',1);
plot([threshPal threshPal],[0 thresholdCriterionCorrect],'g','LineWidth',1);
xlabel('Delta Stimulus','FontSize',16);
ylabel('Prob Correct','FontSize',16);
title(sprintf('TAFC psychometric function'),'FontSize',16);
xlim([comparisonStimuli(1)-testStimulus comparisonStimuli(end)-testStimulus])
ylim([0 1.01]);
if (exist('FigureSave','file'))
	FigureSave('PsychoTAFC',gcf,'pdf');
else
    saveas(gcf,'PsychTAFC','pdf');
end

% Printout
fprintf('TAFC simulated data\n');
fprintf('Palamedes thresh: %g\n',threshPal);
fprintf('Parameters: %0.2g %0.2g %0.2g %0.2g\n',paramsValues(1),paramsValues(2),paramsValues(3),paramsValues(4));
fprintf('\n');

end

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


