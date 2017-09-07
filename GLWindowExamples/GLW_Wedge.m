function GLW_Wedge(fullScreen)
% GLW_Wedge - GLWindow example showing how to create wedges.
%
% Syntax:
% GLW_Wedge
% GLW_Wedge(fullScreen)
%
% Description:
% Shows how to use GLWindow to create wedges of different sizes and colors.
% Press any key to quit.
%
% Input:
% fullScreen (logical) - Toggles fullscreen mode.  Default to true.

if nargin == 0
	fullScreen = true;
end

% Screen dimensions in centimeters assuming a widescreen style display.
screenDims = [48 30];

% Background RGB.
bgColor = [0.3 0.3 0.3];

win = GLWindow('SceneDimensions', screenDims, 'FullScreen', logical(fullScreen), ...
	'BackgroundColor', bgColor);

try
	% Add a wedge.  Note that angle 0 is defined as pointing to the right
	% with increasing angle moving counter clockwise.
	win.addWedge([0 0], ...         % The center of the circle the wedge exists on.
				 3, ...             % The inner radius.
				 10, ...            % The outer radius.
				 22.5, ...	        % Start angle in degrees.
				 22.5, ...          % Sweep angle, i.e angular width.
				 [1 0 0], ...       % RGB color.
				 'Name', 'wedge1'); % GLWindow name of the wedge.
			 
	% Add a second wedge.  For this wedge we use a parameter called
	% 'NumSlices'.  Wedges are actually rendered as a collection of
	% subwedges or slices.  Increasing this number from its default(8) can
	% improve the appearance of larger wedges.  Try playing with this
	% number to see how it works.
	win.addWedge([-5 -5], 5, 8, 90, 180, [1 0 1], 'Name', 'wedge2', ...
		'NumSlices', 16);
	
	% Open the window.
	win.open;
	
	% Draw the wedges.
	win.draw;
	
	% Turn on keyboard capture and wait for a keypress.
	ListenChar(2);
	FlushEvents;
	GetChar;
	
	% Clean up.
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	win.close;
	rethrow(e);
end
