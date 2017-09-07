% TestRotateScaleFlip
%
% Test whether we can map one set of coords into another via
% RotateScaleFlip.
%
% 10/11/05  dhb, scm    Wrote it
% 02/08/06  scm         Randomized the scaling, flipping, and rotation
% 7/5/06    dhb         Make map parameters, rather than random.

% Close and clear
clear; close all;

% Mapping parameters
scale = 3;
rotate = 172;
FLIP =  1;

% Generate random coordinates
pointDimension = 2;
numberPoints = 10;
targetSolution = rand(pointDimension,numberPoints);
POINTSOK = 0;
while (~POINTSOK)
    POINTSOK = 1;
    for i = 1:numberPoints
        for j = (i+1):numberPoints
            if (targetSolution(1,i) == targetSolution(1,j) & targetSolution(2,i) == targetSolution(2,j))
                targetSolution(:,j) = rand(2,1);
                POINTSOK = 0;
            end
        end
    end
end

% Now rotate them elsewhere
inData = RotateScaleFlip(targetSolution,rotate,scale,FLIP);

% Plot data
figure; clf; hold on
plot(targetSolution(1,:),targetSolution(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
plot(inData(1,:),inData(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
axis('square'); axis([-4 4 -4 4]);

% See if we can recover
[mappedData,foundTheta,foundScale,foundFLIP] = FindRotateScaleFlip(inData,targetSolution);

% Map with initial guess for debugging
figure; clf; hold on
plot(targetSolution(1,:),targetSolution(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
plot(mappedData(1,:),mappedData(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
axis('square'); axis([-2 2 -2 2]);
