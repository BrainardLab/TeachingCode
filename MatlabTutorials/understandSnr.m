% CheckSnr
%
% Just a little check to verify that SNR works like we think it should
% for the pixelWorld example.
%
% 10/20/07  dhb  Wrote it.

% Clear
clear; close all;

% k is illumination intensity;
nLightLevels = 100;
k = linspace(0.1,10000,nLightLevels);

% These mean factors tell us the mean reflectance in each waveband.
aMeanReflectance = 0.2;
bMeanReflectance = 0.2;

% These sd factors tell us the standard deviation in each channel relative 
% to the mean.
aStdReflectance = 0.2;
bStdReflectance = 0.2;

% Dark noise levels, expressed as photon counts (same units as k).
aDarkNoise = 10;
bDarkNoise = 10;

% Here is the mixture parameter u for the mixture channel
u = 0.5;

% Set up mean and variance of prior in each channel.  These are also
% in units of photon counts
aPriorMean = k*aMeanReflectance;
aPriorSigma = k*aStdReflectance;
bPriorMean = k*bMeanReflectance;
bPriorSigma = k*bStdReflectance;
uPriorMean = u*aPriorMean + (1-u)*bPriorMean;
uPriorSigma = u*aPriorSigma + (1-u)*bPriorSigma;

% Compute noise distribution for each channel.  We
% assume Poisson statistics on mean response to 
% get the additive noise standard deviation approximation.
% The mean of the noise we model as simply the bias introduced
% by the dark noise
aMeanResponse = aPriorMean+aDarkNoise;
bMeanResponse = bPriorMean+bDarkNoise;
uMeanResponse = u*aMeanResponse+(1-u)*bMeanResponse;
aNoiseMean = aDarkNoise;
bNoiseMean = bDarkNoise;
uNoiseMean = u*aDarkNoise + (1-u)*bDarkNoise;
aNoiseSigma = sqrt(aMeanResponse);
bNoiseSigma = sqrt(bMeanResponse);
uNoiseSigma = sqrt(uMeanResponse);

% Compute SNR for each channel. I always forget
% whether we want to square these numbers or not.
aSNR = (aPriorSigma./aNoiseSigma);
bSNR = (bPriorSigma./bNoiseSigma);
uSNR = (uPriorSigma./uNoiseSigma);

% Plot of SNR versus illuminant intensity
figure; clf; hold on
plot(k,aSNR,'r','LineWidth',2);
plot(k,bSNR,'b.','LineWidth',2);
plot(k,uSNR,'k','LineWidth',1);
xlabel('Illuminant intensity');
ylabel('SNR');
