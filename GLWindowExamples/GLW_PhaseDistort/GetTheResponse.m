function [answerIsCorrect, quitExp] = GetTheResponse(win, imageSize, whichSide, leftImagePosition, rightImagePosition)
% [answerInCorrect, quitExp] = GetTheResponse(win, imageSize, whichSide, leftImagePosition, rightImagePosition)
%
% This function positions the mouse on the center of the screen and waits
% for the user to click on one or the two images that are displayed on the
% experimental window.
%
% If the user clicks on the correct/wrong image (specified by parameter
% whichSide), the returned parameter 'answerIsCorrect' is set to true/false.
%
% If the user clicks outside of either image, we remain in the loop until
% the mouse click occurs within one of the two image areas.
%
% If the user enter a 'q' key, the loop is terminated and the returned
% parameter 'quitExp' is set to true.
% 
%
% 12/10/12  npc Wrote it.
%
    % move cursor to center of screen
    screenSizeInPixels = win.DisplayInfo(win.WindowID).screenSizePixel;
    mouseHomeX = screenSizeInPixels(1)/2;
    mouseHomeY = screenSizeInPixels(2)/2;
    mglSetMousePosition(mouseHomeX, mouseHomeY,win.WindowID);
    
    % compute bounding rects for left and right image
    rect0          = SetRect(0,0, imageSize, imageSize);
    leftImageRect  = CenterRectOnPointd(rect0, leftImagePosition(1) + mouseHomeX, ...
                                        leftImagePosition(2) + mouseHomeY);
    rightImageRect = CenterRectOnPointd(rect0, rightImagePosition(1) + mouseHomeX, ...
                                        rightImagePosition(2) + mouseHomeY);
    
    quitExp         = false;
    keepLooping     = true;
    answerIsCorrect = false;
    
    while (keepLooping)
        
        if CharAvail
            % Get the key
            theKey = GetChar;
            
            if (theKey == 'q')
                keepLooping = false;
                quitExp = true;
            end   
        else  
            % Get the mouse state  
            mouseInfo = mglGetMouse(win.WindowID);
            
            % Check to see if a mouse button was pressed
            if (mouseInfo.buttons > 0)  
                [keepLooping, answerIsCorrect] = ...
                    CheckWhichImageWasSelected(mouseInfo.x, mouseInfo.y, leftImageRect, rightImageRect, whichSide);        
            end
        end
        
    end % while keepLooping
    
    if (~quitExp)
       GiveFeedback(answerIsCorrect); 
    end
    
end
    
function [keepLooping, answerIsCorrect] = CheckWhichImageWasSelected(mouseX, mouseY, leftImageRect, rightImageRect, whichSide)
% [keepLooping, answerIsCorrect] = CheckWhichImageWasSelected(win, mouseX, mouseY, leftImageRect, rightImageRect, whichSide)
% 
% Determine if the mouse click occurred within the left or the right image
% and determine whether the anser is correct or wrong. If the mouse click was
% outside of both image areas, remain in the polling loop.
%
% 12/10/12  npc Wrote it.
%
    answerIsCorrect = false;
    
    % If the user did not click on the left or the right image, remain in the polling loop
    if ((~IsInRect(mouseX, mouseY, leftImageRect))&&(~IsInRect(mouseX, mouseY, rightImageRect)))
        keepLooping = true;
        return;
    end
    
    % Ok, we have a hit. Exit mouse/keyboard polling loop 
    keepLooping = false;
    
    % Determine if the mouse click was on the correct image
    if (IsInRect(mouseX, mouseY, leftImageRect)) 
        % mouse click on LEFT image
        if (whichSide == 0)
           answerIsCorrect = true;
        end
    elseif (IsInRect(mouseX, mouseY, rightImageRect))
        % mouse click on RIGHT image
        if (whichSide == 1)
           answerIsCorrect = true;
        end
    end
    
end
