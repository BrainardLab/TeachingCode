% threeScreenCalTutorial
%
% Show how to equalize light level, chromaticity, and contrast
% across three (!) calibrated screens.
%
% Wrote this to illustrate how to do it for our dog behavior
% experiments, where we actually have three separate screens.
%
% Based on Psychtoolbox CalDemo.m
%
% 5/29/09  dhb  Wrote it.

% Clear
clear; close all

%% Load the three calibration files
cal1 = LoadCalFile('DogScreen1Lights');
cal2 = LoadCalFile('DogScreen2Lights');
cal3 = LoadCalFile('DogScreen3Lights');

%% Plot what is in the calibration files, spectra
wls = SToWls(cal1.S_device);
figure; clf;
subplot(1,3,1); hold on
plot(wls,cal1.P_device(:,1),'r');
plot(wls,cal1.P_device(:,2),'g');
plot(wls,cal1.P_device(:,3),'b');
xlabel('Wavelength (nm)');
ylabel('Power');
title('Device Primary Spectra');
axis('square');
subplot(1,3,2); hold on
plot(wls,cal2.P_device(:,1),'r');
plot(wls,cal2.P_device(:,2),'g');
plot(wls,cal2.P_device(:,3),'b');
xlabel('Wavelength (nm)');
ylabel('Power');
title('Device Primary Spectra');
axis('square');
subplot(1,3,3); hold on
plot(wls,cal3.P_device(:,1),'r');
plot(wls,cal3.P_device(:,2),'g');
plot(wls,cal3.P_device(:,3),'b');
xlabel('Wavelength (nm)');
ylabel('Power');
title('Device Primary Spectra');
axis('square');

%% Plot what is in the calibration files, gamma functions
figure; clf;
subplot(1,3,1); hold on
plot(cal1.gammaInput,cal1.gammaTable(:,1),'r');
plot(cal1.rawdata.rawGammaInput,cal1.rawdata.rawGammaTable(:,1),'ro','MarkerFaceColor','r','MarkerSize',3);
plot(cal1.gammaInput,cal1.gammaTable(:,2),'g');
plot(cal1.rawdata.rawGammaInput,cal1.rawdata.rawGammaTable(:,2),'go','MarkerFaceColor','g','MarkerSize',3);
plot(cal1.gammaInput,cal1.gammaTable(:,3),'b');
plot(cal1.rawdata.rawGammaInput,cal1.rawdata.rawGammaTable(:,3),'bo','MarkerFaceColor','b','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');
subplot(1,3,2); hold on
plot(cal2.gammaInput,cal2.gammaTable(:,1),'r');
plot(cal2.rawdata.rawGammaInput,cal2.rawdata.rawGammaTable(:,1),'ro','MarkerFaceColor','r','MarkerSize',3);
plot(cal2.gammaInput,cal2.gammaTable(:,2),'g');
plot(cal2.rawdata.rawGammaInput,cal2.rawdata.rawGammaTable(:,2),'go','MarkerFaceColor','g','MarkerSize',3);
plot(cal2.gammaInput,cal2.gammaTable(:,3),'b');
plot(cal2.rawdata.rawGammaInput,cal2.rawdata.rawGammaTable(:,3),'bo','MarkerFaceColor','b','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');
subplot(1,3,3); hold on
plot(cal3.gammaInput,cal3.gammaTable(:,1),'r');
plot(cal3.rawdata.rawGammaInput,cal3.rawdata.rawGammaTable(:,1),'ro','MarkerFaceColor','r','MarkerSize',3);
plot(cal3.gammaInput,cal3.gammaTable(:,2),'g');
plot(cal3.rawdata.rawGammaInput,cal3.rawdata.rawGammaTable(:,2),'go','MarkerFaceColor','g','MarkerSize',3);
plot(cal3.gammaInput,cal3.gammaTable(:,3),'b');
plot(cal3.rawdata.rawGammaInput,cal3.rawdata.rawGammaTable(:,3),'bo','MarkerFaceColor','b','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');

% Initialize color space and gamma method for the calibraiton files
load T_xyz1931
T_xyz = 683*T_xyz1931;
cal1 = SetSensorColorSpace(cal1,T_xyz,S_xyz1931);
cal2 = SetSensorColorSpace(cal2,T_xyz,S_xyz1931);
cal3 = SetSensorColorSpace(cal3,T_xyz,S_xyz1931);
cal1 = SetGammaMethod(cal1,1);
cal2 = SetGammaMethod(cal2,1);
cal3 = SetGammaMethod(cal3,1);

%% Compute and print min, mid, and max XYZ settings.  In general
% the calibration structure records the ambient light so
% that the min output is not necessarily zero light.
minXYZ1 = PrimaryToSensor(cal1,[0 0 0]'); minxyY1 = XYZToxyY(minXYZ1);
midXYZ1 = PrimaryToSensor(cal1,[0.5 0.5 0.5]'); midxyY1 = XYZToxyY(midXYZ1);
maxXYZ1 = PrimaryToSensor(cal1,[1 1 1]'); maxxyY1 = XYZToxyY(maxXYZ1);
minXYZ2 = PrimaryToSensor(cal2,[0 0 0]'); minxyY2 = XYZToxyY(minXYZ2);
midXYZ2 = PrimaryToSensor(cal2,[0.5 0.5 0.5]'); midxyY2 = XYZToxyY(midXYZ2);
maxXYZ2 = PrimaryToSensor(cal2,[1 1 1]'); maxxyY2 = XYZToxyY(maxXYZ2);
minXYZ3 = PrimaryToSensor(cal3,[0 0 0]'); minxyY3 = XYZToxyY(minXYZ3);
midXYZ3 = PrimaryToSensor(cal3,[0.5 0.5 0.5]'); midxyY3 = XYZToxyY(midXYZ3);
maxXYZ3 = PrimaryToSensor(cal3,[1 1 1]'); maxxyY3 = XYZToxyY(maxXYZ3);
fprintf('Device properties expressed as x, y, Y\n');
fprintf('\tMin 1 xyY = %0.3g, %0.3g, %0.2f\n',minxyY1(1),minxyY1(2),minxyY1(3));
fprintf('\tMid 1 xyY = %0.3g, %0.3g, %0.2f\n',midxyY1(1),midxyY1(2),midxyY1(3));
fprintf('\tMax 1 xyY = %0.3g, %0.3g, %0.2f\n',maxxyY1(1),maxxyY1(2),maxxyY1(3));
fprintf('\tMin 2 xyY = %0.3g, %0.3g, %0.2f\n',minxyY2(1),minxyY2(2),minxyY2(3));
fprintf('\tMid 2 xyY = %0.3g, %0.3g, %0.2f\n',midxyY2(1),midxyY2(2),midxyY2(3));
fprintf('\tMax 2 xyY = %0.3g, %0.3g, %0.2f\n',maxxyY2(1),maxxyY2(2),maxxyY2(3));
fprintf('\tMin 3 xyY = %0.3g, %0.3g, %0.2f\n',minxyY3(1),minxyY3(2),minxyY3(3));
fprintf('\tMid 3 xyY = %0.3g, %0.3g, %0.2f\n',midxyY3(1),midxyY3(2),midxyY3(3));
fprintf('\tMax 3 xyY = %0.3g, %0.3g, %0.2f\n',maxxyY3(1),maxxyY3(2),maxxyY3(3));

%% Figure out which monitor is the most limiting in terms of overall
% intensity, and use that information to set the target background_XYZ

% First step, find mean chromaticity and luminance of mid point across all
% three monitors, and convert to linear rgb values.
meanXYZ = mean([midXYZ1 midXYZ2 midXYZ3],2);
avg_rgb1 = SensorToPrimary(cal1,meanXYZ);
avg_rgb2 = SensorToPrimary(cal2,meanXYZ);
avg_rgb3 = SensorToPrimary(cal3,meanXYZ);

% Second find the maximum of the linear rgb values, and scale the
% mean mid point so that the maximum linear rgb for the scaled version
% is the targetMidLinearRGB.
%
% You might think the natural value to use
% for the target is 0.5, but monitors tend to dim over time, so using
% a slightly lower value (e.g. 0.45) leaves some room to compensate for
% this over time when the monitor is recalibrated.  Everything else
% below is calculated with respect to what's in background_XYZ, so in
% fact the exact choice doesn't matter all that much.
targetMidLinearRGB = 0.45;
maxOfAll_rgb = max([avg_rgb1 ; avg_rgb2 ; avg_rgb3]);
background_XYZ = targetMidLinearRGB/maxOfAll_rgb*meanXYZ;
background_xyY = XYZToxyY(background_XYZ);

%% Find linear rgb values required to make each monitor have the
% the desired background_XYZ values.  Also compute the gamma
% corrected RGB values and verify by the inverse call that
% we in fact predict the same output for each monitor when
% we use its computed RGB values.
background_rgb1 = SensorToPrimary(cal1,background_XYZ);
background_rgb2 = SensorToPrimary(cal2,background_XYZ);
background_rgb3 = SensorToPrimary(cal3,background_XYZ);
background_RGB1 = SensorToSettings(cal1,background_XYZ);
background_RGB2 = SensorToSettings(cal2,background_XYZ);
background_RGB3 = SensorToSettings(cal3,background_XYZ);
background_XYZ1 = SettingsToSensor(cal1,background_RGB1);
background_XYZ2 = SettingsToSensor(cal2,background_RGB2);
background_XYZ3 = SettingsToSensor(cal3,background_RGB3);
fprintf('Monitor 1 background XYZ computed from settings: %0.3g, %0.3g, %0.3g\n',...
    background_XYZ1(1),background_XYZ1(2),background_XYZ1(3));
fprintf('Monitor 2 background XYZ computed from settings: %0.3g, %0.3g, %0.3g\n',...
    background_XYZ2(1),background_XYZ2(2),background_XYZ2(3));
fprintf('Monitor 3 background XYZ computed from settings: %0.3g, %0.3g, %0.3g\n',...
    background_XYZ3(1),background_XYZ3(2),background_XYZ3(3));

%% Figure out maximum contrast luminance modulation
% available across the monitors.  This is a bit subtle,
% because to do it right you need to make sure to account
% for the ambient light, which may have a chromaticity 
% different from that of the background.  The code below
% accomlishes the trick.

% Here we compute for each monitor the target_XYZ values you'd
% need for the high side of a 100% contrast modulation.  Then
% we find the change in linear rgb values for each monitor needed to 
% acheive this. There is no guarantee that when added to the background
% this modulation leads to rgb values that are in
% the gamut of the monitor.
%
% Thus the fiendishly clever routine
% MaximizeGamutContrast figures out just how far you can go 
% in the modulation direction to get right to the edge of the gamut.
% The computation checks in both the positive and negative modulation
% directions.
%
% Because the modulation passed to MaximizeGamutContrast
% corresponds to a 100% contrast modulation (i.e. contrat of 1), the
% returned scalars are in units of contrast.  We take the maximum
% over the three monitors.  This is as much as we can get while still
% keeping all monitors identical in what they do.
target_XYZ = background_XYZ+background_XYZ;             
target_rgb1 = SensorToPrimary(cal1,target_XYZ);
direction_rgb1 = target_rgb1-background_rgb1;
gamutScalar1 = MaximizeGamutContrast(direction_rgb1,background_rgb1);
target_rgb2 = SensorToPrimary(cal2,target_XYZ);
direction_rgb2 = target_rgb2-background_rgb2;
gamutScalar2 = MaximizeGamutContrast(direction_rgb2,background_rgb2);
target_rgb3 = SensorToPrimary(cal3,target_XYZ);
direction_rgb3 = target_rgb3-background_rgb3;
gamutScalar3 = MaximizeGamutContrast(direction_rgb3,background_rgb3);
maxContrast = min([gamutScalar1 gamutScalar2 gamutScalar3]);
fprintf('Maximum available contrast across monitors is %0.2g\n',maxContrast);

%% Illustrate how to compute settings values that produce a desired
% luminance contrast around backgroundXYZ.  The same compuations
% could be used to produce the RGB values you need for each pixel
% on each frame for spatio-temporal contrast modulations.
%
% Note that in real code, as opposed to a tutorial, you'd
% probably encapsulate the code that is repeated below for
% each monitor a callable function.
targetContrast = 0.80;
if (targetContrast > maxContrast)
    fprintf('Oops, asking for too much contrast');
end

% First step, find the two ends of the modulation in XYZ.  This
% easy, and here done same for each monitor.  You could take
% the DAC quantization of each monitor into account, if you want
% to.
minModulationXYZ = background_XYZ-targetContrast*background_XYZ;
maxModulationXYZ = background_XYZ+targetContrast*background_XYZ;

% Now compute gamma corrected RGB settings separately for each monitor that produce
% the desired min and max modulation XYZ values.  The print
% statements show the RGB settings and also the contrast seen for X, Y, and
% Z. For a luminance modulation, the three contrast numbers printed for
% each monitor should be the same and should match the target contrast.
% The settings used for each monitor however, will in general differ.
%
% Monitor 1
minModulation_RGB1 = SensorToSettings(cal1,minModulationXYZ);
maxModulation_RGB1 = SensorToSettings(cal1,maxModulationXYZ);
minModulation_XYZ1 = SettingsToSensor(cal1,minModulation_RGB1);
maxModulation_XYZ1 = SettingsToSensor(cal1,maxModulation_RGB1);
contrastXYZ1 = (maxModulation_XYZ1-minModulation_XYZ1)./(maxModulation_XYZ1+minModulation_XYZ1);
fprintf('Monitor 1 settings values at low edge of moduluation: %0.4f %0.4f %0.4f\n',...
    minModulation_RGB1(1),minModulation_RGB1(2),minModulation_RGB1(3));
fprintf('Monitor 1 setting values at high edge of moduluation: %0.4f %0.4f %0.4f\n',...
    maxModulation_RGB1(1),maxModulation_RGB1(2),maxModulation_RGB1(3));
fprintf('Monitor 1 XYZ contrast of modulation: %0.4f, %0.4f %0.4f\n',...
    contrastXYZ1(1),contrastXYZ1(2),contrastXYZ1(3));

% Monitor 2
minModulation_RGB2 = SensorToSettings(cal2,minModulationXYZ);
maxModulation_RGB2 = SensorToSettings(cal2,maxModulationXYZ);
minModulation_XYZ2 = SettingsToSensor(cal2,minModulation_RGB2);
maxModulation_XYZ2 = SettingsToSensor(cal2,maxModulation_RGB2);
contrastXYZ2 = (maxModulation_XYZ2-minModulation_XYZ2)./(maxModulation_XYZ2+minModulation_XYZ2);
fprintf('Monitor 2 settings values at low edge of moduluation: %0.4f %0.4f %0.4f\n',...
    minModulation_RGB2(1),minModulation_RGB2(2),minModulation_RGB2(3));
fprintf('Monitor 2 settings values at high edge of moduluation: %0.4f %0.4f %0.4f\n',...
    maxModulation_RGB2(1),maxModulation_RGB2(2),maxModulation_RGB2(3));
fprintf('Monitor 2 XYZ contrast of modulation: %0.4f, %0.4f %0.4f\n',...
    contrastXYZ2(1),contrastXYZ2(2),contrastXYZ2(3));

% Monitor 3.
minModulation_RGB3 = SensorToSettings(cal3,minModulationXYZ);
maxModulation_RGB3 = SensorToSettings(cal3,maxModulationXYZ);
minModulation_XYZ3 = SettingsToSensor(cal3,minModulation_RGB3);
maxModulation_XYZ3 = SettingsToSensor(cal3,maxModulation_RGB3);
contrastXYZ3 = (maxModulation_XYZ3-minModulation_XYZ3)./(maxModulation_XYZ3+minModulation_XYZ3);
fprintf('Monitor 3 settings values at low edge of moduluation: %0.4f %0.4f %0.4f\n',...
    minModulation_RGB3(1),minModulation_RGB3(2),minModulation_RGB3(3));
fprintf('Monitor 3 settings values at high edge of moduluation: %0.4f %0.4f %0.4f\n',...
    maxModulation_RGB3(1),maxModulation_RGB3(2),maxModulation_RGB3(3));
fprintf('Monitor 3 XYZ contrast of modulation: %0.4f, %0.4f %0.4f\n',...
    contrastXYZ3(1),contrastXYZ3(2),contrastXYZ3(3));

%% Check that chromaticity is roughly constant.  This is just done for monitor 1.
% Small deviations from constant xy values for high target contrasts are probably
% teh result of video DAC quantization, which is modeled by SettingsToSensor.
% I didn't delve into this in detail, but theory does say that the video hardware
% can't always produce the exact linear RGB values desired.
minModulationXYZ1_check = SettingsToSensor(cal1,minModulation_RGB1);
maxModulationXYZ1_check = SettingsToSensor(cal1,maxModulation_RGB1);
minModulationxyY1_check = XYZToxyY(minModulationXYZ1_check);
maxModulationxyY1_check = XYZToxyY(maxModulationXYZ1_check);
fprintf('Monitor 1, xy low = %0.3g,%0.3g and xy high = %0.3g,%0.3g\n',...
    minModulationxyY1_check(1),minModulationxyY1_check(2),maxModulationxyY1_check(1),maxModulationxyY1_check(2));

return

