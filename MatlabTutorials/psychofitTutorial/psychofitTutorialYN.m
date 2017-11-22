function psychofitTutorialYN
% psychofitTutorialYN
%
% Show basic use Palamedes toolboxe to simulate and
% fit psychophysical data.  This one for Y/N method of constant stimuli.
%
% You need both the psignifit and Palamedes toolboxes on your path, as well
% as the Brainard lab staircase class and the Psychtoolbox.
%
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
% 11/22/17 dhb  Strip down to Y/N Palemedes and ver 1.8.2 of Palemedes.

%% Clear
clear; close all;

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

% PALAMEDES

% Psychometric function form
PF = @PAL_CumulativeNormal;         % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant

% The first two parameters of the psychometric function define its position and shape.
%
% The third is the guess rate, which determines the value the function
% takes on at low values of x.  For a perfect subject this would be 0,
% but there might be lapses (see below) for small x as well as high x.
%
% The fourth parameter is the lapse rate - the asymptotic performance at 
% high values of x.  For a perfect subject, this would be 0, but sometimes
% subjects have a "lapse" and get the answer wrong even when the stimulus
% is easy to see.  We can search over this, but shouldn't allow it to take
% on unreasonable values.  0.05 as an upper limit isn't crazy.
%
% paramsFree is a boolean vector that determins what parameters get
% searched over. 1: free parameter, 0: fixed parameter
paramsFree = [1 1 1 1];  

% Initial guess.  Setting the first parameter to the middle of the stimulus
% range and the second to 1 puts things into a reasonable ballpark here.
paramsValues0 = [mean(comparisonStimuli') 1/((max(comparisonStimuli')-min(comparisonStimuli'))/4) 0 0];

% This puts limits on the range of the lapse rate.  And we pass an option
% to the fit function that forces the guess and lapse rates to be equal,
% which is reasonable for this case.
lapseLimits = [0 0.05];

% Set up standard options for Palamedes search
options = PAL_minimize('options');

% Fit with Palemedes Toolbox.  The parameter constraints match the psignifit parameters above.  Some thinking is
% required to initialize the parameters sensibly.  We know that the mean of the cumulative normal should be 
% roughly within the range of the comparison stimuli, so we initialize this to the mean.  The standard deviation
% should be some moderate fraction of the range of the stimuli, so again this is used as the initializer.
[paramsValues] = PAL_PFML_Fit(...
    comparisonStimuli',nYes',nSimulate*ones(size(nYes')), ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'lapseLimits',lapseLimits,'gammaEQlambda',true);
probYesFitPal = PF(paramsValues,comparisonStimuliFit');
psePal = PF(paramsValues,0.5,'inverse');
threshPal = PF(paramsValues,0.75,'inverse')-psePal;

% Plot of Y/N simulation.  When the red and green overlap (which they do in all my tests), it
% means that psignfit and Palamedes agree.
figure; clf; hold on
plot(comparisonStimuli,nYes/nSimulate,'ko','MarkerSize',6,'MarkerFaceColor','k');
plot([testStimulus testStimulus],[0 1],'b');
plot(comparisonStimuliFit,probYesFitPal,'g','LineWidth',1);
plot([psePal psePal],[0 1],'g','LineWidth',1);
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
fprintf('Palamedes pse: %g, thresh: %g\n',psePal,threshPal);
fprintf('\n');

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

