function crossvalTutorial
% crossvalTutorial
%
% Quick little tutorial to show how to cross-validate some data.
%
% 12/16/16  dhb, ar  Wrote the skeleton.

%% Clear
clear; close all;

%% Parameters
nIndependentValues = 10;
nReplications = 100;
noiseSd = 10;
nFolds = 8;
c1 = 5;
c2 = -3;

%% Let's generate a dataset of random numbers that are described by a quadratic
xVals = repmat(linspace(0,10,nIndependentValues),nReplications,1);
yObserved = zeros(size(xVals));
for jj = 1:nReplications
    xMatTemp = [xVals(jj,:) ; xVals(jj,:).^ 2];
    yTemp = [c1 c2]*xMatTemp;
    yObserved(jj,:) = yTemp + normrnd(0,noiseSd,1,size(yObserved,2));
end

%% Plot the simulated data
figure; clf; hold on
for jj = 1:size(yObserved,2)   
    plot(xVals(jj,:),yObserved(jj,:),'ro','MarkerSize',8,'MarkerFaceColor','r');
end

%% Do a cross-validated fit, using the crossval function
%
% We'll do both linear and quadratic fits
%
% Linear
linearCrossValErr = crossval(@linearFit,xVals,yObserved,'KFold',nFolds);
meanLinearCrossValErr = mean(linearCrossValErr);

% Quadratic
quadraticCrossValErr = crossval(@quadraticFit,xVals,yObserved,'KFold',nFolds);
meanQuadraticCrossValErr = mean(quadraticCrossValErr);

% Report who won
if (quadraticCrossValErr < linearCrossValErr)
    fprintf('Crossval method: Correctly identified that it was quadratic\n');
else
    fprintf('Crossval method: Incorrectly think it is linear\n');
end

%% Now we'll do the same thing using the cvpartition class.
%
% This is a bit less slick for this simple example, but much
% more flexible when the fit functions need to be more complicated.
c = cvpartition(nReplications,'Kfold',nFolds);
for kk = 1:nFolds
    % Get indices for kkth fold
    trainingIndex = c.training(kk);
    testIndex = c.test(kk);
    check = trainingIndex + testIndex;
    if (any(check ~= 1))
        error('We do not understand cvparitiion''s kFold indexing scheme');
    end
    
    % Get linear and quadratic error for this fold
    linearCrossValErr(kk) = linearFit(xVals(trainingIndex,:),yObserved(trainingIndex,:),xVals(testIndex,:),yObserved(testIndex,:));
    quadraticCrossValErr(kk) = quadraticFit(xVals(trainingIndex,:),yObserved(trainingIndex,:),xVals(testIndex,:),yObserved(testIndex,:));
end

% Get mean error for two types of it
meanQuadraticCrossValErr = mean(quadraticCrossValErr);
meanLinearCrossValErr = mean(linearCrossValErr);

% Report who won
if (quadraticCrossValErr < linearCrossValErr)
    fprintf('CVParitition method: Correctly identified that it was quadratic\n');
else
    fprintf('CVParitition method: Incorrectly think it is linear\n');
end

end

function testVal = linearFit(xTrain,yTrain,xTest,yTest)
    c = xTrain(:)\yTrain(:);
    yPred = xTest(:)*c;
    yDiff = yPred(:)-yTest(:);
    testVal = sum(yDiff.^2);
end

function testVal = quadraticFit(xTrain,yTrain,xTest,yTest)
    c = [xTrain(:) xTrain(:).^2]\yTrain(:);
    yPred = [xTest(:) xTest(:).^2]*c;
    yDiff = yPred(:)-yTest(:);
    testVal = sum(yDiff.^2);
end