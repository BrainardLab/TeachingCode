% Changes color from bytes (0-255) to PWM (0 to 1 scale).

function pwm = bytesToPWMYellow(byte)
    pwm = byte / 255;
end
