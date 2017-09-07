function [phaseDistortedImage1, phaseDistortedImage2] = ComputePhaseDistortedImage(phaseRetentionLevel, image1, image2, generatePhaseFieldFromPinkNoise, useSoftCircularAperture)
%[phaseDistortedImage1, phaseDistortedImage2] = ComputePhaseDistortedImage(pTest, image1, image2, generatePhaseFieldFromPinkNoise, useSoftCircularAperture)
%
% Given two input images, generate two output images whose amplitude spectra 
% are equal to the mean amplitude spectrum of the two images, and whose phase 
% spectra are the original phase spectra mixed with a random phase spectum
% according to the micture parameter phaseRetentionLevel.
%
% 12/10/12  npc  Wrote it.
%    

    % Compute mean amplitude spectrum of the two input images
    meanAmplitude = (image1.Amplitude + image2.Amplitude)/2;
    
    % Reconstruct output image 1 based on the mean spectrum and a phase
    % spectrum that is corrupted by various amounts of phase noise
    % (determined by parameter phaseRetentionLevel)
    phaseDistortedImage1 = struct;
    phaseDistortedImage1.ImageMatrix = ReconstructImage(meanAmplitude, image1.Phase, phaseRetentionLevel, generatePhaseFieldFromPinkNoise, useSoftCircularAperture);
    phaseDistortedImage1.RGBdata     = repmat(phaseDistortedImage1.ImageMatrix, [1 1 3]);
    phaseDistortedImage1.Name        = sprintf('%s phase-distorted',image1.Name);
    
    % Reconstruct output image 2 based on the mean spectrum and a phase
    % spectrum that is corrupted by various amounts of phase noise
    % (determined by parameter phaseRetentionLevel)
    phaseDistortedImage2 = struct;
    phaseDistortedImage2.ImageMatrix = ReconstructImage(meanAmplitude, image2.Phase, phaseRetentionLevel, generatePhaseFieldFromPinkNoise, useSoftCircularAperture);
    phaseDistortedImage2.RGBdata     = repmat(phaseDistortedImage2.ImageMatrix, [1 1 3]);
    phaseDistortedImage2.Name        = sprintf('%s phase-distorted',image2.Name);

end % ComputePhaseDistortedImage


