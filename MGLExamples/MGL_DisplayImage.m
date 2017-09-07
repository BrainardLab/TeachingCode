function MGL_DisplayImage
% MGL_DisplayImage
%
% Description:
% Opens a full screen MGL window with a black background and loads.
% an image. Press any key to exit.

% Setup some parameters we'll use.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.

try
	mglOpen;
	
	% Get the screen dimensions.
	pxWidth = mglGetParam('screenWidth');
	pxHeight = mglGetParam('screenHeight');
	
	% This makes the screen axes define by the pixel dimensions of the
	% display.
	mglScreenCoordinates;
	
	% This flushes the keyboard queue.
	mglGetKeyEvent;
	
	keepLooping = true;
	timeToLoadImage = true;
	while keepLooping
		% Look for a keypress.
		keyPress = mglGetKeyEvent;
		
		if ~isempty(keyPress)
			% Handle keypresses here.
			switch keyPress.charCode
				case 'q'
					keepLooping = false;
			end
		end
		
		% Clear the screen.
		mglClearScreen(backgroundRGB);
		
		% Load the image if we need to.
		if timeToLoadImage
			imData = double(imread('loldog.jpg'));
			timeToLoadImage = false;
			
			% Make the texture.
			texture = mglCreateTexture(imData);
		end
		
		% Draw the texture.
		mglBltTexture(texture, [pxWidth pxHeight] / 2);
		mglFlush;
	end
	
	mglClose;
catch e
	mglClose;
	rethrow(e);
end
