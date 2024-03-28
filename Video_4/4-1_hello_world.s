;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      part of PORTA is for flag bits, PORTB is for data bits when using LCD monitor connected.
;  ..........................................................................................

;  ..........................................................................................
;  This code shows letters on LCD monitor.
;
;  Cautions at '.org', '.word' and label.
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
  STA PORTB
  ; sending instruction protocol
  LDA #0 ; clear dummy setting protocol, just in case
  STA PORTA
  LDA #E ; send instruction
  STA PORTA
  LDA #0 ; clear setting protocol
  STA PORTA

  LDA #%00001110 ; display on, cursor on, blink off
  STA PORTB
  ; sending instruction protocol
  LDA #0 ; clear dummy setting protocol, just in case
  STA PORTA
  LDA #E ; send instruction
  STA PORTA
  LDA #0 ; clear setting protocol
  STA PORTA

  LDA #%00000110 ; increment and shift cursor, do not shift display
  STA PORTB
  ; sending instruction protocol
  LDA #0 ; clear dummy setting protocol, just in case
  STA PORTA
  LDA #E ; send instruction
  STA PORTA
  LDA #0 ; clear setting protocol
  STA PORTA

  ;;; write letters in LCD monitor ;;;
  LDA #"H" ; ascii code of letter 'H'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"e" ; ascii code of letter 'e'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"l" ; ascii code of letter 'l'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"l" ; ascii code of letter 'l'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"o" ; ascii code of letter 'o'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"," ; ascii code of letter ','
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #" " ; ascii code of letter ' '
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"w" ; ascii code of letter 'w'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"o" ; ascii code of letter 'o'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"r" ; ascii code of letter 'r'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"l" ; ascii code of letter 'l'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"d" ; ascii code of letter 'd'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  LDA #"!" ; ascii code of letter '!'
  STA PORTB
  ; sending data protocol
  LDA #RS ; clear dummy data protocol, just in case
  STA PORTA
  LDA #E ; send data
  STA PORTA
  LDA #RS ; clear data protocol
  STA PORTA

  ; work as if it is the end of the program
loop:
  JMP loop

  ; from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFC
  .word init

  ; to save last 2-byte of EEPROM (any data is okay)
  .word $0000