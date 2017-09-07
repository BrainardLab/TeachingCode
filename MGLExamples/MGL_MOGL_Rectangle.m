function MGL_MOGL_Rectangle
% MGLRectangle
%
% Description:
% Opens a full screen MGL window with a black background, and renders a
% rectangle.  Hitting 'r' will randomly change the rectangle color.

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL_ are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDims = [50 30];		% Width, height in centimeters of the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.
rectDims = [10 6];			% Rectangle dimensions in centimeters.
rectRGB = [1 0 0];			% Color of the rectangle in RGB.

try
	mglOpen;
	
	% Setup what our background color will be.  We only need to do this
	% once unless we want to change our background color in the middle of
	% the program.
	glClearColor(backgroundRGB(1), backgroundRGB(2), backgroundRGB(3), ...
		0);  % This 4th value is the alpha value.  We rarely care about it
			 % for the background color.
	
	% Turn on character listening.  This function causes keyboard
	% characters to be gobbled up so they don't appear in any Matlab
	% window.
	mglEatKeys(1:50);
	
	% Clear the keyboard buffer.
	mglGetKeyEvent;
	
	keepDrawing = true;
	while keepDrawing
		% Look for a keyboard press.
		key = mglGetKeyEvent;
		
		% If the nothing was pressed keeping drawing.
		if ~isempty(key)
			% We can react differently to each key press.
			switch key.charCode
				case 'r'
					rectRGB = rand(1,3);
					
				% All other keys go here.
				otherwise
					fprintf('Exiting...\n');
					
					% Quit our drawing loop.
					keepDrawing = false;
			end
		end
		
		% Setup the projection matrix.  The projection matrix defines how
		% the OpenGL coordinate system maps onto the physical screen.
		glMatrixMode(GL.PROJECTION);
		
		% This gives us a clean slate to work with.
		glLoadIdentity;	
		
		% Map the edges of the physical display to our specified screen
		% dimensions.  We do this so the range of our OpenGL coordinates
		% are the same as the physical measurements of the screen.
		glOrtho(-screenDims(1)/2.0, screenDims(1)/2.0, ...	% left, right
				-screenDims(2)/2.0, screenDims(2)/2.0, ...	% bottom, top
				0.0, 1.0);									% near, far
		
		% Now we switch to the modelview mode, which is where we draw
		% stuff.
		glMatrixMode(GL.MODELVIEW);
		glLoadIdentity;
		
		% Clear our rendering space.  If you don't do this rendered in the
		% buffer before will still be there.  The scene is filled with the
		% background color specified above.
		glClear(mor(GL.COLOR_BUFFER_BIT, GL.DEPTH_BUFFER_BIT, GL.STENCIL_BUFFER_BIT, GL.ACCUM_BUFFER_BIT));
		
		% Set the rectangle's color.
		glColor3dv(rectRGB);
		
		% This will center the rectangle on the screen.  We call this prior
		% to specifying rectangle because all vertices are multiplied
		% against the current transformation matrix.  In other words, the
		% order of operations happens in the opposite order they're written
		% in the code.
		glTranslated(-rectDims(1)/2, -rectDims(2)/2, 0);
		
		% Draw the rectangle.
		glBegin(GL.QUADS);
		glVertex2d(0, 0);						% Lower left corner
		glVertex2d(rectDims(1), 0);				% Lower right corner
		glVertex2d(rectDims(1), rectDims(2));	% Upper right corner
		glVertex2d(0, rectDims(2));				% Upper left corner.
		glEnd;
		
		% This command sticks everything we just did onto the screen.  It
		% syncs to the refresh rate of the display.
		mglFlush;
	end
	
	% Close the MGL window.
	mglClose;
	
	% Disable character listening.
	mglEatKeys([]);
catch e
	% Close the MGL window.
	mglClose;
	
	% Disable character listening.
	mglEatKeys([]);
	
	% Send the error to the Matlab command window.
	rethrow(e);
end
