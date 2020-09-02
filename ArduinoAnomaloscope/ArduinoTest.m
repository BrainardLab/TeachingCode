%% Main code. This is simple and can be easily changed by your students, or built into another measurement system.

if (~exist('arduinosetup.m','file'))
    addpath(genpath('/Users/dhb/Documents/MATLAB/SupportPackages/R2020a'))
end

% necessary to get the arduino working
clear a
a = arduino;

yellow = 150;
yellowIncr = 1;

redAnchor = 200;
greenAnchor = 110;
lambda = 0.5;
lambdaInc = 0.005;
redOnly = false;
greenOnly = false;

% Setup character capture.
ListenChar(2);
FlushEvents;

% Loop until the 'q' is pressed.  All other keys cause the rectangle to
% change color randomly.
while true
    red = round(lambda*redAnchor);
    green = round((1-lambda)*greenAnchor);
    fprintf('Red = %d, Green = %d, Yellow = %d\n',red, green, yellow);
    if (redOnly)
        green = 0;
    end
    if (greenOnly)
        red = 0;
    end
    writeRGB(a,red,green,0);
    writeYellow(a,yellow);
    
    switch GetChar
        case 'q'
            break;
            
        case 'r'
            lambda = lambda+lambdaInc;
            if (lambda > 1)
                lambda = 1;
            end
            
        case 'g'
            lambda = lambda-lambdaInc;
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
          
        otherwise
            
    end
    
end

% Turn off character capture.
ListenChar(0);

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









