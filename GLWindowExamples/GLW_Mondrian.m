function GLW_Mondrian(fullScreen, displayType)
% GLW_Mondrian(fullScreen, displayType)
%
% Description:
% GLWindow example to illustrate how to draw a Mondrian.
%
% Input:
% fullScreen (boolean) - Toggles fullscreen mode on/off.
% displayType (string) - Sets the display type of the GLWindow.  Can be
%	'normal', 'hdr', or 'bitspp'.  Defaults to 'normal'.

% Setup variable defaults.
if ~exist('fullScreen', 'var')
	fullScreen = true;
end
if ~exist('displayType', 'var')
	displayType = 'normal';
end

try
	win = [];
		
	% Create the Mondrian raw data.
	numCols = 5;
	numRows = 5;
	onScreenDims = [15 15];

	% This creates a set of colors increasing from black to white across
	% rows.
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

	% Create the GLWindow.  'Position' and 'Size' are ignored in fullscreen
	% mode.
	win = GLWindow('FullScreen', logical(fullScreen), ... % Sets fullscreen mode.
				   'DisplayType', displayType, ...		  % Sets the display type (normal, hdr, or bits++).
				   'SceneDimensions', [40 30]);			  % Sets the size of the window.
	
	% Add a Mondrian.
	win.addMondrian(numRows, numCols, ...		% Number of rows and columns
		  onScreenDims, ...			% Screen dimensions
		  mondrianColors, ...		% Mondrian colors
		  'Type', 'Normal', ...
		  'Border', 0.0, ...		% Border size
		  'Name', 'it');			% Object name

	% Open the GLWindow.
	win.open;
	
	% Setup character listening.
	ListenChar(2);
	FlushEvents;

	while true
		% Render the scene.
		win.draw;
		
		% Wait for keyboard input.
		key = GetChar;
		
		switch key
			case 'q'
				break;
				
			% Set one of the patches to something random.
			case 'r'
				randomRow = round(rand*(numRows-1)) + 1;
				randomCol = round(rand*(numCols-1)) + 1;
				
				fprintf('* Setting row %d, column %d\n', randomRow, randomCol);
				
				setMondrianPatchColor(win, ...		% GLWindow object.
											'it', ...		% Mondrian name.
											randomRow, ...	% Row index.	
											randomCol, ...	% Column index.
											rand(1,3));		% New patch color.
										
			% Makes the Mondrian have a linear set of colors between 0 and
			% 1, with lightness increases across each row from top to
			% bottom.
            case 'l'
				v = linspace(0, 1, numRows*numCols);
				ii = 1;
				c = zeros(numRows, numCols, 3);
				for i = 1:numRows
					for j = 1:numCols
						c(i,j,:) = ones(1, 3) * v(ii);
						ii = ii + 1;
					end
				end
				setObjectColor(win, 'it', c);
                
                
			% Sets the Mondrian colors to random values.
			case 'f'
                randomColors = rand(numRows, numCols, 3);
                setObjectColor(win, 'it', randomColors);
            
			% Randomize the border.
			case 'b'
				setObjectProperty(win, 'it', 'Border', rand);
				
			case 'd'
				dumpSceneToTiff(win, 'mon.tif');
				
			% Animate the border.
			case 'a'
				frame = 0;
				frameRate = 60;
				duration = 5;
				
				for i = 1:(frameRate*duration)
					bval = (sin(2*pi*frame/60) + 1)/2;
					setObjectProperty(win, 'it', 'Border', bval);
					draw(win);
					frame = frame + 1;
				end
		end
	end
	
	% Close up shop.
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	if ~isempty(win)
		win.close;
	end
	rethrow(e);
end
