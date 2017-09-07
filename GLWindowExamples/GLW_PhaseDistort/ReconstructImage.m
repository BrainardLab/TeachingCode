function imageMatrix = ReconstructImage(amplitudeSpectrum, phaseSpectum, phaseRetentionLevel, generatePhaseFieldFromPinkNoise, useSoftCircularAperture)
% imageMatrix = ReconstructImage(amplitudeSpectrum, phaseSpectum, phaseRetentionLevel, generatePhaseFieldFromPinkNoise, useSoftCircularAperture)
%
% Reconstruct an image from a given an amplitude spectrum and a phase spectrum.
% The output image has a phase spectrum that is a mixture of the 
% input phase spectrum and a random phase spectrum. As the parameter 
% phaseRetentionLevel -> 0, the phase spectrum of the output
% image becomes completely random. As phaseRetentionLevel -> 1, the phase 
% spectrum of the output image approaches the input phase spectrum, thus
% retaining progressively more phase information.
% 
% This function called from both ComputePhaseDistortedImage.m and ComputePhaseSwapImage.m
%
% This is a modified version of the ComputeImagePPD.m function which appears 
% in the original version of PhaseDistortDemo.
%
% 6/29/96  dhb, gmp, if  Wrote original ComputeImageP.m
% 3/5/97   dhb           More comments, append PD to name.
% 12/10/12 npc           Re-wrote function with the following modifications:
%                        (1) parameter 'generatePhaseFieldFromPinkNoise'
%                            controls whether the random phase spectrum is
%                            generated via RandPhasePD.m or via
%                            OneOverFnoisePhaseField.m (based on 1/f images).
%                        (2) output image is normalized in the [0..1] range

    % ensure phaseRetentionLevel is in [0 .. 1]
    phaseRetentionLevel = max([0 min([phaseRetentionLevel 1])]);
    
    % determine imageSize
    [imageSize, ~] = size(amplitudeSpectrum);
    
    % Generate random phase spectrum
    if (generatePhaseFieldFromPinkNoise)
        randomPhaseSpectum = OneOverFnoisePhaseField(imageSize);
    else
        randomPhaseSpectum = RandPhasePD(imageSize);
    end
    
    % mix actual with random phase field according to the phaseRandominationLevel
    newPhaseSpectrum = phaseSpectum + (1-phaseRetentionLevel) * randomPhaseSpectum;
    
    % compute new image based on the newPhaseMatrix
    imageMatrix = real(ifft2(amplitudeSpectrum .* exp(sqrt(-1) * newPhaseSpectrum)));
    
    % Normalize to [0..1]
    imageMatrix = NormalizeImageMatrix(imageMatrix);

    % apply soft circular aperture if so specified
    if (useSoftCircularAperture)
        aperture = GenerateSoftCircularAperture(imageSize);
        imageMatrix = imageMatrix .* aperture;
    end
        
end

