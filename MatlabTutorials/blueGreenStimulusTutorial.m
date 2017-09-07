% blueStimulusTutorial
%
% Show how to generate approximately equally spaced blue/green stimuli for
% use in language/color experiments.  Following general approach of Kay lab
% papers.
%
% 8/30/09  Wrote it.

%% Clear
clear; close all;

%% Read in calibration file and initialize calibration file
cal = LoadCalFile('FrontRoomBitsPlus');
S = cal.S_device;
load T_xyz1931
T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
calXYZ = SetSensorColorSpace(cal,T_xyz,S);
calXYZ = SetGammaMethod(calXYZ,0);

%% Method 1:  Use RGB coordinates and interpret
% these with respect to the sRGB standard.  This connects to Siok et al. (2009)
% and Gilbert et al. (2006).  The don't appear to use a
% calibrated monitor, although it was gamma corrected
% using visual methods (easyrgb.com).  The stimuli in Gilbert et al. (2006)
% and in Siok et al. (2009) were generated using the same RGB values, but
% the background RGB values differed between the two studies.
%
% Although they also give CIELUV L*,u*,v* values for their tests, they 
% don't give them for their background.  Nor do they say what white point
% they used in the CIELUV converstion. Using the full white of the monitor
% as the white point, however, produces a very close approximation to the
% L*,u*,v* values given in Siok et al. Whether one should use the background RGB
% values givin in Siok et al. or Gilbert  et al. is a bit ambiguous.  My guess is that the
% better bet is those in Gilbert, as the gamma of a typical monitor is closer
% to the sRGB standard than the gamma of a typical projector.

% Enter in what we know about the stimuli
whiteRGB1 = [255 255 255]';
backgroundRGBSiok = [210 210 210]';
backgroundRGBGilbert = [178 178 178]';
backgroundRGB = backgroundRGBGilbert;
G1_RGB = [0 171 129]';
G2_RGB = [0 170 149]';
B1_RGB = [0 170 170]';
B2_RGB = [0 149 170]';
stimulusRGB = [G1_RGB G2_RGB B1_RGB B2_RGB];

% Compute XYZ of white point using sRGB, as well as of background and
% stimuli.
whiteXYZ1 = SRGBPrimaryToXYZ(SRGBGammaUncorrect(whiteRGB1));
backgroundTargetXYZ1 = SRGBPrimaryToXYZ(SRGBGammaUncorrect(backgroundRGB));
stimulusTargetXYZ1 = SRGBPrimaryToXYZ(SRGBGammaUncorrect(stimulusRGB));

% Convert the XYZ stimulus values to Luv, using the computed white point.
% These end up very close to the values given in Siok et al. (2009)
% Table 3, providing confidence about what they did.
stimulusTargetLuv1 = XYZToLuv(stimulusTargetXYZ1,whiteXYZ1);
backgroundTargetLuv1 = XYZToLuv(backgroundTargetXYZ1, whiteXYZ1);
fprintf('For target Luv in Siok et al. (2009):\n');
for i = 1:size(stimulusTargetLuv1,2)-1
    fprintf('\tLuv distance between stimulus %d and %d is %0.1f\n',i,i+1,...
        ComputeDE(stimulusTargetLuv1(:,i),stimulusTargetLuv1(:,i+1)));
end
fprintf('\n');

% Generate RGB values for our calibrated monitor.  Because the intensity
% range of our monitor differs from the the sRGB standard, we go from
% L*,u*,v* with respect to our monitor's white point back to XYZ and then
% from there to RGB.
whiteUseRGB1 = [1 1 1]';
whiteUseXYZ1 = SettingsToSensor(calXYZ,whiteUseRGB1);
stimulusTargetUseXYZ1 = LuvToXYZ(stimulusTargetLuv1,whiteUseXYZ1);
backgroundTargetUseXYZ1 = LuvToXYZ(backgroundTargetLuv1,whiteUseXYZ1);
stimulusUseRGB1 = SensorToSettings(calXYZ,stimulusTargetUseXYZ1);
backgroundUseRGB1 = SensorToSettings(calXYZ,backgroundTargetUseXYZ1);

% These stimuli are at the edge of the monitor gamut, so we ought to check
% what Luv we actually end up with.
stimulusUseXYZ1 = SettingsToSensor(calXYZ,stimulusUseRGB1);
stimulusUseLuv1 = XYZToLuv(stimulusUseXYZ1,whiteUseXYZ1);
backgroundUseXYZ1 = SettingsToSensor(calXYZ,backgroundUseRGB1);
backgroundUseLuv1 = XYZToLuv(backgroundUseXYZ1 ,whiteUseXYZ1);
fprintf('For our monitor''s approximation to Siok et al. (2009):\n');
for i = 1:size(stimulusUseLuv1,2)-1
    fprintf('\tLuv distance between stimulus %d and %d is %0.1f\n',i,i+1,...
        ComputeDE(stimulusUseLuv1(:,i),stimulusUseLuv1(:,i+1)));
end
fprintf('\n');

%% Method 2: Use Munsell specification and display on our monitor.

% Set up table and data for further Munsell computations.
munsellData = MunsellPreprocessTable;
[nil,Xx,trix,vx,Xy,triy,vy,XY,triY,vY] = MunsellGetxyY(MunsellHueToAngle(4.0,'R'),6,3,munsellData);

% Compute XYZ of Munsell white, to use as white point in CIELUV
% calculations.  Luminance is arbitrary here, so we scale to something
% at the upper end of our monitor gamut.  Note that when chroma is 0,
% the specified hue doesn't matter, so it just gets set to something
% as a place holder.
backgroundHue = '7.5G';
backgroundValue = 9.5;
backgroundChroma = 0;
H = backgroundHue;
H1 = str2num(H(find((double(H) >= double('A')) == 0)));
H2 = H(find((double(H) >= double('A')) == 1));
angle = MunsellHueToAngle(H1,H2);
value = backgroundValue;
chroma = backgroundChroma;
xyY = MunsellGetxyY(angle,value,chroma,[],Xx,trix,vx,Xy,triy,vy,XY,triY,vY);
whiteRawXYZ2 = xyYToXYZ(xyY);
whiteRawrgb2 = SensorToPrimary(calXYZ,whiteRawXYZ2);
scaleFactor = 1/max(whiteRawrgb2(:));
whiteUseRGB2 = PrimaryToSettings(calXYZ,scaleFactor*whiteRawrgb2);
whiteUseXYZ2 = SettingsToSensor(calXYZ,whiteUseRGB2);

% Compute XYZ of a reasonable Munsell neutral background.  In our code, hue
% doesn't matter when chroma is 0.  Choosing value 7 puts the RGB values at
% about the same magnitude as in the Siok et al. (2009) paper, but with
% the chromaticity matched to the Munsell standard.
backgroundHue = '7.5G';
backgroundValue = 7;
backgroundChroma = 0;
H = backgroundHue;
H1 = str2num(H(find((double(H) >= double('A')) == 0)));
H2 = H(find((double(H) >= double('A')) == 1));
angle = MunsellHueToAngle(H1,H2);
value = backgroundValue;
chroma = backgroundChroma;
xyY = MunsellGetxyY(angle,value,chroma,[],Xx,trix,vx,Xy,triy,vy,XY,triY,vY);
backgroundTargetUseXYZ2 = scaleFactor*xyYToXYZ(xyY);
backgroundTargetUseLuv2 = XYZToLuv(backgroundTargetUseXYZ2,whiteUseXYZ2);

% Specify stimuli in Munsell space.  Need to choose value and chroma
% better.  Gilbert et al. (2006) adjusted the brightness and saturation
% to make them equal across subjects.  So much for faith in the Munsell
% system.
%
% The stimulus chroma values in the older Kay and Kempton (1984) paper,
% where these were real Munsell chips, were 10, 8, 6, and 6 for these
% hues respectively.  But some of these don't fit within gamut, and 
% others can be a little more saturated, so I fiddled by hand to bring
% them all close to the edge.
stimulusHues = {
'7.5G'
'2.5BG' 
'7.5BG' 
'2.5B' 
};
stimulusValues = {
6
6
6
6};
stimulusChromas = {
8.5
7.5
7
7};

% Convert to XYZ
nStimuli = size(stimulusHues);
for i = 1:nStimuli
    H = stimulusHues{i};
    H1 = str2num(H(find((double(H) >= double('A')) == 0)));
    H2 = H(find((double(H) >= double('A')) == 1));
    angle = MunsellHueToAngle(H1,H2);
    value = stimulusValues{i};
    chroma = stimulusChromas{i};
    xyY = MunsellGetxyY(angle,value,chroma,[],Xx,trix,vx,Xy,triy,vy,XY,triY,vY);
    stimulusTargetUseXYZ2(:,i) = scaleFactor*xyYToXYZ(xyY);
end
stimulusTargetUseLuv2 = XYZToLuv(stimulusTargetUseXYZ2,whiteUseXYZ2);
fprintf('For approximation to Munsell papers:\n');
for i = 1:size(stimulusTargetUseLuv2,2)-1
    fprintf('\tLuv distance between stimulus %d and %d is %0.1f\n',i,i+1,...
        ComputeDE(stimulusTargetUseLuv2(:,i),stimulusTargetUseLuv2(:,i+1)));
end
fprintf('\n');

% Compute RGB values
stimulusUseRGB2 = SensorToSettings(calXYZ,stimulusTargetUseXYZ2);
backgroundUseRGB2 = SensorToSettings(calXYZ,backgroundTargetUseXYZ2);

% Convert back in to XYZ, to take account of any gamut issues
stimulusUseXYZ2 = SettingsToSensor(calXYZ,stimulusUseRGB2);
stimulusUseLuv2 = XYZToLuv(stimulusUseXYZ2,whiteUseXYZ2);
backgroundUseXYZ2 = SettingsToSensor(calXYZ,backgroundUseRGB2);
backgroundUseLuv2 = XYZToLuv(backgroundUseXYZ2 ,whiteUseXYZ2);
fprintf('For our monitor''s approximation to Munsell papers:\n');
for i = 1:size(stimulusUseLuv2,2)-1
    fprintf('\tLuv distance between stimulus %d and %d is %0.1f\n',i,i+1,...
        ComputeDE(stimulusUseLuv2(:,i),stimulusUseLuv2(:,i+1)));
end
fprintf('\n');

