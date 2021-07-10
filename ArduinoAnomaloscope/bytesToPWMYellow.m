function pwm = bytesToPWMYellow(byte)
% Convert 0-255 yellow value to [0-1] pulse width modulation value.
%
% Syntax:
%    pwm = bytesToPWMYellow(byte)
%
% Description:
%    Changes color from bytes (0-255) to PWM (0 to 1 scale), for the yellow
%    LED. For the yellow LED, 0 pwm is off and 1 is full on.
%
%    Requires Matlab arduino toolbox, and designed to
%    match our teaching anomaloscope.
%
% Inputs:
%    byte    - yellow value (0 - 255; 255 brightest)
%
% Outputs:
%    pwm     - Corresponding pwm value.
%
% See also: writeRGB, writeYellow, bytesToPWMRGB.

% History:
%    08/xx/20  lk  Wrote initial version
%    10/03/20  dhb Current version and comments

% Do the conversion
pwm = (255-byte) / 255;

end
