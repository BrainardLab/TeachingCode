function GLW_FlyTest
% GLW_FlyTest  Demonstrates how to drift a grating in GLWindow.
%
% Syntax:
%     GLW_FlyTest
%
% Description:
%     The function makes various changes to stimuli for use in KK's lab to
%     study fly circadian rhythm.

% 11/29/20 dhb  Started.
% 12/03/20 dhb  Getting there.

try
    % Initialize
    close all;
    
    % Set initial background at roughly half the
    % dispaly maximum luminance.
    % bgRGB = [173 173 173]/255;
    bgRGB = [255 255 255]/255;
    
    % Static struct
    clear stimStruct
    stimStruct.type = 'drifting';
    stimStruct.name = 'Background';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.5;
    stimStruct.nPhases = 1;
    stimStruct.contrast = 1;
    stimStruct.sine = false;
    stimStruct.sigma = 0.5;
    stimStruct.theta = 0;
    stimStruct.xdist = 0;
    stimStruct.ydist = 0;
    stimStruct.bgRGB = bgRGB;
    stimStructs{1} = stimStruct;
    
    % Drifting grating struct
    clear stimStruct;
    stimStruct.type = 'drifting';
    stimStruct.name = 'Gabor';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.5;
    stimStruct.nPhases = 100;
    stimStruct.contrast = 1;
    stimStruct.sine = false;
    stimStruct.sigma = Inf;
    stimStruct.theta = 0;
    stimStruct.xdist = 0;
    stimStruct.ydist = 0;
    stimStruct.bgRGB = bgRGB;
    stimStructs{2} = stimStruct;
    
    % Drifting grating struct
    clear stimStruct;
    stimStruct.type = 'looming';
    stimStruct.name = 'Circles';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.5;
    stimStruct.nSizes = 100;
    stimStruct.contrast = 1;
    stimStruct.bgRGB = bgRGB;
    stimStructs{3} = stimStruct;
    
    % Stimulus cycle time info
    waitToStart = false;
    startTime = 15:45;
    stimCycle = [1 2 3];
    stimDurationsHours = [0.1];
    stimDurationsSecs = stimDurationsHours*3600;
    stimDurationsSecs = [10 10 10];
    
    % Open the window
    %
    % Choose the last attached screen as our target screen, and figure out its
    % screen dimensions in pixels.  Using these to open the GLWindow keeps
    % the aspect ratio of stuff correct.
    fullScreen = false;
    debugNoTiming = false;
    d = mglDescribeDisplays;
    frameRate = d.refreshRate;
    screenDims = d(end).screenSizePixel;
    rowSize = screenDims(1);
    colSize = screenDims(2);
    pixelSize = min(screenDims);
    win = GLWindow('SceneDimensions', screenDims,'windowId',length(d),'FullScreen',fullScreen);
    win.open;
    win.BackgroundColor = bgRGB;
    win.draw;
    
    % Set up key listener
    ListenChar(2);
    FlushEvents;
    
    % Initialize for each stimulus type actually used
    whichStructsUsed = unique(stimCycle);
    for ss = 1:length(whichStructsUsed)
        fprintf('Initializing stimulus type %d ...',ss);
        stimStruct = stimStructs{whichStructsUsed(ss)};
        switch stimStruct.type
            case 'drifting'
                % Initialize drifting grating
                phases = linspace(0,360,stimStruct.nPhases);
                for ii = 1:stimStruct.nPhases
                    % Make gabor in each phase
                    gaborrgb{ii} = createGabor(rowSize,colSize,stimStruct.contrast,stimStruct.sfCyclesImage,stimStruct.theta,phases(ii),stimStruct.sigma);
                    
                    if (~stimStruct.sine)
                        gaborrgb{ii}(gaborrgb{ii} > 0.5) = stimStruct.contrast;
                        gaborrgb{ii}(gaborrgb{ii} < 0.5) = 1-stimStruct.contrast;
                    end
                    
                    % Convert to RGB
                    [calForm1 c1 r1] = ImageToCalFormat(gaborrgb{ii});
                    RGB = calForm1;
                    gaborRGB{ii} = CalFormatToImage(RGB,c1,r1);
                    clear gaborrgb
                    
                    % Add the images to the window.
                    win.addImage([stimStruct.xdist stimStruct.ydist], [pixelSize pixelSize], gaborRGB{ii}, 'Name',sprintf('%s%d',stimStruct.name,ii));
                    win.disableObject(sprintf('%s%d',stimStruct.name,ii));
                    clear gaborRGB
                end
                
            case 'looming'
                % Compute sizes and create circle of each size
                theSizes = linspace(1,pixelSize,stimStruct.nSizes/2);
                
                % White square
                win.addRectangle([0 0],[pixelSize pixelSize],[stimStruct.contrast stimStruct.contrast stimStruct.contrast],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name));

                % Circles of increasing then decreasing size
                whichCircle = 1;
                for ii = 1:stimStruct.nSizes/2
                    win.addOval([0 0], ...                                                                % Center position
                        [theSizes(ii) theSizes(ii)], ...                                                  % Width, Height of oval
                        [1-stimStruct.contrast 1-stimStruct.contrast 1-stimStruct.contrast], ...          % RGB color
                        'Name', sprintf('%sCircle%d',stimStruct.name,whichCircle));                       % Tag associated with this oval.
                    win.disableObject(sprintf('%sCircle%d',stimStruct.name,whichCircle));
                    whichCircle = whichCircle+1;
                end
                for ii = stimStruct.nSizes/2:-1:1
                    win.addOval([0 0], ...                                                                % Center position
                        [theSizes(ii) theSizes(ii)], ...                                                  % Width, Height of oval
                        [1-stimStruct.contrast 1-stimStruct.contrast 1-stimStruct.contrast], ...          % RGB color
                        'Name', sprintf('%sCircle%d',stimStruct.name,whichCircle));                       % Tag associated with this oval.
                    win.disableObject(sprintf('%sCircle%d',stimStruct.name,whichCircle));
                    whichCircle = whichCircle+1;
                end
                
            otherwise
                error('Unknown stimulus type specified');
        end
        fprintf(' done\n');
    end
    
    % Wait until start time
    if (waitToStart)
        fprintf('Waiting until specified start time of day, hit space to override ...');
        while (datenum(datestr(now,'HH:MM'),'HH:MM')-datenum(startTime,'HH:MM') < 0)
            % Check whether key was hit, start if ' '
            key = 'z';
            if (CharAvail)
                key = GetChar;
            end
            switch key
                case ' '
                    break;
                otherwise
            end
        end
        fprintf(' done\n');
    end
    fprintf('Starting stimulus cycling\n');
    
    % Cycle through stimulus types until someone hits q
    allStimIndex = 1;
    whichStim = 1;
    nStim = length(stimCycle);
    quit = false;
    while true
        % Get current stimulus struct
        stimStruct = stimStructs{stimCycle(whichStim)};
        stimShownList(allStimIndex) = stimCycle(whichStim);
        
        % Display.  Assumes already initialized
        startSecs = GetSecs;
        stimShownStartTimes(allStimIndex) = startSecs;
        if (debugNoTiming)
            finishSecs = Inf;
        else
            finishSecs = startSecs + stimDurationsSecs(whichStim);
        end
        switch stimStruct.type
            
            case 'drifting'
                % Temporal params
                framesPerPhase = round((frameRate/stimStruct.tfHz)/stimStruct.nPhases);
                
                % Drift the grating according to the grating's parameters
                whichPhase = 1;
                whichFrame = 1;
                oldPhase = stimStruct.nPhases;
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        win.disableObject(sprintf('%s%d',stimStruct.name,oldPhase));
                        win.enableObject(sprintf('%s%d',stimStruct.name,whichPhase));
                        oldPhase = whichPhase;
                        whichPhase = whichPhase + 1;
                        if (whichPhase > stimStruct.nPhases)
                            whichPhase = 1;
                        end
                    end
                    win.draw;
                    whichFrame = whichFrame + 1;
                    if (whichFrame > framesPerPhase)
                        whichFrame = 1;
                    end
                    
                    % Check whether key was hit, quit if 'q' then
                    % immediately break out of stimulus show loop
                    key = 'z';
                    if (CharAvail)
                        key = GetChar;
                    end
                    switch key
                        case 'q'
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%s%d',stimStruct.name,oldPhase));

                % If we're quiting break out of stimulus loop too
                if (quit)
                    break;
                end
                
            case 'looming'
                % Temporal params
                framesPerSize = round((frameRate/stimStruct.tfHz)/stimStruct.nSizes);
                
                % Drift the grating according to the grating's parameters
                whichSize = 1;
                whichFrame = 1;
                oldSize = stimStruct.nSizes;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        win.disableObject(sprintf('%sCircle%d',stimStruct.name,oldSize));
                        win.enableObject(sprintf('%sCircle%d',stimStruct.name,whichSize));
                        oldSize = whichSize;
                        whichSize = whichSize + 1;
                        if (whichSize > stimStruct.nSizes)
                            whichSize = 1;
                        end
                    end
                    win.draw;
                    whichFrame = whichFrame + 1;
                    if (whichFrame > framesPerSize)
                        whichFrame = 1;
                    end
                    
                    % Check whether key was hit, quit if 'q' then
                    % immediately break out of stimulus show loop
                    key = 'z';
                    if (CharAvail)
                        key = GetChar;
                    end
                    switch key
                        case 'q'
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sCircle%d',stimStruct.name,oldSize));
                
                % If we're quiting break out of stimulus loop too
                if (quit)
                    win.enableObject(sprintf('%sSquare',stimStruct.name));
                    win.disableObject(sprintf('%sCircle%d',stimStruct.name,oldSize));
                    break;
                end
                
            otherwise
                error('Unknown stimulus type specified');
        end
        stimShownFinishTimes(allStimIndex) = GetSecs;
        allStimIndex = allStimIndex + 1;
        
        % Quit out of everything?
        if (quit)
            break;
        end
        
        % Cycle stimulus type
        whichStim = whichStim + 1;
        if (whichStim > nStim)
            whichStim = 1;
        end
    end
    
    % We're done, or we quit, clean up and exit
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


function theGabor = createGabor(rowSize,colSize,contrast,sf,theta,phase,sigma)
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
if rem(rowSize,2) ~= 0 | rem(colSize,2) ~= 0
    error('row/col sizes must be an even integers');
end
res = [rowSize colSize];
xCenter=res(1)/2;
yCenter=res(2)/2;
[gab_x gab_y] = meshgrid(0:(res(1)-1), 0:(res(2)-1));

% Compute the oriented sinusoidal grating
a=cos(deg2rad(theta));
b=sin(deg2rad(theta));
sinWave=sin((2*pi/rowSize)*sf*(b*(gab_x - xCenter) - a*(gab_y - yCenter)) + deg2rad(phase));

% Compute the Gaussian window
x_factor=-1*(gab_x-xCenter).^2;
y_factor=-1*(gab_y-yCenter).^2;
varScale=2*(sigma*rowSize)^2;
gaussianWindow = exp(x_factor/varScale+y_factor/varScale);

% Compute gabor.  Numbers here run from -1 to 1.
theGabor=gaussianWindow.*sinWave;

% Convert to contrast
theGabor = (0.5+0.5*contrast*theGabor);

% Convert single plane to rgb
theGabor = repmat(theGabor,[1 1 3]);


