% ArduinoRayleighMatch
%
% Little program to do Rayleigh matches with our arduino device.
%
% The initial parameters here are close to a match with my device,
% Scotch tape as diffuser, and a Roscolux #23 orange filter
% to cut out short wavelengths.
%
% This version lets you adjust r/g mixture and yellow intensity, as in
% classic anomaloscope.  See ArduinoRayleighMatchRGY for a different set of
% controls.

% History
%   Written 2020 by David Brainard based on demo code provided by Liana Keesing.
%
%   2022-08-27  dhb  Autodect of port for compatibility with newer systesm.
%                    Thanks to John Mollon's group for identifying the
%                    basic problem and fix.

% Put the arduino toolbox some place on you system. This
% the adds it dynamically. The Matlab add on manager doesn't
% play well with ToolboxToolbox, which is why it's done this
% way here.  Also OK to get the arduino toolbox on your path
% in some other manner.
%
% This adds the Arduino toolbox to the path if it isn't there.
% Does it's best to guess where it is in a version and user independnet
% manner.  Will probably fail on Windows and Linux
if (~exist('arduinosetup.m','file'))
    if (~strcmp(computer,'MACI64'))
        error('You need to modify code for Windows/Linux to get the Arduino AddOn Toolbox onto your path and to get the arduino call to find the device');
    end
    a = ver;
    rel = a(1).Release(2:end-1);
    sysInfo = GetComputerInfo;
    user = sysInfo.userShortName;
    addpath(genpath(fullfile('/Users',user,'Documents','MATLAB','SupportPackages',rel)));
end

% Initialize arduino
%
% In newer versions of OS/Matlab, the arduino call without an argument
% fails because the port naming convention it assumes fails.  
%
% We look for possible ports.  If none, we try a straight call to arduino
% because it might work.  Otherwise we try each port in turn, hoping we 
% can open the arduino on one of them.
clear;
clear a;
devRootStr = '/dev/cu.usbmodem';
arduinoType = 'leonardo';
possiblePorts = dir([devRootStr '*']);
openedOK = false;
if (isempty(possiblePorts))
    try 
        a = arduino;
        openedOK = true;
        fprintf('Opened arduino using arduino function''s autodetect of port and type\n');
    catch e
        fprintf('Could not detect the arduino port or otherwise open it.\n');
        fprintf('Rethrowing the underlying error message.\n');
        rethrow(e);
    end
else
    for pp = 1:length(possiblePorts)
        thePort = fullfile(possiblePorts.folder,possiblePorts.name);
        try
            a = arduino(thePort,arduinoType);
            openedOK = true;
        catch e
        end
    end
    if (~openedOK)
        fprintf('Despite our best cleverness, unable to open arduino. Exiting with an error\n');
        error('');
    else
        fprintf('Opened arduino on detected port %s\n',thePort);
    end
end

% Yellow LED parameters
yellow = 66;                                    % Initial yellow value
yellowDeltas = [10 5 1];                        % Set of yellow deltas
yellowDeltaIndex = 1;                           % Delta index    
yellowDelta = yellowDeltas(yellowDeltaIndex);   % Current yellow delta

% Red/green mixture parameters.  These get traded off in the
% mixture by a parameter lambda.
redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0
lambda = 0.5;                                   % Initial lambda value
lambdaDeltas = [0.02 0.005 0.001];              % Set of lambda deltas
lambdaDeltaIndex = 1;                           % Delta index
lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Current delta

% Booleans that control whether we just show red or just green
% LED in mixture.  This is mostly useful for debugging
redOnly = false;
greenOnly = false;

% Setup character capture.  Note that if you crash out of the program
% you need to execute ListenChar(0) before you can enter keys at keyboard 
% again.
ListenChar(2);
FlushEvents;

% KbName('UnifyKeyNames');
%
%     [ keyIsDown, seconds, keyCode ] = KbCheck;
%     keyCode = find(keyCode, 1);
% 
%     % If the user is pressing a key, then display its code number and name.
%     if keyIsDown
%         % Note that we use find(keyCode) because keyCode is an array.
%         % See 'help KbCheck'
%         fprintf('You pressed key %i which is %s\n', keyCode, KbName(keyCode));
% 
%         if keyCode == escapeKey
%             break;
%         end
% 
%         % If the user holds down a key, KbCheck will report multiple events.
%         % To condense multiple 'keyDown' events into a single event, we wait until all
%         % keys have been released.
%         KbReleaseWait;

% Loop and process characters to control yellow intensity and 
% red/green mixture
%
% 'q' - Exit program
%
% 'r' - Increase red in r/g mixture
% 'g' - Increase green in r/g mixture
% 'i' - Increase yellow intensity
% 'd' - Decrease yellow intensity
%
% '1' - Turn off green, only red in r/g mixture
% '2' - Turn off red, only green in r/g mixture
% '3' - Both red and green in r/g mixture
% 
% 'a' - Advance to next r/g delta (cyclic)
% ';' - Advance to next yellow delta (cyclic)
while true
    % Set red and green values based on current lambda
    red = round(lambda*redAnchor);
    if (red < 0)
        red = 0;
    end
    if (red > 255)
        red = 255;
    end
    green = round((1-lambda)*greenAnchor);
    if (green < 0)
        green = 0;
    end
    if (green > 255)
        green = 255;
    end
    
    % Handle special modes for red and green
    if (redOnly)
        green = 0;
    end
    if (greenOnly)
        red = 0;
    end
    
    % Tell user where we are
    fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda,red, green, yellow); 
    fprintf('\tLambda delta %0.3f; yellow delta %d\n',lambdaDelta,yellowDelta);
    
    % Write the current LED settings
    writeRGB(a,red,green,0);
    writeYellow(a,yellow);
    
    % Check for chars and process if one is pressed.  See comment above for
    % what each character does.
    switch GetChar
        case 'q'
            break;
            
        case 'r'
            lambda = lambda+lambdaDelta;
            if (lambda > 1)
                lambda = 1;
            end
            
        case 'g'
            lambda = lambda-lambdaDelta;
            if (lambda < 0)
                lambda = 0;
            end
            
        case 'i'
            yellow = round(yellow+yellowDelta);
            if (yellow > 255)
                yellow = 255;
            end
            
        case 'd'
            yellow = round(yellow-yellowDelta);
            if (yellow < 0)
                yellow = 0;
            end
            
        case '1'
            redOnly = true;
            greenOnly = false;
            
        case '2'
            redOnly = false;
            greenOnly = true;
            
        case '3'
            redOnly = false;
            greenOnly = false;
            
        case 'a'
            lambdaDeltaIndex = lambdaDeltaIndex+1;
            if (lambdaDeltaIndex > length(lambdaDeltas))
                lambdaDeltaIndex = 1;
            end
            lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
            
        case ';'
            yellowDeltaIndex = yellowDeltaIndex+1;
            if (yellowDeltaIndex > length(yellowDeltas))
                yellowDeltaIndex = 1;
            end
            yellowDelta = yellowDeltas(yellowDeltaIndex);
            
        otherwise
            
    end
    
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;
