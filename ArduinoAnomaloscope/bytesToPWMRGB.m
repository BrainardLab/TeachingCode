function pwm = bytesToPWMRGB(byte)
% Convert 0-255 R,G, or B value to [0-1] pulse width modulation value.
%
% Syntax:
%    pwm = bytesToPWMRGB(byte)
%
% Description:
%    Changes color from bytes (0-255) to PWM (0 to 1 scale). Because the RGB
%    LED is common cathode, a value of 0 PWM is the brightest, and 1 PWM is
%    off.
%
%    Requires Matlab arduino toolbox, and designed to
%    match our teaching anomaloscope.
%
% Inputs:
%    byte    - R, G, B value (0 - 255; 255 brightest)
%
% Outputs:
%    pwm     - Corresponding pwm value.
%
% See also: writeRGB, writeYellow, bytesToPWMYellow.

% History:
%    08/xx/20  lk  Wrote initial version
%    10/03/20  dhb Current version and comments

% Do the conversion
pwm = (255 - byte) / 255;

end