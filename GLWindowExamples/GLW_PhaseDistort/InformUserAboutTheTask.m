function InformUserAboutTheTask(pThreshold, trialsDesired)
% InformUserAboutTheTask
%
% Provide instructions for the task (shown in the command window)
%
   fprintf('\n**************************************\n\n');
   fprintf('Next you will run an experiment to see how much phase information\n');
   fprintf('is required to discriminate between Reagan and Einstein.\n');
   fprintf('On each trial of the experiment, you will see two images.\n');
   fprintf('Your task is to indicate which is Reagan.  To make the task\n');
   fprintf('hard, the images you see will have identical amplitude spectra\n');
   fprintf('(the mean of the two original images) and their phase spectra\n');
   fprintf('will be titrated (via a parameter p) with a random phase image.\n');
   fprintf('When p is 0, the phase of both images becomes completely\n');
   fprintf('random.  When p is 1, each image has its proper phase.\n');
   fprintf('The Quest algorithm will be used to find your %g%% correct\n',100*pThreshold);
   fprintf('threshold on parameter p for discriminating Reagan from Einstein.\n');
   fprintf('The program is set to run %g trials.\n\n',trialsDesired);
   fprintf('On each trial, use the cursor to click on Reagan or press\n');
   fprintf('the key ''q'' to quit early.  A single beep indicates\n');
   fprintf('correct, two beeps indicates incorrect.\n\n');
   fprintf('Click the mouse now to proceed.\n');

end
