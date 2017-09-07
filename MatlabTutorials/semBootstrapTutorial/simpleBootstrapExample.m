% simpleBootstrapExample
%
% Used to generate some numbers for a class example.
% Very simple.
%
% 9/20/11  dhb  Wrote it.

% %% Clean out
clear; close all; clc;
format short
format compact

%% Draw 'population' distribution.  In this case, it's a
% normal distribution with specified mean and sd.  Make
% a nice plot of the population.
theoreticalMean = 0;
theoreticalSd = 3;
nPopulationDraws = 10000;
populationX = Ranint(nPopulationDraws,100);
populationMean = mean(populationX);
populationSd = std(populationX);

%% Suppose we ran an experiment and got some subset of data from
%this underlying distribution, with its own mean and standard deviation.
nExperimentDraws = 10;
index = unidrnd(nPopulationDraws,nExperimentDraws,1);
experimentX = populationX(index);


%% Resample from the sample
nBootstraps = 5;
for b = 1:nBootstraps
    index = unidrnd(nExperimentDraws,nExperimentDraws,1);
    bootstrapX(:,b) = experimentX(index);
end

