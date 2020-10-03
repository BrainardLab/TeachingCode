function writeYellow(a, yellow)
% Write the value of the yellow LED.
%
% Syntax:
%    writeYellow(a, yellow)
%
% Description:
%    Control the yellow LED.
%
%    Requires Matlab arduino toolbox, and designed to
%    match our teaching anomaloscope.
%
% Inputs:
%    a       - Arduino object, obtained via a = arduino;
%    yellow  - Yellow LED value (0 - 255; 255 brightest)
%
% Outputs:
%    None.
%
% See also: writeRGB, bytesToPWMRGB, bytesToPWMYellow.

% History:
%    08/xx/20  lk  Wrote initial version
%    10/03/20  dhb Current version and comments

% Convert input value to pulse width modulation and write
pwmYellow =    bytesToPWMYellow(yellow);
writePWMDutyCycle(a, "D9", pwmYellow);

end