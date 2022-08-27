Brief explanation of the code (Matlab and Arduino). The code was written on windows, and is based on 
Arduino Leonardo (what might be relevant is the pin number of the red and green LED and/or the maximum 
range of intensities, which for Leonardo is 0-255).


Parts of this document
-Arduino
-Matlab
  - ConstantsHFP
  - Initialise Procedure
  - ArduinoMethodOfAdjustmentHFP
  - SaveHFPResultsTable
  
-Running the program
-Typical Problems


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ARDUINO:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

(NB: in general I've put extensive notes in the arduino code to guide understanding).
!!! the arduino code contains the initial red and green values, as well as the frequency


when, at the start of each new trial, it receives the 's' command, it will randomise the starting red 
intensity (between .4 and .6 of the total range of the red LED) and save it as rValinit


Serial communications are read in the loop whenever one is available (Serial.available())
a SINGLE char value is read everytime Serial.read() is called

the accepted serial 'commands' from matlab (via Serial.read) are 
- q = +20
- w = +5
- e = +1
- r = -20
- t = -5
- y = -1

- f = sends initial red value and final red value through serial port (in this order)

the code will calculate the output values (from 0 to 255) based on a sinewave in the form


rWave=(sin(TWOPI*(float)Freq*(float)time/1000000+rPhase)/2+.5)*rAmp

EXPLANATION OF THE SINEWAVE FORMULA IS PRESENT IN THE ARDUINO CODE ITSELF.

TWOPI (i.e., 2*pi), Frequency and rPhase are all defined at the beginning of the arduino code.
time is calculated in each loop by the function micros(), i.e., the number of microseconds from the
beginning of the code

rAmp is derived from rVal/255. rVal is changed via some "if" statements, requiring some serial input from 
MATLAB.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MATLAB:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                  ConstantsHFP.mat

Defines some basic constants: 
-Arduino Port
-minimum red amplitude
-maximum red amplitude


                              initialiseProcedure.m


Defines the command keys (increaseKey=up, decreaseKey=down, deltaKey=space, finishKey=q)
to see what these keys do, check ArduinoMethodOfAdjustmentHFP.m

It also defines the messages to send arduino to ask to increase the red output (increaseInputs)
and to decrease it (decreaseInputs)

deltaIndex is used to decide by how much to change the arduino output (increaseInput{1} and
decreaseInput{1} change the output by 20, {2} change it by 5, {3} change it by 1, see code for more info')

rDeltas are also defined. 

WATCH OUT. TO CHANGE THE DELTAS, ONE NEEDS TO ACTUALLY CHANGE THE ARDUINO CODE "IF" STATEMENTS 
DIRECTLY (AT THE END OF THE ARDUINO LOOP). THE RED DELTAS IN MATLAB ARE ONLY USED FOR REFERENCE, 
TO ALLOW THE DELTAINDEX TO GET BACK TO 1 ONCE IT GETS OVER 3 (which is the number of deltas available).



                            ArduinoMethodOfAdjustmentHFP.m

There are extensive comments in the code itself, if needed


The code

- deletes all existing variables and active ports 
- opens the arduino and establishes the Baud rate (9600). Baud rate needs to be the same as
in Serial.begin(), in the Arduino "setup" sections.

- gets command-key codes, arduino outputs, deltaindex, and red deltas from initialiseProcedure.m


- opens the serial port for communication (this allows to write input into arduino) via fopen
All commands to Arduino are sent as single characters, through serial communication via fprintf()

-asks whether to start new trial

the MATLAB loop
- sends requirement to randomise the first red Intensity and records it. ('s')
- records initial red and green values (read function)
- waits for keyboard input and sends the corresponding command to arduino (increaseKey will
ask arduino to increase output by the current delta amount, as specified by the arduino code).
see above the part in initialiseProcedure.m dedicated to deltaIndex for more information



-when the finishKey is pressed, the final values are recorded (as chars) and converted to numbers

-everything is saved via the SaveHFPResultsTable. 


the code ends by closing everything


            
                               SaveHFPResultsTable.m

Creates a table of six columns, with variables:

-ParticipantCode: research participant code (rp_001, rp_002 and so on) this changes between every
two observations, and does not take account the fact that a participant might have run through
the test multiple times

-DateTime:1x6 array storing year, month, day, hour, minute, and second that the procedure finished

-RedValue: the value (in 0-255 bytes) of the final red Intensity

-GreenValue: the final green intensity (in 0-255 bytes)

-InitialRedSetting: the initial red intensity value (randomly determined by Arduino at the beginning
of each trial. for more info see beginning of the Arduino section in this document.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Running the program

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To run the program: (this is based on windows 11)

- connect the arduino board via USB cable
- Open "Device Manager" and select "Ports" (or something like that)
- Check where arduino is, it should be written as somehing like 'COM7'
- Open the FlickeringLight arduino code
- In the top bar select "Tools", click on "Board" and select "Leonardo"
- In "Tools", also click on "Port" and select the right port.
- click on the arrow under the top bar to upload the code on arduino. Once it's done uploading, it 
should start flickering in a few seconds or send an error below the code

- Once the code is correctly uploaded, close the arduino code and open the matlab code.
- MAKE SURE THAT THE ConstantsHFP.SerialPort is the right port
- Run ArduinoMethodOfAdjustmentHFP.m 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Typical Problems

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Typical problems include:

-board isn't found at current port in which case, select correct port (in arduino or in matlab, depending
on where the error arose)

- no board is connected. Well, connect it!

- Arduino doesn't like when more than one program is trying to tell it what to do. 
Matlab might complain if other matlab programs have opened the serial port or if an arduino code is
still open. Close all other codes.  (also see below)

- Similarly, when the arduino code cannot be uploaded if matlab is using arduino already.
To close the matlab-Arduino communication, just type "clear" and "delete(instrfindall)" in the
matlab command window.





