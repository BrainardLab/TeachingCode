%red is test light, green is reference light
classdef ConstantsHFP
    properties (Constant=true)
        %arduino
        serialPort=('COM9');
   
        minRedAmp=0;
        maxRedAmp=255;    
    end

end