function GLW_Mouse(fullScreen)
% GLW_Mouse - Shows how to capture/set the mouse with GLWindow.
%
% Syntax:
% GLW_Mouse
% GLW_Mouse(fullScreen)
%
% Description:
% Demonstrates how to capture mouse position and button clicks and how to
% set the mouse position while using GLWindow.  Mouse functionality is
% provided by the MGL libraries.  At the beginning of the program the mouse
% is forced to the middle of the display. Clicking the mouse prints out the
% RGB value of the pixel that was clicked if using the system mouse cursor.
% If the rendered cursor is enabled, detection of the pixel values isn't
% possible without doing some geometry calculations or reading non RGB pixel
% data, which this example doesn't get into.
%
% Input:
% fullScreen (logical) - Toggles fullscreen mode on/off.  Defaults to on.

% This global lets us access some low level OpenGL values.
global GL;

if nargin == 0
	fullScreen = true;
end

% Dimensions of our GLWindow scene.
screenDimsCm = [48 30];

% If we want to display the cursor as a dot instead of the system cursor,
% enable this flag.  The consequence of not using the system cursor and instead
% using a rendered cursor is that it's harder to get the underlying RGB values
% and we don't do that here.
useSystemCursor = true;

% Create the GLWindow object.
win = GLWindow('FullScreen', logical(fullScreen), 'SceneDimensions', screenDimsCm, ...
	'HideCursor', ~useSystemCursor);

try
	% Add a blue oval.
	win.addOval([0 0], [5 5], [0 0 1], 'Name', 'square');
	
	if ~useSystemCursor
		% Add a small oval to represent our mouse position.  Add this last
		% to your GLWindow so that it is always on top of your other
		% objects.
		win.addOval([0 0], [0.25 0.25], [1 0 0], 'Name', 'mouse');
	end
	
	% Open up the display.
	win.open;
	
	% Store the pixel dimensions of the display.  We'll use this later to
	% convert pixel values into SceneDimensions values.
	screenDimsPx = win.DisplayInfo(win.WindowID).screenSizePixel;
	
	% Enable keyboard capture.
	ListenChar(2);
	FlushEvents;
	
	% Flag to keep track of mouse button state.
	alreadyPressed = false;
	
	% Force the mouse to the center of the screen.
	fprintf('- Moving mouse to center of the display.\n');
	mglSetMousePosition(screenDimsPx(1)/2, screenDimsPx(2)/2, win.WindowID);
	
	% Loop continuously until 'q' is pressed.
	keepLooping = true;
	while keepLooping
		if CharAvail
			switch GetChar
				case 'q'
					keepLooping = false;
			end
		else
			% Get the current mouse state.  The mouse state has 3 fields:
			% buttons, x, y.  x and y will give you the horizontal and
			% vertical pixel position of the mouse relative to the
			% specified screen where (0,0) is the bottom left corner of the
			% display.  The GLWindow object contains a property 'WindowID'
			% that gives us the target screen for mglGetMouse.
			mouseInfo = mglGetMouse(win.WindowID);
			
			% Look to see if the user is pressing a button.  We keep track
			% of button state so that we don't register the same button
			% press multiple times.
			if mouseInfo.buttons > 0 && ~alreadyPressed
				if useSystemCursor
					% Print out the RGB value of the pixel the mouse was on.
					% To do this we make a low level OpenGL call to read pixels
					% straight from the framebuffer.  This call also returns
					% the alpha (transparency) value as the 4th value in the
					% return vector.
					glReadBuffer(GL.FRONT);
					pxRGBA = squeeze(glReadPixels(mouseInfo.x, mouseInfo.y, 1, 1, GL.RGB, GL.UNSIGNED_BYTE)) / 255;
					fprintf('- Pixel RGB: [%g, %g, %g]\n', pxRGBA(1), pxRGBA(2), pxRGBA(3));
					glReadBuffer(GL.BACK);
				else
					fprintf('- Mouse clicked at pixel (%d, %d)\n', mouseInfo.x, mouseInfo.y);
				end
				
				% Toggle that the button is being pressed.
				alreadyPressed = true;
			elseif mouseInfo.buttons == 0
				% If the button isn't currently being pressed we can turn
				% off the alreadyPressed flag.
				alreadyPressed = false;
			end
			
			if ~useSystemCursor
				% Move our circle to the position of the mouse so it looks like
				% we're moving around a cursor.  We first need to put the
				% mouse pixel coordinates into the same units as
				% SceneDimensions in our GLWindow object.  There's a short
				% function at the bottom of this file that does this.
				mousePos = px2cm([mouseInfo.x mouseInfo.y], screenDimsPx, screenDimsCm);
				win.setObjectProperty('mouse', 'Center', mousePos);
			end
			
			% Render the scene.
			win.draw;
		end
	end
	
	% Clean up.
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	win.close;
	rethrow(e);
end


function cmCoords = px2cm(pxCoords, screenDimsPx, screenDimsCm)
% px2cm - Converts a position in pixels to centimeters.
%
% Syntax:
% cmCoords = px2cm(pxCoords, screenDimsPx, screenDimsCm)
%
% Input:
% pxCoords (Mx2) - Pixel coordinates.
% screenDimsPx (1x2) - Screen dimensions in pixels.
% screenDimsCm (1x2) - Screen dimensions in centimeters.
%
% Output:
% cmCoords (Mx2) - Coordinates in centimeters.

if nargin ~= 3
	error('Usage: EyeTracker.px2cm(pxCoords, screenDimsPx, screenDimsCm)');
end

cmCoords = zeros(size(pxCoords));
cmCoords(:,1) = pxCoords(:,1) * screenDimsCm(1) / screenDimsPx(1) - screenDimsCm(1)/2;
cmCoords(:,2) = -screenDimsCm(2)/2 + pxCoords(:,2) * screenDimsCm(2) / screenDimsPx(2);
