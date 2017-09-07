function MGL_MOGL_Basic
% MGLBasic
%
% Description:
% Opens a full screen MGL window with a black background.  Press any key to
% exit.

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL_ are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDims = [50 30];		% Width, height in centimeters of the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.

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
				case 'a'
				case 'b'
				case 'c'
					
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
		
		% Stick any ojects we want to draw here.
		
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
