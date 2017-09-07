function randomPhaseField = OneOverFnoisePhaseField(imageSize)
% randomPhaseField = OneOverFnoisePhaseField(imageSize)
%
% Generate 'naturalistic' random phase fields based on 'pink' (1/F) spatial noise
%
% 12/10/12  npc Wrote it.
%

    % create spatial grid
    x       = [-imageSize/2:imageSize/2-1]/(imageSize/2);
    [X,Y]   = meshgrid(x,x);
    
    % generate the inverse of the 1/f filter
    filter  = sqrt(X.^2 + Y.^2);
    % avoid division by zero
    filter(imageSize/2+1, imageSize/2+1) = 1;
   
    % generate 1/f spatial filter
    oneOverFfilter = 1.0 ./ filter;
    oneOverFfilter = fftshift(oneOverFfilter);
   
    % generate white noise field
    noiseField = random('Uniform', 0, 1.0, imageSize, imageSize);
    
    % transform it into a 1/F (pink) noise field
    imageMatrix = real(ifft2( fft2(noiseField) .* oneOverFfilter));
    imageMatrix = NormalizeImageMatrix(imageMatrix);
   
    % extract its phase field
    randomPhaseField = angle(fft2(imageMatrix));
   
    % visualize 1/f image if so desired
    visualizeFilter = false;
    if (visualizeFilter)
        figure(99); clf;
        imagesc(imageMatrix); axis 'square'; colormap(gray);
        drawnow;
    end 
end
