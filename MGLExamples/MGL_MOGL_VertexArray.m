function MGL_MOGL_VertexArray
% MGL_MOGL_VertexArray
%
% Description:
% Shows how to create a simple shape with vertex arrays.

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL_ are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDims = [50 30];		% Width, height in centimeters of the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.
screenDist = 50;			% The distance from the observer to the display.
cubeSize = 10;				% Size of one side of the cube.

% This the half the distance between the observers 2 pupils.  This value is
% key in setting up the stereo perspective for the left and right eyes.
% For a single screen setup, we'll use a value of 0 since we're not
% actually in stereo.
ioOffset = 0;

% Define the vertices of our cube.
v = zeros(8, 3);
v(1,:) = [-1 -1 1];
v(2,:) = [1 -1 1];
v(3,:) = [1 1 1];
v(4,:) = [-1 1 1];
v(5,:) = [-1 -1 -1];
v(6,:) = [1 -1 -1];
v(7,:) = [1 1 -1];
v(8,:) = [-1 1 -1];
			 
% Now we define the vertex information for the vertex arrays we'll be
% using.  Essentially, we're defining the vertices for the OpenGL
% primitives that will be used.
cubeVerts = [v(1,:), v(2,:), v(3,:), v(4,:), ...	% Front
			 v(2,:), v(6,:), v(7,:), v(3,:), ...	% Right
			 v(6,:), v(5,:), v(8,:), v(7,:), ...	% Back
			 v(5,:), v(1,:), v(4,:), v(8,:), ...	% Left
			 v(4,:), v(3,:), v(7,:), v(8,:), ...	% Top
			 v(2,:), v(1,:), v(5,:), v(6,:)];		% Bottom
			 
% Define the surface normals for the each vertex for every primitive.  It
% is possible to use shared vertices to reduce the number of specified
% values, but it makes it trickier to define vertex normals.  These need to
% match the vertices defined above.
n.front = [0 0 1];
n.back = [0 0 -1];
n.right = [1 0 0];
n.left = [-1 0 0];
n.up = [0 1 0];
n.down = [0 -1 0];
cubeNormals = [repmat(n.front, 1, 4), repmat(n.right, 1, 4), ...
			   repmat(n.back, 1, 4), repmat(n.left, 1, 4), ...
			   repmat(n.up, 1, 4), repmat(n.down, 1, 4)];
		   
% Define the vertex colors.
cubeColors = repmat([1 0 0], 1, 24);
			   
			 
% Now we define the indices of the vertices that we'll use to define the
% cube.  These are indices into the 'cubeVerts' array specified above.
% Note that OpenGL uses 0 based indices unlike Matlab.
cubeIndices = [0 1 2 3, ...			% Front
			   4 5 6 7, ...			% Right
			   8 9 10 11, ...		% Back
			   12 13 14 15, ...		% Left
			   16 17 18 19, ...		% Top
			   20 21 22 23];		% Bottom

% Convert the indices to unsigned bytes for storage optimization.
cubeIndices = uint8(cubeIndices);

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
	
	% Turn on lighting.
	glLightfv(GL.LIGHT0, GL.AMBIENT, [0.5 0.5 0.5 1]);
	glLightfv(GL.LIGHT0, GL.DIFFUSE, [0.6 0.6 0.6 1]);
	glLightfv(GL.LIGHT0, GL.SPECULAR, [0.5 0.5 0.5 1]);
	glLightfv(GL.LIGHT0, GL.POSITION, [0 0 0 1]);
	glEnable(GL.LIGHTING);
	glEnable(GL.COLOR_MATERIAL);
	glEnable(GL.LIGHT0);
	
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
		
		glRotated(20, 1, 1, 1);
		
		% Set the size of the cube.
		glScaled(cubeSize/2, cubeSize/2, cubeSize/2);
				
		% Render the cube.
		glEnableClientState(GL.VERTEX_ARRAY);
		glEnableClientState(GL.NORMAL_ARRAY);
		glEnableClientState(GL.COLOR_ARRAY);
		glNormalPointer(GL.DOUBLE, 0, cubeNormals);
		glColorPointer(3, GL.DOUBLE, 0, cubeColors);
		glVertexPointer(3, GL.DOUBLE, 0, cubeVerts);
		
		glColorMaterial(GL.FRONT_AND_BACK, GL.AMBIENT_AND_DIFFUSE);
		
		glDrawElements(GL.QUADS, length(cubeIndices), GL.UNSIGNED_BYTE, cubeIndices);
		glDisableClientState(GL.VERTEX_ARRAY);
		glDisableClientState(GL.NORMAL_ARRAY);
		glDisableClientState(GL.COLOR_ARRAY);
		
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
