function WaitForMouseClick(win, timeOut)
% WaitForMouseClick(win, timeOut)
%
% This function goes in a busy wait loop until the user presses a mouse button.
% It uses mgl to assess the mouse state.
% After the first mouse click is registered it keeps reading the mouse
% state for a period equal to timeOut seconds.
%
% 12/10/12  npc Wrote it.

    keepLooping = true;
        
    while (keepLooping)   
    
       % Get the current mouse state.  
       mouseInfo = mglGetMouse(win.WindowID);     
       
       if (mouseInfo.buttons > 0)     
          keepLooping = false;     
       end
       
    end % while keepLooping
    
    % consume any more clicks for a period of timeOut seconds after the first click
    tend = GetSecs + timeOut;
    
    while (GetSecs < tend)
        mouseInfo = mglGetMouse(win.WindowID);
    end
            
end 