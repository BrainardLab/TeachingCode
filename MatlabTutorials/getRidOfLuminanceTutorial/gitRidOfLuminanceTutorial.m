% gitRidOfLuminanceTutorial
%
% Demonstrate how to take an RGB image as input and zero out the luminance
% variation. Written for the Swingley lab, so they can reduce pupil
% response to movies they show subjects while recording changes in pupil
% to auditory events.
%
% This assumes that the input image is in sRGB format.  sRGB describes as
% standard for color monitors.  Not all monitors comply with this standard,
% but assuming this will almost surely reduce the luminance in the image.
% Since there is individual variation in what is known as isoluminance, 
% something approximate is about all you can do without heroic measures 
% in any case.
%
% Note that silencing luminance, even if done perfectly, will not
% completely eliminate pupil responses to image input.  There are transient
% responses to isoluminant changes in the stimulus, and in addition there
% is an input to the pupil from melanopsin cells.
%
% See http://en.wikipedia.org/wiki/SRGB for information on the sRGB
% standard.
%
% This routine requires the Psychophysics toolbox, which you may obtain
% free via http://psychtoolbox.org.
%
% It also uses some routines and a sample image from Matlab's image
% processing toolbox.  If you don't have that, I think all you need to
% do is delete the imwrite commands and supply your own input image.
%
% 10/22/14  dhb  Wrote it.

%% Clear, close
clear; close all;

%% Load in an rgb image.
% This one comes with the image processing toolbox.
% The code here assumes that the image values are
% specified as RGB numbers between 0 and 255.
inputRGBImage = imread('toysflash.png');
figure; imshow(inputRGBImage);
imwrite(inputRGBImage,'noLumInput.jpg','jpg');

%% Convert to "cal" format.
% "Cal" format is Brainard lab jargon and refers to a
% format where the image is specified as a 3 by (nX*nY) matrix.
% That is, each pixel is represented by one column of a matrix.
% This format allows efficient computation, becuase you can simply
% apply a color transformation matrix to the left hand side.
%
% This code also converts the image data into real numbers in the
% range 0-1, rather than integers in the range 0-255.
[inputRGBCal,nX,nY] = ImageToCalFormat(inputRGBImage);
gammaSRGBCal = double(inputRGBCal)/255;

%% Ungammacorrect the sRGB values
% This produces image values that are linear in the amount
% of light emitted from the display.  The sRGB standard incorporates
% gamma correction to account for the typical input-output non-linearity
% of display devices.  We undo this so as to do our calculations with
% respect to light, not input to a non-linear device.
SRGBPrimaryCal = SRGBGammaUncorrect(gammaSRGBCal);

%% Convert to XYZ
% XYZ is a standard colorimetric representation, and there
% is a well-defined transformation between sRGB and XYZ (once
% we have undone the gamma correction.
XYZCal = SRGBPrimaryToXYZ(SRGBPrimaryCal);

%% Convert to chromaticity/luminance representation.  This factors
% out luminance as a separate value in a representation where we
% can adjust luminance without changing chromatiicty.
xyYCal = XYZToxyY(XYZCal);
meanY = mean(xyYCal(3,:));

%% Find reasonable luminance to fill in.
% We do this by finding the luminance corresponding to linear input values of
% r=g=b=rgbTarget.  Then convert to xyY and extract.  I tuned the target
% value by hand to result in a reasonable tradeoff between the overall
% brightness of the output image and the number of pixels that needed to
% be clipped because they were out of gamut (such pixels will not be
% isoluminant with the rest.) The number of out of gamut pixels is 
% reported below.
rgbTarget = 0.2; 
midXYZ = SRGBPrimaryToXYZ([rgbTarget rgbTarget rgbTarget]');
midxyY = XYZToxyY(midXYZ);
useY = midxyY(3);
fprintf('Mean luminance of input: %0.2g, using %0.2g\n',meanY,useY);

%% Set luminance to a constant.
% Make this constant equal to the midpoint of the display.
xyYNoLumVarCal = xyYCal;
xyYNoLumVarCal(3,:) = useY;
XYZNoLumVarCal = xyYToXYZ(xyYNoLumVarCal);
SRGBPrimaryNoLumVarCal = XYZToSRGBPrimary(XYZNoLumVarCal);
fprintf('Output linear min val: %0.2g, max val %0.2g\n',min(SRGBPrimaryNoLumVarCal(:)),max(SRGBPrimaryNoLumVarCal(:)));
index = find(SRGBPrimaryNoLumVarCal > 1);
fprintf('Number out of gamut pixels %d out of %d\n',length(index),length(SRGBPrimaryNoLumVarCal(:)));

%% Gamma correct the linear values
SRGBPrimaryNoLumVarCal(SRGBPrimaryNoLumVarCal < 0) = 0;
SRGBPrimaryNoLumVarCal(SRGBPrimaryNoLumVarCal > 1) = 1;
SRGBGammaNoLumVarCal = uint8(SRGBGammaCorrect(SRGBPrimaryNoLumVarCal,0));

%% Convert back to an image representation and take a look
outputRGBImage = CalFormatToImage(SRGBGammaNoLumVarCal,nX,nY);
figure; imshow(outputRGBImage);
imwrite(outputRGBImage,'noLumOutput.jpg','jpg');
  

    
