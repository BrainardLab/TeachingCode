function exploreMemBiasTutorial
% exploreMemBiasTutorial
%
% Work out predictions of a very simple memory model.  The idea is to see
% what the predictions are if we start with the ideas that
%   a) there is a non-linear transduction between the stimulus variable and perceptual response.
%   b) noise is added in the perceptual domain
%   c) noise can have different variance depending on delay.
%
% This is worked out for the circular stimulus variable hue, but nothing
% much would change in the model for an intensive variable.
%
% 4/25/09  dhb  Started on it.

%% Clear
clear; close all;

%% Parameters
% Specify precision as noise of a Gaussian variable.  There is a separate
% noise for the test stimulus and the comparison stimulus.  This is
% because we want to model both simultaneous presentation and delayed, and we'll
% do this by mucking with the variances.
testSd = 0.06;
comparisonSd = 0.06;
scaleBase = 2*max([testSd comparisonSd]);
testHueRawIndex = 300;
nComparison = 100;
nMatchSimulate = 10000;
nPsychoSimulate = 1000;
nFitSimulate = nPsychoSimulate;
nStimulusHues = 600;
respType = 'naka';
responseOrder = 2;
responseCoeefs = 0.1*[0 1 1 0.4 0.25 0.5 0.2];
fittype = 'c';

%% Generate the non-linear response function.  This is veridical plus a sum of some
% sinusoids.
stimulusHues = linspace(0,1,nStimulusHues);
stimulusHues = [stimulusHues];
switch (respType)
    case 'fourier'
        responseFun = stimulusHues + ComputeFourierModel(responseCoeefs,stimulusHues);
    case 'naka'
        responseFun = (stimulusHues.^6)./(stimulusHues.^6 + 0.4.^6);
end


sumPlot = figure('WindowStyle','docked'); clf;
subplot(4,1,1); hold on
plot(stimulusHues,responseFun,'r','LineWidth',2);
xlim([0 1]); ylim([0 1]);
xlabel('Hue','FontSize',16);
ylabel('Response','FontSize',16);
title('Underlying Psychophysical Function','FontSize',16);

%% Compute psychometric function through a specified test hue.  Response will be 1 (aka "yes")
% if subjects thinks comparison presentation is of higher perceptual hue, 0 (aka "no") otherwise.
testHueIndex = testHueRawIndex;
testHue = stimulusHues(testHueIndex);
meanResponseTest = responseFun(testHueIndex);
comparisonIndices = testHueIndex-nComparison:testHueIndex+nComparison;
comparisonHues = stimulusHues(comparisonIndices);
for i = 1:length(comparisonIndices)
    meanResponseComparison = responseFun(comparisonIndices(i));
    probYes(i) = SimulateProbYes(meanResponseTest,meanResponseComparison,testSd,comparisonSd,nPsychoSimulate); %#ok<AGROW>
end

% Fit simulated data
pfitdata = [comparisonHues', probYes', nFitSimulate*ones(size(probYes'))];
pfitstruct = pfit(pfitdata,'no plot','matrix_format','xyn', ...
    'shape', fittype, 'n_intervals', 1, 'runs',0, 'sens',0, ...
    'compute_stats', 0, 'cuts', [0.5], 'verbose', 0);
probYesFit = psigpsi(fittype, pfitstruct.params.est, comparisonHues');
pse = findthreshold(fittype,pfitstruct.params.est,0.5,'performance');
thresh = findthreshold(fittype,pfitstruct.params.est,0.75,'performance') - ...
    findthreshold(fittype,pfitstruct.params.est,0.25,'performance');

% Little plot
figure('WindowStyle','docked'); clf; hold on
plot(comparisonHues,probYes,'ko','MarkerSize',2,'MarkerFaceColor','k');
plot([testHue testHue],[0 0.5],'b');
plot([comparisonHues(1) testHue],[0.5 0.5],'b');
plot(comparisonHues,probYesFit,'r','LineWidth',2);
plot([pse pse],[0 0.5],'g');
xlabel('Comparison Hue','FontSize',16);
ylabel('Prob "Yes"','FontSize',16);
title(sprintf('Psychometric function, test hue %g',testHue),'FontSize',16);
xlim([comparisonHues(1) comparisonHues(end)])
ylim([0 1]);

%% Find average match for each test hue
nPrint = 25;
theMatchedStimuli = zeros(nMatchSimulate,nStimulusHues-2*nComparison-1);
matchProgPlot = figure('WindowStyle','docked');
for t = 1:nStimulusHues-2*nComparison-1
    testHueIndex = nComparison+t;
    testHuesMatch(t) = stimulusHues(testHueIndex);
    meanResponseTest = responseFun(testHueIndex);
    noiseDrawsTest = normrnd(0,testSd,nMatchSimulate,1);
    for i = 1:nMatchSimulate
        theResponse = meanResponseTest + noiseDrawsTest(i);
        noiseDrawsComparison = normrnd(0,comparisonSd,size(responseFun));
        comparisonResponses = responseFun + noiseDrawsComparison;
        [nil,index] = min(abs(comparisonResponses-theResponse));
        theMatchedStimuli(i,t) = stimulusHues(index(1));
    end
    meanMatch(t) = mean(theMatchedStimuli(:,t));
    medianMatch(t) = median(theMatchedStimuli(:,t));
    
    % Diagnostic plot if desired
    if (rem(t,nPrint) == 0)
        figure(matchProgPlot); clf; hold on
        [n,x] = hist(theMatchedStimuli(:,t),25);
        bar(x,n);
        plot([testHuesMatch(t) testHuesMatch(t)],[0 1.2*max(n)],'k','LineWidth',2);
        plot([meanMatch(t) meanMatch(t)],[0 1.2*max(n)],'r','LineWidth',2);
        %plot([medianMatch(t) medianMatch(t)],[0 1.2*max(n)],'g','LineWidth',2);
        xlabel('Matches','FontSize',16);
        ylabel('Count','FontSize',16);
        xlim([0 1]);
        ylim([0 1.2*max(n)]);
        title(sprintf('Match distribution, test hue %0.2g',testHuesMatch(t)),'FontSize',16);
        drawnow;
        saveas(matchProgPlot,sprintf('Matches_%g_%g_%0.2g.png',testSd,comparisonSd,testHuesMatch(t)),'png');
        fprintf('Computing mean match for test hue %d of %d\n',t,nStimulusHues-2*nComparison-1);
    end   
end

% Plot of simulated matches
figure(sumPlot);
subplot(4,1,3); hold on
plot(testHuesMatch,meanMatch-testHuesMatch,'r','LineWidth',2);
%plot(testHuesMatch,medianMatch-testHuesMatch,'b','LineWidth',2);
xlim([0 1]);
ylim([-scaleBase scaleBase]);
xlabel('Test Hue','FontSize',16);
ylabel('Match Bias','FontSize',16);

%% Now compute out PSE as a function of test hue, as well as threshold
nPrint = 25;
progPlot = figure('WindowStyle','docked');
for t = 1:nStimulusHues-2*nComparison-1
    testHueIndex = nComparison+t;
    testHues(t) = stimulusHues(testHueIndex);
    meanResponseTest = responseFun(testHueIndex);
    comparisonIndices = testHueIndex-nComparison:testHueIndex+nComparison;
    comparisonHues = stimulusHues(comparisonIndices);
    for i = 1:length(comparisonIndices)
        meanResponseComparison = responseFun(comparisonIndices(i));
        probYes(i) = SimulateProbYes(meanResponseTest,meanResponseComparison,testSd,comparisonSd,nPsychoSimulate); %#ok<AGROW>
    end
    
    % Fit
    pfitdata = [comparisonHues', probYes', nFitSimulate*ones(size(probYes'))];
    pfitstruct = pfit(pfitdata,'no plot','matrix_format','xyn', ...
    	'shape', fittype, 'n_intervals', 1, 'runs',0, 'sens',0, ...
    	'compute_stats', 0, 'cuts', [0.5], 'verbose', 0);
    probYesFit = psigpsi(fittype, pfitstruct.params.est, comparisonHues');
    pses(t) = findthreshold(fittype,pfitstruct.params.est,0.5,'performance');
    threshs(t) = findthreshold(fittype,pfitstruct.params.est,0.75,'performance') - ...
        findthreshold(fittype,pfitstruct.params.est,0.25,'performance');
    
    % Fit central part
    centralIndex = nComparison-10:nComparison+10;
    pfitdata = [comparisonHues(centralIndex)', probYes(centralIndex)', nFitSimulate*ones(size(centralIndex'))];
    pfitstruct1 = pfit(pfitdata,'no plot','matrix_format','xyn', ...
    	'shape', fittype, 'n_intervals', 1, 'runs',0, 'sens',0, ...
    	'compute_stats', 0, 'cuts', [0.5], 'verbose', 0);
    probYesFit1 = psigpsi(fittype, pfitstruct1.params.est, comparisonHues(centralIndex)');
    pses1(t) = findthreshold(fittype,pfitstruct1.params.est,0.5,'performance');

    % Diagnostic plot if desired
    if (rem(t,nPrint) == 0)
        figure(progPlot); clf; hold on
        plot(comparisonHues,probYes,'ko','MarkerSize',2,'MarkerFaceColor','k');
        plot(comparisonHues,probYesFit,'r','LineWidth',2);
        plot(comparisonHues(centralIndex),probYesFit1,'b','LineWidth',2);
        plot([testHues(t) testHues(t)],[0 1],'b');
        plot([pses(t) pses(t)],[0 1],'g');
        xlabel('Comparison Hue','FontSize',16);
        ylabel('Prob "Yes"','FontSize',16);
        title(sprintf('Psychometric function, test hue %0.2g',testHues(t)),'FontSize',16);
        xlim([comparisonHues(1) comparisonHues(end)])
        xlim([0 1]);
        ylim([0 1]);
        drawnow;
        saveas(progPlot,sprintf('Psycho_%g_%g_%0.2g.png',testSd,comparisonSd,testHues(t)),'png');
        fprintf('Computing PSE for test hue %d of %d\n',t,nStimulusHues-2*nComparison-1);
    end   
end

% Plot of simulated PSEs
figure(sumPlot);
subplot(4,1,2); hold on
plot(testHues,1./threshs,'r','LineWidth',2);
xlim([0 1]);
%ylim([0 scaleBase]);
xlabel('Test Hue','FontSize',16);
ylabel('Inverse Threshold','FontSize',16);
subplot(4,1,4); hold on
plot(testHues,pses-testHues,'r','LineWidth',2);
plot(testHues,pses1-testHues,'b','LineWidth',2);
xlim([0 1]);
ylim([-scaleBase scaleBase]);
xlabel('Test Hue','FontSize',16);
ylabel('PSE Bias','FontSize',16);
saveas(sumPlot,sprintf('Summary_%g_%g.png',testSd,comparisonSd),'png');

end

%% Subfunctions

function probYes = SimulateProbYes(responseTest,responseComparison,testSd,comparisonSd,nSimulate)
% probYes = SimulateProbYes(responseTest,responseComparison,testSd,comparisonSd,nSimulate)
%
% Simulate out the number of times that the comparison is judged as larger on the response variable
% than the test.  I'm sure there is an analytic solution, but it's a little tricky because we
% allow different standard deviations for the test and comparison noise.
%
% 4/25/09  dhb  Wrote it.

diffNoise = normrnd(0,comparisonSd,nSimulate,1)-normrnd(0,testSd,nSimulate,1);
nYes = length(find(responseComparison-responseTest+diffNoise > 0));
probYes = nYes/nSimulate;
end

function ypred = ComputeFourierModel(coeffs,x)
% ypred = ComputeFourierModel(coeffs,x)
%
% ypred = coeffs(1) + coeffs(2)*(sin(2*pi*x) + coeffs(3)*cos(2*pi*x) + coeffs(4)*sin(2*pi*2*x) + coeffs(5)*cos(2*pi*2*x) + ...
%
% The order of the equation is determined from the length of coeffs.
% The input x is assumed to be in the range [0-1].
%
% 4/21/09  dhb  Wrote it.

% Modulation
a = coeffs(1);
b = coeffs(2);

modulation = sin(2*pi*x) + coeffs(3)*cos(2*pi*x);
for i = 1:length(coeffs(4:end))/2
    modulation = modulation + coeffs(2*(i-1)+4)*sin(2*pi*(i+1)*x) + coeffs(2*(i-1)+5)*cos(2*pi*(i+1)*x);
end
ypred = a + b*modulation;

end



