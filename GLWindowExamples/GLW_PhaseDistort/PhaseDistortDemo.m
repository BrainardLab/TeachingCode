function PhaseDistortDemo(varargin)
% PhaseDistortDemo([generatePhaseFieldFromPinkNoise, useSoftCircularAperture, imageResizingFactor, questIterations]);
%
% Measures how much spatial phase information you need to discriminate two images.
% When you run it, the command window will come forward and explain what is going on.
% No gamma correction is done on the images before display.
%
% Usage: There are 3 ways to run PhaseDistortDemo.  
%        (1) type PhaseDistortDemo() to run with the default (old) set of parameters, or 
%        (2) type PhaseDistortDemo(param1, param2, param3, param4) to run with a desired set
%        of parameters (see header for parameter definitions), or
%        (3) type PhaseDistortDemoGUI to set the parameters and visualize the results via a GUI
%
% 6/29/96   dhb,gmb,if  Wrote it.
% 3/4/97    dhb	 Bells, whistles, and comments.
% 3/5/97    dhb	 More enhancements in response to dgp comments.
% 4/11/97   dhb	 Fixed small bug, pThreshold was undefined at time of first use.
% 3/12/98   dgp	 Use Ask.
% 3/25/98   dgp	 In line 80, delete illegal x argument to Ask.
% 7/9/98    dgp  Cope when GetClut is not available.
% 4/8/02    awi  -Passed window pointer to Screen 'GetClut' instead of screen number. 
%                Windows wants a screen number.
%               -Previosly we opened an onscreen window then positioned the 
%                Matlab command window within view and printed instructions.  
%                This doesn't work in Windows because we can't control the 
%                command window So instead we close the onscreen window to 
%                display the instructions under Windows. 
% 12/5/12   jbj  Small updates for OSX psychtoolbox
% 12/10/12  npc  Re-wrote demo using GLWindow commands for drawing and 
%                mgl-based mouse interaction
%                Other additions :
%                (1) Introduced option to compute random phase field from 
%                    'pink'(1/f) spatial noise images
%                (2) Introduced option to taper images with a soft circular
%                    aperture to make the task harder
%                (3) Introduced option to enlarge input images (which are
%                    128x128) to any desired size
%                (4) Modularized code overall
% 12/13/12  npc  Added extra input argument which specifies the number of
%                trials desired for the Quest procedure

    if (nargin >= 4)   
        % parse inputs
        generatePhaseFieldFromPinkNoise = varargin{1};
        useSoftCircularAperture         = varargin{2};
        imageResizingFactor             = varargin{3};
        QuestTrials                     = varargin{4};
        
        % check on input parameter values
        if (generatePhaseFieldFromPinkNoise ~= 1)
            generatePhaseFieldFromPinkNoise = false;
        end
        
        if (useSoftCircularAperture ~= 1)
            useSoftCircularAperture = false;
        end
        
        if (imageResizingFactor < 1)
            imageResizingFactor = 1;
        end
        
        if (QuestTrials < 2)
            QuestTrials = 1;
        end
        
        if (nargin == 5)
            figHandle = varargin{5};
        else
            figHandle = 1;
        end
    else 
        % Specify default options
        % Flag for method of phase field generation.
        % If set to true,  the code in OneOverFnoisePhaseField.m is called
        % If set to false, the code in RandPhasePD.m is called
        generatePhaseFieldFromPinkNoise = false;

        % Flag for windowing test images with a soft circular aperture.
        % If set to true, the images are windowed by a soft circular aperture. This
        % eliminates some sprurious information at the edges which may make
        % the task easier, for example Reagan's dark hair edge (upper-left corner).
        % If set to false, the images are not windowed.
        useSoftCircularAperture = false;

        % Image resizing factor. 
        % If set to 1.0, the original images (128x128) are presented. 
        % If set to > 1.0, images that are resized by that factor.
        imageResizingFactor = 1.0;
        
        % Number of trials in the Quest procedure
        QuestTrials = 40;
        
        % output will be generated in Figure 1
        figHandle = 1;
    end

    % add all subfolders (because the images reside in a subdirectory)
    addpath(genpath(pwd));

    % Get information about the displays attached to our system.
    displayInfo = mglDescribeDisplays;

    % We will present everything to the last display. Get its ID.
    lastDisplay = length(displayInfo);

    % Get the screen size
    screenSizeInPixels = displayInfo(lastDisplay).screenSizePixel;

    % Load in the images from the disk, resize them and compute their spectra.
    [image1Struct, image2Struct, imageSize] = LoadImagesAndComputeTheirSpectra(imageResizingFactor);

    % Exit if input images are not found.
    if (imageSize == 0)
        return;
    end

    try 
        % Create a full-screen GLWindow object which will be used to control 
        % our experimental display.
        win = GLWindow( 'SceneDimensions', screenSizeInPixels, ...
                        'windowID',        lastDisplay);

        % Open the window            
        win.open;

        % Set the screen position for the instructional text.
        theShift      = round(imageSize*0.6);
        textPosition  = [0 theShift+30+imageSize/2];

        % Display instructional text on the GLWindow.
        textToDisplay = sprintf('Click on the screen to proceed');
        win.addText(textToDisplay, 'Center', textPosition, 'FontSize', 60, ...
                   'Color', [1.0 0.5 0.5], 'Name', 'InstructionalText');

        % Render the scene
        win.draw;

        % Wait for a character keypress.
        ListenChar(2);
        FlushEvents;

        % Provide introductory remarks (shown in the command window)
        ProvideIntroductoryRemarks;
        WaitForMouseClick(win, 0.2);

        % Add original images to the GLWindow (top row)
        centerPosition = [-theShift theShift];
        win.addImage(centerPosition, size(image1Struct.ImageMatrix), ...
                     image1Struct.RGBdata, 'Name', image1Struct.Name);

        centerPosition = [ theShift theShift];
        win.addImage(centerPosition, size(image2Struct.ImageMatrix), ...
                     image2Struct.RGBdata, 'Name', image2Struct.Name);

        % Compute amplitude-swapped images
        [phaseDistortedImage1Struct, phaseDistortedImage2Struct] = ...
            ComputeAmplitudeSwappedImage(image1Struct, image2Struct, false); 

        % Add amplitude-swapped images to the GLWindow (bottom row)
        centerPosition = [-theShift -theShift];
        win.addImage(centerPosition, size(phaseDistortedImage1Struct.ImageMatrix), ...
                     phaseDistortedImage1Struct.RGBdata, ...
                     'Name', phaseDistortedImage1Struct.Name);

        centerPosition = [ theShift -theShift];
        win.addImage(centerPosition, size(phaseDistortedImage2Struct.ImageMatrix), ...
                     phaseDistortedImage2Struct.RGBdata, ...
                     'Name', phaseDistortedImage2Struct.Name);

        % Update instructional text on the GLWindow
        win.deleteObject('InstructionalText');
        textToDisplay = sprintf('Click on the screen to start the task');
        win.addText(textToDisplay, 'Center', textPosition, 'FontSize', 60, ...
                   'Color', [0.5 1.0 0.5], 'Name', 'InstructionalText');

        % Render the scene
        win.draw;

        % Set up QUEST Parameters
        grainFactor     = 20;
        tGuess          = 0.35;
        beta            = 3.5;
        delta           = 0.01;
        gamma           = 0.5;
        pThreshold      = 0.82;
        tGuessSd        = 4.0;
        trialsDesired   = QuestTrials;

        q = QuestCreate(tGuess*grainFactor, tGuessSd*grainFactor, pThreshold,...
                        beta, delta, gamma);
        wrongRight = str2mat('wrong','right');

        % Provide instructions about the task (shown in the command window).
        InformUserAboutTheTask(pThreshold, trialsDesired);
        WaitForMouseClick(win, 0.0);

        % Remove the original image objects from our GLwindow. We do not need them anymore.
        win.deleteObject(image1Struct.Name);
        win.deleteObject(image2Struct.Name);

        % Set the positions of the two test images.
        leftImagePosition  = [-theShift 0];
        rightImagePosition = [ theShift 0];

        % Update instructional text in the GLWindow
        win.deleteObject('InstructionalText');
        textToDisplay = sprintf('Click on Reagan, ''q'' to quit');
        win.addText(textToDisplay, 'Center', textPosition, 'FontSize', 60, ...
                   'Color', [0.5 0.7 0.7], 'Name', 'InstructionalText');

        % Preallocate array to hold the data
        theData = zeros(trialsDesired,4);

        % Now run the trials
        for trialNo = 1: trialsDesired

            % remove the previous phase-distorted image objects from our GLWindow
            win.deleteObject(phaseDistortedImage1Struct.Name);
            win.deleteObject(phaseDistortedImage2Struct.Name);

            % Get trial level.  Force it into range.
            % pTest: 1.0 = keep all phase information
            %        0.0 = discard all phase information
            pTest = QuestQuantile(q)/grainFactor;

            % Compute updated phase-distored images based on pTest
            [phaseDistortedImage1Struct, phaseDistortedImage2Struct] = ...
                ComputePhaseDistortedImage(pTest, image1Struct, image2Struct, ...
                                           generatePhaseFieldFromPinkNoise, ...
                                           useSoftCircularAperture);

            % Choose a side for the target image at random
            whichSide = CoinFlip(1,0.5);

            % Show the stimulus on the GLWindow
            ShowTheStimulus(win, phaseDistortedImage1Struct, phaseDistortedImage2Struct, ...
                            whichSide, leftImagePosition, rightImagePosition);

            % Aquire user-response (mouse and/or keyboard events)
            [correct, quitExp] = GetTheResponse(win, imageSize, whichSide, ...
                                 leftImagePosition, rightImagePosition);

            % Exit trial loop if a quit button was pressed
            if (quitExp) break; end

            % Update QUEST
            q     = QuestUpdate(q, pTest*grainFactor, correct);
            pEst  = QuestMean(q) / grainFactor;
            sdEst = QuestSd(q) / grainFactor;

            % Store the data
            theData(trialNo,1) = pTest;
            theData(trialNo,2) = correct;
            theData(trialNo,3) = pEst;
            theData(trialNo,4) = sdEst;

        end % for trialNo

        if (~quitExp)
            % Get the final threshold
            pEst  = QuestMean(q)/grainFactor;
            sdEst = QuestSd(q)/grainFactor;

            % Print results
            fprintf('\n**************************************\n\n');
            fprintf('Threshold estimate is %4.2f ± %.2f\n\n',pEst,sdEst);
            fprintf('Array theData contains the data.  It has four\n');
            fprintf('columns.  The first column provides for each trial\n');
            fprintf('the p value tested.  The second column tells\n');
            fprintf('whether the trial was right (1) or wrong (0)\n');
            fprintf('The third column gives Quest''s running threshold estimate.\n');
            fprintf('The fourth column gives Quest''s running estimate standard\n');
            fprintf('deviation.\n\n');
            fprintf('The plot shows how the threshold estimate\n');
            fprintf('converged over trials.\n\n');
            fprintf('DHB''s threshold in this task was once, long ago, about 0.25.\n\n');
        end
        
        % Plot the threshold estimates.
         if (figHandle == 1)
            figure(1);
            clf;
         else
            axes(figHandle); 
         end
         set(gca, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 10);
         plot(theData(:,3),'bs-', 'LineWidth', 2);
         xlabel('Trial number', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12);
         ylabel('Value of p', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12);
         title('Threshold estimate vs. Trial Number', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12);
        

        % Close the window.
        win.close;
        ListenChar(0);
     
    catch e
        disp('An exception was raised');

        % Disable character listening.
        ListenChar(0);

        % Close the window if it was succesfully created.
        if ~isempty(win)
            win.close;
        end

        % Send the error back to the Matlab command window.
        rethrow(e);

    end  % try
end