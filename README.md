# Build a 6502 computer

## About

All files for Ben Eater's incredible 6502(65c02) breadboard computer making lecture.

## Structure

### Schematics



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

4-1_hello_world.s: print "hello, world!" using I/O controller and LCD monitor connected<br>

### Video 5

5-1_hello_world.s: print "hello, world!" using subrutine w/o memory - so, not working<br>

### Video 6

No code<br>

### Video 7

7-1_hello_world.s: print "hello, world!" using subrutine w/ memory, and clear display instruction added<br>

### Video 8

No code<br>

### Video 9

9-1_hello_world.s: print "hello, world!" using 750 'nop' instructions to give enough time to LCD monitor to execute initialization instructions<br>
9-2_hello_world.s: print "hello, world!" checking busy flag to give enough time to LCD monitor to execute instructions<br>
9-3_hello_world.s: print "hello, world!" w/ refactored print_char subrutine<br>

### Video 10

10-1_binary_to_decimal.s: print decimal number using algorithm for binary division<br>
10-2_binary_to_decimal.s: print decimal number w/ algorithm for reversing the number<br>

### Video 11

11-1_interrupt.s: interrupt counter using irq handler<br>
11-2_interrupt.s: interrupt counter using nmi handler<br>

### Video 12

12-1_interrupt.s: interrupt counter using irq handler w/ I/O controller<br>

### Video 13



### Video 14



### Video 15



### Video 16



### Video 17



### Video 18



