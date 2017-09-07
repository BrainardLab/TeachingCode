function glmTutorial
%
% Demonstrate how to use Matlab's Statistics Toolbox glm routines
% to fit data.
%
% This is right basic idea, but needs a little fixing up still.
%
% Need to:
%  a) Add better comments.
%  b) Show how to wrap a parameter search around the parameters of
%     the linking function.
%  c) Worry about the regime where the linking function is such that
%     the glm routines return NaN because of ill-conditioning.
%
% 9/21/13  dhb  Wrote it.

%% Clear
clear; close all;

%% Parameters.
%
% We construct a linear function of some
% random numbers, bTrue gives the weights.
bTrue = [2 3 5]';
xDim = length(bTrue);
nObservations = 100;
noiseSd = 0.01;

%% Link function and its parameters.
%
% We assume that the observed data are a Naka-Rushton function
% of the linear values.  The way the glm stuff works,
% this means that the linking function is the inverse of the
% Naka-Rushton function.
global linkParams
linkParams.type = 'AffinePower';
switch (linkParams.type)
    case 'InverseNakaRushton'
        linkParams.params(1) = 10;
        linkParams.params(2) = 3;
        linkParams.params(3) = 2;
        linkS.Link = @ForwardLink;
        linkS.Derivative = @DerivativeLink;
        linkS.Inverse = @InverseLink;
    case 'AffinePower'
        linkParams.params(1) = 1;
        linkParams.params(2) = 0.5;
        linkS.Link = @ForwardLink;
        linkS.Derivative = @DerivativeLink;
        linkS.Inverse = @InverseLink;
    case 'Power'
        linkParams.params(1) = 2;
        linkS.Link = @ForwardLink;
        linkS.Derivative = @DerivativeLink;
        linkS.Inverse = @InverseLink;
    otherwise
        error('Unknown link function type');
end

%% X variables
X = rand(nObservations,xDim);

%% Linear y is a linear function of X
yLinear = X*bTrue;
yNonLinear = InverseLink(yLinear);
yObserved = yNonLinear + noiseSd*randn(size(yNonLinear));

%% Figure
[~,index] = sort(yLinear);
theFig = figure; clf;
hold on
plot(yLinear(index),yObserved(index),'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(yLinear(index),yNonLinear(index),'r');

%% GLM fit
warnState = warning('off','stats:glmfit:IterationLimit');
GLM = GeneralizedLinearModel.fit(X,yObserved,'Distribution','normal','Link',linkS,'Intercept',false);
warning(warnState);
bFit = GLM.Coefficients.Estimate
yLinearPred = X*bFit;
yNonLinearPred = InverseLink(yLinearPred);
figure(theFig);
plot(yLinear(index),yNonLinearPred(index),'b');
xlabel('True linear value');
ylabel('Obs/Predicted nonlinear value');

%% This is just a check that the PTB NakaRushton function properly
% inverts itself.
switch (linkParams.type)
    case 'NakaRushton'
        linearInvertCheck = ForwardLink(yNonLinearPred);
        if (any(abs(yLinearPred-linearInvertCheck) > 1e-7))
            error('Naka-Rushton inversion error');
        end
        
        % A little more testing
        figure; clf;
        derivCheck = DerivativeLink(yNonLinearPred);
        subplot(2,1,1); hold on
        plot(yNonLinearPred(index),linearInvertCheck(index),'r');
        subplot(2,1,2); hold on
        plot(yNonLinearPred(index),derivCheck(index),'r');
end


end

function out = ForwardLink(in)

global linkParams

switch (linkParams.type)
    case 'InverseNakaRushton'
        in(in < 0) = 0;
        in(in > linkParams.params(1)) = linkParams.params(1);
        out = InvertNakaRushton(linkParams.params,in);
    case 'AffinePower'
        in(in < 0) = 0;
        out = linkParams.params(1) + in.^linkParams.params(2);
    case 'Power'
        in(in < 0) = 0;
        out = in.^linkParams.params(1);
    otherwise
        error('Unknown link function type');
end

end

function out = DerivativeLink(in)

global linkParams

switch (linkParams.type)
    case 'InverseNakaRushton'
        in(in < 0) = 0;
        in(in > linkParams.params(1)) = linkParams.params(1);
        out = DerivativeInvertNakaRushton(linkParams.params,in);
    case 'AffinePower'
        in(in < 0) = 0;
        out = linkParams.params(2)*in.^(linkParams.params(2)-1);
    case 'Power'
        in(in < 0) = 0;
        out = linkParams.params(2)*in.^(linkParams.params(2)-1);
    otherwise
        error('Unknown link function type');
end

end

function out  = InverseLink(in)

global linkParams

switch (linkParams.type)
    case 'InverseNakaRushton'
        % Force input into required range
        in(in < 0) = 0;
        out = ComputeNakaRushton(linkParams.params,in);
    case 'AffinePower'
        in(in < 0) = 0;
        tmp = in - linkParams.params(1);
        tmp(tmp < 0) = 0;
        out = tmp.^(1/linkParams.params(2));
    case 'Power'
        in(in < 0) = 0;
        out = in.^(1/linkParams.params(2));
    otherwise
        error('Unknown link function type');
end

end




