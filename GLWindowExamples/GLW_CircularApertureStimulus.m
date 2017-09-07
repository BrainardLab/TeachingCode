function GLW_CircularApertureStimulus()
% GLW_CircularApertureStimulus() 
%
% Demonstrate how to generate a noise stimulus with a circular aperture using
% GLWindow.
%
% The program terminates when the user presses the'q' key.
% 
%

% 12/3/13  npc Wrote it.

    % Generate 256x256 noise stimulus
    imageSize = 256;
    stimMatrix  = rand(imageSize, imageSize)-0.5;
    
    % Generate circular aperture
    mask = GenerateSoftCircularAperture(imageSize);
    
    % Apply the mask to the stimulus
    imageMatrix = 0.5 + (stimMatrix .* mask);
       
    % Create an RGB version for display by GLWindow
    imageMatrixRGB = repmat(imageMatrix, [1 1 3]);
    
    % Get information about the displays attached to our system.
    displayInfo = mglDescribeDisplays;

    % We will present everything to the last display. Get its ID.
    lastDisplay = length(displayInfo);

    % Get the screen size
    screenSizeInPixels = displayInfo(lastDisplay).screenSizePixel;
    
    win = [];
    try 
        % Create a full-screen GLWindow object
        win = GLWindow( 'SceneDimensions', screenSizeInPixels, ...
                        'BackgroundColor', [0.5 0.5 0.5],...
                        'windowID',        lastDisplay);

        % Open the window            
        win.open;
        
        % Add stimulus image to the GLWindow
        centerPosition = [0 0];
        win.addImage(centerPosition, size(imageMatrix), ...
                     imageMatrixRGB, 'Name', 'stimulus');
                 
        % Render the scene
        win.draw;
        
        % Wait for a character keypress.
        ListenChar(2);
        FlushEvents;
        
        disp('Press q to exit');
        Speak('Press q to exit', 'Alex');
        
        keepLooping = true;
        while (keepLooping)
        
            if CharAvail
                % Get the key
                theKey = GetChar;
            
                if (theKey == 'q')
                    keepLooping = false;
                end   
            end
        end
        
        % Close the window.
        win.close;
        ListenChar(0);

    catch e
        disp('An exception was raised');

        % Disable character listening.
        ListenChar(0);

        % Close the window if it was succesfully created.
        if ~isempty(win)
            win.close;
        end

        % Send the error back to the Matlab command window.
        rethrow(e);

    end  % try
    
end


function aperture = GenerateSoftCircularAperture(imageSize)
% aperture = GenerateSoftCircularAperture(imageSize)
%
% This function generates a soft circular aperture that is used to window the test image.
%
% 12/10/12  npc Wrote it.
% 12/13/12  npc Changed computation of soft border to decrease the width of
%               the transition area, and thus display more of the image
    
    x          = [-imageSize/2:imageSize/2-1] + 0.5;
    [X,Y]      = meshgrid(x,x);
    
    radius     = sqrt(X.^2 + Y.^2);
    softRadius = (imageSize/2)*0.9;
    softSigma  = (imageSize/2 - softRadius) / 3.0;
    delta      = radius - softRadius;
    
    aperture   = ones(size(delta));
    indices    = find(delta > 0);
    aperture(indices) = exp(-0.5*(delta(indices)/softSigma).^2);
    
end