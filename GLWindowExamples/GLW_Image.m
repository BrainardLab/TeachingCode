function GLW_Image(fullScreen)
% GLW_Image - GLWindow example to show image rendering.
%
% Syntax:
% GLW_Image
% GLW_Image(fullScreen)
%
% Description:
% GLWindow example showing how to display an image either from an image
% file on disk or from a generated matrix.
%
% Input:
% fullScreen (logical) - Toggles fullscreen mode on/off.  Defaults to on.

if ~exist('fullScreen', 'var')
	fullScreen = true;
end

try
	win = [];
	showImage1 = false;
	
	% Create the GLWindow.
	win = GLWindow('FullScreen', logical(fullScreen), ...
		'SceneDimensions', [48 30]); % These are the approximate dimensions 
									 % (cm) of a wide screen.
	
	% Add our first image from a file.
	win.addImageFromFile([0 0], [20 20], 'loldog.bmp', 'Name', ...
		'loldog');
	
	% Generate a random matrix and use that for the 2nd image.  Due to how
	% the low level MGL libraries were written, the coordinate system for
	% matrices being added as images is as follows.  Each pixel is
	% specified as an RGB triplet (row,col,RGB) where row specifies the
	% pixel's vertical position from the bottom of the image and col
	% represents the pixel's horizontal position from the left of the
	% image.  For example, a triplet (5, 10, rand(1,3)) would be a randomly
	% colored pixel 5 pixels from the bottom and 10 pixels from the left of
	% the image.
	imData = rand(256, 256, 3);
	win.addImage([10 -10], [20 20], imData, 'Name', 'randImage','Enabled',false);

	win.open;

	ListenChar(2);
	FlushEvents;

	while true
		win.draw;
		
		key = GetChar;
		
		switch key
			% Quit
			case 'q'
				break;
				
			% Change the background color.
			case 'b'
				win.BackgroundColor = rand(1,3);
			
			% Turn both images on.
			case 't'
				win.enableObject('loldog');
				win.enableObject('randImage');
			
			% Swap images.
			case 's'
				showImage1 = ~showImage1;
				
				if showImage1
					win.enableObject('loldog');
					win.disableObject('randImage');
				else
					win.enableObject('randImage');
					win.disableObject('loldog');
				end
			
			% Save the image on the screen to a file.
			case 'd'
				win.dumpSceneToTiff('GLWindowImage.tif');
		end
	end
	
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	if ~isempty(win)
		win.close;
	end
	rethrow(e);
end
