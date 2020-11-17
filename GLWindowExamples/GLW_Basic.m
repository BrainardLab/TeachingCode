function GLW_Basic(fullScreen)
% GLW_Basic - Simple demonstration of using GLWindow
%
% Syntax:
%     GLW_Basic
%     GLW_Basic(false)
%
% Description:
%     Opens a window and displays a red oval.
%
%     Press any key to exit the demo.
%
% Input:
%     fullScreen (logical) - If true, the last screen attached to the computer
%         will be opened in fullscreen mode.  If false, a regular window is opened
%         on the main screen.  Defaults to true.

% Check input arguments
error(nargchk(0, 1, nargin));

% Setup defaults for the input.
if ~exist('fullScreen', 'var')
	fullScreen = false;
end

% Do everything in a try/catch to clean up better in case of error.
try	
    
    % Create the GLWindow object, which controls the display and anything
    % you want to draw on the screen.
    win = GLWindow('FullScreen', fullScreen);
    
	% Add any objects we want to the GLWindow.  We'll just add a red
	% oval that's 5 centimeters wide and tall sitting in the middle of
	% the screen.
	win.addOval([0 0], ...		    % Center of the oval
					 [5 5], ...		% Width, Height of oval
					 [1 0 0]);		% RGB color
	
	% Open the actual OpenGL window.
	win.open;
	
	% This draws the contents of the GLWindow object to the display.  This
	% consists of any objects you added to GLWindow and the background
	% color.
	win.draw;
	
	% Wait for a character keypress.
	ListenChar(2);
	FlushEvents;
	GetChar;
	ListenChar(0);
	
	% Close the window.
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