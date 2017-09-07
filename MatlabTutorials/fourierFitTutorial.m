function fourierFitTutorial
% fourierFitTutorial
%
% Demonstrate how to fit fourier functions to data, using optimization
% toolbox.  Both unconstrained and constrained.  Shows fmincon in action.
%
% 4/21/09  dhb  Started on it.
% 7/15/09  dhb  Check optim version and handle inconsistences in options.

%% Clear
clear; close all;

%% Generate a test data set with three elements in the data set.  Make shape similar but not identical.
noisesd = 0.2;
fitorder = 2;
testHues = 1:40;
xset{1} = (testHues-1)/length(testHues+1);
xset{2} = xset{1};
xset{3} = xset{1};
coeffstrue{1} = [2 1 1 0.4 0.25 0.1 0.2];
yset{1} = ComputeFourierModel(coeffstrue{1},xset{1}) + normrnd(0,noisesd,size(xset{1}));
coeffstrue{2} = [1 0.3 1.2 0.5 0.25 -0.1 0.0];
yset{2} = ComputeFourierModel(coeffstrue{2},xset{2}) + normrnd(0,noisesd,size(xset{1}));
coeffstrue{3} = [1.5 0.5 0.9 0.3 0.35 0 0.2];
yset{3} = ComputeFourierModel(coeffstrue{3},xset{3}) + normrnd(0,noisesd,size(xset{1}));

%% Fit the dataset, unconstrained
[coeffsunset,ypredunset,errorunset] = FitUnconstrainedModel(xset,yset,fitorder);

%% Fit the dataset, constrained
[coeffsconset,ypredconset,errorconset] = FitConstrainedModel(xset,yset,fitorder);

%% Report what happened
figure; clf;
subplot(3,1,1); hold on
plot(xset{1},yset{1},'ro','MarkerFaceColor','r','MarkerSize',6);
plot(xset{1},ypredunset{1},'r');
plot(xset{1},ypredconset{1},'b');
ylim([0 5]);
subplot(3,1,2); hold on
plot(xset{2},yset{2},'ro','MarkerFaceColor','r','MarkerSize',6);
plot(xset{2},ypredunset{2},'r');
plot(xset{2},ypredconset{2},'b');
ylim([0 5]);
subplot(3,1,3); hold on
plot(xset{3},yset{3},'ro','MarkerFaceColor','r','MarkerSize',6);
plot(xset{3},ypredunset{3},'r');
plot(xset{3},ypredconset{3},'b');
ylim([0 5]);

end

function [coeffsset,ypredset,errorset] = FitUnconstrainedModel(xset,yset,order)
% [coeffset,ypred] = FitUnconstrainedModel(x,y,order)
%
% Fit the fourier model of given order separately to each data set in the
% passed cell arrays xset and yset.  Return cell arrays giving fit coefficients,
% predictions, and errors.
%
% 4/21/09  dhb  Wrote it.

% Optimization options
options = optimset('fmincon');
if (verLessThan('optim','4.1'))
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off');
else
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
end

% Define length of coefficients from order
coeffs00 = zeros(1,3+2*(order-1));

% Do each set separately
nSets = length(xset);
for i = 1:nSets
    x = xset{i};
    y = yset{i};

    % Initialize guess and set bounds, based loosely on data.
    coeffs0 = coeffs00;
    coeffs0(1) = mean(y);
    coeffs0(2) = mean(y);
    lb = [min(y) -10*max(abs(y))*ones(1,length(coeffs0(2:end)))];
    ub = [max(y) 10*max(abs(y))*ones(1,length(coeffs0(2:end)))];
    
    % Do the fit.
    coeffsset{i} = fmincon(@FitUnconstrainedFun,coeffs0,[],[],[],[],...
        lb,ub,[],options,x,y);

    % Get final prediction and error for return
    ypredset{i} = ComputeFourierModel(coeffsset{i},x);
    errorset{i} = EvaluateModelFit(y,ypredset{i});
end

end

function f = FitUnconstrainedFun(coeffs,x,y)
% f = FitUnconstrainedFun(coeffs,x,y)
%
% Error function for unconstrained model fit.
%
% 4/21/09  dhb  Wrote it.

ypred = ComputeFourierModel(coeffs,x);
f = EvaluateModelFit(y,ypred);
end

function [coeffsset,ypredset,errorset] = FitConstrainedModel(xset,yset,order,guesscoeffs)
% [coeffset,ypred] = FitConstrainedModel(x,y,order,guesscoeffs)
%
% Fit the fourier model of given order separately to each data set in the
% passed cell arrays xset and yset.  Return cell arrays giving fit coefficients,
% predictions, and errors.  The fit is constrained so that each element of the
% dataset has the same modulation shape, but the modulation mean and depth can
% vary.
%
% 4/21/09  dhb  Wrote it.

% Optimization options
options = optimset('fmincon');
if (verLessThan('optim','4.1'))
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off');
else
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
end

% Grab number of sets
nSets = length(xset);

% Initialize guess and set bounds, based loosely on data.
concoeffs0 = [zeros(1,2*nSets) zeros(1,1+2*(order-1))];
miny = Inf;
maxy = -Inf;
index = 1;
for i = 1:nSets
    concoeffs0(2*(i-1)+1) = mean(yset{i});
    concoeffs0(2*(i-1)+2) = mean(yset{i});
    index = index+2;
    if (min(yset{i}) < miny)
        miny = min(yset{i});
    end
    if (max(yset{i}) > maxy)
        maxy = max(yset{i});
    end
end
lb = [-10*max(abs([miny maxy]))*ones(1,length(concoeffs0))];
ub = [10*max(abs([miny maxy]))*ones(1,length(concoeffs0))];
for i = 1:nSets
    lb(2*(i-1)+1) = miny;
    ub(2*(i-1)+1) = maxy;
end

% Do the numerical fit
concoeffs = fmincon(@FitConstrainedFun,concoeffs0,[],[],[],[],...
    lb,ub,[],options,xset,yset);

% Get final prediction and error for return
coeffsset = UnpackConCoeffs(concoeffs,nSets);
for i = 1:nSets
    ypredset{i} = ComputeFourierModel(coeffsset{i},xset{i});
    errorset{i} = EvaluateModelFit(yset{i},ypredset{i});
end
end

function f = FitConstrainedFun(concoeffs,xset,yset)
% f = FitUnconstrainedFun(coeffs,xset,yset)
%
% Error function for constrained model fit.
%
% 4/21/09  dhb  Wrote it.

% Unpack constrained coefficients
nSets = length(xset);
coeffsset = UnpackConCoeffs(concoeffs,nSets);

% Get error for each set and sum
f = 0;
for i = 1:nSets
    ypred = ComputeFourierModel(coeffsset{i},xset{i});
    f = f + EvaluateModelFit(yset{i},ypred);
end
end

function coeffsset = UnpackConCoeffs(concoeffs,nSets)
% coeffsset = UnpackConCoeffs(concoeffs,nSets)
%
% Unpack array of constrained coefficients into cell array
% in form to evaluate each component separately.
%
% 4/21/09  dhb  Wrote it.

index = 1;
for i = 1:nSets
    coeffsset{i}(1) = concoeffs(index);
    index = index+1;
    coeffsset{i}(2) = concoeffs(index);
    index = index+1;
end
for i = 1:nSets
    coeffsset{i}(3:3+length(concoeffs(index:end))-1) = concoeffs(index:end);
end
   
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

function f = EvaluateModelFit(y,ypred)
% f = EvaluateModelFit(y,ypred)
%
% 4/21/09  dhb  Wrote it.

resid = y-ypred;
f = sqrt(sum(resid.^2)/length(resid));

end



