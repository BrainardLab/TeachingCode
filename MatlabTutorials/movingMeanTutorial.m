% movingMeanTutorial

% Clear
clear; close all;

% Load in some info that we need
S = [380 5 81];
load spd_D65
spdIlluminant = SplineSpd(S_D65,spd_D65,S);
load T_xyz1931
T = SplineCmf(S_xyz1931,T_xyz1931,S);
load B_nickerson
B_sur = SplineSrf(S_nickerson,B_nickerson(:,1:3),S);

% Grab a bunch of surfaces that will serve as our simulated
% set of surfaces
load sur_nickerson
theSurfaces = SplineSrf(S_nickerson,sur_nickerson,S);
nSurfaces = 25;
whichSurfaces = Ranint(nSurfaces,size(theSurfaces,2));
theWeights = B_sur\theSurfaces(:,whichSurfaces);
theSurfaces = B_sur*theWeights;

% Simulate the image formation process
rawXYZ = T*diag(spdIlluminant)*theSurfaces;
rawMeanXYZ = mean(rawXYZ,2);

% Set target mean, different from what we ended up with in rawXYZ
targetMeanXYZ = 0.3*rawMeanXYZ + rawMeanXYZ*2;

% Do the magic
M = T*diag(spdIlluminant)*B_sur;
S = diag(targetMeanXYZ./rawMeanXYZ);
Q = inv(M)*S*M;
newWeights = Q*theWeights;
newSurfaces = B_sur*newWeights;

% Did we get the right answer
newXYZ = T*diag(spdIlluminant)*newSurfaces;
newMeanXYZ = mean(newXYZ,2);

targetMeanXYZ
newMeanXYZ

max(newSurfaces(:))
min(newSurfaces(:))


