function ShowTheStimulus(win, targetImageStruct, nonTargetImageStruct, whichSide, leftImagePosition, rightImagePosition)
% ShowTheStimulus(win, phaseDistortedImage1Struct, phaseDistortedImage2Struct, whichSide, leftImagePosition, rightImagePosition)
%
% Add two image objects to the current GLWindow (win) object in the positions specified
% by the leftImagePosition and rightImagePosition parameters. The target image is placed
% at the leftImagePosition if whichSide == 0, and at the rightImagePosition otherwise.
%
% 12/10/12  npc Wrote it.
%

    if (whichSide == 0) 
        % target position on the left side
        win.addImage(leftImagePosition, size(targetImageStruct.ImageMatrix), ...
                     targetImageStruct.RGBdata, 'Name' , targetImageStruct.Name);
             
        win.addImage(rightImagePosition, size(nonTargetImageStruct.ImageMatrix), ...
                     nonTargetImageStruct.RGBdata, 'Name' , nonTargetImageStruct.Name);
    else  
        % target position on the right side
        win.addImage(rightImagePosition, size(targetImageStruct.ImageMatrix), ...
                     targetImageStruct.RGBdata, 'Name' , targetImageStruct.Name);
             
        win.addImage(leftImagePosition, size(nonTargetImageStruct.ImageMatrix), ...
                     nonTargetImageStruct.RGBdata, 'Name' , nonTargetImageStruct.Name);
    end
        
    % Render the scene
    win.draw;
end
