
function [increaseKey, decreaseKey, deltaKey, finishKey, ...
    increaseInputs, decreaseInputs, deltaIndex, rDeltas]=initialiseProcedure
increaseKey=KbName('up');            % key code for increasing red intensity
decreaseKey=KbName('down');          % key code for decreaseing red intensity
deltaKey=KbName('space');            % key code for changing red delta
finishKey=KbName('q');          % key code for finishing procedure and recording data

% THIS IS IMPORTANT: increase/decrease inputs are the messages telling Arduino
% how to change red intensity. increaseInput{i} and decreaseInput{i} have
% the same absolute value, but opposite sign (e.g., increaseInput{1}=20,
% decreaseInput{1}=-20. so that a single index can change the delta of
% both. in the current arduino code, 'q'/'r' change the intensity by 20
% bytes (0-255), 'w'/'t' by 5, 'e', 'y' by 1. To change how much each
% affects the code, you need to change the arduino FlickeringLight code.
% (by changing the if statements for each input signal)
increaseInputs={'q', 'w', 'e'}; 
decreaseInputs={'r', 't', 'y'};
deltaIndex=1;
rDeltas=[20, 5, 1];

end