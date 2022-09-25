#include <Wire.h>
#include <stdio.h>
#include <stdlib.h>
#include <Keyboard.h>

//before starting remember to check that tools/port shows the port with the arduino hardware

// define twopi (2*pi) and the frequency
const double TWOPI=6.2831853;
const int Freq = 25;                               //FREQUENCY

// define red and green output pins (red=D6, green=D5)
const int rOutPin=6;
const int gOutPin=5;

// define all variables (amplitude of red ang green, red minimum, maximum, and start value (0-255) 
// green value (0-255) red phase setting (degrees), red phase (radiants), red and green wave value, 
// time. 
double gAmp;
double rAmp;
int rValMax=255;
int rValMin=0;
double rVal=round(random(rValMax*.4, rValMax*.6));  //RED VAL
double rValinit = rVal;                         
double gVal=255;                                    //GREEN VAL
int rPhaseSetting=180;
double rPhase=rPhaseSetting/360.0*TWOPI;;
double gWave;
double rWave;
unsigned long time;

// define the input signal from matlab. q,w,e will cause a 20, 5, 1 bytes increase and r,t,y will 
// cause a 20, 5, 1 bytes decrease in the red intensity. 
int InputFromMatlab;

void setup() {
  // Start communication with computer (baud rate 9600, has to be the same as the receiving program/
  // serial monitor)
  Serial.begin(9600);
  
  // set red ang green pins as output pins
  pinMode(rOutPin, OUTPUT);
  pinMode(gOutPin, OUTPUT);

  // calculate starting red and green amplitudes (0-1). 
  rAmp=(double)rVal/255.0;
  gAmp=(double)gVal/255.0;

  // find current time
  time=micros();  

  // calculate current output value based on current time (as the loop repeats, the values will follow
  // a sinewave). rPhase allows red to peak when green is lowest and viceversa. the "/2+.5" part is 
  // necessary to put the [-1 1]-ranged sinewave into range [0 1].
  rWave=(sin(TWOPI*(float)Freq*(float)time/1000000+rPhase)/2.0+0.5)*rAmp;
  gWave=(sin(TWOPI*(float)Freq*(float)time/1000000)/2.0+0.5)*gAmp;

}

void loop() {
  // Send values to arduino hardware. LEONARDO (or Leo if you prefer) requires 0-255 input, where
  // 0 is the maximum intensity and 255 is the minimum. This inversion here allows us to work with 
  // 255 as max and 0 as min in all the rest of the code.
  analogWrite(rOutPin,255-(rWave*255));
  analogWrite(gOutPin, 255-(gWave*255));
  
  // find new amplitudes
  rAmp=(double)rVal/255;
  gAmp=(double)gVal/255;

  // find new time to move along the sinewave
  time=micros();  

  // find output values at this time. See above for explanation
  rWave=(sin(TWOPI*(float)Freq*(float)time/1000000+rPhase)/2.0+0.5)*rAmp;
  gWave=(sin(TWOPI*(float)Freq*(float)time/1000000)/2.0+0.5)*gAmp;

 
  
  
  // HERE STARTS THE PART OF CODE WHERE THE INPUT FROM MATLAB CHANGES THE INTENSITY OF THE RED LED
  if (Serial.available()){
  InputFromMatlab=Serial.read();
  if (InputFromMatlab=='q'){
    rVal=rVal+20;
    if (rVal>rValMax){
      rVal=rValMax;
    }
  }
  if (InputFromMatlab=='w'){
    rVal=rVal+5;
    if (rVal>rValMax){
      rVal=rValMax;
    }
  }
  if (InputFromMatlab=='e'){
    rVal=rVal+1;
    if (rVal>rValMax){
      rVal=rValMax;
    }
  }    
  if (InputFromMatlab=='r'){
    rVal=rVal-20;
    if(rVal<rValMin){
      rVal=rValMin;
    }
  }
  if (InputFromMatlab=='t'){
    rVal=rVal-5;
    if(rVal<rValMin){
      rVal=rValMin;
    }
  }
  if (InputFromMatlab=='y'){
    rVal=rVal-1;
    if(rVal<rValMin){
      rVal=rValMin;
    }
  }
  if (InputFromMatlab=='f'){
    // Send initial and final red intensity to MATLAB
    Serial.print(rValinit);
    Serial.print(rVal);

  }
  if (InputFromMatlab=='s'){
    // set random initial red intensity (between .4 and .6 quantiles) for new trial. And save
    // new initial settings
    rVal=round(random(rValMax*.4, rValMax*.6));
    rValinit=rVal;
    Serial.print(rVal);
    Serial.print(gVal);
  }
  InputFromMatlab=0;
}
}
