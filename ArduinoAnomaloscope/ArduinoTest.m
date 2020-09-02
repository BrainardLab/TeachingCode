%% Main code. This is simple and can be easily changed by your students, or built into another measurement system.

if (~exist('arduinosetup.m','file'))
    addpath(genpath('/Users/dhb/Documents/MATLAB/SupportPackages/R2020a'))
end

% necessary to get the arduino working
clear a
a = arduino;

% call to turn on LEDs
writeYellow(a, "D9", 128);
writeRGB(a, 255, 255, 0);

end


% %delay for as long as necessary to perform measurements
% pause;
% 
% nLevels = 100;
% levels = linspace(0,1,nLevels);
% for jj = 1:5
%     for ii = 1:nLevels
%         writePWMDutyCycle(a, "D9", levels(ii));
%         WaitSecs(1/nLevels);
%     end
%     for ii = nLevels:-1:1
%         writePWMDutyCycle(a, "D9", levels(ii));
%         WaitSecs(1/nLevels);
%     end
% end
% 
% writeYellow(a, 128);
% writeRGB(a, 255, 128, 255);  
%  
% pause;

%clear a









