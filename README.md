# Build a 6502 computer

## About

All files for Ben Eater's incredible 6502(65c02) breadboard computer making lecture.

## Structure

### Memory map



## Code

### Video 1

1-1_6502_monitor.ino: print each address line signal comes from A0-A15 pins of W65C02S<br>
1-2_6502_monitor.ino: print each address line signal comes from A0-A15 pins of W65C02S only when clock pulse rises<br>
1-3_6502_monitor.ino: Print each address line signals and data line signals from W65C02S only when clock pulse rises<br>

### Video 2

2-1_makerom.py: make every byte of data of EEPROM as 'nop' instruction<br>
2-2_makerom.py: make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored<br>
2-3_makerom.py: make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored, and write some instructions from 0x8000<br>
2-4_makerom.py: make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored, and write some instructions(init and loop) from 0x8000<br>

### Video 3

3-1_compare.s: make same code of video 2 using Assembly language (w/ '.org', '.word')<br>
3-2_compare.s: make same code of video 2 using Assembly language (w/ '.org', '.word', lable)<br>
3-3_blink.s: this code makes LED bulbs blink left to right<br>

### Video 4



### Video 5



### Video 6



### Video 7



### Video 8



### Video 9



### Video 10



### Video 11



### Video 12



### Video 13



### Video 14



### Video 15



### Video 16



### Video 17



### Video 18



