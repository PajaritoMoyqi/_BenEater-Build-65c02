/*
  Print each signal comes from A0-A15 and D0-D7 pins of W65C02S
  only when clock pulse rises.
  Address & Data pins, Clock & Read_Write pins are connected to Arduino.
*/

// connected pin numbers
const char ADDR[] = { 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52 };
const char DATA[] = { 39, 41, 43, 45, 47, 49, 51, 53 };
#define CLOCK 2
#define RW 3

void setup()
{
    // put setup code that runs once

    for ( int n = 0; n < 16; n += 1 )
    {
        pinMode( ADDR[n], INPUT );
    }
    for ( int n = 0; n < 8; n += 1 )
    {
        pinMode( DATA[n], INPUT );
    }
    pinMode( CLOCK, INPUT );
    pinMode( RW, INPUT );

    // print detected signal only when clock pulse rises which works as an interrupt
    attachInterrupt( digitalPinToInterrupt( CLOCK ), onClock, RISING );

    Serial.begin( 57600 );
}

// interrupt handler
void onClock()
{
    // print all address and data bits

    char output[15];

    unsigned int address = 0;
    for ( int n = 0; n < 16; n += 1 )
    {
        int bit = digitalRead( ADDR[n] ) ? 1 : 0;
        Serial.print( bit );

        // accumulate address value
        address = (address << 1) + bit;
    }

    // seperate address bits and data bits
    Serial.print( "    " );

    unsigned int data = 0;
    for ( int n = 0; n < 8; n += 1 )
    {
        int bit = digitalRead( DATA[n] ) ? 1 : 0;
        Serial.print( bit );

        data = (data << 1) + bit;
    }

    // seperate line for next input signal
    sprintf( output, "   %04x  %c %02x", address, digitalRead( RW ) ? 'r' : 'w', data );
    Serial.println( output );
}

void loop()
{
    // put main code that runs repeatedly


}