function [amplitudeSwappedImage1, amplitudeSwappedImage2] = ComputeAmplitudeSwappedImage(image1, image2, useSoftCircularAperture)
% [phaseDistortedImage1, phaseDistortedImage2] = ComputeAmplitudeSwappedImage(image1, image2, useSoftCircularAperture)
%
% Given two input images, generate two output images whose amplitude spectra 
% are swapped but whose phase spectra are kept the same as those of the 
% corresponding input images.
%
% 12/10/12  npc  Wrote it.
%

    % Do not add phase noise, just swap the amplitude spectra
    phaseRetentionLevel = 1.0;
    
    % Reconstruct output image 1 based on the amplitude spectrum of image 2
    % and the phase spectrum of image 1
    amplitudeSwappedImage1 = struct;
    amplitudeSwappedImage1.ImageMatrix = ReconstructImage(image2.Amplitude, image1.Phase, phaseRetentionLevel, true, useSoftCircularAperture);
    amplitudeSwappedImage1.RGBdata     = repmat(amplitudeSwappedImage1.ImageMatrix, [1 1 3]);
    amplitudeSwappedImage1.Name        = sprintf('%s amplitude-swapped',image1.Name);
    
    % Reconstruct output image 2 based on the amplitude spectrum of image 1
    % and the phase spectrum of image 2
    amplitudeSwappedImage2 = struct;
    amplitudeSwappedImage2.ImageMatrix = ReconstructImage(image1.Amplitude, image2.Phase, phaseRetentionLevel, true, useSoftCircularAperture);
    amplitudeSwappedImage2.RGBdata     = repmat(amplitudeSwappedImage2.ImageMatrix, [1 1 3]);
    amplitudeSwappedImage2.Name        = sprintf('%s amplitude-swapped',image2.Name);
    
end


