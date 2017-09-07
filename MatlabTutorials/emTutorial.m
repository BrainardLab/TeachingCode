% emTutorial
%
% Show EM at work on fitting the mixture of two Gaussians.
%
% This tutorial requires the statistics toolbox, although
% you could make do without it by re-writing a few things.
% (It uses mnrnd to generate the mixture draws, and normrnd
% for the Gaussian pdf.)
%
% 7/15/08   dhb  Wrote it.

%% Clear
clear; close all;

%% Define some parameters.  At present these are set up for the mixture of
% just two Gaussians.  Some of the code below is pretty general, but the
% plots count on there just being two.  You can muck with the parameters
% of these Gaussians and see the impact on what the algorithm does.
trueGaussParams(1).mean = 0;
trueGaussParams(2).mean = 6;
trueGaussParams(1).stdev = 1;
trueGaussParams(2).stdev = 6;
trueMixingProbs = [0.3 0.7];
nGaussians = length(trueMixingProbs);
nSimulateData = 1000;

%% Generate a bunch of data according to the true specified distribution
dataIdentities = zeros(nSimulateData,1);
simulatedData = zeros(nSimulateData,1);
for i = 1:nSimulateData
    % Choose which mixture to draw from, and keep true labels
    temp = mnrnd(1,trueMixingProbs);
    dataIdentities(i) = find(temp == 1);
    
    % Now draw from appropriate Gaussian
    simulatedData(i) = trueGaussParams(dataIdentities(i)).stdev*randn(1)+trueGaussParams(dataIdentities(i)).mean;
end

%% Now try to estimate the mixture distribution using EM.
% Start by initializing a guess as to the underlying Gaussians.  You can
% play with these to see how sensitive it is to the initial guess.
fitGaussParams(1,1).mean = 5;
fitGaussParams(1,2).mean = 6;
fitGaussParams(1,1).stdev = 10;
fitGaussParams(1,2).stdev = 10;
fitMixingProbs(1,:) = [0.5 0.5];

% Do the EM iteration. It's just over 30 lines of code; most of the lines below
% are to display an informatitive diagnostc plot.
maxSteps = 50;
for step = 1:maxSteps
    % Expectation step.  Start by computing probability that each observation is from each of the component distributions,
    % given current distribution parameters
    expectationResults = NaN*ones(maxSteps,nSimulateData,nGaussians);
    for j = 1:nGaussians
        probXGivenJ = normpdf(simulatedData,fitGaussParams(step,j).mean,fitGaussParams(step,j).stdev);
        expectationResults(step,:,j) = probXGivenJ*fitMixingProbs(step,j);
    end
    for i = 1:nSimulateData
        expectationResults(step,i,:) = expectationResults(step,i,:)/sum(expectationResults(step,i,:));
    end
   
    % Maximization step. Maximize expected likelihood of data with respect to Gaussian parameters,
    % given current expectation results.  This relies on analytic results
    % for the Gaussian case.  I found the Wikepedia entry on EM clearer than Bishop on this.
    for j = 1:nGaussians
        % Compute some quantities we'll need to use several times below
        pzConditionalOnData = squeeze(expectationResults(step,:,j))';
        sumPzConditionalOnData = sum(pzConditionalOnData);
        
        % Mean for each class
        fitGaussParams(step+1,j).mean = sum(pzConditionalOnData.*simulatedData)/sumPzConditionalOnData;
        
        % Variance for each class.  [Should we use new or old mean here?  I'm using new.]
        weightedDataLessMean = sqrt(pzConditionalOnData).*(simulatedData-fitGaussParams(step+1,j).mean);
        theVar = (weightedDataLessMean'*weightedDataLessMean)/sumPzConditionalOnData;
        fitGaussParams(step+1,j).stdev = sqrt(theVar);

        % Mixing probability for each class
        fitMixingProbs(step+1,j) = (1/nSimulateData)*sumPzConditionalOnData;
    end
    
    % This is actually the end of the algorithm loop.  Everything else
    % below is either comment or code to put up a diagnostic plot each time
    % through the loop.
    
    % In a real implementation, we'd have some stopping
    % criterion when the estimates stopped changing much.  But here we just
    % fix the maximum number of iterations and go until we hit that limit.

    % If you wanted to run an interesting exercise, you could use brute
    % force parameter search to find the parameters for each Gaussian that
    % maximize the expected likelihood.  It's just a two parameter search
    % for each Gaussian, once the expectation step is done, since the
    % estimates for each class are independent.  The parameter search will
    % be slower than for the analytic results, but parameter search can
    % work for the mixture of anything, not just the Gaussian case where we
    % have an analytic maximization method.
     
    % Diagnostic plot.  This updates on each iteration.  The pause command
    % at the end slows it all down so you can watch the development.
    figure(1);
    
    % This panel shows a histogram of the data, the true underlying
    % distribution(red), and an updating estimate of that distribution (green).
    subplot(2,3,1); cla; hold on
    [n,x] = hist(simulatedData,100);
    bar(x,n); 
    theory = 0;
    fit = 0;
    for j = 1:nGaussians
        theory = theory+(x(2)-x(1))*(trueMixingProbs(j)*normpdf(x,trueGaussParams(j).mean,trueGaussParams(j).stdev));
        fit = fit+(x(2)-x(1))*(fitMixingProbs(step+1,j)*normpdf(x,fitGaussParams(step+1,j).mean,fitGaussParams(step+1,j).stdev));
    end
    plot(x,sum(n)*theory,'r','LineWidth',2);
    plot(x,sum(n)*fit,'g','LineWidth',2);
    xlim([min(x) max(x)]);
    xlabel('Data Value')
    ylabel('Mixture Distribution Proportion');
    
    % This panel shows the updating estimates of which data values are
    % assigned to each class (probabilities).
    subplot(2,3,2); cla; hold on
    plot(simulatedData,expectationResults(step,:,1),'ro');
    plot(simulatedData,expectationResults(step,:,2),'go');
    xlim([min(x) max(x)]);
    xlabel('Data Value')
    ylabel('Mixing Probs');
    
    % This shows updating estimates of the mixing parameters,and their true
    % values.  Red for class one and green for class two.
    subplot(2,3,4); hold on
    plot(1:step+1,fitMixingProbs(:,1),'ro');
    plot(1:step+1,fitMixingProbs(:,2),'go');
    plot(1:step+1,trueMixingProbs(1)*ones(1,step+1),'r');
    plot(1:step+1,trueMixingProbs(2)*ones(1,step+1),'g');
    xlim([1 step+1]);
    xlabel('Step');
    ylabel('Fit Mixing Probs');
    ylim([0 1]);
    
    % Updating estimate of the mean of each Gaussian, and the true
    % values.
    subplot(2,3,5); hold on
    plot(step+1,fitGaussParams(step+1,1).mean,'ro');
    plot(step+1,fitGaussParams(step+1,2).mean,'go');
    plot(1:step+1,trueGaussParams(1).mean*ones(1,step+1),'r');
    plot(1:step+1,trueGaussParams(2).mean*ones(1,step+1),'g');
    xlim([1 step+1]);
    xlabel('Step');
    ylabel('Mean Estimates');
    
    % And finally the updating stdev estimates
    subplot(2,3,6); hold on
    plot(step+1,fitGaussParams(step+1,1).stdev,'ro');
    plot(step+1,fitGaussParams(step+1,2).stdev,'go');
    plot(1:step+1,trueGaussParams(1).stdev*ones(1,step+1),'r');
    plot(1:step+1,trueGaussParams(2).stdev*ones(1,step+1),'g');
    xlim([1 step+1]);
    xlabel('Step');
    ylabel('Stdev Estimates');
    drawnow;
    
    % This pause is so that you can see the plot evolve.
    pause(0.05);
end
  