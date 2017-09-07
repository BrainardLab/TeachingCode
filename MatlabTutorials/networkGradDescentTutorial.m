% networkGradientDescentTutorial.m
%
% Illustrate various ways of doing regression and logistic regression,
% particularly incremental gradient descent techniques.  This is a
% companion to Bishop, Chapter 3.
%
% You can generate the simulated data in two ways, linear or with a static
% non-linearity.  The flag LOGIT_GENERATE controls which way you do this.
%
% The program does the iterative learning two ways, one appropriate for
% linear and one for logistic.  It does this no matter how you generate
% the data.  It is satisfying to note that you only converge to the right
% answer when the form of the learning is matched to the way the simulated data
% was actually generated.  But the linear iterative method is always
% consistent with the result of batch linear regression -- it's just that
% they are both wrong when the data are generated with the logistic.
%
% It's instructive to vary the added noise, rate parameters, and amount
% of data and see what happens for both linear and logistic simulated
% data.
%
% 8/6/08  dhb  Wrote it in preference to paying the bills.

%% Clear and close
clear; close all;

%% Define network dimension.  This number includes the additive term.
inputDimension = 4;

%% Decide whether true output is mapped through a logistic function.
LOGIT_GENERATE = 1;

%% Generate x and y pairs.  We're going to construct each y to be a weighted
% sum of the components of x.  So the dimension of x is inputDimension.
% The last entry of each x is constructed to be 1.
nObservations = 5000;
noiseSd = 0.01;
weightFactor = 1;
trueWeights = weightFactor*[rand(inputDimension,1)'-0.5];
observedXs = [rand(inputDimension-1,nObservations) ; ones(1,nObservations)];
if (LOGIT_GENERATE)
    underlyingYs = 1./(1 + exp(-trueWeights*observedXs));
else
    underlyingYs = trueWeights*observedXs;
end
observedYs =  underlyingYs + noiseSd*randn(1,nObservations);

%% Use straight multiple regression to estimate the weights.  The
% transposing in the expression just puts the data into the form
% MATLAB wants it, and then converts the answer back to the row
% vector form we're using.
regressionEstimate = ((observedXs)'\(observedYs)')';

%% Solve the problem using the gradient descent method described in
% Bishop.  I did add a parameter, decayExponent, that helps control
% how fast the learning parameter decreases with iteration.
n0 = 1;
decayExponent = 0.5;
logitn0 = 5;
logitDecayExponent = 0.2;
nIterations = 2000;

% Initialize weights at random.  We'll do this too ways, one on
% the assumption that the y's are linear in the x's, and the other
% on the assumption that there is a logistic static non-linearity.
descentWeights = zeros(nIterations+1,inputDimension);
logitDescentWeights = zeros(nIterations+1,inputDimension);
descentWeights(1,:) = zeros(inputDimension,1)';
logitdescentWeights(1,:) = descentWeights(1,:);

% Iterate
for k = 2:nIterations+1
    % Choose a random observation from our generated set, with replacement
    randomObservationIndices = randperm(nObservations);
    randomObservationIndex = randomObservationIndices(1);
    x = observedXs(:,randomObservationIndex);
    t(k-1) = observedYs(randomObservationIndex);
    
    % Compute current network output for the chosen observation X
    y(k-1) = descentWeights(k-1,:)*x;
    logity(k-1) = 1./(1 + exp(-logitDescentWeights(k-1,:)*x));
    
    % Compute error
    delta(k-1) = y(k-1)-t(k-1);
    
    % Compute logistic regression factor.  From Bishop, you might
    % conclude that you should square gprime when computing logitdelta,
    % but I think this is a typo.  It doesn't seem to converge as well
    % if you do. I did find that you can just set gprime to 1 and get
    % good convergence if you also get the rate parameter right.
    gprime(k-1) = logity(k-1)*(1-logity(k-1));
    logitdelta(k-1) = gprime(k-1)*(logity(k-1)-t(k-1));
       
    % Get current learning rate parameter.  If you play around,
    % you'll discover that how fast it converges is pretty sensitive
    % to how you set n0 and the decayExponent.  If you make these too big,
    % you get a lot of ringing at the start of learning.  If you make them
    % too small, then the convergence is very very very slow.
    n = n0/((k-1)^decayExponent);
    logitn = logitn0/((k-1)^logitDecayExponent);
    
    % Linear update
    update= n*delta(k-1)*x';
    descentWeights(k,:) = descentWeights(k-1,:) - update;
    
    % Logistic update
    logitupdate = logitn*logitdelta(k-1)*x';
    logitDescentWeights(k,:) = logitDescentWeights(k-1,:) - logitupdate;
    
end

% Make plot comparing true, regression, and descent estimates for each
% input dimension.
%   Black line - true weight
%   Red line - linear regression
%   Green line - gradient descent, linear
%   Blue line - gradient descent, logistic
for i = 1:inputDimension
    figure; clf; hold on
    plot(1:nIterations+1,trueWeights(i)*ones(1,nIterations+1),'k','LineWidth',2);
    plot(1:nIterations+1,regressionEstimate(i)*ones(1,nIterations+1),'r','LineWidth',1);
    plot(1:nIterations+1,descentWeights(1:end,i),'g','LineWidth',2);
    plot(1:nIterations+1,logitDescentWeights(1:end,i),'b','LineWidth',2);
    xlabel('Iteration','FontName','Helvetica','FontSize',14);
    ylabel('Weight Estimate','FontName','Helvetica','FontSize',14);
    title(sprintf('Coordiante %d',i),'FontName','Helvetica','FontSize',16);
end
    

    



