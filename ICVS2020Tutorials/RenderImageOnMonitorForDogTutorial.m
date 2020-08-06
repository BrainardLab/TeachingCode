% RenderImageOnMonitorForDogTutorial
%
% Render an RGB image as a metamer for a dichromat.  This tutorial builds
% on the ideas introduced in RenderSpectrumOnMonitorTutorial and
% RenderSpectrumOnMonitorForDogTutorial.
%
% In this version, you can control the metameric image you produce by
% changing the parameter lambda near the top.
%
% This tutorial is available in the github repository
%   https://github.com/BrainardLab/TeachingCode
% You can either clone the respository or just download a copy from
% that page (see green "Code" button).
%
% To run this, you will need both the Psychophysics Toolbox (PsychToolbox)
% and the BrainardLabToolbox on your path.  You can get the PsychToolbox
% from
%   psychtoolbox.org
% You can get the BrainardLabToolbox from
%   https://github.com/BrainardLab/BrainardLabToolbox
%
% If you use the ToolboxToolbox (https://github.com/toolboxhub/toolboxtoolbox)
% and install the TeachingCode repository in your projects folder, you can
% install the dependencies by using
%     tbUseProject('TeachingCode')
% at the Matlab prompt.
%
% You also need the calibration file NEC_MultisyncPA241W.mat, which is in
% the same directory as this script in the github respository.
%
% See also: RenderSpectrumOnMonitorTutorial, RenderSpectrumOnMonitorForDogTutorial

% History
%     08/03/2020  dhb  Wrote it.

%% Clear
clear; close all;

%% Parameters
%
% The lambda parameter governs how the red and green primary spectra are
% mixed to produce the "yellow" primary for the simulated two primary
% device.  Varying this will change the metameric image you produce.  This
% variable should stay between 0 and 1.
lambda = 0.7;

%% Load and examine a test calibration file
%
% These are measurements from an LCD monitor, with data stored in a
% structure that describes key monitor properties.
calData = load('NEC_MultisyncPA241W');
cal = calData.cals{end};
redPhosphor = cal.processedData.P_device(:,1);
greenPhosphor = cal.processedData.P_device(:,2);
bluePhosphor = cal.processedData.P_device(:,3);

% Get wavelength sampling of functions in cal file.
S = cal.rawData.S;
wls = SToWls(S);

% For simplicity, let's assume that no light comes off the monitor when the
% input is set to zero.  This isn't true for real monitors, but we don't
% need to fuss with that aspect at the start.  
cal.processedData.P_ambient = zeros(size(cal.processedData.P_ambient));

%% Load human cone spectral sensitivities
load T_cones_ss2
T_conesTrichrom = SplineCmf(S_cones_ss2,T_cones_ss2,S);

%% Get animal spectral sensitivities
%
% Here we use the dog, a dichromat.
%
% By convention in the Psychtoolbox, we store sensitivities as the rows of
% a matrix. Spline the wavelength sampling to match that in the calibration
% file.
%
% T_dogrec has the dog L cone, dog S cone, and dog rod in its three
% rows.  We only want the cones for high light level viewing.
load T_dogrec
T_conesDichrom = SplineCmf(S_dogrec,T_dogrec([1,2],:),S);

% If you want ground squirrel instead comment in these lines.  You could
% also set T_conesDichrom to some pair of the human LMS cones to generate
% metameric image for human dichromats.
% load T_ground
% T_conesDichrom = SplineCmf(S_dogrec,T_dogrec([1,2],:),S);

%% Get an image to render
%
% This one comes with Matlab, just need to map through the color lookup
% table in variable map to produce a full color image.
load mandrill
RGBImage = zeros(size(X,1),size(X,2),3);
for ii = 1:size(X,1)
    for jj = 1:size(X,2)
        RGBImage(ii,jj,:) = map(X(ii,jj),:);
    end
end
figure(1); imshow(RGBImage);

%% Ungamma correct the image
%
% Cal format strings out each pixel as a column in a 3 by n*m matrix.
% Convenient for color transformations. Put the image in cal format.
[RGBCal,m,n] = ImageToCalFormat(RGBImage);

% Inverse gamma correction to get rgb from RGB
rgbCal = zeros(size(RGBCal));
for ii = 1:m*n
    for cc = 1:3
       rgbCal(cc,ii) = SimpleGammaCorrection(cal.processedData.gammaTable(:,cc),cal.processedData.gammaInput,RGBCal(cc,ii));
    end
end

%% Get spectrum and LS coordinates from rgb
theSpectrumCal = cal.processedData.P_device*rgbCal;
theLSCal = T_conesDichrom*theSpectrumCal;

%% Make virtual two primary monitor and find yb values that produce metamers
%
% Use a controlable mixture of red and green, with parameter lambda
% determining how much of each.
monitorBasis = [lambda*redPhosphor+(1-lambda)*greenPhosphor bluePhosphor];
ybToLSMatrix = T_conesDichrom*monitorBasis;
LSToybMatrix = inv(ybToLSMatrix);
ybCal = LSToybMatrix*theLSCal;

%% Promote yb to rgb using our knowledge of how we built the primaries
% 
% Use lambda to determine ratio of red to green, to match the way we set up
% the combined phosphor.
rgbMetamerCal = [lambda*ybCal(1,:) ; (1-lambda)*ybCal(1,:) ; ybCal(2,:)];

%% Check that we get the desired LS excitations ro numerical precision
theLSCalCheck = T_conesDichrom*cal.processedData.P_device*rgbMetamerCal;
if (max(abs(theLSCal(:)-theLSCalCheck(:))) > 1e-10)
    error('Do not get desired LS values');
end

%% Gamma correct to get RGB for the metamer, convert back to image format, and display
RGBMetamerCal = zeros(size(RGBCal));
for ii = 1:m*n
    for cc = 1:3
       RGBMetamerCal(cc,ii) =  SimpleGammaCorrection(cal.processedData.gammaInput,cal.processedData.gammaTable(:,cc),rgbMetamerCal(cc,ii));
    end
end
RGBMetamerImage = CalFormatToImage(RGBMetamerCal,m,n);
figure(2);
imshow(RGBMetamerImage);

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
