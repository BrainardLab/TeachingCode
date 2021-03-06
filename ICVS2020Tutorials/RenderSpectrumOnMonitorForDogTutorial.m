% RenderSpectrumOnMonitorForDogTutorial
%
% Exercise to learn about rendering metamers on a monitor. This version is
% for a dichromat.  As an example, we'll use the cone spectral
% sensitivities of the dog.
%
% Before working through this tutorial, you should work through the
% tutorial RenderSpectrumOnMonitorTutorial.  After you understand this one,
% you can look at RenderImageOnMonitorForDogTutorial, which applies the
% idea to render images rather than a single spectrum.
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
% the same directory as this tutorial in the github respository.
%
% See also: RenderSpectrumOnMonitorTutorial, RenderImageOnMonitorForDogTutorial

% History:
%    08/02/2020  dhb  Wrote for ICVS from other tutorials that weren't quite
%                     what we wanted.

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
T_cones = SplineCmf(S_dogrec,T_dogrec([1,2],:),S);
load T_cones_ss2
T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);
T_cones = T_cones([1,3],:);

% Make a plot
figure(2); clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
plot(wls,T_cones(1,:),'r','LineWidth',3);
plot(wls,T_cones(2,:),'b','LineWidth',3);
title( 'LS Cone Fundamentals','FontSize',24);
xlabel( 'Wavelength','FontSize',24); ylabel( 'Sensitivity','FontSize',24);
hold off

%% Get a spectrum to render
%
% We want to render a spectrum on the monitor so that the light coming off
% the monitor has the same effect on the human cones as the spectrum would
% have.  So we need a spectrum.  We'll use a spectrum computed from CIE D65
% that renders pinkish for a human. (See alternate spectrum in
% RenderSpectrumOnMonitorTutorial).
load spd_D65
spectrumToRender = SplineSpd(S_D65,spd_D65,S)/0.75e4;
spectrumToRender = 1.5*max(spectrumToRender(:))*ones(size(spectrumToRender))-spectrumToRender;

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
LSToRender = T_cones*spectrumToRender;

%% We want to find a mixture of the monitor primaries that produces the same excitations
%
% Since there are only two primaries needed, we'll average the red and green
% and treat that as a yellow primary.
%
% Let's use the column vector [y b]' to denote the amount of each primary
% we'll ultimately want in the mixture.  By convention we'll think of y
% and b as proportions relative to the maximum amount of each primary
% available on the monitor.
%
% It might be useful to make a plot of the example spectrum and see that it
% indeed looks like a mixture of the primary spectra.
ybExample = [0.2 0.5]';
monitorSpectrumExample = ybExample(1)*(redPhosphor+greenPhosphor)/2 + ybExample(2)*bluePhosphor;

% We can also compute the spectrum coming off the monitor for any choice of
% y and b using a matrix multiply.  In this case, think of the
% multiplication as weighting each of the columns of monitorBasis (defined
% below) and then summing them.  You can verify that this gives the same
% answer as the expanded form just above.
monitorBasis = [(redPhosphor+greenPhosphor)/2 bluePhosphor];
monitorSpectrumExampleCheck = monitorBasis*ybExample;

% We can also compute the LMS cone excitations for this example.  This is
% just a column vector of three numbers.
monitorLMSExample = T_cones*monitorSpectrumExample;

% Now note that we can combine the two steps above, precomputing the matrix
% that maps between the rgb vector and the LS excitations that result.
%
% You can verify that monitorLMSExample and monitorLMSExampleCheck are the
% same as each other.
ybToLSMatrix = T_cones*monitorBasis;
monitorLMSExampleCheck = ybToLSMatrix*ybExample;

% We want to go the other way, starting with LSToRender and obtaining an
% rgb vector that produces it.  This is basically inverting the relation
% above, which is easy in Matlab.
LSTorgbMatrix = inv(ybToLSMatrix);
ybThatRender = LSTorgbMatrix*LSToRender;

% Let's check that it worked.  The check values here should be the same as
% LMSToRender.
renderedSpectrum = monitorBasis*ybThatRender;
LSToRenderCheck = T_cones*renderedSpectrum;

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

% We need to convert our yb values to rgb values at this point. But that's
% easy r = g = y/2.
rgbThatRender = [ybThatRender(1)/2 ybThatRender(1)/2 ybThatRender(2)]';

% Check that this rgb does what we want
renderedSpectrum1 = cal.processedData.P_device*rgbThatRender;
LSToRenderCheck1 = T_cones*renderedSpectrum1;

% Then we invert the RGB gamma curve - for each of our desired rgb values we need
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