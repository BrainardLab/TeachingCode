function GLW_HDR(fullScreen, displayType)

if ~exist('fullScreen', 'var')
	fullScreen = false;
end
if ~exist('displayType', 'var')
	displayType = 'HDR';
end

win = [];

try
	% For HDR displays, RGB values can be specified using a structure with
	% 2 fields: front and back.  Each field should contain an RGB value.
	% Alternatively, the RGB values can be specified as a cell array with
	% the first cell being the front RGB, or a 2x3 matrix with the first
	% row being the front RGB.
	bgColor.front = [.5 .5 .5];
	bgColor.back = [.2 .2 .2];
	
	sceneDims = [38.1 30.48];
	
	% Create a new GLWindow object.
	win = GLWindow('FullScreen', logical(fullScreen), ...
				   'DisplayType', displayType, ...	 % Sets the display type (hdr, normal, or bits++).
				   'BackgroundColor', bgColor, ...
                   'SceneDimensions', sceneDims, ... % Background color.
				   'WarpFile', 'HDRWarp');  % Name of the screen warping file.
	
	% Add two rectangles to the scene.
	win.addRectangle([-2.5 0], [5 5], rand(2,3), 'Name', 'hdrRect1');
	win.addRectangle([2.5 0], [5 5], rand(2,3), 'Name', 'hdrRect2');

	% Open the actual window.
	win.open;

	% Setup character listening.
	ListenChar(2);
	FlushEvents;
	
	while true
		% Render the scene.
		win.draw;
		
		% Wait for a keypress.
		key = GetChar;
		
		switch key
			case 'q'
				break;
				
			case 'a'
				gs = zeros(1, 100);
				for i = 1:100
					win.setObjectColor('hdrRect1', rand(1,3));
					win.draw;
					gs(i) = GetSecs;
				end
				%plot(diff(gs));
				
			case 'r'
				% Change hdrRect1's color.
				win.setObjectColor('hdrRect1', {rand(1,3), rand(1,3)});
		end
	end

	% Turn off character listening and close the open window.
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	if ~isempty(win)
		win.close;
	end
	rethrow(e);
end
