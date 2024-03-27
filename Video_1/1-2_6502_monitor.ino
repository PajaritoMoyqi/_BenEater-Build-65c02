/*
  Print each signal comes from A0-A15 pins of W65C02S
  only when clock pulse rises.
  Address pins and Clock pin are connected to Arduino.
*/

// connected pin numbers
const char ADDR[] = { 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52 };
#define CLOCK 2

void setup()
{
    // put setup code that runs once
    for ( int n = 0; n < 16; n += 1 )
    {
        pinMode( ADDR[n], INPUT );
    }
    pinMode( CLOCK, INPUT );

    // print detected signal only when clock pulse rises
    attachInterrupt( digitalPinToInterrupt( CLOCK ), onClock, RISING );

    Serial.begin( 57600 );
}

void onClock()
{
    // print all 16-bits
    for ( int n = 0; n < 16; n += 1 )
    {
        int bit = digitalRead( ADDR[n] ) ? 1 : 0;
        Serial.print( bit );
    }
    // seperate line for next input signal
    Serial.println();
}

void loop()
{
    // put main code that runs repeatedly


}