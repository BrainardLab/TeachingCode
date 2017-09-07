function GLW_MultipleObjects(fullScreen)
% GLW_MultipleObjects - Demonstrates showing multiple objects with GLWindow.
%
% Syntax:
% GLW_MultipleObjects
% GLW_MultipleObjects(fullScreen)
%
% Description:
% This example shows the basics of showing multiple objects with GLWindow.
% Demonstrates how to enable/disable objects, which determines whether
% they're drawn or not.  'h' toggles the oval on/off, 'q' exits the
% program, 'p' randomly changes the oval's position, and all other keys
% randomly change the object colors.
%
% Input:
% fullScreen (logical) - If true, the last screen attached to the computer
%     will be opened in fullscreen mode.  If false, a regular window is opened
%     on the main screen.  Defaults to false.

if ~exist('fullScreen', 'var')
	fullScreen = true;
end

% We can set the coordinate range of our OpenGL window.
sceneDimensions = [50 30];

% Background color (RGB) of the window.
bgRGB = [0 0 0];

% Create the GLWindow object.
win = GLWindow('FullScreen', fullScreen, ...
			   'SceneDimensions', sceneDimensions, ...
			   'BackgroundColor', bgRGB);

try
	% Add two ovals.  We give them unique names so we can
	% refer to them later easily.
	win.addOval([0 0], ...  % Center position
		[5 5], ...               % Width, Height of oval
		[1 0 0], ...             % RGB color
		'Name', 'coolOval');     % Tag associated with this oval.
	
	% You'll notice one difference here. We use the 'Enabled' property
	% to set the object to hidden.  We can unhide it later.
	win.addOval([-5 5], [6 4], [0 0 1], 'Name', 'wackyOval', 'Enabled', false);

	% Open the actual OpenGL window.
	win.open;

	% Setup character capture.
	ListenChar(2);
	FlushEvents;
	
	% Use this variable to track the state of the oval.
	ovalState = false;

	while true
		% Draw the scene.
		win.draw;

		switch GetChar
			case 'q'
				break;
			
			case 'p'
				win.setObjectProperty('wackyOval', 'Center', rand(1,2)*10 - 5);

			case 'h'
				ovalState = ~ovalState;
				
				% Turn the oval on/off depending on the oval state.
				if ovalState
					win.enableObject('wackyOval');
				else
					win.disableObject('wackyOval');
				end

			otherwise
				% Change the color of the oval and oval to random
				% colors.
				win.setObjectColor('coolOval', rand(1,3));
				win.setObjectColor('wackyOval', rand(1,3));
		end
	end

	% Turn off character capture.
	ListenChar(0);

	% Close the open window.
	win.close;
catch e
	ListenChar(0);
	if ~isempty(win)
		win.close;
	end
	rethrow(e);
end
