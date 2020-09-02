% Changes color from bytes (0-255) to PWM (0 to 1 scale). Because the RGB
% LED is common cathode, a value of 0 PWM is the brightest, and 1 PWM is
% off.

function pwm = bytesToPWMRGB(byte)
    pwm = (255 - byte) / 255;
end