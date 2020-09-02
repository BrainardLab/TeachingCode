% Controls the RGB LED. Takes four arguments: the arduino object and the
% RGB color code to be displayed. The red, green, and blue values should
% all go from 0 to 255, with 255 being the brightest. 
function writeRGB(a, red, green, blue)
    pwmRed =    bytesToPWMRGB(red);
    pwmGreen =  bytesToPWMRGB(green);
    pwmBlue =   bytesToPWMRGB(blue);
    writePWMDutyCycle(a, "D6", pwmRed);
    writePWMDutyCycle(a, "D5", pwmGreen);
    writePWMDutyCycle(a, "D3", pwmBlue);
end