% ColourCamouflageImageTutorial
%
% Example code to colour a 3-colour image with dichromat confusion colours 
% for use in camouflage example.
%
% To run this, you will need both the Psychophysics Toolbox (PsychToolbox)
% and the BrainardLabToolbox on your path.  You can get the PsychToolbox
% from
%   psychtoolbox.org
% You can get the BrainardLabToolbox from
%   https://github.com/BrainardLab/BrainardLabToolbox
%
% You also need the kmeans_fast_Color function from Matlab Central
%   https://uk.mathworks.com/matlabcentral/fileexchange/44598-fast-kmeans-algorithm-code?s_tid=mwa_osa_a
%
% If you use the ToolboxToolbox (https://github.com/toolboxhub/toolboxtoolbox)
% and install the TeachingCode repository in your projects folder, you can
% install the above dependencies by using
%    tbUseProject('TeachingCode')
% at the Matlab prompt.
%
% You also need the calibration file NEC_MultisyncPA241W.mat and the image
% animal-silhouette-squirrel.jpg which are in the same directory as this
% tutorial in the TeachingCode github respository.
%
% Before running this, you may want to become familiar with
% RenderSpectrumOnMonitorTutorial.
%
% See also: RenderSpectrumOnMonitorTutorial.

% History:
%   Written 04/08/2020 (that's 08/04/2020 for Americans) by Hannah Smithson
%                      using example code from the RenderSpectrumOnMonitorTutorial
%   08/06/20  dhb      Some commenting.

%% Clear old variables, and close figure windows
clear; close all;

%% Set some key parameters
rgbBackground = [0.2 0.2 0.0]';                 % for a 'natural looking' image, choose a brown background
coneContrastsForTarget = [1.4 1.4 1.4];         % triplet specifying multiplier on the background LMS (e.g. [1.2, 1.0, 1.0] is 20% L-cone contrast)
coneContrastsForCamouflage = [1.3 0.7 1.0];     % triplet specifying multiplier on the background LMS (e.g. [1.2, 1.0, 1.0] is 20% L-cone contrast) 

numberOfCamoBlobs = 700;                        % specify the number of "camouflage" blobs
numberOfIntensityBlobs = 300;                   % specify the number of blobs used to add intensity variation

sizeScaleFactorCamo = 0.03;                     % size of blobs (fraction of image width)
sizeScaleFactorIntensity = 0.05;

%% Load and a test calibration file
%
% These are measurements from an LCD monitor, with data stored in a
% structure that describes key monitor properties.
calData = load('NEC_MultisyncPA241W');
cal = calData.cals{end};

% Get wavelength sampling of functions in cal file.
S = cal.rawData.S;
wls = SToWls(S);

% For simplicity, let's assume that no light comes off the monitor when the
% input is set to zero.  This isn't true for real monitors, but we don't
% need to fuss with that aspect at the start.  
cal.processedData.P_ambient = zeros(size(cal.processedData.P_ambient));

%% Get human cone spectral sensitivities
%
% Here we use the Stockman-Sharpe 2-degree fundamentals, which are also the
% CIE fundamentals.  They are stored as a .mat file in the Psychophysics
% Toolbox.  See "help PsychColorimetricMatFiles'.
%
% By convention in the Psychtoolbox, we store sensitivities as the rows of
% a matrix. Spline the wavelength sampling to match that in the calibration
% file.
load T_cones_ss2
T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);

%% We want to find a mixture of the monitor primaries that produces a given LMS excitation
%
% Use the calibration data to generate the rgbToLMSMatrix
% (more info available in RenderSpectrumOnMonitor tutorial)
%
% We use the column vector [r g b]' to denote the amount of each primary
% we'll ultimately want in the mixture.  By convention we'll think of r, g,
% and b as proportions relative to the maximum amount of each phosphor
% available on the monitor.
rgbToLMSMatrix = T_cones*cal.processedData.P_device;
lmsBackground = rgbToLMSMatrix*rgbBackground;

% Now set an LMS triplet for the "figure", which differs from the ground
% only in L-cone excitation - a 20% increase in L-cone excitation
lmsTarget = coneContrastsForTarget' .* lmsBackground;
lmsCamouflage = coneContrastsForCamouflage' .* lmsBackground;

% We want to go the other way, starting with lmsFigure and obtaining an
% rgb vector that produces it.  This is basically inverting the relation
% above, which is easy in Matlab.
LMSTorgbMatrix = inv(rgbToLMSMatrix);
rgbTarget = LMSTorgbMatrix*lmsTarget;
rgbCamouflage = LMSTorgbMatrix*lmsCamouflage;

%% Make an image that shows the three colors - background, target and camouflage
%
% What we need to do is find RGB values to put in the image so that we get
% the desired rgb propotions in the mixture that comes off.  This is a
% little tricky, because the relation between the RGB values we put into an
% image and the rgb values that come off is non-linear.  This non-linearity
% is called the gamma curve of the monitor, and we have to correct for it,
% a process known as gamma correction.
RGBBackground = GammaCorrectionForTriplet(rgbBackground, cal);
RGBTarget = GammaCorrectionForTriplet(rgbTarget, cal);
RGBCamouflage = GammaCorrectionForTriplet(rgbCamouflage, cal);

nPixels = 256;
theImageBackground = cat(3, ones(nPixels)*RGBBackground(1), ones(nPixels)*RGBBackground(2), ones(nPixels)*RGBBackground(3));
theImageTarget = cat(3, ones(nPixels)*RGBTarget(1), ones(nPixels)*RGBTarget(2), ones(nPixels)*RGBTarget(3));
theImageCamouflage = cat(3, ones(nPixels)*RGBCamouflage(1), ones(nPixels)*RGBCamouflage(2), ones(nPixels)*RGBCamouflage(3));
figure;
imshow(cat(1, theImageBackground, theImageTarget, theImageCamouflage));

%% Make a more naturalistic image of camouflaged targets
%
% Read in a binary black and white image
A = imread('animal-silhouette-squirrel.jpg'); % white = background; black = target
imW = size(A, 1);
imH = size(A, 2);

% Show the original image
figure
imagesc(A)

%% Convert the white to grey and add camo blobs
A = 0.5 * A; 
for i = 1:numberOfCamoBlobs
    A = insertShape(A,'FilledCircle',[imH*rand(1), imW*rand(1), sizeScaleFactorCamo*imW*rand(1)], 'Color', 'white','Opacity',1.0);
end

% Show the grey scale image with blobs
figure
imshow(A)

% If the original image has smoothing or compression, cluster 3 pixel values
[threeColImage,vec_mean] = kmeans_fast_Color(A, 3);

% Make a colour map from the colours we defined
map = cat(1, RGBTarget, RGBBackground, RGBCamouflage); 
figure
imshow(threeColImage, map);

% Add intensity noise to true colour image
A = ind2rgb(threeColImage, map);
for i = 1:numberOfIntensityBlobs
    A = insertShape(A,'FilledCircle',[imH*rand(1), imW*rand(1), sizeScaleFactorIntensity*imW*rand(1)], 'Color', 'black','Opacity',0.1);
end
figure
imshow(A)


function useRGB = GammaCorrectionForTriplet(desiredrgb, cal)

% As part of the monitor calibration, we meausured the gamma curves of our
% monitor, and they are in the calibration structure.  Let's have a look
gammaInput = cal.processedData.gammaInput;
redGamma = cal.processedData.gammaTable(:,1);
greenGamma = cal.processedData.gammaTable(:,2);
blueGamma = cal.processedData.gammaTable(:,3);

% We need to invert this gamma curve - for each of our desired rgb values we need
% to find the corresponding RGB. That's not too hard, we can just do
% exhasutive search. This is done here in a little subfunction called
% SimpleGammaCorrection at the bottom of this file.
R = SimpleGammaCorrection(gammaInput,redGamma,desiredrgb(1));
G = SimpleGammaCorrection(gammaInput,greenGamma,desiredrgb(2));
B = SimpleGammaCorrection(gammaInput,blueGamma,desiredrgb(3)); 
useRGB = [R G B];

end

function output = SimpleGammaCorrection(gammaInput,gamma,input)
% output = SimpleGammaCorrection(gammaInput,gamma,input)
%
% Perform gamma correction by exhaustive search.  Just to show idea,
% not worried about efficiency.
%
% 9/14/08  ijk  Wrote it.
% 12/2/09  dhb  Update for [0,1] input table.
% 08/01/20 dhb  Get rid of extraneous input variable

min_diff = Inf;
for i=1:length(gammaInput)
    currentdiff = abs(gamma(i)-input);
    if(currentdiff < min_diff)
        min_diff = currentdiff;
        output = i;
    end
end
output = gammaInput(output);

end
