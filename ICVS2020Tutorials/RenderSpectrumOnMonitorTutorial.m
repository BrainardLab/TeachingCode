% RenderSpectrumOnMonitorTutorial
%
% Exercise to learn about rendering metamers on a monitor.
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
% You also need the calibration file NEC_MultisyncPA241W.mat, which is in
% the same directory as this tutorial in the github respository.
%
% 08/01/2020  dhb  Wrote for ICVS from other tutorials that weren't quite
%                  what we wanted.

%% Clear
clear; close all;

%% Load and examine a test calibration file
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

%% Plot the spectra of the three monitor primaries.
%
% For this monitor each primary is determined by the emission spectra of
% one of the phosphors on its faceplate, but that's a detail. Whwat we care
% about are the spectra, not how they were instrumented physically.
%
% Each primary spectrum is in a separate column of the matrix cal.processedData.P_device.
% In MATLAB,can use the : operator to help extract various pieces of a
% matrix.  So:
redPhosphor = cal.processedData.P_device(:,1);
greenPhosphor = cal.processedData.P_device(:,2);
bluePhosphor = cal.processedData.P_device(:,3);
figure(1);clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
plot(wls,redPhosphor,'r','LineWidth',3);
plot(wls,greenPhosphor,'g','LineWidth',3);
plot(wls,bluePhosphor,'b','LineWidth',3);
title( 'Monitor channel spectra','FontSize',24);
xlabel( 'Wavelength [ nm ]','FontSize',24); ylabel( 'Radiance [ W / m^2 / sr / wlbin ]','FontSize',24);
hold off

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

% Make a plot
figure(2); clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
plot(wls,T_cones(1,:),'r','LineWidth',3);
plot(wls,T_cones(2,:),'g','LineWidth',3);;
plot(wls,T_cones(3,:),'b','LineWidth',3);
title( 'LMS Cone Fundamentals','FontSize',24);
xlabel( 'Wavelength','FontSize',24); ylabel( 'Sensitivity','FontSize',24);
hold off

%% Get a spectrum to render
%
% We want to render a spectrum on the monitor so that the light coming off the monitor has
% the same effect on the human cones as the spectrum would have.  So we
% need a spectrum.  We'll CIE daylight D65, since we have it available.
%
% The spectrum we read in is too bright to render on our monitor, so we
% also scale it down into a more reasonable range so we don't have to worry
% about that below.
load spd_D65
spectrumToRender = SplineSpd(S_D65,spd_D65,S)/0.75e4;

% If you want a different spectrum, this is operation on the D65
% produces a spectrum with more long wavelenght power and that renders
% pinkish.
% spectrumToRender = 1.5*max(spectrumToRender(:))*ones(size(spectrumToRender))-spectrumToRender;

% Make a plot of the spectrum to render
figure(3); clf; hold on
plot(wls,spectrumToRender,'k','LineWidth',3);
title('Metamers','FontSize',24);
xlabel('Wavelength','FontSize',24); ylabel( 'Power','FontSize',24);

%% Compute the cone excitations from the spectrum we want to render
%
% This turns out to be a simple matrix multiply in Matlab.  The
% sensitivities are in the rows of T_cones and the spectral radiance is in
% the column vector spectrumToRender.  For each row of T_cones, the matrix
% multiple consists of weighting the spectrum by the sensitivity at each
% wavelength and adding them up.
%
% Implicit here is that the units of spectrum give power per wavelength
% sampling bin, another important detail you'd want to think about to get
% units right for a real application and that we won't worry about here.
LMSToRender = T_cones*spectrumToRender;

%% We want to find a mixture of the monitor primaries that produces the same excitations
%
% Let's use the column vector [r g b]' to denote the amount of each primary
% we'll ultimately want in the mixture.  By convention we'll think of r, g,
% and b as proportions relative to the maximum amount of each phosphor
% available on the monitor.
%
% It might be useful to make a plot of the example spectrum and see that it
% indeed looks like a mixture of the primary spectra.
rgbExample = [0.2 0.5 0.9]';
monitorSpectrumExample = rgbExample(1)*redPhosphor + rgbExample(2)*greenPhosphor + rgbExample(3)*bluePhosphor;

% We can also compute the spectrum coming off the monitor for any choice of r,
% g, and b using a matrix multiply.  In this case, think of the
% multiplication as weighting each of the columns of cal.processedData.P_device (which
% are the primary spectra) and then summing them.  You can verify that this
% gives the same answer as the expanded form just above.
monitorSpectrumExampleCheck = cal.processedData.P_device*rgbExample;

% We can also compute the LMS cone excitations for this example.  This is
% just a column vector of three numbers.
monitorLMSExample = T_cones*monitorSpectrumExample;

% Now note that we can combine the two steps above, precomputing the matrix
% that maps between the rgb vector and the LMS excitations that result.
%
% You can verify that monitorLMSExample and monitorLMSExampleCheck are the
% same as each other.
rgbToLMSMatrix = T_cones*cal.processedData.P_device;
monitorLMSExampleCheck = rgbToLMSMatrix*rgbExample;

% We want to go the other way, starting with LMSToRender and obtaining an
% rgb vector that produces it.  This is basically inverting the relation
% above, which is easy in Matlab.
LMSTorgbMatrix = inv(rgbToLMSMatrix);
rgbThatRender = LMSTorgbMatrix*LMSToRender;

% Let's check that it worked.  The check values here should be the same as
% LMSToRender.
renderedSpectrum = cal.processedData.P_device*rgbThatRender;
LMSToRenderCheck = T_cones*renderedSpectrum;

% Add rendered spectrum to plot of target spectrum. You can see that they
% are of the same overall scale but differ in relative spectra.  These two
% spectra are metamers - they produce the same excitations in the cones and
% will look the same to a human observer.
figure(3);
plot(wls,renderedSpectrum,'k:','LineWidth',3);

%% Make an image that shows the color
%
% We know the proportions of each of the monitor primaries required to
% produce a metamer to the spectrum we wanted to render.  Now we'd like to
% look at this rendered spectrum.  We have to assume that the properties of
% the monitor we're using are the same as the one in the calibration file,
% which isn't exactly true but will be close enough for illustrative
% purposes.

% What we need to do is find RGB values to put in the image so that we get
% the desired rgb propotions in the mixture that comes off.  This is a
% little tricky, because the relation between the RGB values we put into an
% image and the rgb values that come off is non-linear.  This non-linearity
% is called the gamma curve of the monitor, and we have to correct for it,
% a process known as gamma correction.

% As part of the monitor calibration, we meausured the gamma curves of our
% monitor, and they are in the calibration structure.  Let's have a look
figure(4); clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
gammaInput = cal.processedData.gammaInput;
redGamma = cal.processedData.gammaTable(:,1);
greenGamma = cal.processedData.gammaTable(:,2);
blueGamma = cal.processedData.gammaTable(:,3);
plot(gammaInput,redGamma,'r','LineWidth',3);
plot(gammaInput,greenGamma,'g','LineWidth',3);
plot(gammaInput,blueGamma,'b','LineWidth',3);
title( 'Monitor gamma curves','FontSize',24);
xlabel( 'Input RGB','FontSize',24); ylabel( 'Mixture rgb','FontSize',24);

% We need to invert this curve - for each of our desired rgb values we need
% to find the corresponding RGB. That's not too hard, we can just do
% exhasutive search. This is done here in a little subfunction called
% SimpleGammaCorrection at the bottom of this file.
nLevels = length(gammaInput);
R = SimpleGammaCorrection(gammaInput,redGamma,rgbThatRender(1));
G = SimpleGammaCorrection(gammaInput,greenGamma,rgbThatRender(2));
B = SimpleGammaCorrection(gammaInput,blueGamma,rgbThatRender(3)); 
RGBThatRender = [R G B]';

% Make an and show the color image. We get (on my Apple Display) a slightly
% bluish gray, which is about right for D65 given that we aren't using a
% calibration of this display.
nPixels = 256;
theImage = zeros(nPixels,nPixels,3);
for ii = 1:nPixels
    for jj = 1:nPixels
        theImage(ii,jj,:) = RGBThatRender;
    end
end
figure(5);
imshow(theImage);

%% Go from RGB back to the spectrum coming off the monitor
%
% There will be a very small difference between rgbFromRGB and
% rgbThatRender because the gamma correction quantizes the RGB
% values to discrete levels. 
rgbFromRGB(1) = SimpleGammaCorrection(redGamma,gammaInput,RGBThatRender(1));
rgbFromRGB(2) = SimpleGammaCorrection(greenGamma,gammaInput,RGBThatRender(2));
rgbFromRGB(3) = SimpleGammaCorrection(blueGamma,gammaInput,RGBThatRender(3));
rgbFromRGB = rgbFromRGB';
spectrumFromRGB = cal.processedData.P_device*rgbFromRGB;
figure(3);
plot(wls,spectrumFromRGB,'r:','LineWidth',2);

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