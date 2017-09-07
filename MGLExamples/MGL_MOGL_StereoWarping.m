function MGL_MOGL_StereoWarping

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL_ are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDist = 76.4;			% The distance from the observer to the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.
rectDims = [2.54 2.54]*2;	% Rectangle dimensions in centimeters.
rectRGB = [1 0 0];			% Color of the rectangle in RGB.
rectPos = [0 0 0];			% (x,y,z) position of the rectangle.
rectInc = 1;				% How much we'll move the rectangle for a given step.

% The 2 screens we'll use have different IDs associated with them.  We'll
% set up some variables that make it easy to reference them.  These IDs are
% determined by the operating system, these are not arbitrary.  Under 
screenID.left = 3;
screenID.right = 2;

% This the half the distance (cm) between the observers 2 pupils.  This value is
% key in setting up the stereo perspective for the left and right eyes.
ioOffset.left = -3;
ioOffset.right = 3;

% Turn on character listening.  This function causes keyboard
% characters to be gobbled up so they don't appear in any Matlab
% window.
mglEatKeys(1:50);

% Clear the keyboard buffer.
mglGetKeyEvent;

try
	% Open both displays.  We setup some of the OpenGL parameters for both
	% displays because OpenGL commands are only effective for the
	% currently active display as specified by mglSwitchDisplay.
	for whichScreen = {'left', 'right'}
		% Pull out the string that's contained in the cell.
		i = whichScreen{1};
		
		mglSwitchDisplay(screenID.(i));
		mglOpen(screenID.(i));
		
		% Setup what our background color will be.  We only need to do this
		% once unless we want to change our background color in the middle of
		% the program.
		glClearColor(backgroundRGB(1), backgroundRGB(2), backgroundRGB(3), ...
			0);  % This 4th value is the alpha value.  We rarely care about it
				 % for the background color.
		
		% Make sure we're testing for depth.  Important if more than 1 thing is
		% on the screen and you don't want to deal with render order effects.
		glEnable(GL.DEPTH_TEST);
		
		% These help things rendered look nicer.
		glEnable(GL.BLEND);
		glEnable(GL.POLYGON_SMOOTH);
		glEnable(GL.LINE_SMOOTH);
		glEnable(GL.POINT_SMOOTH);
		
		% Load in the calibration file for the display.  We use this to
		% extract information needed for the framebuffer objet which
		% handles the warping, and some of the screen info.
		calFileName = sprintf('StereoWarp-NoRadiance-%s', i);
		cal = LoadCalFile(calFileName);
		
		% Extract the screen dimensions.
		screenDims.(i) = cal.warpParams.screenDims;
		
		% Create the framebuffer object.
		fbWidth = cal.warpParams.fbObject.width;
		fbHeight = cal.warpParams.fbObject.height;
		fbo.(i) = mglCreateFrameBufferObject(fbWidth, fbHeight);
		
		% Create the OpenGL display list we'll use to warp the vertices of
		% the framebuffer object onto the screen.
		warpList.(i) = mglCreateWarpList(cal.warpParams.actualGrid, [fbWidth fbHeight]);
		
		% Get the scene dimensions of the framebuffer object.
		fbSceneDims.(i) = cal.warpParams.fbSceneDims;
		
		% We need to calculate a frustum to define our perspective matrix.
		% Using this data in combination with the glFrustum command, we can now
		% have a 3D rendering space instead of orthographic (2D).  The left and
		% right screen will have different frustums because the eye offset is
		% in different horizontal directions.
		frustum.(i) = calculateFrustum(screenDist, fbSceneDims.(i), ioOffset.(i));
	end
	
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
					
				% Move the rectangle closer to the subject.
				case 'j'
					rectPos(3) = rectPos(3) + rectInc;
					
				% Move the rectangle further from the subject.
				case 'k'
					rectPos(3) = rectPos(3) - rectInc;
					
				% Move the rectangle left.
				case 'a'
					rectPos(1) = rectPos(1) - rectInc;
					
				% Move the rectangle right.
				case 'd'
					rectPos(1) = rectPos(1) + rectInc;
					
				% Move the rectangle up.
				case 'w'
					rectPos(2) = rectPos(2) + rectInc;
					
				% Move the rectangle down.
				case 's'
					rectPos(2) = rectPos(2) - rectInc;
					
				% All other keys go here.
				otherwise
					fprintf('Exiting...\n');
					
					% Quit our drawing loop.
					keepDrawing = false;
			end
		end
		
		% We need to do the rendering for both displays.
		for whichScreen = {'left', 'right'}
			i = whichScreen{1};
			
			% Direct all OpenGL commands to the appropriate screen.
			mglSwitchDisplay(screenID.(i));
			
			% Setup the framebuffer object so that we can render into it.
			mglBindFrameBufferObject(fbo.(i));
			
			% Setup the projection matrix.  The projection matrix defines how
			% the OpenGL coordinate system maps onto the physical screen.
			glMatrixMode(GL.PROJECTION);
			
			% This gives us a clean slate to work with.
			glLoadIdentity;
			
			% Map our 3D rendering space to the display given a specific
			% distance from the screen to the subject and an interocular
			% offset.  This is calculated at the beginning of the program.
			glFrustum(frustum.(i).left, frustum.(i).right, frustum.(i).bottom, ...
				frustum.(i).top, frustum.(i).near, frustum.(i).far);
			
			% Now we switch to the modelview mode, which is where we draw
			% stuff.
			glMatrixMode(GL.MODELVIEW);
			glLoadIdentity;
			
			% In 3D mode, we need to specify where the camera (the subject) is
			% in relation to the display.  Essentially, for proper stereo, the
			% camera will be placed at the screen distance facing straight
			% ahead not at (0,0).
			gluLookAt(ioOffset.(i), 0, screenDist, ... % Eye position
				ioOffset.(i), 0, 0, ...				   % Fixation center
				0, 1, 0);							   % Vector defining which way is up.
			
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
			glTranslated(-rectDims(1)/2 + rectPos(1), -rectDims(2)/2 + rectPos(2), rectPos(3));
			
			% Draw the rectangle.
			glBegin(GL.QUADS);
			glVertex2d(0, 0);						% Lower left corner
			glVertex2d(rectDims(1), 0);				% Lower right corner
			glVertex2d(rectDims(1), rectDims(2));	% Upper right corner
			glVertex2d(0, rectDims(2));				% Upper left corner.
			glEnd;
			
			% Stop rendering to the framebuffer object.
			mglUnbindFrameBufferObject;
			
			% Draw the framebuffer object to the screen.
			mglRenderWarpedFrameBufferObject(fbo.(i).texture, warpList.(i), screenDims.(i));
			
			% This command sticks everything we just did onto the screen.  It
			% syncs to the refresh rate of the display.
			mglFlush;
		end
	end
	
	% Passing -1 to mglSwitchDisplay is a special option which closes any
	% MGL windows open on the screen.
	mglSwitchDisplay(-1);
catch e
	% Close any open MGL windows.
	mglSwitchDisplay(-1);
	
	% Disable character listening.
	mglEatKeys([]);
	
	% Send the error to the Matlab command window.
	rethrow(e);
end


function frustum = calculateFrustum(screenDistance, screenDims, horizontalOffset)
% frustum = calculateFrustum(screenDistance, screenDims, horizontalOffset)
%
% Description:
% Takes some basic screen information and calculates the frustum parameters
% required to setup a 3D projection matrix.
%
% Input:
% screenDistance (scalar) - Distance from the screen to the observer.
% screenDims (1x2) - Dimensions of the screen. (width, height)
% horizontal offset (scalar) - Horizontal shift of the observer from the
%   center of the display.  Should be 0 for regular displays and half the
%   interocular distance for stereo setups.
%
% Output:
% frust (struct) - Struct containing all calculated frustum parameters.
%   Contains the following fields.
%   1. left - Left edge of the near clipping plane.
%	2. right - Right edge of the near clipping plane.
%	3. top - Top edge of the near clipping plane.
%	4. bottom - Bottom edge of the near clipping plane.
%	5. near - Distance from the observer to the near clipping plane.
%	6. far - Distance from the observer to the far clipping plane.

if nargin ~= 3
	error('Usage: frustum = calculateFrustum(screenDistance, screenDims, horizontalOffset)');
end

% I chose these constants as reasonable values for the distances from the
% camera for the type of experiments the Brainard lab does.
frustum.near = 1;
frustum.far = 100;

% Use similar triangles to figure out the boundaries of the near clipping
% plane based on the information about the screen size and its distance
% from the camera.
frustum.right = (screenDims(1)/2 - horizontalOffset) * frustum.near / screenDistance;
frustum.left = -(screenDims(1)/2 + horizontalOffset) * frustum.near / screenDistance;
frustum.top = screenDims(2)/2 * frustum.near /  screenDistance;
frustum.bottom = -frustum.top;
