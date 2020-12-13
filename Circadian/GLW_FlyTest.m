function GLW_FlyTest
% GLW_FlyTest  Demonstrates how to drift a grating in GLWindow.
%
% Syntax:
%     GLW_FlyTest
%
% Description:
%     The function makes various changes to stimuli for use in KK's lab to
%     study fly circadian rhythm.
%
%     To update code, type tbUseProject('TeachingCode')'
%
%     Starts running at specied time if set to wait, otherwise starts as
%     soon as it's ready to go.  (Initialization can take a little time.)
%     If you specify waiting, hitting ' ' will override the specified wait
%     and start.
%
%     Hitting 'q' terminates program gracefully.  
%     Hitting ' ' advances to next stimulus cycle
%
%     After quiting or it finishes, hit the up arrow key to get rid of the
%     black window.

% 11/29/20 dhb  Started.
% 12/03/20 dhb  Getting there.
% 12/13/20 dhb  Back to one circle, add flicker

try
    % Initialize
    close all; win = [];
    
    % Cd to directory containing this function
    [a] = fileparts(mfilename('fullpath'));
    cd(a);
    
    % Control flow parameters.  Set these to true for regular running.
    % Setting to false controls things for development/debugging.
    fullScreen = true;
    regularTiming = true;
    hideCursor = false;
    
    % Path to data files
    dataDir = '/Users/flydisplay/Desktop/data';
        
    % Set bg RGB.  This may get covered up in the end and have no effect.
    bgRGB = [1 1 1];
    
    % Gamma correction exponent. Raise contrat to this to approximately
    % linearize.
    invGamma = 0.5;
    
    % Reversal parameter
    probReverse = 0;
    
    % Stimulus cycle time info
    %
    % If waitUntilStartTime is true, will start at this time of day
    waitUntilToStartTime = false;
    startTime = 15:45;
    
    % Run through these stimulus types (defined below in stimStructs cell
    % array), in this order.  Duration of each stimulus type is specified
    % in seconds.  The whole cycle repeats stimRepeats times (can be set to
    % a large number for just run until stopped).
    stimCycles = [2 1 4 3 6 5];
    stimDurationsSecs = [10 10 10 10 10 10];
    stimRepeats = 100;
    
    % Drifting grating struct
    %   Drifting, stimulus type 1
    %   Static version, stimulus type 2
    structIndex = 1;
    clear stimStruct;
    stimStruct.type = 'drifting';
    stimStruct.name = 'Bars';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.25;
    stimStruct.nPhases = 120;
    stimStruct.contrast = 1;
    stimStruct.sine = false;
    stimStruct.sigma = Inf;
    stimStruct.theta = 0;
    stimStruct.xdist = 0;
    stimStruct.ydist = 0;
    stimStruct.reverseProb = probReverse;
    stimStructs{structIndex} = stimStruct;
    stimStructs{structIndex+1} = stimStructs{structIndex};
    stimStructs{structIndex+1}.name = 'BackgroundBars';
    stimStructs{structIndex+1}.nPhases = 1;
    structIndex = structIndex+2;
    
    % Flickering screen
    %   Flickering, stimulus type 3
    %   Static version, stimulus type 4
    clear stimStruct
    stimStruct.type = 'flickering';
    stimStruct.name = 'Flicker';
    stimStruct.tfHz = 0.25;
    stimStruct.nPhases = 120;
    stimStruct.contrast = 1;
    stimStruct.reverseProb = probReverse;
    stimStructs{structIndex} = stimStruct;
    stimStructs{structIndex+1} = stimStructs{structIndex};
    stimStructs{structIndex+1}.name = 'BackgroundFlciker';
    stimStructs{structIndex+1}.nPhases = 1;
    structIndex = structIndex+2;
   
    % Circles
    %   Looming, stimulus type 5
    %   Static version, stimulus type 6
    clear stimStruct;
    stimStruct.type = 'looming';
    stimStruct.name = 'Circles';
    stimStruct.tfHz = 0.25;
    stimStruct.nSizes = 240;
    stimStruct.minDiameter = 3;
    stimStruct.maxDiameter = 800;
    stimStruct.minBarPixels = 4;
    stimStruct.contrast = 1;
    stimStruct.reverseProb = probReverse;
    stimStructs{structIndex} = stimStruct;
    stimStructs{structIndex+1} = stimStructs{structIndex};
    stimStructs{structIndex+1}.name = 'BackgroundCircles';
    stimStructs{structIndex+1}.nSizes= 1;
    structIndex = structIndex+2;
     
    % Open the window
    %
    % And use screen info to get parameters.
    %
    % Choose the last attached screen as our target screen, and figure out its
    % screen dimensions in pixels.  Using these to open the GLWindow keeps
    % the aspect ratio of stuff correct.
    d = mglDescribeDisplays;
    frameRate = d(end).refreshRate;
    screenDims = d(end).screenSizePixel;
    colSize = screenDims(1);
    halfColSize = colSize/2;
    rowSize = screenDims(2);
    maxCircleSize = min([colSize/2 rowSize]) - 5;
    win = GLWindow('SceneDimensions', screenDims,'windowId',length(d),'FullScreen',fullScreen);
    
    % Check that parameters divide things up properly
    if (rem(colSize,4) ~= 0 | rem(rowSize,2) ~= 0)
        error('Col size must be a multiple of 4, and row size a multiple of 2');
    end
    
    % Open up the window and set background
    win.open;
    win.BackgroundColor = bgRGB;
    win.draw;
    
    % Initialize for each stimulus type actually used
    whichStructsUsed = unique(stimCycles);
    for ss = 1:length(whichStructsUsed)
        fprintf('Initializing stimulus type %d\n',ss);
        stimStruct = stimStructs{whichStructsUsed(ss)};
        switch stimStruct.type
            case 'drifting'
                % Create the drifting grating stimulus type
                %
                % Check number of cycles relative to row size
                if (rem(rowSize,2*stimStruct.sfCyclesImage) ~= 0)
                    fprintf('Row size %d, cycles/image %d\n',rowSize,stimStruct.sfCyclesImage);
                    error('Two times cycles/image must evenly divide row size');
                end
                barHeight = rowSize/(2*stimStruct.sfCyclesImage);
                
                % White square
                win.addRectangle([0 0],[colSize rowSize],[stimStruct.contrast^invGamma stimStruct.contrast^invGamma stimStruct.contrast^invGamma],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name))
                
                % Initialize drifting grating
                if (stimStruct.nPhases == 1)
                    phases = 0;
                else
                    phases = linspace(0,2*barHeight,stimStruct.nPhases);
                end
                for ii = 1:stimStruct.nPhases
                    for cc = 0:stimStruct.sfCyclesImage
                        barPosition = (2*(cc-1))*barHeight+phases(ii)-rowSize/2 + barHeight/2;
                        % fprintf('Row size: %d, barHeight %d, putting black bar %d at offset %0.1f\n',...
                        %    rowSize,barHeight,cc,barPosition);
                        win.addRectangle([0 barPosition], ...                                              % Center position
                            [colSize barHeight], ...                                                       % Width, Height of oval
                            [1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma], ...       % RGB color
                            'Name', sprintf('%sB%d%d',stimStruct.name,cc,ii));
                        barPosition = (2*(cc-1)+1)*barHeight+phases(ii)-rowSize/2 + barHeight/2;
                        % fprintf('\tRow size: %d, barHeight %d, putting white bar at offset %0.1f\n',...
                        %    rowSize,barHeight,barPosition);
                        win.addRectangle([0 barPosition], ...                                              % Center position
                            [colSize barHeight], ...                                                       % Width, Height of oval
                            [stimStruct.contrast^invGamma stimStruct.contrast^invGamma stimStruct.contrast^invGamma], ...       % RGB color
                            'Name', sprintf('%sW%d%d',stimStruct.name,cc,ii));
                        win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,ii))
                        win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,ii))
                    end
                end
                
            case 'flickering'
                % Create the flickering screen stimulus type
                %
                % Contrasts
                maxContrast = stimStruct.contrast;
                minContrast = 1-stimStruct.contrast;
                halfContrast = minContrast + (maxContrast-minContrast)/2;
                sinVals = halfContrast+sin(2*pi*(0:(stimStruct.nPhases-1))/stimStruct.nPhases)/2;
                theContrasts = minContrast+sinVals*(maxContrast-minContrast);
                
                % White square
                win.addRectangle([0 0],[colSize rowSize],[halfContrast^invGamma halfContrast^invGamma halfContrast^invGamma],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name))
                
                % Flickering stimuli themselves
                for ii = 1:stimStruct.nPhases
                    win.addRectangle([0, 0], [colSize rowSize], [theContrasts(ii)^invGamma theContrasts(ii)^invGamma theContrasts(ii)^invGamma], ...
                        'Name', sprintf('%s%d',stimStruct.name,ii));
                    win.disableObject(sprintf('%s%d',stimStruct.name,ii))
                end
                
            case 'looming'
                % Create the looming circle stimulus type
                %
                % Compute sizes and create circle of each size, equally
                % space by area
                minArea = pi*(stimStruct.minDiameter/2)^2;
                maxArea = pi*(stimStruct.maxDiameter/2)^2;
                halfArea = minArea+(maxArea-minArea)/2;
                
                % Set up sequence
                if (stimStruct.nSizes == 1)
                    theAreas = halfArea;
                else
                    theAreas = [linspace(halfArea,maxArea,stimStruct.nSizes/4) linspace(maxArea,minArea,stimStruct.nSizes/2) linspace(minArea,halfArea,stimStruct.nSizes/4)];
                end
                theSizes = 2*sqrt(theAreas/pi);
                
                % Compute bar areas.  The left and right black bars should come to this much area,
                % so as to leave constant black on the screen.
                barAreas = maxArea-theAreas+stimStruct.minBarPixels*rowSize;
                
                % White background
                win.addRectangle([0 0],[colSize rowSize],[stimStruct.contrast^invGamma stimStruct.contrast^invGamma stimStruct.contrast^invGamma],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                
                % Circles of increasing then decreasing size, with bars to
                % keep areas constant
                for ii = 1:stimStruct.nSizes
                    win.addOval([0 0], ...                                                              % Center position
                        [theSizes(ii) theSizes(ii)], ...                                                % Width, Height of oval
                        [1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma], ...        % RGB color
                        'Name', sprintf('%s%d',stimStruct.name,ii));                                    % Tag associated with this oval.
                    win.disableObject(sprintf('%s%d',stimStruct.name,ii));
                    
                    % Compute width of left and right black bars so that
                    % their total area is the desired bar area.
                    barWidth = barAreas(ii)/(rowSize*2);
                    
                    % Put bar at left edge of screen
                    barPosition = barWidth/2-colSize/2;
                    win.addRectangle([barPosition 0], ...                                              % Center position
                        [barWidth rowSize], ...                                                        % Width, Height of oval
                        [1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma], ...       % RGB color
                        'Name', sprintf('%sBarL%d',stimStruct.name,ii));
                    win.disableObject(sprintf('%sBarL%d',stimStruct.name,ii));
                    
                    % And another on the right
                    barPosition = -barWidth/2+colSize/2;
                    win.addRectangle([barPosition 0], ...                                              % Center position
                        [barWidth rowSize], ...                                                        % Width, Height of oval
                        [1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma 1-stimStruct.contrast^invGamma], ...       % RGB color
                        'Name', sprintf('%sBarR%d',stimStruct.name,ii));
                    win.disableObject(sprintf('%sBarR%d',stimStruct.name,ii));
                end
                
            otherwise
                error('Unknown stimulus type specified');
        end
        fprintf('Done with that initialize\n');
    end
    
    % Set up key listener
    ListenChar(2);
    FlushEvents;
    
    % Hide cursor
    if (hideCursor)
        mglDisplayCursor(0);
    end
    
    % Wait until start time
    if (waitUntilToStartTime)
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
    
    % Cycle through stimulus types until number of repetions reached or someone hits q
    allStimIndex = 1;
    whichStim = 1;
    nStim = length(stimCycles);
    quit = false;
    for rr = 1:(stimRepeats*length(stimCycles))
        % Get current stimulus struct
        stimStruct = stimStructs{stimCycles(whichStim)};
        stimShownList(allStimIndex) = stimCycles(whichStim);
        
        % Set up drawtimes
        whichDraw = 1;
        maxDraws = round(frameRate*(stimDurationsSecs(whichStim)+1));
        drawTimes{allStimIndex} = NaN*ones(1,maxDraws);
        
        % Display.  Assumes already initialized
        startSecs = GetSecs;
        stimShownStartTimes(allStimIndex) = startSecs;
        if (~regularTiming)
            finishSecs = Inf;
        else
            finishSecs = startSecs + stimDurationsSecs(whichStim);
        end
        switch stimStruct.type
            case 'drifting'
                % Run the drifting grating stimulus
                %
                % Temporal params
                framesPerPhase = round((frameRate/stimStruct.tfHz)/stimStruct.nPhases);
                fprintf('Running at %d frames per phase, frame rate %d Hz, %0.2f cycles/sec\n', ...
                    framesPerPhase,frameRate,frameRate/(stimStruct.nPhases*framesPerPhase));
                
                % Drift the grating according to the grating's parameters
                whichPhase = 1;
                whichFrame = 1;
                phaseAdjust = 1;
                oldPhase = stimStruct.nPhases;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        for cc = 0:stimStruct.sfCyclesImage
                            win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,oldPhase));
                            win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,oldPhase))
                            win.enableObject(sprintf('%sB%d%d',stimStruct.name,cc,whichPhase));
                            win.enableObject(sprintf('%sW%d%d',stimStruct.name,cc,whichPhase))
                        end
                        oldPhase = whichPhase;
                        whichPhase = whichPhase + phaseAdjust;
                        if (whichPhase > stimStruct.nPhases)
                            whichPhase = 1;
                        end
                        if (whichPhase < 1)
                            whichPhase = stimStruct.nPhases;
                        end
                        if (CoinFlip(1,stimStruct.reverseProb))
                            if (phaseAdjust == 1)
                                phaseAdjust = -1;
                            else
                                phaseAdjust = 1;
                            end
                        end
                    end
                    win.draw;
                    drawTimes{allStimIndex}(whichDraw) = GetSecs;
                    whichDraw = whichDraw+1;
                    
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
                            stimShownFinishTimes(allStimIndex) = GetSecs;
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                for cc = 0:stimStruct.sfCyclesImage
                    win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,oldPhase));
                    win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,oldPhase))
                end
                
                % If we're quiting break out of stimulus loop too
                if (quit)
                    break;
                end
                
            case 'flickering'
                % Run the flickering screen stimulus.
                
                % Temporal params
                framesPerSize = round((frameRate/stimStruct.tfHz)/stimStruct.nPhases);
                fprintf('Running at %d frames per size, frame rate %d Hz, %0.2f cycles/sec\n', ...
                    framesPerSize,frameRate,frameRate/(stimStruct.nPhases*framesPerSize));
                
                % Drift the grating according to the grating's parameters
                whichPhase = 1;
                whichFrame = 1;
                oldPhase = stimStruct.nPhases;
                phaseAdjust = 1;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        win.disableObject(sprintf('%s%d',stimStruct.name,oldPhase));
                        win.enableObject(sprintf('%s%d',stimStruct.name,whichPhase));
                        
                        oldPhase = whichPhase;
                        whichPhase = whichPhase + phaseAdjust;
                        if (whichPhase > stimStruct.nPhases)
                            whichPhase = 1;
                        end
                        if (whichPhase < 1)
                            whichPhase = stimStruct.nPhases;
                        end
                        if (CoinFlip(1,stimStruct.reverseProb))
                            if (phaseAdjust == 1)
                                phaseAdjust = -1;
                            else
                                phaseAdjust = 1;
                            end
                        end
                    end
                    win.draw;
                    drawTimes{allStimIndex}(whichDraw) = GetSecs;
                    whichDraw = whichDraw+1;
                    
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
                            stimShownFinishTimes(allStimIndex) = GetSecs;
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%s%d',stimStruct.name,oldPhase));
                
                % If we're quiting break out of stimulus loop too
                if (quit)
                    break;
                end
                
            case 'looming'
                % Run the looming circle stimulus
                %
                % Temporal params
                framesPerSize = round((frameRate/stimStruct.tfHz)/stimStruct.nSizes);
                fprintf('Running at %d frames per size, frame rate %d Hz, %0.2f cycles/sec\n', ...
                    framesPerSize,frameRate,frameRate/(stimStruct.nSizes*framesPerSize));
                
                % Drift the grating according to the grating's parameters
                whichSize = 1;
                whichFrame = 1;
                oldSize = stimStruct.nSizes;
                sizeAdjust = 1;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        win.disableObject(sprintf('%s%d',stimStruct.name,oldSize));
                        win.disableObject(sprintf('%sBarL%d',stimStruct.name,oldSize));
                        win.disableObject(sprintf('%sBarR%d',stimStruct.name,oldSize));
                        
                        win.enableObject(sprintf('%s%d',stimStruct.name,whichSize));
                        win.enableObject(sprintf('%sBarL%d',stimStruct.name,whichSize));
                        win.enableObject(sprintf('%sBarR%d',stimStruct.name,whichSize));
                        
                        oldSize = whichSize;
                        whichSize = whichSize + sizeAdjust;
                        if (whichSize > stimStruct.nSizes)
                            whichSize = 1;
                        end
                        if (whichSize < 1)
                            whichSize = stimStruct.nSizes;
                        end
                        if (CoinFlip(1,stimStruct.reverseProb))
                            if (sizeAdjust == 1)
                                sizeAdjust = -1;
                            else
                                sizeAdjust = 1;
                            end
                        end
                    end
                    win.draw;
                    drawTimes{allStimIndex}(whichDraw) = GetSecs;
                    whichDraw = whichDraw+1;
                    
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
                            stimShownFinishTimes(allStimIndex) = GetSecs;
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%s%d',stimStruct.name,oldSize));
                win.disableObject(sprintf('%sBarL%d',stimStruct.name,oldSize));
                win.disableObject(sprintf('%sBarR%d',stimStruct.name,oldSize));
                
                % If we're quiting break out of stimulus loop too
                if (quit)
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
    if (~isempty(win))
        win.close; win = [];
    end
    ListenChar(0);
    mglDisplayCursor(1);
    
    % Save data
    filename = fullfile(dataDir,['theData_' datestr(now,'yyyy-mm-dd') '_' datestr(now,'HH:MM:SS')]);
    %filename = fullfile(dataDir,['theData_Temp']);
    save(filename);
    
    % Error handler
catch e
    if (~isempty(win))
        win.close;
    end
    ListenChar(0);
    mglDisplayCursor(1);
    rethrow(e);
end




