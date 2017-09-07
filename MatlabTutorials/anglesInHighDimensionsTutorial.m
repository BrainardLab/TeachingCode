% anglesInHighDimensionTutorial
%
% Try to understand orthogonality in high dimensions, a little.
%
% 2/6/16  dhb Wrote it

%% Initialize
clear; close all;

%% Set parameters
theDimensions = [3 30 300 3000 30000 300000];
trialsPerDimension = 10;

%% Loop over dimensions and trials
%

for i = 1:length(theDimensions)
    theDimension = theDimensions(i);
    for j = 1:trialsPerDimension
        theVector = rand(theDimension,1)-0.5;
        
        % Flip sign of smallest magnitude entry and find angle
        % These do not seem to got to 90 degrees as dimension increases.
        [minMag,minMagIndex] = min(abs(theVector));
        theNewVector = theVector;
        theNewVector(minMagIndex) = -theVector(minMagIndex);
        theMinFlipAngles(i,j) = (180/pi)*subspace(theVector,theNewVector);
        
        % Choose another random vector and get angle between it and
        % original vector.  These seem to go to about 41 degrees as
        % dimension increases, with very little variance.
        theNewVector = rand(theDimension,1)-0.5;
        theRandVectorAngles(i,j) = (180/pi)*subspace(theVector,theNewVector);
    end
end