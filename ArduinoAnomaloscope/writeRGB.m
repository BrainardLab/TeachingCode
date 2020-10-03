function writeRGB(a, red, green, blue)
% Write the R, G, and B channels of the RGB LED.
%
% Syntax:
%    writeRGB(a, red, green, blue)
%
% Description:
%    Control the R,G, and B channels of the RGB LED.
%
%    Requires Matlab arduino toolbox, and designed to
%    match our teaching anomaloscope.
%
% Inputs:
%    a       - Arduino object, obtained via a = arduino;
%    red     - Red channel value (0 - 255; 255 brightes)
%    green   - Green channel value (0 - 255; 255 brightes)
%    blue    - Blue channel value (0 - 255; 255 brightes)
%
% Outputs:
%    None.
%
% See also: bytesToPWMRGB, writeYellow, bytesToPWMYellow.

% History:
%    08/xx/20  lk  Wrote initial version
%    10/03/20  dhb Current version and comments

% Convert input values to pulse width modulation value
pwmRed = bytesToPWMRGB(red);
pwmGreen = bytesToPWMRGB(green);
pwmBlue = bytesToPWMRGB(blue);

% Write out the pwm values.
writePWMDutyCycle(a, "D6", pwmRed);
writePWMDutyCycle(a, "D5", pwmGreen);
writePWMDutyCycle(a, "D3", pwmBlue);

end