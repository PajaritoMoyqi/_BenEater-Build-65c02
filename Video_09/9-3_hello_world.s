;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      part of PORTA is for flag bits, PORTB is for data bits when using LCD monitor connected.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code shows letters on LCD monitor.
;  But not working because of the difference of speed between CPU clock cycle and instruction execution time of LCD monitor.
;  So we add lcd_check_busy_flag subrutine to check busy flag of LCD monitor.
;
;  Cautions at subrutine, 'JRS', 'RTS', 'TXS', '.asciiz', 'INX'.
;  ..........................................................................................

PORTB = $6000 ; I/O signal through port B
PORTA = $6001 ; I/O signal through port A
DDRB = $6002 ; Data direction setting register for port B
DDRA = $6003 ; Data direction setting register for port A

; flags for PORTA
E = %10000000
RW = %01000000
RS = %00100000

  ; origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

init:
  ; initialize stack pointer to 0x01FF
  LDX #$FF
  TXS

  ;;; set data directions ;;;
  ; set all pins on port B to output
  ; which are the pins connected to D0-D7
  LDA #%11111111
  STA DDRB
  ; set only top three pins on port A to output
  ; which are the pins connected to E, R/WB, RS
  LDA #%11100000
  STA DDRA

  ;;; set initial setting for display of LCD monitor ;;;
  LDA #%00111000 ; 8-bit mode, 2-line display, 5x8 font
  JSR lcd_send_instruction
  LDA #%00001110 ; display on, cursor on, blink off
  JSR lcd_send_instruction
  LDA #%00000110 ; increment and shift cursor, do not shift display
  JSR lcd_send_instruction
  LDA #%00000001 ; Clear display
  JSR lcd_send_instruction

  ;;; write letters in LCD monitor ;;;
  LDX #0
lcd_print:
  ; load next character
  LDA message, x
  BEQ loop ; if zero flag is set, that is, if character is null character

  ; print character
  JSR lcd_print_char
  INX
  JMP lcd_print

  ; work as if it is the end of the program
loop:
  JMP loop

  ; insert string in EEPROM
message: .asciiz "Hello, world!" ; 'z' in asciiz means additional zero after string

  ;;; subrutines ;;;
lcd_send_instruction:
  ; PHA ; put current value of Accumulator in Stack if needed

  JSR lcd_check_busy_flag ; wait for previous instruction does one's job done

  STA PORTB ; send data stored in Accumulator to port B

  ; sending instruction protocol
  LDA #0 ; clear dummy setting protocol, just in case
  STA PORTA
  LDA #E ; send instruction
  STA PORTA
  LDA #0 ; clear setting protocol
  STA PORTA

  ; PLA ; pull value in Stack to Accumulator if needed

  RTS ; return from subrutine

lcd_print_char:
  JSR lcd_check_busy_flag ; wait for previous instruction does one's job done

  STA PORTB ; send data stored in Accumulator to port B

  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  RTS ; return from subrutine

lcd_check_busy_flag:
  PHA ; put current value of Accumulator in Stack

  ; change data direction of port B to use it as read result
  LDA #%00000000
  STA DDRB

check_busy_flag_loop:
  ; ask whether busy flag is set or not
  LDA #RW
  STA PORTA
  LDA #(RW | E)
  STA PORTA

  ; read result
  LDA PORTB

  AND #%10000000 ; MSB is where LCD monitor gives the result of busy flag
  BNE check_busy_flag_loop ; if not zero, in other words, if zero flag is not set after AND operation, that is, if LCD is busy

  ;;; clear instructions ;;;
  ; turn off enable bit
  LDA #RW
  STA PORTA

  ; change data direction of port B to output mode
  LDA #%11111111
  STA DDRB

  PLA ; pull value in Stack to Accumulator

  RTS

  ; from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFC
  .word init

  ; to save last 2-byte of EEPROM (any data is okay)
  .word $0000