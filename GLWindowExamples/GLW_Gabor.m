function GLW_Gabor
% GLW_Gabor  Demonstrates how to show a gabor patch in GLWindow.
%
% Syntax:
%     GLW_Gabor
%
% Description:
%     The function createGabor at the end does the work of
%     creating the gabor patch. 
% 
%     Also demonstrated is how to use the PTB calibration routines
%     to gamma correct the gabor.
%
%     Press - 'd' to dump image of window into a file
%           - 'q' to quit

% 12/5/12  dhb  Wrote it from code lying around, in part due to Adam Gifford.

try 
    % Choose the last attached screen as our target screen, and figure out its
    % screen dimensions in pixels.  Using these to open the GLWindow keeps
    % the aspect ratio of stuff correct.
    d = mglDescribeDisplays;
    screenDims = d(end).screenSizePixel;
    
    % Open the window.
    win = GLWindow('SceneDimensions', screenDims,'windowId',length(d));
    win.open;
    
    % Load a calibration file for gamma correction.  Put
    % your calibration file here.
    calFile = 'PTB3TestCal';
    S = WlsToS((380:4:780)');
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
    igertCalSV = LoadCalFile(calFile);
    igertCalSV = SetGammaMethod(igertCalSV,0);
    igertCalSV = SetSensorColorSpace(igertCalSV,T_xyz,S);
    
    % Draw a neutral background at roughly half the
    % dispaly maximum luminance.
    bgrgb = [0.5 0.5 0.5]';
    bgRGB1 = PrimaryToSettings(igertCalSV,bgrgb);
    win.BackgroundColor = bgRGB1';
    win.draw;
    
    % Add central fixation cross, just for fun
    win.addLine([-20 0], [20 0], 3, [1 1 1],'Name','fixHorz');
    win.addLine([0 20], [0 -20], 3, [1 1 1],'Name', 'fixVert');
    
    % Create two gabor patches with specified parameters
    pixelSize = 400;
    contrast1 = 0.75;
    contrast2 = 0.25;
    sf1 = 6;
    sf2 = 3;
    sigma1 = 0.1;
    sigma2 = 0.2;
    theta1 = 0;
    theta2 = 75;
    phase1 = 90;
    phase2 = 0;
    xdist = 400;
    ydist = 0;
    gabor1rgb = createGabor(pixelSize,contrast1,sf1,theta1,phase1,sigma1);
    gabor2rgb = createGabor(pixelSize,contrast2,sf2,theta2,phase2,sigma2);
    
    % Gamma correct
    [calForm1 c1 r1] = ImageToCalFormat(gabor1rgb);
    [calForm2 c2 r2] = ImageToCalFormat(gabor2rgb);
    [RGB1] = PrimaryToSettings(igertCalSV,calForm1);
    [RGB2] = PrimaryToSettings(igertCalSV,calForm2);
    gabor1RGB = CalFormatToImage(RGB1,c1,r1);
    gabor2RGB = CalFormatToImage(RGB2,c2,r2);
    
    % Add to display and draw.  One is on left and the other on the right.
    win.addImage([-xdist ydist], [pixelSize pixelSize], gabor1RGB, 'Name','leftGabor');
    win.addImage([xdist ydist], [pixelSize pixelSize], gabor2RGB, 'Name','rightGabor');
    win.enableObject('leftGabor');
    win.enableObject('rightGabor');
    win.draw;
    
    % Wait for a key to quit
    ListenChar(2);
    FlushEvents;
    while true
        win.draw;
        key = GetChar;
        
        switch key
            % Quit
            case 'q'
                break;
            case 'd'
                win.dumpSceneToTiff('GLGabors.tif');
            otherwise
                break;
        end
    end
    
    % Clean up and exit
    win.close;
    ListenChar(0);
    
    % Error handler
catch e
    ListenChar(0);
    if ~isempty(win)
        win.close;
    end
    rethrow(e);
end


function theGabor = createGabor(meshSize,contrast,sf,theta,phase,sigma)
%
% Input
%   meshSize: size of meshgrid (and ultimately size of image).
%       Must be an even integer
%   contrast: contrast on a 0-1 scale
%   sf: spatial frequency in cycles/image
%          cycles/pixel = sf/meshSize
%   theta: gabor orientation in degrees, clockwise relative to positive x axis.
%          theta = 0 means horizontal grating
%   phase: gabor phase in degrees.
%          phase = 0 means sin phase at center, 90 means cosine phase at center
%   sigma: standard deviation of the gaussian filter expressed as fraction of image
%
% Output
%   theGabor: the gabor patch as rgb primary (not gamma corrected) image


% Create a mesh on which to compute the gabor
if rem(meshSize,2) ~= 0
    error('meshSize must be an even integer');
end
res = [meshSize meshSize];
xCenter=res(1)/2;
yCenter=res(2)/2;
[gab_x gab_y] = meshgrid(0:(res(1)-1), 0:(res(2)-1));

% Compute the oriented sinusoidal grating
a=cos(deg2rad(theta));
b=sin(deg2rad(theta));
sinWave=sin((2*pi/meshSize)*sf*(b*(gab_x - xCenter) - a*(gab_y - yCenter)) + deg2rad(phase));

% Compute the Gaussian window
x_factor=-1*(gab_x-xCenter).^2;
y_factor=-1*(gab_y-yCenter).^2;
varScale=2*(sigma*meshSize)^2;
gaussianWindow = exp(x_factor/varScale+y_factor/varScale);

% Compute gabor.  Numbers here run from -1 to 1.
theGabor=gaussianWindow.*sinWave;

% Convert to contrast
theGabor = (0.5+0.5*contrast*theGabor);

% Convert single plane to rgb
theGabor = repmat(theGabor,[1 1 3]);


