function aperture = GenerateSoftCircularAperture(imageSize)
% aperture = GenerateSoftCircularAperture(imageSize)
%
% This function generates a soft circular aperture that is used to window the test images.
%
% 12/10/12  npc Wrote it.
% 12/13/12  npc Changed computation of soft border to decrease the width of
%               the transition area, and thus display more of the image
    
    x          = [-imageSize/2:imageSize/2-1] + 0.5;
    [X,Y]      = meshgrid(x,x);
    
    radius     = sqrt(X.^2 + Y.^2);
    softRadius = (imageSize/2)*0.9;
    softSigma  = (imageSize/2 - softRadius) / 3.0;
    delta      = radius - softRadius;
    
    aperture   = ones(size(delta));
    indices    = find(delta > 0);
    aperture(indices) = exp(-0.5*(delta(indices)/softSigma).^2);
    
end