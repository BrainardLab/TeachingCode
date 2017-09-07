function GLW_BitsPP(displayType)

if ~exist('displayType', 'var')
	displayType = 'bits++';
end

try
	win = [];

	% Create the Mondrian raw data.
	numCols = 5;
	numRows = 5;
	onScreenDims = [15 15];
% 	mondrianColors = rand(numRows, numCols, 3);
% 	windowPosition = [0 0 ; 0 410];
% 	windowSize = [400 400 ; 400 400];
	
	v = linspace(0, 1, numRows*numCols);
	ii = 1;
	c = zeros(numRows, numCols, 3);
	for i = 1:numRows
		for j = 1:numCols
			c(i,j,:) = ones(1, 3) * v(ii);
			ii = ii + 1;
		end
	end
	mondrianColors = c;

	win = GLWindow('DisplayType', displayType, ...
		'BackgroundColor', [.5 .5 .5], ...
		'SceneDimensions', [40 30]);
	
% 	% Add any objects we want to the GLWindow.  These won't actually be
% 	% rendered until later, but this allows us to formulate our scene ahead of
% 	% time.  Objects can always be added later if the scene is dynamic.
% 	win = addRectangle(win, ...		% GLWindow object
% 		[0 0], ...					% Center position
% 		[5 5], ...					% Width, Height of rectangle
% 		[1 1 0], ...				% RGB color
% 		'Name', 'coolRect');		% Tag associated with this rectangle.

	% Add a Mondrian.
	win = addMondrian(win, ...		% GLWindow object
		numRows, numCols, ...		% Number of rows and columns
		onScreenDims, ...			% Screen dimensions
		mondrianColors, ...			% Mondrian colors
		'Border', 0.25, ...			% Border size
		'Name', 'it');				% Object name

	%win = addRectangle(win, [0 5], [5 5], [1 0 1], 'Name', 'suckRect');

	%win = addText(win, 'Hello', 'Center', [0, 10]);

	% Open the actual OpenGL window.
	win = open(win);

	% Setup character capture.
	ListenChar(2);
	FlushEvents;

	while true
		% Draw the scene.
		draw(win);

		switch GetChar
			case 'q'
				break;

			otherwise
				% Change the color of the rectangle to some random color.
				%win = setObjectColor(win, 'coolRect', rand(1,3));
		end
	end

	% Turn off character capture.
	ListenChar(0);

	% Close the open window.
	close(win);
catch e
	if ~isempty(win)
		close(win);
	end
	ListenChar(0);
	rethrow(e);
end
