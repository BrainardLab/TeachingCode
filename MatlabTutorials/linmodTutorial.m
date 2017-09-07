% linmodTutorial
%
% To answer Sarah's questions about creating and using linear models
%
% 4/8/09  dhb  Wrote it.

% Clear
clear; close all;

% Generate some data from a 'prior', in this case just a multivariate
% normal.
priorDim = 25;
nDraws = 2000;
mean = ones(1,priorDim);
neighborCorr = 0.9;
cov = BuildMarkovK(priorDim,neighborCorr,1);
priorDraws = mvnrnd(mean,cov,nDraws)';

% Generate a linear model from these data and
% plot the components.  Look at code for FindLinMod
% to see how its produced.  That code uses the svd,
% but you could pretty do the same thing using a
% direct computation of the eigenvectors.
linModDim = 6;
[linMod] = FindLinMod(priorDraws,linModDim);
figure; clf;
plot(linMod);

% Pick a new draw from the prior, and fit with the
% linear model.  You will probably want to fit the
% prior mean to your linear model to initialize 
% the weights for your search.  After your search,
% you just use matrix multiplication to reconstruct
% the full function.
newDraw = mvnrnd(mean,cov,1)';
weightsForNewDraw = FindModelWeights(newDraw,linMod);
fitToNewDraw = linMod*weightsForNewDraw;
figure; clf; hold on
plot(newDraw,'ro','MarkerSize',6,'MarkerFaceColor','r');
plot(newDraw,'r');
plot(fitToNewDraw,'k');


