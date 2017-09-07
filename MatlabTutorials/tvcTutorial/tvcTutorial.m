%% tvcTutorial
%
% Well, how do you infer a response function from TvI/TvC data?
%
% Relies on a number of subfunctions in this same directory.
%
% 6/21/06   dhb, sra    Started in on this.
% 6/22/06   dhb         Pulled out subfunctions, removed globals, cosmetic.
% 6/23/06   sra         Added some text explanation.
%% INITIALIZE, LOAD AND PLOT SOME DATA
clear; close all;

% Here are some data.  We think these came from Hillis and Brainard
% 2005, but it doesn't really matter. The first point is really at 0
% pedestal intensity, but we don't want to screw around figuring out how to
% make MATLAB plot the log of zero right now.  [H and B report their data
% as incremental intensities rather than contrasts.  But whether it's
% intensity or contrast doesn't change any of the logic we're working
% through here.]
thePedestalIntensities = [1.0000e-04 0.00094460 0.0025677 0.0069798 0.018973 0.051574 0.084125 0.18695 0.19466 0.22611]';
theThresholds = [0.011252 0.0071570 0.0089313 0.0057842 0.0071912 0.011039 0.017978 0.042996 0.039610 0.060971]';
dataFig = figure; clf;
dataPlot = subplot(1,2,1); hold on
plot(log10(thePedestalIntensities),log10(theThresholds),'ro','MarkerSize',8,'MarkerFaceColor','r');
xlabel('Log10 Pedestal Intensity'); ylabel('Log10 Threshold Intensity');

%% FORM OF THE RESPONSE FUNCTION
% Our goal is to find the parameters of a response function that predicts
% the TvI data.  We'll use a simple Naka-Rushton function:
%   r = rMax*(g*I)^n/((g*I)^n+1)
% This function is computed by the function ComputeResponses. Below we 
% develop an intuition about the form of the response function by using
% artificial data to show how the response function changes when you change
% the parameters. We plots a response function for two choices of g.  You can also 
% explore the effect of varying n and rMax if you're into it.
rMax = 10; g0 = 2; g1 = 10; n = 3;
examplePedestals = linspace(1e-4,2,1000);
responses0 = ComputeResponses(examplePedestals,rMax,g0,n);
responses1 = ComputeResponses(examplePedestals,rMax,g1,n);
respFig = figure; clf; 
subplot(1,2,1); hold on
plot(log10(examplePedestals),responses0,'r','LineWidth',2);
plot(log10(examplePedestals),responses1,'g','LineWidth',2);
xlabel('Log10 Intensity'); ylabel('Response'); axis('square');

%% PREDICTING THRESHOLDS FROM RESPONSE
% The fitting logic goes as follows.  For any choice of response function
% parameters, we can predict the thresholds, by finding how far we need to
% increase the intensity above each pedestal to produce a constant response
% difference.  This is done here by function PredictThreshods below.  Once
% we can predict thresholds given response parameters, we can then use
% numerical search to find the parameters that minimize the error between
% the predictions and the data. Here we plot the predicted thresholds for
% the two possible response functions defined above, using the artificial 
% data examplePedestals.
 
predictions0 = PredictThresholds(examplePedestals,rMax,g0,n);
predictions1 = PredictThresholds(examplePedestals,rMax,g1,n);
figure(respFig);
subplot(1,2,2); hold on
plot(log10(examplePedestals),log10(predictions0),'r','LineWidth',1);
plot(log10(examplePedestals),log10(predictions0),'ro','MarkerSize',4);
hold on
plot(log10(examplePedestals),log10(predictions1),'g','LineWidth',1);
plot(log10(examplePedestals),log10(predictions1),'go','MarkerSize',4);
xlabel('Log10 Pedestal Intensity'); ylabel('Log10 Threshold'); axis('square')

%% FIT RESPONSE FUCNTION
% We now return to the real data. Use numerical search to find the response 
% function parameters that result in the
% best fit to the data.
%
% The function FitResponseFunctionFun computes the error to the data, given
% the parameters, pedestal intensities, and observed thresholds.
% MATLAB function fminunc peforms unconstrained minimization.  In our
% experience, fmincon works better than fminunc, even when you don't really
% want to impose any serious constraint.

% Choose initial parameters.
rMax0 = 50;
g0 = 1/mean(thePedestalIntensities);
n0 = 2;
x0=[rMax0, g0, n0];

% Set reasonable bounds on parameters
vlb = [0.1 0.001 0.1];
vub = [1000 100 20];

% Do the search and make predictions
options = optimset('fmincon');
options = optimset(options,'TolX',1e-4,'LargeScale','Off','Display','Off');
x = fmincon('FitResponseFunctionFun',x0,[],[],[],[],vlb,vub,[],options,thePedestalIntensities,theThresholds);
thePredictedThresholds = PredictThresholds(thePedestalIntensities,x(1),x(2),x(3));
thePredictedResponses = ComputeResponses(thePedestalIntensities,x(1),x(2),x(3));

%% PLOT
% We now plot the predicted thresholds and inferred response function calculated
% from the parameters from our numerical search. We compare these to the observed
% thresholds.
figure(dataFig);
subplot(dataPlot); hold on
plot(log10(thePedestalIntensities),log10(thePredictedThresholds),'b','LineWidth',2);
subplot(1,2,2); hold on
plot(log10(thePedestalIntensities),thePredictedResponses,'b','LineWidth',2);
xlabel('Log10 Pedestal Intensity'); ylabel('Inferred Response');


