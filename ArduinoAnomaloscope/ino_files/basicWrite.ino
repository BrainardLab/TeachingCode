/* Basic example of how to confirm
 * that pins are working, communicating
 * directly through Arduino. */

int redPin = 3;
int greenPin = 6;
int bluePin = 5;
int yellowPin = 9;

#define COMMON_ANODE // not necessary, but could be used

void setup ()
{
	pinMode(redPin, OUTPUT);
	pinMode(greenPin, OUTPUT);
	pinMode(bluePin, OUTPUT);
	pinMode(yellowPin, OUTPUT);
}

void loop()
{
	// turn the yellow pin on
	digitalWrite(yellowPin, LOW);

	// set the RGB LED
	analogWrite(redPin, 29);
	analogWrite(greenPin, 220);
	analogWrite(bluePin, 0);

	delay(100);
}