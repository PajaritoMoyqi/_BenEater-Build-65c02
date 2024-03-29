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
12-2_interrupt.s: interrupt counter using irq handler w/ I/O controller and delay to get rid of switch bouncing problem<br>

### Video 13

No code

### Video 14

¡Cautions! All pins of PORTA, which was partly a output pins for LCD monitor, is now used to read input data from keyboard. To solve this problem, Ben Eater changed the hardware and the code without mention it in public video. To get every changes, I played and stopped in very short interval(25:48-25:50 in the video) and looked up a final code([keyboard.s](https://eater.net/downloads/keyboard.s "keyboard.s")), which is gonna be completed in later video, by Ben Eater.

According to datasheet, D0-D3 pins are not used during 4-bit operation. Considering the changed code shown in the video, he may connected DB4 to DB7 of LCD to PB0 to PB3 of I/O controller. And RS to PB4, RW to PB5 and E to PB6. I guess PB7 isn't used as an important pin in this video.

14-1_keyboard_irq.s: shows transmitted protocol data from keyboard continuously using irq handler w/ I/O controller<br>

### Video 15

15-1_keyboard_irq.s: shows transmitted characters from keyboard continuously w/ keymap<br>
15-2_keyboard_irq.s: shows transmitted characters from keyboard continuously w/ keymap - release key & duplicated key data dealt<br>
15-3_keyboard_irq.s: shows transmitted characters from keyboard continuously w/ keymap - release key & duplicated key data dealt, shift key dealt<br>

### Video 16

16-1_sensor.s: receives data sent from sensor continuously<br>

### Video 17



### Video 18

