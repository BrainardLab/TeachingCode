function MGL_MOGL_Surface
% MGL_MOGL_Surface
%
% Description:
% Shows how to display an arbitrary surface/mesh.

% This setups up some OpenGL constants in the Matlab environment.
% Essentially, anything in C OpenGL that starts with GL_ becomes GL.., e.g.
% GL_RECT becomes GL.RECT.  All GL_ are stored globally in the GL struct.
global GL;
InitializeMatlabOpenGL;

% Setup some parameters we'll use.
screenDims = [50 30];		% Width, height in centimeters of the display.
backgroundRGB = [0 0 0];	% RGB of the background.  All values are in the [0,1] range.
screenDist = 50;			% The distance from the observer to the display.
rotationAmount = -80;		% Amount of rotation to apply to the surface.

% This the half the distance between the observers 2 pupils.  This value is
% key in setting up the stereo perspective for the left and right eyes.
% For a single screen setup, we'll use a value of 0 since we're not
% actually in stereo.
ioOffset = 0;

% Create the (x,y,z) coordinates of a mesh.
[meshData.x, meshData.y] = meshgrid(-8:0.1:8);
r = sqrt(meshData.x .^ 2 + meshData.y .^ 2) + eps;
meshData.z = 5*sin(r)./r;

% Now create the surface normals.
[meshData.nx meshData.ny meshData.nz] = surfnorm(meshData.x, meshData.y, meshData.z);

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
	glShadeModel(GL.SMOOTH);
	
	% Turn on lighting.
	glLightfv(GL.LIGHT0, GL.AMBIENT, [0.5 0.5 0.5 1]);
	glLightfv(GL.LIGHT0, GL.DIFFUSE, [0.6 0.6 0.6 1]);
	glLightfv(GL.LIGHT0, GL.SPECULAR, [0.5 0.5 0.5 1]);
	glLightfv(GL.LIGHT0, GL.POSITION, [20 10 0 0]);
	glEnable(GL.LIGHTING);
	glEnable(GL.COLOR_MATERIAL);
	glEnable(GL.LIGHT0);

	% Create our OpenGL display list.  A display list is basically a group
	% of OpenGL commands that can be pre-computed and displayed later.
	% There is a reduction in overhead so the display lists improve
	% performance for complex renderings.
	displayList = createDisplayList(meshData);
	
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
					rotationAmount = rotationAmount + 20;
					
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
		
		glColorMaterial(GL.FRONT_AND_BACK, GL.AMBIENT_AND_DIFFUSE);
		
		% This rotates the mesh so we can see it better.
		glRotated(rotationAmount, 1, 1, 1);
		
		% Set our specular lighting component manually.
		glMaterialfv(GL.FRONT, GL.SPECULAR, [0.1 0 0 1])
				
		% Use glColor to specify the ambient and diffuse material
		% properties of the surface.
		glColor3dv([1 0 0]);
		
		% Call the display list to render the mesh.  We wrap the call to
		% the list with push and pop commands to save OpenGL state
		% information that might get modified by the display list.
		glPushMatrix;
		glPushAttrib(GL.ALL_ATTRIB_BITS);
		glCallList(displayList);
		glPopMatrix;
		glPopAttrib;

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


function displayList = createDisplayList(meshData)
% displayList = createDisplayList(meshData)
%
% Description:
% Generates a display list containing the specified mesh.
%
% Input:
% meshData (struct) - Struct containing the vertex and surface normal data.
%
% Output:
% displayList (scalar) - A pointer to the generated display list.

global GL;

% Create the empty display list.
displayList = glGenLists(1);

% We stick all the stuff we want in the display list between glNewList and
% glEndList.
glNewList(displayList, GL.COMPILE);

glBegin(GL.QUADS);
	numRows = size(meshData.x, 1);
	numCols = size(meshData.x, 2);
	
	% Loop over all the vertices in the mesh to render all the rectangle
	% polygons.
	for row = 1:numRows - 1
		for col = 1:numCols - 1
			% Upper left corner.
			glNormal3d(meshData.nx(row, col), meshData.ny(row, col), meshData.nz(row, col));
			glVertex3d(meshData.x(row, col), meshData.y(row, col), meshData.z(row, col));
			
			% Lower left corner.
			glNormal3d(meshData.nx(row+1, col), meshData.ny(row+1, col), meshData.nz(row+1, col));
			glVertex3d(meshData.x(row+1, col), meshData.y(row+1, col), meshData.z(row+1, col));
			
			% Lower right corner.
			glNormal3d(meshData.nx(row+1, col+1), meshData.ny(row+1, col+1), meshData.nz(row+1, col+1));
			glVertex3d(meshData.x(row+1, col+1), meshData.y(row+1, col+1), meshData.z(row+1, col+1));
			
			% Upper right corner.
			glNormal3d(meshData.nx(row, col+1), meshData.ny(row, col+1), meshData.nz(row, col+1));
			glVertex3d(meshData.x(row, col+1), meshData.y(row, col+1), meshData.z(row, col+1));
		end
	end
glEnd;

glEndList;


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
