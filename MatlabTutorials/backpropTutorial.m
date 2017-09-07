function backpropTutorial
% backpropTutorial.m
%
% Illustrate backprop, by trying to use it to fit a function with a two
% layer network.  The initial idea was to set this up to reproduce some
% of the fits shown in Figure 4.12 of Bishop, using the backpropagation
% algorithm described later in the chapter. 
%
% The line example works perfectly.  For the parabola, dualramp, and step
% functions, the network does approximately the right thing, but the quality of fit
% is markedly worse than shown in Figure 4.12.  The sinusoid is not fit 
% at all well.
%
% The example in Bishop uses a different algorithm to set the weights, and
% this may be the problem.  Or we may still have a bug in the backprop
% implementation here.
%
% For some of the test functions, the training can get stuck in a local
% minima.  Whether it does this or not is pretty sensitive to the initial
% weights, learning rate, etc.  For the most part, the current parameters
% seem to work pretty well for the functions being fit (except for the
% sine).
%
% 8/27/08  dhb                  Wrote it.
% 8/27/08  dhb and others       Squashed several bugs during reading group meeting.
% 8/27/08  dhb                  Store previous weights from output layer for hidder layer update.
%          dhb                  Get tanh derivative correct.
%          dhb                  Variable learning rate.
%          dhb                  More functions to try to fit.

%% Clear and close
clear; close all;

%% Define network dimension and initialize weights.  The number of weights
% includes the additive term.
nInputUnits = 2;
nHiddenUnits = 5;
    inputWeights = rand(nHiddenUnits-1,nInputUnits);
    outputWeights = rand(1,nHiddenUnits);

%% Define function to try to fit.  Change the string
% to one of the options in the case statement to try
% different functions.
inputFunction = 'dualramp';
nTrainingPoints = 1000;
x = 2*rand(nInputUnits-1,nTrainingPoints)-1;
switch(inputFunction)
    case 'parabola'
        t = x.^2;
    case 'line'
        t = x;
    case 'step'
        t = sign(x);
    case 'dualramp'
        t = abs(x);
    case 'sine'
        t = sin(2*pi*x);
end
      
%% Plot of target function
funPlot = figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',14);
plot(x,t,'ro','MarkerSize',2,'MarkerFaceColor','r');

%% Add plot of the initial network response
y0 = ComputeNetwork(x,inputWeights,outputWeights);
plot(x,y0,'go','MarkerSize',2,'MarkerFaceColor','g');
drawnow;

%% Set up learning and error tracking parameters
n0 = 0.2;
decayExponent = 0.01;
errIndex = 1;
err(errIndex) = sum((t-y0).^2);
errPlot = figure; clf;
set(gca,'FontName','Helvetica','FontSize',14);
plotEvery = 100;

%% Train the network, using the backprop algorithm
nTrainingIterations = 5000;
for i = 1:nTrainingIterations
    % Print and plot of incremental error
    if (rem(i,100) == 0)
        yNow = ComputeNetwork(x,inputWeights,outputWeights);
        errIndex = errIndex+1;
        err(errIndex) = sum((t-yNow).^2);
        figure(errPlot); hold on
        plot(plotEvery*((1:errIndex)-1),err(1:errIndex),'k');
    end
    
    % Choose a training value from training set
    randomObservationIndices = randperm(nTrainingPoints);
    randomObservationIndex = randomObservationIndices(1);
    xTrain = x(:,randomObservationIndex);
    xTrainOnes = [ones(1,size(xTrain,2)) ; xTrain];
    tTrain = t(randomObservationIndex);
    
    % Compute network values for this training exemplar
    [yCurrent,yCurrentLinear,hiddenCurrent,hiddenCurrentLinear] = ComputeNetwork(xTrain,inputWeights,outputWeights);
    
    % Update learning rate
    n = n0/(i^decayExponent);
     
    % Update output weights
    deltaOut = (yCurrent-tTrain);
    outputWeights0 = outputWeights;
    for j = 1:nHiddenUnits
        outputWeights(1,j) = outputWeights(1,j) - n*deltaOut*hiddenCurrent(j);
    end
    
    % Backprop to input weights
    for j = 2:nHiddenUnits
        deltaHidden = nonlinderiv(hiddenCurrentLinear(j-1))*deltaOut*outputWeights0(1,j);
        for k = 1:nInputUnits
            inputWeights(j-1,k) = inputWeights(j-1,k) - n*deltaHidden*xTrainOnes(k);     
        end
    end
end

% Labels for error plot
figure(errPlot);
xlabel('Iteration','FontName','Helvetica','FontSize',18);
ylabel('Summed Squared Error','FontName','Helvetica','FontSize',18);

%% Add plot final network response, in black
figure(funPlot);
y = ComputeNetwork(x,inputWeights,outputWeights);
plot(x,y,'ko','MarkerSize',2,'MarkerFaceColor','k');
xlim([-1 1.5]);
xlabel('X','FontName','Helvetica','FontSize',18);
ylabel('Y','FontName','Helvetica','FontSize',18);
legend('target','initial','final');

%% Done
end


%% Forward network computation.  Linear output layer and non-linearity on
% output of hidden units.
function [response,responseLinear,hiddenResponse,hiddenResponseLinear] = ComputeNetwork(x,inputWeights,outputWeights)
    % Compute response of hidden units
    x = [ones(1,size(x,2)) ; x];
    hiddenResponseLinear = inputWeights*x;
    hiddenResponse = nonlin(hiddenResponseLinear);
    
    % Compute output response
    hiddenResponse = [ones(1,size(hiddenResponse,2)) ; hiddenResponse];
    responseLinear = outputWeights*hiddenResponse;
    response = responseLinear;  
end

%% Nonlinear function.  Can change this and the corresponding derivative
% function if you want to use another non-linearity (e.g. logistic).
function y = nonlin(x)
    y = tanh(x);
end

%% Nonlinear function derivative.
function y = nonlinderiv(x)
    y = tanhderiv(x);
end

%% Derivative of hyperbolic tangent.
function y = tanhderiv(x)
    y = 1-tanh(x).^2;
end

% Logistic function
function y = logit(x)
    y = 1./(1+exp(-x));
end

% Logistic derivative
function y = logitderiv(x)
    y = logit(x).*(1-logit(x));
end



