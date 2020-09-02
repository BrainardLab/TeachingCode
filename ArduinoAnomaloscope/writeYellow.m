% Controls the Yellow LED. Takes two arguments: the arduino object and the
% Y color code to be displayed. The color values should
% go from 0 to 255, with 255 being the brightest. 
function writeYellow(a, yellow)
    pwmYellow =    bytesToPWMYellow(yellow);
    writePWMDutyCycle(a, "D9", pwmYellow);
end