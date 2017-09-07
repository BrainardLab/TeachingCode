function GLW_Text(fullScreen)
% GLW_Text  Demonstrates how to show text with GLWindow
%
% Syntax:
%     GLW_Text
%     GLW_Text(fullScreen)
%
% Description:
%     Opens a window and shows the string 'red' on the screen.
%
%     Press - 'r' to change the word
%           - 'c' to change the color of the text
%           - 'e' to enable the text (i.e. display it)
%           - 'd' to disable the text (i.e. hide it)
%           - 'q' to quit
%
% Input:
%     fullScreen (logical) - If true, the last screen attached to the computer
%         will be opened in fullscreen mode.  If false, a regular window is opened
%         on the main screen.  Defaults to true.

error(nargchk(0, 1, nargin));

if ~exist('fullScreen', 'var')
	fullScreen = true;
end

% We can set the coordinate range of our OpenGL window.
sceneDimensions = [50 30];

% Background color (RGB) of the window.
bgRGB = [0 0 0];

% Create the GLWindow object.
win = GLWindow('FullScreen', fullScreen, ...
			   'SceneDimensions', sceneDimensions, ...
			   'BackgroundColor', bgRGB);
		   
try	
	% Add some text.  At minimum, we have to pass the text to display to
	% 'addText', but there are other parameters we can set including its
	% location, color, and font size.
    txtString = 'red';
    enableState = true;
	win.addText(txtString, ...        % Text to display
		        'Center', [0 0], ...   % Where to center the text. (x,y)
				'FontSize', 100, ...   % Font size
				'Color', [1 0 0], ...  % RGB color
				'Name', 'myText');     % Identifier for the object.
	
	% Open the window.
	win.open;
	
	% Initialize our keyboard capture.
	ListenChar(2);
	FlushEvents;
	
	while true
		% Draw the scene.
		win.draw;
		
		% Wait for a keypress.
		switch GetChar
			% Quit
			case 'q'
				break;
			
			% Randomly change the text.
			case 'r'
				switch ceil(rand*6)
					case 1
						txtString = 'red';
					case 2
						txtString = 'green';
					case 3
						txtString = 'blue';
					case 4
						txtString = 'yellow';
					case 5
						txtString = 'brown';
					case 6
						txtString = 'pink';
				end
				
				% This will replace whatever text was shown before.
				win.setText('myText', txtString);
             
            % Change color
            case 'c'
               % For technical reasons, you can't change the color
               % of a text object directly.  But, you can 're-add'
               % it with the same name and it will replace the 
               % previous version.  This this code acts to change
               % the color of the currently displayed string.
               win.addText(txtString, ... % Text to display
		        'Center', [0 0], ...       % Where to center the text. (x,y)
				'FontSize', 100, ...       % Font size
				'Color',  rand(1,3), ...   % RGB color
                'Enabled',enableState, ... % Preseve enable/disable
				'Name', 'myText');         % Identifier for the object.
            
            % Enable
            case 'e'
                enableState = true;
                win.enableObject('myText'); 
                
            case 'd'
                enableState = false;
                win.disableObject('myText');
		end
	end
	
	cleanup(win);
catch e
	cleanup(win);
	rethrow(e);
end


function cleanup(win)
if ~isempty(win)
	win.close;
end
ListenChar(0);
