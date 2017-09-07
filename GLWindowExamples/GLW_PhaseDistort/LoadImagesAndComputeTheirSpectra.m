function [image1Struct, image2Struct, imageSize] = LoadImagesAndComputeTheirSpectra(imageResizingFactor)
% [image1struct, image2struct, imageSize] = LoadImagesAndComputeTheirSpectra(imageResizingFactor)
%
% Load images, resize them according to parameter imageResizingFactor
% (via bicubic interpolation) and perform Fourier analysis on them. 
% Convention assumes that images are in MAT files with image name 
% equal to file name.  Images are also assumed scaled in range 0-255.
%
% The returned image structs contain the following fields:
% - Name         : a string with the name of the image
% - ImageMatrix  : the image data, i.e, a [rows x cols] matrix
% - Amplitude    : the amplitude spectrum of the image, i.e., a [rows x cols] matrix
% - Phase        : the phase spectrum of the image,  i.e., a [rows x cols] matrix
% - RGBdata      : the RGB version of the image data, i.e, a [rows x cols x 3] matrix 
% 
% 12/10/12  npc  Wrote it.
%

    image1Struct = loadAndAnalyze('reagan128', imageResizingFactor);
    image2Struct = loadAndAnalyze('einstein128', imageResizingFactor);
    
    if (isempty(image1Struct) || isempty(image2Struct))
        imageSize = 0;
    else
        [imageSize,~] = size(image1Struct.ImageMatrix);
    end
    
end

function imageStruct = loadAndAnalyze(imageName, imageResizingFactor)
% Load image, interpolate and compute its amplitude/phase spectra
%
    if (exist(sprintf('%s.mat', imageName)) == 2)    
        % load mat file with image
        load(imageName, '-mat');
        eval(['imageMatrix = ' imageName ';']);
        
        % interpolate imageMatrix by imageResizingFactor
        if (imageResizingFactor > 1)
            imageMatrix = intepolateImage(imageMatrix, imageResizingFactor);
        end
       
        % flip image upside-down and normalize it
        imageMatrix =  flipud(imageMatrix) / 255;
        
        % compute spectral analysis
        imageFT = fft2(imageMatrix);
        
        % generate imageStruct
        imageStruct             = struct;  
        imageStruct.Name        = imageName;
        imageStruct.ImageMatrix = imageMatrix;
        imageStruct.Amplitude   = abs(imageFT);
        imageStruct.Phase       = angle(imageFT);
        imageStruct.RGBdata     = repmat(imageStruct.ImageMatrix, [1 1 3]);
    else    
        % file does not exist. Print message
        fprintf('Did not find image %s', sprintf('%s.mat', imageName));
        imageStruct = [];
    end
end

function newImage = intepolateImage(image, factor)
% Intepolate image by the given factor
%
    % make sure newImageSize is an even number
    newImageSize = ceil(size(image,1) * factor);
    if (mod(newImageSize,2) == 1)
        newImageSize = newImageSize-1;
    end
    
    % compute original and interpolated indices
    x       = [1:size(image,1)];  
    xi      = 1+[0:newImageSize-1]/newImageSize*size(image,1);
    [X,Y]   = meshgrid(x,x);   
    [XI,YI] = meshgrid(xi,xi);

    % do the interpolation
    newImage = interp2(X,Y, image, XI, YI, 'cubic*');
    
    % take care of any nan values
    newImage(isnan(newImage)) = 0;
    
    % enable this flag to generate a figure showing the original and intepolated images
    displayIntepolatedPhotos = false;
  
    if (displayIntepolatedPhotos)
        figure(2); clf;
        subplot(1,2,1);
        imagesc(image); axis square
        set(gca, 'CLim', [0 255]);
        subplot(1,2,2);
        imagesc(newImage); axis square
        set(gca, 'CLim', [0 255]);
        colormap(gray);
    end 
end