function GLW_MulticoloredText
% GLW_MulticoloredText - Shows how to make multicolored text with GLWindow.
%
% Syntax:
% GLW_MulticoloredText
%
% Description:
% Demonstrates how to make multicolored text using GLWindow and OpenGL.  At
% present, there is no simple way using GLWindow and MGL to render
% multicolored text.  To get around that we use a combination of GLWindow
% and low level OpenGL calls.  This example shows how to make a few
% different multicolored text objects and render them on the screen.  Press
% any key to quit.

% We need this for the OpenGL calls.
global GL;

% For this example we'll use pixel dimensions of the display for our scene
% dimensions.
win = GLWindow;
sceneDimsPx = win.DisplayInfo(win.WindowID).screenSizePixel;
win.SceneDimensions = sceneDimsPx;

try
	% Open our window before adding text objects.  We must do this before
	% doing anything else because our tricks to generate multicolored text
	% depend on it.
	win.open;
	
	% Make a struct defining the multicolored words.
	words(1).text = 'Red';
	words(1).name = 'red50'; % The GLWindow name.
	words(1).color1 = [1 0 0];
	words(1).color2 = [0 1 1];
	words(1).center = [0 0];
	words(1).ratio = 50;		% Percent of the word that is color 1.
	                            % Color 1 will be the color on top.
	
	words(2).text = 'Blue';
	words(2).name = 'blue25';
	words(2).color1 = [0 0 1];
	words(2).color2 = [1 1 0];
	words(2).center = [0 250];
	words(2).ratio = 75;
    
    words(3).text = 'Green';
	words(3).name = 'greenH';
	words(3).color1 = [0 1 0];
	words(3).color2 = [1 0 1];
	words(3).center = [250 0];
	words(3).ratio = 25;

	for i = 1:length(words)
		% First thing we need to do is create a dummy text object.  This text
		% object's job is to generate the OpenGL texture containing the text we
		% want to make multicolored.  With the texture we can extract the
		% actual pixel data as a matrix, modify (multicolor) it, then redisplay
		% the text as an image object.  The text object will be disabled so
		% that it's never displayed.  This process isn't fast, so if possible,
		% generate the different text we want to display ahead of time.  If
		% that isn't an option, expect there to be a short delay (100ms) when creating
		% the multicolored text.
		win.addText(words(i).text, 'Enabled', false, 'Name', 'dummyText', ...
			'Center', words(i).center);
		
		% Extract the red channel's pixel data from the text object.  We do
		% this because the pixel data is returned formatted in an annoying way
		% and it's easier to just grab 1 channel then clone it for the other 2.
		tex = win.getObjectProperty('dummyText', 'Texture');
		texData = squeeze(double(glGetTexImage(tex.textureType, 0, GL.RED, GL.FLOAT)));
		texData = repmat(texData, [1 1 3]);
		
		% Now we're going to set the 2 colors of the text.  We'll
        % do it different ways for different words.
        
        if (i == 1 || i == 2)
            % The top will be color1 and the bottom color2.
            textHeight = size(texData, 1);
            changePoint = round(textHeight * (100 - words(i).ratio)/100);
            for j = 1:3
                texData(changePoint:end,:,j) = texData(changePoint:end,:,j) * words(i).color1(j);
                
                % Make sure we don't get an indexing error.
                if (changePoint - 1) >= 1
                    texData(1:changePoint-1,:,j) = texData(1:changePoint-1,:,j) * words(i).color2(j);
                end
            end
        else
            % The left will be color1 and the right color2. Note the reversal of the order of
            % color1/color2 relative to the up/down case.  This is because the word in the matrix
            % comes out upside down.
            textWidth = size(texData, 2);
            changePoint = round(textWidth * (100 - words(i).ratio)/100);
            for j = 1:3
                texData(:,changePoint:end,j) = texData(:,changePoint:end,j) * words(i).color2(j);
                
                % Make sure we don't get an indexing error.
                if (changePoint - 1) >= 1
                    texData(:,1:changePoint-1,j) = texData(:,1:changePoint-1,j) * words(i).color1(j);
                end
            end
        end
		
		% Create an image object that contains the text data.  We set its
		% displayed size and center to that of the dummy text object.
		textDims = win.getObjectProperty('dummyText', 'TextDims');
		textCenter = win.getObjectProperty('dummyText', 'Center');
		win.addImage(textCenter, textDims, texData, 'Name', words(i).name);
	end
	
	win.draw;
	
	% Wait for a keypress.
	ListenChar(2);
	FlushEvents;
	GetChar;
	
	% Clean up.
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	win.close;
	rethrow(e);
end
