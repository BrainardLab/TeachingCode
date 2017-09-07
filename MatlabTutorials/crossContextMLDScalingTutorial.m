function CrossContextMLDSScalingTutorial
% CrossContextMLDSScalingTutorial
%
% Suppose we have cross-context data of the form, see stimulus
% X, seen in context 1, and choose which of two alternatives, Y1 and Y2,
% seen in context 2, that is most like X. 
% 
% We want to take a bunch of data of this form, where Y1 and Y2 vary
% trial-to-trial, and find the value of Y that is the best match to X. 
%
% We assume that the Y's live in an N dimensional perceptual space.
% This seems like an MDS setup, with triad data.  As discussed
% in Maloney and Yang (2003), triads are a special case of 
% the MLDS stimuli, with one stimulus repeated twice.  
%
% The other difference here is the change of context, but I don't think
% that is fundamental.
%
% If we're willing to take the scales as one-dimensional and assume that
% the scale in one context maps into the other in some parametric
% way, we could find the parametric transformation.
%
% This code simulates out the basic MLDS analysis for a case like the above,
% to make sure nothing goes too wonky.
%
% NOTE: We how have a toolbox, BrainardLabToolbox/MLDSColorSelection, that
% implements much of what is here.  This should be modified to call through
% that, and the two should cross-reference each other.
%
% 1/10/12  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Parameters
sigma = 0.10;
nY = 10;
nSimulatePerPair = 100;

%% Generate a list of X and Y stimuli
x = 0.55;
yOfX = MapXToY(x);
linY = logspace(log10(0.5),log10(0.6),nY);
y = MapXToY(linY);

%% Simulate out probabilities for pairwise trials
thePairs = nchoosek(1:nY,2);
nPairs = size(thePairs,1);
theSimResponse1 = zeros(nPairs,1);
theTheoryResponse1 = zeros(nPairs,1);
for i = 1:nPairs
    n1 = 0;
    for j = 1:nSimulatePerPair
        if (SimulateResponse1(x,y(thePairs(i,1)),y(thePairs(i,2)),sigma,@MapXToY))
            n1 = n1 + 1;
        end
    end
    theSimResponse1(i) = n1;
    theTheoryProb1(i) = ComputeProb1(x,y(thePairs(i,1)),y(thePairs(i,2)),sigma,@MapXToY);
end
theSimProb1 = theSimResponse1/nSimulatePerPair;

%% Make sure that simulated data matches the theoretical model.  Nothing
% else is going to work if this isn't done correctly
figure; clf; hold on
plot(theTheoryProb1,theSimProb1,'ro','MarkerSize',4,'MarkerFaceColor','r');
xlabel('Theory'); ylabel('Simulation');
axis('square'); axis([0 1 0 1]);
plot([0 1],[0 1],'k');

%% Find the maximum likelihood solution for x and the y's.  We
% fix the origin at y(1) and the scale via sigma, which are thus
% assumed known.

% Compute log likelihood of actual simulated data as a baseline
logLikelyTrue = ComputeLogLikelihood(thePairs,theSimResponse1,nSimulatePerPair,MapXToY(x),y,sigma);        

% Search to find the best solution
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');
y1 = y(1);
x0 = [x linY(2:end)];
vlb = -10*max(x0)*ones(size(x0));
vub = 10*max(x0)*ones(size(x0));
fitX = fmincon(@(x)FitContextFCScalingFun(x,y1,thePairs,theSimResponse1,nSimulatePerPair,sigma),x0,[],[],[],[],vlb,vub,[],options);
xFit = fitX(1);
yFit = [y1 fitX(2:end)];
logLikelyFit = ComputeLogLikelihood(thePairs,theSimResponse1,nSimulatePerPair,xFit,yFit,sigma);        
fprintf('Log likelihood true: %g, fit: %g\n',logLikelyTrue,logLikelyFit);

%% Plot the recovered configuration
figure; clf; hold on
plot(y,yFit,'ro','MarkerSize',4,'MarkerFaceColor','r');
plot(MapXToY(x),xFit,'bo','MarkerSize',4,'MarkerFaceColor','b');
xlabel('Simulated'); ylabel('Fit');
axis('square');
minVal = min([y yFit]);
maxVal = max([y yFit]);
axis([minVal maxVal minVal maxVal]);
plot([minVal maxVal],[minVal maxVal],'k');

end

%% f = FitContextFCScalingFun(x,y1,thePairs,theResponse1,nTrials,sigma)
% 
% Error function for the numerical search.
function f = FitContextFCScalingFun(x,y1,thePairs,theResponse1,nTrials,sigma)

if (any(isnan(x)))
    error('Entry of x is Nan');
end
xFit = x(1);
yFit = [y1 x(2:end)];
logLikely = ComputeLogLikelihood(thePairs,theResponse1,nTrials,xFit,yFit,sigma);
f = -logLikely;

end

%% logLikely = ComputeLogLikelihood(thePairs,theResponse1,nTrials,xFit,yFit,sigma)
%
% Compute likelihood of data for any configuration
function logLikely = ComputeLogLikelihood(thePairs,theResponse1,nTrials,xFit,yFit,sigma)

nPairs = size(thePairs,1);
logLikely = 0;
for i = 1:nPairs
    theTheoryProb1 = ComputeProb1(xFit,yFit(thePairs(i,1)),yFit(thePairs(i,2)),sigma,@IdentityMap);
    if (isnan(theTheoryProb1))
        error('Returned probability is NaN');
    end
    if (isinf(theTheoryProb1))
        error('Returend probability is Inf');
    end
    logLikely = logLikely + theResponse1(i)*log10(theTheoryProb1) + (nTrials-theResponse1(i))*log10(1-theTheoryProb1);
end
if (isnan(logLikely))
    error('Returned likelihood is NaN');
end

end

%% p1 = ComputeProb1(x,y1,y2,sigma,mapFunction)
%
% Compute probability of responding 1 given target and pair.
% The passed mapFunction simulates the effect of context change 
% between x domain and y domain
function p1 = ComputeProb1(x,y1,y2,sigma,mapFunction)

yOfX = mapFunction(x);
diff1 = y1-yOfX;
diff2 = y2-yOfX;
diffDiff = abs(diff1)-abs(diff2);
p1 = normcdf(-diffDiff,0,sigma);
if (p1 == 0)
    p1 = 0.0001;
elseif (p1 == 1)
    p1 = 0.9999;
end

end

%% response1 = SimulateResponse1(x,y1,y2,sigma,mapFunction)
%
% Simulate a trial given target and pair.
% The passed mapFunction simulates the effect of context change 
% between x domain and y domain
function response1 = SimulateResponse1(x,y1,y2,sigma,mapFunction)

yOfX = mapFunction(x);
diff1 = y1-yOfX;
diff2 = y2-yOfX;
if (abs(diff1)-abs(diff2) + normrnd(0,sigma) <= 0)
    response1 = 1;
else
    response1 = 0;
end

end

%% yOfX = MapXToY(x)
%
% Example map function
function yOfX = MapXToY(x)

yOfX = x.^0.8 - 0.1;

end

%% yOfX = IdentityMap(x)
%
% Identity map function.  When simulating fit
% we use this.
function yOfX = IdentityMap(x)
    
yOfX = x;
    
end