function MGL_MOGL_NURBS
% MGL_MOGL_NURBS
%
% Description:
% Opens a full screen MGL window with a black background, and renders a
% NURBS surface.
%
% Keyboard Control:
% 'q' - Exits the program.
% 't', 'r' - Rotate the surface about the x-axis.

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL. are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDims = [50 30];		% Width, height in centimeters of the display.
screenDist = 50;			% The distance from the observer to the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.
rotationAmount = -80;		% Degrees of rotation about the x-axis.

% This the half the distance between the observers 2 pupils.  This value is
% key in setting up the stereo perspective for the left and right eyes.
% For a single screen setup, we'll use a value of 0 since we're not
% actually in stereo.
ioOffset = 0;

% Define the NURBS surface.
ctlPoints = zeros(4,4,3);
cPoints = zeros(1, 4*4*3);
cIndex = 1;
for u = 1:4
	for v = 1:4
		ctlPoints(u,v,1) = 2.0*(u - 1.5);
		ctlPoints(u,v,2) = 2.0*(v - 1.5);
		
		if ( (u == 2 || u == 3) && (v == 2 || v == 3))
			ctlPoints(u,v,3) = 3.0;
		else
			ctlPoints(u,v,3) = -3.0;
		end
		
		% Re-pack the control points data into an array that the glNurbs
		% functions below understand.
		cPoints(cIndex:(cIndex+2)) = ctlPoints(u,v,:);
		cIndex = cIndex + 3;
	end
end

knots = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0];

try
	mglOpen;
	
	% We need to calculate a frustum to define our perspective matrix.
	% Using this data in combination with the glFrustum command, we can now
	% have a 3D rendering space instead of orthographic (2D).
	frustum = calculateFrustum(screenDist, screenDims, ioOffset);
	
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
	
	% Setup some lighting and material properties for the surface.
	glEnable(GL.LIGHTING);
	glEnable(GL.LIGHT0);
	matDiffuse = [0.7, 0.7, 0.7, 1.0];
	matSpecular = [1.0, 1.0, 1.0, 1.0];
	matShininess = 100;
	glMaterialfv(GL.FRONT, GL.DIFFUSE, matDiffuse);
	glMaterialfv(GL.FRONT, GL.SPECULAR, matSpecular);
	glMaterialfv(GL.FRONT, GL.SHININESS, matShininess);
	
	% Have OpenGL do polygon normalization for us to make the surface look
	% smoother.
	glEnable(GL.AUTO_NORMAL);
	glEnable(GL.NORMALIZE);
	
	% Create the NURBS renderer.
	theNurb = gluNewNurbsRenderer;
	
	% Turn on character listening.  This function causes keyboard
	% characters to be gobbled up so they don't appear in any Matlab
	% window.
	mglEatKeys(1:50);
	
	keepDrawing = true;
	while keepDrawing
		% Look for a keyboard press.
		key = mglGetKeyEvent;
		
		% If the nothing was pressed keeping drawing.
		if ~isempty(key)
			% We can react differently to each key press.
			switch key.charCode
				case 'r'
					rotationAmount = rotationAmount + 10;
					
				case 't'
					rotationAmount = rotationAmount - 10;
					
				% All other keys go here.
				case 'q'
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
		
		% Map our 3D rendering space to the display given a specific
		% distance from the screen to the subject and an interocular
		% offset.  This is calculated at the beginning of the program.
		glFrustum(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.near, frustum.far);
		
		% Now we switch to the modelview mode, which is where we draw
		% stuff.
		glMatrixMode(GL.MODELVIEW);
		glLoadIdentity;
		
		% In 3D mode, we need to specify where the camera (the subject) is
		% in relation to the display.  Essentially, for proper stereo, the
		% camera will be placed at the screen distance facing straight
		% ahead not at (0,0).
		gluLookAt(ioOffset, 0, screenDist, ... % Eye position
				  ioOffset, 0, 0, ...          % Fixation center
				  0, 1, 0);					   % Vector defining which way is up.
		
		% Clear our rendering space.  If you don't do this rendered in the
		% buffer before will still be there.  The scene is filled with the
		% background color specified above.
		glClear(mor(GL.COLOR_BUFFER_BIT, GL.DEPTH_BUFFER_BIT, GL.STENCIL_BUFFER_BIT, GL.ACCUM_BUFFER_BIT));
		
		% Rotate the surface.
		glRotated(rotationAmount, 1, 0, 0);
		
		% Move the surface to the center of the screen.
		glTranslated(-2, -2, 0);
		
		% Render the NURBS surface.
		gluBeginSurface(theNurb);
		gluNurbsSurface(theNurb, ...
			8, knots, 8, knots, ...
			4 * 3, 3, cPoints, ...
			4, 4, GL.MAP2_VERTEX_3);
		gluEndSurface(theNurb);
		
		% Show the control points.
		glPointSize(5.0);
		glDisable(GL.LIGHTING);
		glColor3f(1.0, 1.0, 0.0);
		glBegin(GL.POINTS);
		for i = 1:4
			for j = 1:4
				glVertex3fv(ctlPoints(i,j,:));
			end
		end
		glEnd;
		glEnable(GL.LIGHTING);
		
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
