function outData = RotateScaleFlip(inData,theta,alpha,FLIP)
% outData = RotateScaleFlip(inData,theta,alpha,FLIP)
%
% Take the two dimensional data (in the columns of inData)
% and rotate it anti-clockwise through theta, scale by alpha,
% and flip wrt x axis if FLIP = 1.  (Flip is actually applied
% first.
%
% Input theta in degrees.
%
% 10/11/05  dhb, scm    Wrote it.

% Flip if specified
if (FLIP)
    inData(1,:) = -inData(1,:);
end

% Rotate.  First convert to spherical coordinates
[inTheta,inPhi,inR] = cart2sph(inData(1,:),inData(2,:),zeros(size(inData(1,:))));

% Add theta to inTheta
outTheta = inTheta+pi*theta/180;
outPhi = inPhi;

% Scale R
outR = alpha*inR;

% Convert back to cartesian
[outX,outY,outZ] = sph2cart(outTheta,outPhi,outR);

% Put together the output data
outData = [outX ; outY];

