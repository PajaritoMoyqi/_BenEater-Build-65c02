# Build a 6502 computer

## About

All files for Ben Eater's incredible 6502(65c02) breadboard computer making lecture.

## Structure

### Schematics

![img](https://eater.net/schematics/6502.png)
Eater 6502 Schematics

![img](https://eater.net/schematics/6502-serial.png)
Eater 6502 with Serial Interface Schematics

All images from [eater.net](https://eater.net "eater.net").

### Memory map



## Code

### Video 1

<strong>1-1_6502_monitor.ino:</strong> print each address line signal comes from A0-A15 pins of W65C02S<br>
<strong>1-2_6502_monitor.ino:</strong> print each address line signal comes from A0-A15 pins of W65C02S only when clock pulse rises<br>
<strong>1-3_6502_monitor.ino:</strong> Print each address line signals and data line signals from W65C02S only when clock pulse rises<br>

### Video 2

<strong>2-1_makerom.py:</strong> make every byte of data of EEPROM as 'nop' instruction<br>
<strong>2-2_makerom.py:</strong> make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored<br>
<strong>2-3_makerom.py:</strong> make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored, and write some instructions from 0x8000<br>
<strong>2-4_makerom.py:</strong> make every byte of data of EEPROM as 'nop' instruction except the places where start address is stored, and write some instructions(init and loop) from 0x8000<br>

### Video 3

<strong>3-1_compare.s:</strong> make same code of video 2 using Assembly language (w/ '.org', '.word')<br>
<strong>3-2_compare.s:</strong> make same code of video 2 using Assembly language (w/ '.org', '.word', lable)<br>
<strong>3-3_blink.s:</strong> this code makes LED bulbs blink left to right<br>

### Video 4

<strong>4-1_hello_world.s:</strong> print "hello, world!" using I/O controller and LCD monitor connected<br>

### Video 5

<strong>5-1_hello_world.s:</strong> print "hello, world!" using subrutine w/o memory - so, not working<br>

### Video 6

No code<br>

### Video 7

<strong>7-1_hello_world.s:</strong> print "hello, world!" using subrutine w/ memory, and clear display instruction added<br>

### Video 8

No code<br>

### Video 9

<strong>9-1_hello_world.s:</strong> print "hello, world!" using 750 'nop' instructions to give enough time to LCD monitor to execute initialization instructions<br>
<strong>9-2_hello_world.s:</strong> print "hello, world!" checking busy flag to give enough time to LCD monitor to execute instructions<br>
<strong>9-3_hello_world.s:</strong> print "hello, world!" w/ refactored print_char subrutine<br>

### Video 10

<strong>10-1_binary_to_decimal.s:</strong> print decimal number using algorithm for binary division<br>
<strong>10-2_binary_to_decimal.s:</strong> print decimal number w/ algorithm for reversing the number<br>

### Video 11

<strong>11-1_interrupt.s:</strong> interrupt counter using irq handler<br>
<strong>11-2_interrupt.s:</strong> interrupt counter using nmi handler<br>

### Video 12

<strong>12-1_interrupt.s:</strong> interrupt counter using irq handler w/ I/O controller<br>
<strong>12-2_interrupt.s:</strong> interrupt counter using irq handler w/ I/O controller and delay to get rid of switch bouncing problem<br>

### Video 13

No code

### Video 14

¡Cautions! All pins of PORTA, which was partly a output pins for LCD monitor, is now used to read input data from keyboard. To solve this problem, Ben Eater changed the hardware and the code without mention it in public video. To get every changes, I played and stopped in very short interval(25:48-25:50 in the video) and looked up a final code([keyboard.s](https://eater.net/downloads/keyboard.s "keyboard.s")), which is gonna be completed in later video, by Ben Eater.

According to datasheet, D0-D3 pins are not used during 4-bit operation. Considering the changed code shown in the video, he may connected DB4 to DB7 of LCD to PB0 to PB3 of I/O controller. And RS to PB4, RW to PB5 and E to PB6. I guess PB7 isn't used as an important pin in this video.

<strong>14-1_keyboard_irq.s:</strong> shows transmitted protocol data from keyboard continuously using irq handler w/ I/O controller<br>

### Video 15

<strong>15-1_keyboard_irq.s:</strong> shows transmitted characters from keyboard continuously w/ keymap<br>
<strong>15-2_keyboard_irq.s:</strong> shows transmitted characters from keyboard continuously w/ keymap - release key & duplicated key data dealt<br>
<strong>15-3_keyboard_irq.s:</strong> shows transmitted characters from keyboard continuously w/ keymap - release key & duplicated key data dealt, shift key dealt<br>

### Video 16

¡Cautions! '16-2_sensor.s' code is not completed.

<strong>16-1_sensor.s:</strong> receives data sent from sensor continuously<br>
~~<strong>16-2_sensor.s:</strong> receives data sent from sensor continuously~~ (not working, full-code not provided)<br>

### Video 17

<strong>17-1_delay.s:</strong> simple delay with single loop<br>
<strong>17-2_delay.s:</strong> simple delay with double loop<br>
<strong>17-3_delay.s:</strong> delay w/ I/O controller(W65C22) timer in one-shot mode<br>
<strong>17-4_delay.s:</strong> delay w/ I/O controller(W65C22) timer in free-run mode ('update_lcd' update needed, full-code not provided)<br>

### Video 18

<strong>18-1_rs232.s:</strong> shows characters that comes from DTE<br>

### Video 19

No code

### Video 20

<strong>20-1_rs232.s:</strong> sends hardcoded character and shows characters that comes from DTE<br>

### Video 21

<strong>21-1_uart.s:</strong> connects CPU to UART chip which is connected to RS-232 serial interface<br>

### Video 22

<strong>22-1_uart.s:</strong> receives data from UART chip which is connected to RS-232 serial interface<br>
<strong>22-2_uart.s:</strong> sends & receives data from UART chip which is connected to RS-232 serial interface(not working, because of a hardware bug)<br>
<strong>22-3_uart.s:</strong> sends & receives data from UART chip which is connected to RS-232 serial interface(fixed the hardware bug)<br>

### Video 23

<strong>wozmon.s:</strong> The WOZ Monitor for the Apple 1<br>
<strong>23-1_adapted_wozmon.s:</strong> The WOZ Monitor for the Ben Eater 6502 Computer<br>
<strong>23-2_hello_would.s:</strong> shows "Hello, would!"(intentional typo), which is gonna be mounted together with the WOZ Monitor program<br>

### Video 24

Also, you'd better(but not necessarily) watch together "How Wozniak’s code for the Apple 1 works", although it's not included in Ben Eater's 6502 playlist.

<strong>24-1_adapted_wozmon.s:</strong> The WOZ Monitor for Ben Eater 6502 Computer<br>

### Video 25

<strong>adapted_wozmon.s:</strong> Now it only contains WOZ Monitor code<br>
<strong>bios.cfg:</strong> tells linker how to allocate the code in ROM/RAM etc<br>
<strong>bios.s:</strong> simple bios file<br>

### Video 26

<strong>All changed codes</strong> from [original codes](https://github.com/mist64/msbasic "msbasic") are included.

### Video 27

<strong>All changed codes</strong> from [original codes](https://github.com/mist64/msbasic "msbasic") are included.

Only adapted_wozmon.s, bios.s, defines_eater.s and eater.cfg has been changed from previous video.