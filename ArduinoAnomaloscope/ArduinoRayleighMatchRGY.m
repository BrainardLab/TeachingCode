% ArduinoRayleighMatchRGY
%
% Little program to do Rayleigh matches with our arduino device.
%
% This version lets you adjust red, green and yellow intensities separately
% For classic anomaloscope adjustments, see ArduinoRayleighMatch.

% History
%   Written 2020 by David Brainard based on demo code provided by Liana Keesing.

% Put the arduino toolbox some place on you system. This
% the adds it dynamically. The Matlab add on manager doesn't
% play well with ToolboxToolbox, which is why it's done this
% way here.  Also OK to get the arduino toolbox on your path
% in some other manner.
%
% This adds the Arduino toolbox to the path if it isn't there.
if (~exist('arduinosetup.m','file'))
    addpath(genpath('/Users/dhb/Documents/MATLAB/SupportPackages/R2020a'))
end

% Initialize arduino
clear;
clear a;
a = arduino;

% Initial LED parameters.  These are close to a match with my device,
% Scotch tape as diffuser, and a Roscolux #23 orange filter
% to cut out short wavelengths.
red = 29;                             % Initial red value
green = 220;                          % Initial gree value
yellow = 66;                          % Initial yellow value

% Delta parameters
whichAdjust = 'green';                 % Which to adjust
theDeltas = [10 5 1];                  % Set of yellow deltas
theDeltaIndex = 1;                     % Delta index    
theDelta = theDeltas(theDeltaIndex);   % Current yellow delta

% Booleans that control whether we just show red or just green
% LED in mixture.  This is mostly useful for debugging
redOnly = false;
greenOnly = false;

% Setup character capture.  Note that if you crash out of the program
% you need to execute ListenChar(0) before you can enter keys at keyboard 
% again.
ListenChar(2);
FlushEvents;

% Loop and process characters to control yellow intensity and 
% red/green mixture
%
% 'q' - Exit program
%
% 'r' - Adjust red
% 'g' - Adjust gree
% 'y' - Adjust yellow
% 'i' - Increase
% 'd' - Decrease
%
% '1' - Turn off green, only red in r/g mixture
% '2' - Turn off red, only green in r/g mixture
% '3' - Both red and green in r/g mixture
% 
% 'a' - Advance to next delta (cyclic)
while true
    % Store
    lastRed = red;
    lastGreen = green;
    
    % Handle special modes for red and green
    if (redOnly)
        green = 0;
    end
    if (greenOnly)
        red = 0;
    end
    
    % Tell user where we are
    fprintf('Red = %d, Green = %d, Yellow = %d\n',red, green, yellow); 
    fprintf('\tAdjusting %s; Delta %d\n',whichAdjust,theDelta);
    
    % Write the current LED settings
    writeRGB(a,red,green,0);
    writeYellow(a,yellow);
    
    % Restore
    red = lastRed;
    green = lastGreen;
    
    % Check for chars and process if one is pressed.  See comment above for
    % what each character does.
    theChar = GetChar;
    switch theChar
        case 'q'
            break;
            
        case 'r'
            whichAdjust = 'red';
            
        case 'g'
            whichAdjust = 'green';
            
        case 'y'
            whichAdjust = 'yellow';
            
        case 'i'
            switch (whichAdjust)
            case 'red'
                    red = red+theDelta;
                    if (red > 255)
                        red = 255;
                    end
                case 'green'
                    green = green+theDelta;
                    if (green > 255)
                        green = 255;
                    end
                case 'yellow'
                    yellow = yellow+theDelta;
                    if (yellow > 255)
                        yellow = 255;
                    end
            end
            
        case 'd'
            switch (whichAdjust)
                case 'red'
                    red = red-theDelta;
                    if (red < 0)
                        red = 0;
                    end
                case 'green'
                    green = green-theDelta;
                    if (green < 0)
                        green = 0;
                    end
                case 'yellow'
                    yellow = yellow-theDelta;
                    if (yellow < 0)
                        yellow = 0;
                    end
            end    
            
        case '1'
            lastRed = red;
            redOnly = true;
            greenOnly = false;
            
        case '2'
            redOnly = false;
            greenOnly = true;
            
        case '3'
            redOnly = false;
            greenOnly = false;
            
        case 'a'
            theDeltaIndex = theDeltaIndex+1;
            if (theDeltaIndex > length(theDeltas))
                theDeltaIndex = 1;
            end
            theDelta = theDeltas(theDeltaIndex);
            
        otherwise
            
    end
    
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;
