% semBootstrapTutorial
%
% Demonstrate the relationship between the standard 
% deviation and standard error.  Then show that
% we can also use bootstrapping to estimate the
% precision to which the mean is measured and that
% for this simple case it agrees with what you get
% from using the SEM.
%
% 6/10/09  tyl  Wrote it.
% 6/12/09  dhb  Review and clean.
% 9/19/11  dhb  Save plots.  Remove Ranint and replace with unidrnd.

%% Clean out
clear; close all;
format short
format compact

%% Draw 'population' distribution.  In this case, it's a
% normal distribution with specified mean and sd.  Make
% a nice plot of the population.
theoreticalMean = 0;
theoreticalSd = 3;
nPopulationDraws = 10000;
populationX = normrnd(theoreticalMean,theoreticalSd,nPopulationDraws,1);
populationMean = mean(populationX);       
populationSd = std(populationX);

% Plot population distribution, along with theoretical curve (in blue) from the
% normal pdf that generated it.  Red bar is mean of population
% distribution, which should be near the specified theoretical mean.
histFig = figure; clf; 
subplot(3,1,1); hold on
nBins = 30;
[n,bins] = hist(populationX,nBins);
bar(bins,n);
minX = min(bins)-(bins(2)-bins(1)); maxX = max(bins)+(bins(2)-bins(1));
fineBins = linspace(minX,maxX,100);
plot([populationMean populationMean],[0 max(n)],'r','LineWidth',3);
theoreticalPdf = nPopulationDraws*(bins(2)-bins(1))*normpdf(fineBins,theoreticalMean,theoreticalSd);
plot(fineBins,theoreticalPdf,'b','LineWidth',4);
xlabel('X'); ylabel('N'); title(sprintf('Population Distribution (N = %d)',nPopulationDraws));
xlim([minX,maxX]);

%% Suppose we ran an experiment and got some subset of data from
%this underlying distribution, with its own mean and standard deviation.
nExperimentDraws = 40;
index = unidrnd(nPopulationDraws,nExperimentDraws,1);
experimentX = populationX(index);
experimentMean = mean(experimentX);
experimentSd = std(experimentX);

% Plot the experimental draws.  The blue curve is the underlying
% theoretical distribution from which the population was drawn.
% The red bar is the experimental mean.
figure(histFig);
subplot(3,1,2); hold on
nBins = 10;
[n,bins] = hist(experimentX,nBins);
bar(bins,n);
plot([experimentMean experimentMean],[0 max(n)],'r','LineWidth',3);
theoreticalPdf = nExperimentDraws*(bins(2)-bins(1))*normpdf(fineBins,theoreticalMean,theoreticalSd);
plot(fineBins,theoreticalPdf,'b','LineWidth',4);
xlabel('X'); ylabel('N'); title(sprintf('Experiment Distribution (N = %d)',nExperimentDraws));
xlim([minX,maxX]);

%% Simulation of multiple experiments.
% How confident are we that the mean from our sampled distribution, xbarhat,
% reflects the true mean of the underlying process?
%
% Suppose we repeat the above experiment many times, each time getting a new subset
% of data from the original underlying distribution, with a new xbarhat and
% new sdhat.
nSimulatedExps = 100;
for w = 1:nSimulatedExps
	index = unidrnd(nPopulationDraws,nExperimentDraws,1);
    simulatedX{w} = populationX(index);
    simulatedMeans(w) = mean(simulatedX{w});
    simulatedSds(w) = std(simulatedX{w});
end
meanOfSimulatedMeans = mean(simulatedMeans);
stdOfSimulatedMeans = std(simulatedMeans);

% This plot shows the means obtained from repeats of the simulated
% experiment.  There is some scatter to these means that arises
% because the exact draws vary for each simulated experiment.
% The red bar in the plot shows the mean from the original version
% of the experiment. 
%
% Often one wants to know how precisely a mean has been measured.
% The distribution shown in the plot gives a sense for this.  Note
% that the simulated distribution of means is well fit by the
% blue curve.  This curve was generated from the orignal theoretical
% distribution simply be reducing the standard deviation by the
% square root of the number of experimental draws.
figure(histFig);
subplot(3,1,3); hold on
nBins = 10;
[n,bins] = hist(simulatedMeans,nBins);
bar(bins,n);
plot([experimentMean experimentMean],[0 max(n)],'r','LineWidth',3);
theoreticalPdf = nSimulatedExps*(bins(2)-bins(1))*normpdf(fineBins,theoreticalMean,theoreticalSd/sqrt(nExperimentDraws));
plot(fineBins,theoreticalPdf,'b','LineWidth',4);
xlabel('X'); ylabel('N'); title(sprintf('Distribution of Means of N = %d',nExperimentDraws));
xlim([minX,maxX]);
if (exist('FigureSave','file'))
    FigureSave('ExperimentDrawHistos',histFig,'pdf');
end

%% SEM
% The standard error of the mean (SEM) is an estimate of the precision
% which a mean has been measured.  It is obtained by dividing the
% standard deviation of the measurements from which the mean was
% computed by the square root of the number of measurements.
%
% For each simulated experiment, compute the SEM.
simulatedSEMs = simulatedSds/sqrt(nExperimentDraws);

% The plot shows the distribution of SEMs we get from
% multiple simulations of the experiment.  The red
% bar is the theoretical value of the precision. The
% green bar shows the mean of the simulated SEMs.
semFig = figure; clf;
subplot(2,1,1); hold on
nBins = 10;
[n,semBins] = hist(simulatedSEMs,nBins);
bar(semBins,n);
minX = min(semBins)-(semBins(2)-semBins(1)); maxX = max(semBins)+(semBins(2)-semBins(1));
plot([theoreticalSd/sqrt(nExperimentDraws) theoreticalSd/sqrt(nExperimentDraws)],[0 max(n)],'r','LineWidth',3);
plot([mean(simulatedSEMs) mean(simulatedSEMs)],[0 max(n)],'g','LineWidth',3);

xlabel('Theoretical SEM'); ylabel('N'); title('Distribution of SEMs');
xlim([minX,maxX]);

%% Bootstrapping procedure
% Estimate precision of mean by bootstrapping.  Here, for each simulated
% experiment, we resample from the data for that experiment, compute the
% mean for each resampling, and then take the standard deviation (not SEM)
% of the means to get an estimate of the standard error of the mean.
nBootstraps = 200;
for w = 1:nSimulatedExps
    for b = 1:nBootstraps
        index = unidrnd(nExperimentDraws,nExperimentDraws,1);
        bootstrapX = simulatedX{w}(index);
        bootstrapMeans(w,b) = mean(bootstrapX);
    end
    bootstrapEstimatesOfPrecision(w) = std(bootstrapMeans(w,:));  
end

% Plot the boostrapped estimates of the precision to which the
% means were measured.  Note similarity to what you get by
% computing the standard error of the mean.
%
% The bootstrap procedure has two advantages over just computing
% the standard error of the mean.  The first is that you can
% bootstrap any quantity you estimate from data, whereas the
% analytic formula for the SEM only applies to means.
%
% Second, if you want, you can look at the entire distribution of the
% boostrapped estimates, not just their standard deviation.  This
% can be of interest when the distribution of estimates is not
% approximately normal.  [This is not done here.]
subplot(2,1,2); hold on
[n] = hist(bootstrapEstimatesOfPrecision,semBins);
bar(semBins,n);
plot([theoreticalSd/sqrt(nExperimentDraws) theoreticalSd/sqrt(nExperimentDraws)],[0 max(n)],'r','LineWidth',3);
plot([mean(bootstrapEstimatesOfPrecision) mean(bootstrapEstimatesOfPrecision)],[0 max(n)],'g','LineWidth',3);
xlabel('Boostrapped Precision of Mean'); ylabel('N'); title('Bootstrap');
xlim([minX,maxX]);
if (exist('FigureSave','file'))
    FigureSave('BootstrappedSEMs',semFig,'pdf');
end


