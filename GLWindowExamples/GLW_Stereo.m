function GLW_Stereo(fullScreen, displayType)

if ~exist('fullScreen', 'var')
    fullScreen = false;
end
if ~exist('displayType', 'var')
	displayType = 'Stereo';
end

try
    win = [];
	
	% If background color isn't specified, it will default to [0 0 0] for
	% both displays.
	bgColor.left = [0 0 0];
	bgColor.right = [0 0 0];
	
	% Stereo displays require that the warp files are specified.
	warpFile.left = 'StereoWarpNoRadiance-left';
	warpFile.right = 'StereoWarpNoRadiance-right';

    % Create the GLWindow object.  This is the core element that all commands
    % function around.
    win = GLWindow('FullScreen', fullScreen, ...
				   'SceneDimensions', [40 30], ...
				   'DisplayType', displayType, ...
				   'BackgroundColor', bgColor, ...
				   'WarpFile', warpFile);

	% Add a random noise patch.
	imData.left = rand(512, 512, 3);
	imData.right = imData.left;
	%imData.right = rand(512, 512, 3);
	win.addImage([0 0], [20 20], imData, 'Name', 'randomPatch');

	
	% Now add a red square.  We can pass a common value like [0 0] or we
	% can set each window to give the square a unique center.
	objCenter.left = [.75 0];
	objCenter.right = [-.75 0];
	% Added by TYL %%%%%%%%%%%%%%%%%
	tempdraws = rand(5,5);
	tempdraws(3,3) = 0;
	for i = 1:3
	tempArray(:,:,i) = tempdraws;
	end
	initMond.left = tempArray;
	initMond.right = initMond.left;
	win.addMondrian(5,5,[15 15],initMond,'Name','theMond','Center',[-5 0]); 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	win.addRectangle(objCenter, [4 4], rand*ones(1,3), 'Name', 'theSquare');
	%win.addRectangle(objCenter, [5 5], [1 0 0], 'Name', 'theSquare');
	
    % Open the actual OpenGL window.
    win.open;

    % Setup character capture.
	ListenChar(2);
	FlushEvents;
	
	while true
		% Draw the scene.
		win.draw;
		
		switch GetChar
			% Added by TYL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			case '1'
				nextMondValues = rand(5,5);
				middleValue = nextMondValues(3,3);
				nextMondValues(3,3) = 0;
				for i = 1:3
				nextTempArray(:,:,i) = nextMondValues;
				end
				for x = 1:5
					for y = 1:5
					win.setMondrianPatchColor('theMond',x,y,squeeze(nextTempArray(x,y,:))');
					win.setObjectColor('theSquare',middleValue*ones(1,3));
					end
				end
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
			case 'q'
				break;
				
			otherwise
				
		end
	end
	
	% Exit the program via the catch statement.
	me = MException('GLW_Stereo:close', 'close');
	throw(me);
catch e
    if ~isempty(win)
        close(win);
    end
    ListenChar(0);
	
	% Only show an error if the exception wasn't a close exception.
	if ~strcmp(e.identifier, 'GLW_Stereo:close')
		rethrow(e);
	end
end