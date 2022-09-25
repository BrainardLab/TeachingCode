
% if the code doesn't work, check that the arduino port (written in
% ConstantsHFP) is the right one (for windows, check Device Manager->ports)

function ArduinoImplementedHFP

% clear everything before starting program
delete(instrfindall)
clear
addpath('C:\Users\mediaworld\Documents\MATLAB\internship\HFP_Code\HFP_Code');

% call arduino object
serialObj=serialport(ConstantsHFP.serialPort, 9600);

% create variables
[increaseKey, decreaseKey, deltaKey,... 
    finishKey, ...
    increaseInputs, decreaseInputs, ...
    deltaIndex, rDeltas]=initialiseProcedure;


% adjust flicker settings
while true
    fopen(serialObj);
    
    ListenChar(0)
    DoYouWantToStart=input('would you like to run a new trial? (yes or no)  ', 's');
    if strcmp(DoYouWantToStart, 'yes')==0
        disp('aborting mission')
        break;
    end
    ListenChar(2)


    % setup random initial flicker setting ('s' is the message, in the 
    % FlickeringLight.ino code that stands for randomised start)
    fprintf(serialObj, 's');
    

    % Record red and green initial values for final save
    rInit=read(serialObj, 6, "char");
    gInit=read(serialObj, 6, "char");

    pause(2)
    disp('starting new trial');
    
    % run trial
    while true
        % get keyboard input
        [secs, keyCode, deltaSecs]=KbPressWait();

        
        if keyCode(increaseKey)

            % if user asks to increase light, select increase amount
            % corresponding to current delta. See initialiseProcedure.m for more info
            arduinoInput=increaseInputs{deltaIndex};

            fprintf(serialObj, arduinoInput);

        elseif keyCode(decreaseKey)
            
            % decrease intensity. for more info look at
            % initialiseProcedure.m
            arduinoInput=decreaseInputs{deltaIndex};

            fprintf(serialObj, arduinoInput);
            
        elseif keyCode(deltaKey)
            deltaIndex=deltaIndex+1;
            if deltaIndex>length(rDeltas)
                deltaIndex=1;
            end
        
        elseif keyCode(finishKey)

            disp('Printing final results... please wait')
            % print initial and final red value
            
            fprintf(serialObj, 'f');
            

            %in case you want to eliminate one of these "read" commands,
            %remember to cancel the correspondent part in the "f" if
            %statement in the FlickeringLight arduino code
            initialRed=read(serialObj, 6, "char");
            finalRed=read(serialObj, 6, "char");
            fprintf("Initial Red Value = %d,\n", str2num(initialRed));
            fprintf("Final Red Value = %d \n", str2num(finalRed));

            % save everything
            ListenChar(0)
            WantToSave=input("Would you like to save these data?  (yes or no)  ", 's');
            if strcmp(WantToSave, 'yes')
                disp("Saving results...");
                SaveHFPResultsTable(finalRed, rInit, gInit);
            
            else
                disp("Results not saved");
            end
            ListenChar(2)
            break;
        else
            continue;
        end
    end
delete(instrfindall);

%save data

end
ListenChar(0)