% PlotRayleighMeas
%
% Plot some spectral measurements made of the Arduino anomaloscope.

% History
%   10/25/20  dhb  Wrote it.

%% Clear
clear; close all;

%% Load data
load RayleighMeas_Sept25_2020
wls = SToWls([380 5 81]);

%% Plot approximate match (measurements taken through Rosco filter
%
% Divide by 5 to convert power per wl band to power per nam
figure; clf; hold on
plot(wls,specL/5,'r','LineWidth',2);
plot(wls,specR/5,'k','LineWidth',2);
xlabel('Wavelength (nm)');
ylabel('Radiance (Watts/sr-m2-nm)');
title('Spectra at approximate perceptual match');
ylim([0 0.025]);


%% Plot RGB spectra of LED with and without filter
%
% Input was R = 31, G = 202, B = 150 for no terribly
% good reason.
figure; clf;
subplot(1,2,1); hold on
plot(wls,specBNoFilter/5,'b','LineWidth',2);
plot(wls,specGNoFilter/5,'g','LineWidth',2);
plot(wls,specRNoFilter/5,'r','LineWidth',2);
xlabel('Wavelength (nm)');
ylabel('Radiance (Watts/sr-m2-nm)');
title('RGB spectra no filter');
%ylim([0 0.1]);
subplot(1,2,2); hold on
plot(wls,specGThroughFilter/5,'g','LineWidth',2);
plot(wls,specRThroughFilter/5,'r','LineWidth',2);
xlabel('Wavelength (nm)');
ylabel('Radiance (Watts/sr-m2-nm)');
title('RG spectra with filter');
ylim([0 0.1]);

%% Check RG additivity
specSum = specRThroughFilter + specGThroughFilter;
figure; clf; hold on
plot(wls,(specL)/5,'r','LineWidth',3);
plot(wls,specSum/5,'k:','LineWidth',2);
xlabel('Wavelength (nm)');
ylabel('Radiance (Watts/sr-m2-nm)');
title('Additivity of spectra');
ylim([0 0.025]);

