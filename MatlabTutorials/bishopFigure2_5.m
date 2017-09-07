% bishopFigure2_5.m
%
% Simple example to illstrate bayesian inference of normally distributed
% data.
%
% Suppose the data is drawn from a normal distribution with known variance
% and that the prior over the mean is also normally distributed with known
% mean and variance.
%
% We want to find out whether as sample number N become larger, 
% the posterior distribution become more peaky and concentrated around the
% true value of the mean. 
%
% Development follows Bishop, Chapter 2, with goal to reproduce Figure 2.5
% 
% 06/26/08 bx       Wrote it.
% 06/28/08 dhb      Cosmetic changes

% Initialize
close all; clear;

% Data is drawn from a normal distribution for which the standard deviation
% sigma is known. The goal is to find the mean mu of the distribution given
% a set of data points (x1,....xN)


% Specify parameters of underlying distribution.  Our goal is to estimate
% mu from samples.
mu = 0.8;
std = 0.3;

% Prior distribution over mu is also a normal distribution with mu_0 = 0 and
% std = 0.3
mu_0 = 0;
std_0 = 0.3;

% Construct posterior on discretely sample interval
mu_step = 0.01;
mu_values = [-4:mu_step:4];

% Compute prior on sampled steps
for i = 1:length(mu_values)
    prior(i) = normpdf(mu_values(i),mu_0,std_0);
end
prior = prior/sum(prior);

% Do the calculation for different amounts of data observed
index = 1;
for n = [1 10 50]
    % Simulate data
    data = std.*randn(n,1) + mu;

    % Compute posterior for each value of mu_values
    for i = 1:length(mu_values)
        likelihood(i) = 1;
        for j = 1:n
            likelihood(i) = likelihood(i)*normpdf(data(j),mu_values(i),std);
        end
        unnormalizedposterior(index,i) = (prior(i)*likelihood(i));
    end
    posterior(index,:) = unnormalizedposterior(index,:)/sum(unnormalizedposterior(index,:));
    index = index+1;
end

figure;
plot(mu_values,prior,'r-');
hold on;
plot(mu_values,posterior(1,:),'k-');
plot(mu_values,posterior(2,:),'b-');
plot(mu_values,posterior(3,:),'c-');
xlim([0 1]);
xlabel('mu');
ylabel('p(mu)');
drawnow

	