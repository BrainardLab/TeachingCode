function GLW_Basic2(fullScreen)
% GLW_Basic2 - More advanced variation of GLW_Basic.m, with a rectangle instead of an oval
%
% Syntax:
%     GLW_Basic2
%     GLW_Basic2(false)
%
% Description:
%     Shows more settings of GLWindow including SceneDimensions and BackgroundColor.
%     a window and displays a rectangle.
%
%     Press - 'b' to randomly set the background color
%           - 'q' to quit
%           - any other key to randomly change the rectangle's color.
%
% Input:
%     fullScreen (logical) - If true, the last screen attached to the computer
%         will be opened in fullscreen mode.  If false, a regular window is opened
%         on the main screen.  Defaults to true.

error(nargchk(0, 1, nargin));

% Setup defaults for the input.
if ~exist('fullScreen', 'var')
	fullScreen = true;
end

% We can set the coordinate range of our OpenGL window.  These values
% are arbitrary and can be set to anything.  For a fullscreen window,
% these will most likely be set the width and height of the display's
% screen in centimeters.  We'll make window to be 50x30cm for this example.
sceneDimensions = [50 30];

% Background color (RGB) of the window.
bgRGB = [0.5 0.5 0.5];

% Create the GLWindow object.
win = GLWindow('FullScreen', fullScreen, ...
			   'SceneDimensions', sceneDimensions, ...
			   'BackgroundColor', bgRGB);

try
    % Add a rectangle to draw.  If this doesn't show up, try recompiling
    % the mgl mex files.
    win.addRectangle([0 0], ...				% Center position
					 [5 5], ...				% Width, Height of rectangle
					 [1 0 0], ...			% RGB color
					 'Name', 'coolRect');	% Tag associated with this rectangle.

    % Open the actual OpenGL window.
    win.open;

    % Setup character capture.
    ListenChar(2);
    FlushEvents;

	% Loop until the 'q' is pressed.  All other keys cause the rectangle to
	% change color randomly.
    while true
        % Draw the scene.
        win.draw;

        switch GetChar
            case 'q'
                break;
				
			case 'b'
				win.BackgroundColor = rand(1,3);

            otherwise
                % Change the color of the rectangle to some random color.
                win.setObjectColor( 'coolRect', rand(1,3));
        end
    end

    % Turn off character capture.
    ListenChar(0);

    % Close the open window.
    win.close;
catch e
	% Disable character listening.
	ListenChar(0);
	
	% Close the window if it was succesfully created.
	if ~isempty(win)
		win.close;
	end
	
	% Send the error back to the Matlab command window.
	rethrow(e);
end
