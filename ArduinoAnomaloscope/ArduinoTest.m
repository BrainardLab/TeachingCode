%% Main code. This is simple and can be easily changed by your students, or built into another measurement system.

% I stuck the arduino toolbox in its own place so I could add it
% dynamically.  The
% Matlab add on manager doesn't play well with ToolboxToolbox.
%
% This adds the Arduino toolbox to the path if it isn't there.
if (~exist('arduinosetup.m','file'))
    addpath(genpath('/Users/dhb/Documents/MATLAB/SupportPackages/R2020a'))
end

% Initialize arduino
clear a
a = arduino;

yellow = 150;
yellowIncrs = [10 5 1];
yellowIncrIndex = 1;
yellowIncr = yellowIncrs(yellowIncrIndex);

redAnchor = 100;
greenAnchor = 120;
lambda = 0.5;
lambdaIncrs = [0.02 0.005 0.001];
lambdaIncrIndex = 1;
lambdaIncr = lambdaIncrs(lambdaIncrIndex);
redOnly = false;
greenOnly = false;

% Setup character capture.
ListenChar(2);
FlushEvents;

% Loop until the 'q' is pressed.  All other keys cause the rectangle to
% change color randomly.
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
% 'a' - Advance to next r/g increment sizz (cyclic)
% ';' - Advance to next yellow increment (cyclic)
while true
    red = round(lambda*redAnchor);
    green = round((1-lambda)*greenAnchor);
    if (redOnly)
        green = 0;
    end
    if (greenOnly)
        red = 0;
    end
    fprintf('Red = %d, Green = %d, Yellow = %d\n',red, green, yellow); 
    fprintf('\tLambda increment %0.3f; yellow increment %d\n',lambdaIncr,yellowIncr);
    writeRGB(a,red,green,0);
    writeYellow(a,yellow);
    
    switch GetChar
        case 'q'
            break;
            
        case 'r'
            lambda = lambda+lambdaIncr;
            if (lambda > 1)
                lambda = 1;
            end
            
        case 'g'
            lambda = lambda-lambdaIncr;
            if (lambda < 0)
                lambda = 0;
            end
            
        case 'i'
            yellow = round(yellow+yellowIncr);
            if (yellow > 255)
                yellow = 255;
            end
            
        case 'd'
            yellow = round(yellow-yellowIncr);
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
            lambdaIncrIndex = lambdaIncrIndex+1;
            if (lambdaIncrIndex > length(lambdaIncrs))
                lambdaIncrIndex = 1;
            end
            lambdaIncr = lambdaIncrs(lambdaIncrIndex);
            
        case ';'
            yellowIncrIndex = yellowIncrIndex+1;
            if (yellowIncrIndex > length(yellowIncrs))
                yellowIncrIndex = 1;
            end
            yellowIncr = yellowIncrs(yellowIncrIndex);
            
        otherwise
            
    end
    
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;



% %delay for as long as necessary to perform measurements
% pause;
%
% nLevels = 100;
% levels = linspace(0,1,nLevels);
% for jj = 1:5
%     for ii = 1:nLevels
%         writePWMDutyCycle(a, "D9", levels(ii));
%         WaitSecs(1/nLevels);
%     end
%     for ii = nLevels:-1:1
%         writePWMDutyCycle(a, "D9", levels(ii));
%         WaitSecs(1/nLevels);
%     end
% end
%
% writeYellow(a, 128);
% writeRGB(a, 255, 128, 255);
%
% pause;

%clear a









