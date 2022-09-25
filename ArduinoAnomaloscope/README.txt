
This directory contains Matlab software for running a Rayleigh match on the arduino anomaloscope.  Instructions for building the kit and making a kit are in the README.txt file in the directory xxxMakingOne.

Contributed software is in the directory xxxContributed.

Software installation:

These instructions are for a Mac.  Presumably similar actions will get it to work with Windows or Linux,
but we have not tested this ourselves.

1) Download the repository that contains the code for controlling the device.  This
is on github.com at
                https://github.com/BrainardLab/TeachingCode
If you haven't used git before, the simplest thing is to use the little green "Code" button
you'll see on this page and select the "Download Zip" option.  This repository
can go anywhere on your computer.
 
2) Get the Psychophysics Toolbox (psychtoolbox.org) and put it onto your Matlab path.
You can either download this from the psychtoolbox.org site, or directly from github
(as above) at
                https://github.com/Psychtoolbox-3/Psychtoolbox-3
 
3) Use the MATLAB "Add On" manager to install their arduino support toolbox.  General
instructions for Add Ons are here:
                https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html?s_tid=mwa_osa_a
You can find the arduino support by typing "arduino" into the Add On search box.
 
I think this is all you need, but it may be some dependency I've forgotten about has crept
into the code.  In any case, once you do the above you can try it.
 
Plug the USB cable into your computer, and then run the program ArduinoAnomaloscope/ArduinoRayleighMatch.m.
 
If it is working, you'll see a message that it's updating the firmware in the arduino, which takes a few minutes,
and then the LEDs should turn on and you should be able to control them with key presses.  I've pasted
the available commands below.  This is the program John used at ICVS to set a match.

We have found that updates to the OS and/or Matlab can change the name of the USB device that needs to
be opened to talk to the arduino.  We have tried to be clever about finding the write name automatically,
but it could fail in the future.  

