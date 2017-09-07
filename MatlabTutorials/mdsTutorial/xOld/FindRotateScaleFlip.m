function [mappedSolution,theta,scale,translate,FLIP] = FindRotateScaleFlip(inSolution,targetSolution)
% [mappedSolution,theta,scale,translate,FLIP] = FindRotateScaleFlip(inSolution,targetSolution)
% 
% Find the mapping that best puts inSolution into register with targetData.
% This is a calling routine for underlying parameter search.  It searches 
% separately on the assumption that the solution is mirror-reversed
% (FLIPed) from the starting point, and picks the best result.
%
% 10/11/05  dhb, scm    Wrote it.
% 1/19/06   dhb         Tried to resurrect from the dead.
% 1/28/06   scm         On a bug hunt.
% 2/2/06    dhb, scm    Rationalize variable names, clean.
% 2/8/06    scm         Working on rotation/flip bug.
% 2/10/06   scm         Working on rotation/flip problem.

% Debug?
DEBUG = 1;
SEARCH = 1;
nTheta0 = 30;
nTheta1 = 30;

% Get initial guess for rotation: FLIP = 0;
centeredInSolution = inSolution - inSolution(:,1)*ones(1,size(inSolution,2));
centeredTargetSolution = targetSolution - targetSolution(:,1)*ones(1,size(targetSolution,2));
inLength = norm(centeredInSolution(:,1)-centeredInSolution(:,2));
targetLength = norm(centeredTargetSolution(:,1)-centeredTargetSolution(:,2));
scale0 = targetLength/inLength;
inVector = centeredInSolution(:,1)-centeredInSolution(:,2);
targetVector = centeredTargetSolution(:,1)-centeredTargetSolution(:,2);
dotProd = inVector'*targetVector;
cosTheta = dotProd/(inLength*targetLength);
temp = cross([inVector ; 0],[targetVector ; 0]);
theta0 = sign(temp(3))*acos(cosTheta)*180/pi;
translate0 = [0 0]';
initialMappedSolution0 = RotateScaleFlip(centeredInSolution,theta0,scale0,0) + (translate0 + targetSolution(:,1))*ones(1,size(targetSolution,2));
initialThetas0 = linspace(0,360,nTheta0);
if (SEARCH)
    minError = Inf;
    for i = 1:nTheta0
        %fprintf('Initial parameters %d: theta = %g, scale = %g, translate = %g, %g\n',i,initialThetas0(i),scale0,translate0(1),translate0(2));
        [thetaSearch,scaleSearch,translateSearch] = SearchRotateScale(initialThetas0(i),scale0,translate0,centeredInSolution,centeredTargetSolution,0);
        thetaTemp0(i) = thetaSearch;
        scaleTemp0(i) = scaleSearch;
        translateTemp0(:,i) = translateSearch;
        %fprintf('Final parameters %d: theta = %g, scale = %g, translate = %g, %g\n',i,thetaTemp0(i),scaleTemp0(i),translateTemp0(1,i),translateTemp0(2,i));
        mappedSolution0 = RotateScaleFlip(centeredInSolution,thetaTemp0(i),scaleTemp0(i),0) + (translateTemp0(i) + targetSolution(:,1))*ones(1,size(targetSolution,2));
        sumErrors0(i) = ComputeMapError(targetSolution,mappedSolution0);
        if (sumErrors0(i) < minError)
            minError = sumErrors0(i);
            minI = i;
        end
    end
    theta0 = thetaTemp0(minI);
    scale0 = scaleTemp0(minI);
    translate0 = translateTemp0(:,minI);
end
mappedSolution0 = RotateScaleFlip(centeredInSolution,theta0,scale0,0) + (translate0 + targetSolution(:,1))*ones(1,size(targetSolution,2));
sumError0 = ComputeMapError(targetSolution,mappedSolution0);
%fprintf('Non-flipped error = %g\n',sumError0);
% if (DEBUG)
%     figure; clf; hold on
%     plot(targetSolution(1,:),targetSolution(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
%     plot(initialMappedSolution0(1,:),initialMappedSolution0(2,:),'bx','MarkerFaceColor','b','MarkerSize',4);   
%     plot(mappedSolution0(1,:),mappedSolution0(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
%     axis('square');
% end

% Get initial guess for rotation: FLIP = 1
flipSolution = inSolution;
flipSolution(1,:) = -flipSolution(1,:);
centeredFlipSolution = flipSolution - flipSolution(:,1)*ones(1,size(flipSolution,2));
centeredTargetSolution = targetSolution - targetSolution(:,1)*ones(1,size(targetSolution,2));
inLength = norm(centeredFlipSolution(:,1)-centeredFlipSolution(:,2));
targetLength = norm(centeredTargetSolution(:,1)-centeredTargetSolution(:,2));
scale1 = targetLength/inLength;
inVector = centeredFlipSolution(:,1)-centeredFlipSolution(:,2);
targetVector = centeredTargetSolution(:,1)-centeredTargetSolution(:,2);
dotProd = inVector'*targetVector;
cosTheta = dotProd/(inLength*targetLength);
temp = cross([inVector ; 0],[targetVector ; 0]);
theta1 = sign(temp(3))*acos(cosTheta)*180/pi;
translate1 = [0 0]';
initialMappedSolution1 = RotateScaleFlip(centeredInSolution,theta1,scale1,1) + (translate1 + targetSolution(:,1))*ones(1,size(targetSolution,2));
initialThetas1 = linspace(0,360,nTheta1);
if (SEARCH)
    minError = Inf;
    for i = 1:nTheta1
        %fprintf('Initial parameters %d: theta = %g, scale = %g, translate = %g, %g\n',i,initialThetas1(i),scale1,translate1(1),translate1(2));
        [thetaSearch,scaleSearch,translateSearch] = SearchRotateScale(initialThetas1(i),scale1,translate1,centeredInSolution,centeredTargetSolution,1);
        thetaTemp1(i) = thetaSearch;
        scaleTemp1(i) = scaleSearch;
        translateTemp1(:,i) = translateSearch;
        %fprintf('Final parameters %d: theta = %g, scale = %g, translate = %g, %g\n',i,thetaTemp1(i),scaleTemp1(i),translateTemp1(1,i),translateTemp1(2,i));
        mappedSolution1 = RotateScaleFlip(centeredInSolution,thetaTemp1(i),scaleTemp1(i),1) + (translateTemp1(i) + targetSolution(:,1))*ones(1,size(targetSolution,2));
        sumErrors1(i) = ComputeMapError(targetSolution,mappedSolution1);
        if (sumErrors1(i) < minError)
            minError = sumErrors1(i);
            minI = i;
        end
    end
    theta1 = thetaTemp1(minI);
    scale1 = scaleTemp1(minI);
    translate1 = translateTemp1(:,minI);
end
mappedSolution1 = RotateScaleFlip(centeredInSolution,theta1,scale1,1) + (translate1 + targetSolution(:,1))*ones(1,size(flipSolution,2));

% See which way produces the smaller error
sumError1 = ComputeMapError(targetSolution,mappedSolution1);
% fprintf('Flipped error = %g\n',sumError1);
% if (DEBUG)
%     plot(mappedSolution1(1,:),mappedSolution1(2,:),'gx','MarkerFaceColor','b','MarkerSize',4);
%     axis('square');
% end

% Set output values
if (sumError0 < sumError1)
    mappedSolution = mappedSolution0;
    theta = theta0;
    scale = scale0;
    translate = translate0;
    FLIP = 0;
else
    mappedSolution = mappedSolution1;
    theta = theta1;
    scale = scale1;
    translate = translate1;
    FLIP = 1;
end