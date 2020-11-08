function GLW_FlickeringGabor
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
        
    % Create gabor patches with specified parameters
    pixelSize = 400;
    contrast = 0.75;
    sf = 6;
    sigma = 0.1;
    theta = 0;
    nPhases = 10;
    phases = linspace(0,360,nPhases);
    xdist = 0;
    ydist = 0;
    for ii = 1:nPhases
        % Make gabor in each phase
        gaborrgb{ii} = createGabor(pixelSize,contrast,sf,theta,phases(ii),sigma);
        
        % Gamma correct
        [calForm1 c1 r1] = ImageToCalFormat(gaborrgb{ii});
        [RGB] = PrimaryToSettings(igertCalSV,calForm1);
        gaborRGB{ii} = CalFormatToImage(RGB,c1,r1);
   
        win.addImage([xdist ydist], [pixelSize pixelSize], gaborRGB{whichPhase}, 'Name',sprintf('theGabor%d',whichPhase));
    end
    
    % Temporal params
    hz = 1;
    frameRate = d.refreshRate;
    framesPerPhase = round((frameRate/hz)/nPhases);
    
    % Wait for a key to quit
    ListenChar(2);
    FlushEvents;
    whichPhase = 1;
    whichFrame = 1;
    oldPhase = nPhases;
    win.enableObject(sprintf('theGabor%d',nPhases));
    while true
        if (whichFrame == 1)
            win.disableObject(sprintf('theGabor%d',oldPhase));
            win.enableObject(sprintf('theGabor%d',whichPhase));
            oldPhase = whichPhase;
            whichPhase = whichPhase + 1;
            if (whichPhase > nPhases)
                whichPhase = 1;
            end
        end
        win.draw;
        whichFrame = whichFrame + 1;
        if (whichFrame > framesPerPhase)
            whichFrame = 1;
        end
        
        key = GetChar; 
        switch key
            % Quit
            case 'q'
                break;
            otherwise
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


