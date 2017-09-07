% simulateColorTopographyTutorial
%
% Simulate out the experiment of Xiao et al.  Shows that adding color
% tuning produces the appearance of topographic organization.
%
% Here is the idea as I described in an email to Brian at the time
% I wrote this:
%
% "Are you familiar with the attached Xiao et al. paper, which concludes  
% that there is a regular organization of the cortical representation  
% of hue in V1?  And if so, do you find the conclusion compelling?  My  
% memory is that you once told me you'd started to look at this sort of  
% question using fMRI, and I know we once chatted about an earlier Xiao  
% paper (with Fellerman) that studied V2.
% 
% I think they make a reasonable case that they have measured something  
% out of the noise.  But to get from their data to their conclusion,  
% they use a model of unit response that assumes any given neuron  
% responds to one and only one of the stimuli.  At least, that's my  
% reading.  But if instead you build a model that assumes that any  
% given unit is tuned somewhat broadly, and responds to a range of  
% stimuli around a hue circle, a quick simulation suggests that you'd  
% get exactly the pattern of results they observe, even if the spatial  
% distribution of these units on the cortical surface has no  
% structure.    The intuition (which I admit is a bit vague) is that  
% overlapping tuning will tend to push the highly blurred responses of  
% similarly tuned units towards each other in response images, which in  
% turn tends to induce a reliable spatial pattern of how the responses  
% to different stimuli are arrayed."
%
% 3/12/08  dhb  Wrote it.
% 6/30/12  dhb  Found old email and added it as a comment.
%          dhb  Change name and stick it into my tutorials repository,
%               which is where I looked for it first.

% Clear
clear; close all;

% Parameters
nColors = 8;                            % Number of color units in the small cortical patch
                                        % Each unit is tuned to a different angle on the hue circle.
colorTuningSd = 0.3;                    % Spread of unit color tuning on the 0-1 hue circle.
imageSize = 300;                        % Size in pixels of our cortical patch
pointRegionSize = 0.75*imageSize;       % Units are placed within a box of this size (pixels) in center of image
vascularBlurSd = 40;                    % Blur in pixels of the cortical imaging method
nSims = 8;                              % Number of times to simulate the experiment

% Positions.  Hard coded wrt 200 image size
xPositions = [45 56 40 120 130 133 199 200 210];
yPositions = [40 130 200 56 122 220 60 120 244];

% Set up color locations on interval 0-1, which we will process
% as a hue circle
theColors = linspace(0,1,nColors+1);
theColors = theColors(1:end-1);

% Set up color transfer matrix.  Entry i,j indicates how strongy
% neuron of type i reponds to stimulus of type j.  The key thing
% is that each unit will be driven by a range of stimuli
colorTransferMat = eye(nColors,nColors);
colorBlurKernal = normpdf(theColors,0.5,colorTuningSd);
colorBlurKernal = colorBlurKernal/sum(colorBlurKernal(:));
if (colorTuningSd > 0)
    for i = 1:nColors
        temp = [colorTransferMat(i,:) colorTransferMat(i,:) colorTransferMat(i,:)];
        temp = conv2(temp,colorBlurKernal,'same');
        colorTransferMat(i,:) = temp(nColors+1:2*nColors);
    end
end
colorTuningFig = figure; clf;
imshow(Expand(colorTransferMat,20)/max(colorTransferMat(:)));
title('Color Transfer Matrix');

% Set up the vascular blur kernal.  See "help mvnpdf" for basic
% code snipped used.
vascularBlurBase = linspace(-imageSize/2,imageSize/2,imageSize);
[X1,X2] = meshgrid(vascularBlurBase',vascularBlurBase');
X = [X1(:) X2(:)];
vascularBlurKernal = reshape(mvnpdf(X, 0, diag([vascularBlurSd^2 vascularBlurSd^2])),imageSize,imageSize);
vascularBlurKernal = vascularBlurKernal/sum(vascularBlurKernal(:));
vascularBlurFig = figure; clf;
imshow(vascularBlurKernal/max(vascularBlurKernal(:)));
title('Vascular Blur Kernal');

% Simulate nSims times
unitFig = figure;
simFig = figure;
imFig = figure;
for k = 1:nSims
    % Drop down nColors "neurons" at random image locations.
    % There is one unit of each color type, and the color tuning of each neuron centered
    % at one point in the hue circle.
    %
    % For computational convenience, we store the neuron of each type in
    % its own plane of a 3D matrix
    neuronImages = zeros(imageSize,imageSize,nColors);
    unitImage = zeros(imageSize,imageSize,3);
    colorAssignment = Shuffle(1:nColors);
    for i = 1:nColors
        
        %xPos = round((imageSize-pointRegionSize)/2 + 1 + rand(1,1)*(pointRegionSize-1));
        %yPos = round((imageSize-pointRegionSize)/2 + 1 + rand(1,1)*(pointRegionSize-1));
        xPos = xPositions(colorAssignment(i));
        yPos = yPositions(colorAssignment(i));
        neuronImages(yPos,xPos,i) = 1;
        
        % To let us visualize the neuron locations, we also build an image
        % for display, with colors for equally spaced around a hue like circle.
        unitColorAngle = 2*pi*i/nColors;
        unitColorR = cos(unitColorAngle);
        unitColorB = sin(unitColorAngle);
        if (unitColorR >= 0)
            unitColorG = 0;
        else
            unitColorG = -unitColorR;
            unitColorR = 0;
        end
        unitColorR = 0.5+unitColorR/2; unitColorB = 0.5+unitColorB/2;
        unitImage(yPos,xPos,:) = [unitColorR unitColorG unitColorB];
    end
    
    % Show the depiction of the unit locationa
    for c = 1:3
        unitImage(:,:,c) = conv2(unitImage(:,:,c),ones(8,8),'same');
    end
    figure(unitFig); subplot(2,nSims/2,k);
    imshow(unitImage/max(unitImage(:)));
    

    % Compute neural/vascular response images for each color stimulus.
    %   Index i denotes stimulus (controlled by the experimenter)
    %   Index j denotes neurons (which respond to the stimulus and thus the observable response.)
    neuralResponses = zeros(imageSize,imageSize,nColors);
    figure(imFig); clf;
    for i = 1:nColors
        for j = 1:nColors
            neuralResponses(:,:,i) = neuralResponses(:,:,i) + colorTransferMat(i,j)*neuronImages(:,:,j);
        end
        vascularResponses(:,:,i) = conv2(neuralResponses(:,:,i),vascularBlurKernal,'same');
        subplot(2,nColors/2,i); imshow(vascularResponses(:,:,i)/max(max(vascularResponses(:,:,i)))); drawnow; 

        % Find peak response location
        temp = vascularResponses(:,:,i);
        [maxVal,maxIndices] = max(temp(:));
        [maxI,maxJ] = ind2sub(size(vascularResponses(:,:,i)),maxIndices(1));
        if (vascularResponses(maxI,maxJ,i) ~= maxVal)
            error('Did not compute max index correctly');
        end
        peakLocations(1,i) = maxI;
        peakLocations(2,i) = maxJ;
    end
    
    % Make a figure of the peak spatial layout.  The lines connect
    % the data in color order.
    figure(simFig); subplot(2,nSims/2,k); hold on
    plot(peakLocations(1,:),peakLocations(2,:),'ro');
    plot(peakLocations(1,:),peakLocations(2,:),'r');
    axis('square');
    axis([0 imageSize 0 imageSize]); drawnow;
end
saveas(simFig,sprintf('Topo_%d_%d.png',round(10*colorTuningSd),round(vascularBlurSd)),'png');


    