;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;    Vector table: init_loop function is mapped at 0xFFFC.
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      All pins of port A is for sensor(BME280) I/O, all pins of port B is for data output when using LCD monitor connected.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code receives id data sent from sensor continuously.
;
;  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
;  Now all pins of port A is connected to shift register which is connected to keyboard,
;  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
;  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
;  ..........................................................................................

;;; I/O controller ;;;
PORTB = $6000 ; I/O signal through port B
PORTA = $6001 ; I/O signal through port A
DDRB = $6002 ; Data direction setting register for port B
DDRA = $6003 ; Data direction setting register for port A

;;; flags ;;;
SCK = %00000001
MOSI = %00000010
CS = %00000100
MISO = %01000000

  ; origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

init_loop:
  ; open
  LDA #CS
  STA PORTA
  ; set directions
  LDA #%00000111 ; nc/miso/nc/nc/nc/cs/mosi/sck
  STA DDRA

  ;;; bit bang $D0 %11010000 ;;;
  ; $D0 is a memory address where ID exists.
  LDA #MOSI
  STA PORTA
  LDA #(SCK | MOSI) ; SCK is manual clock pulse here
  STA PORTA

  LDA #MOSI
  STA PORTA
  LDA #(SCK | MOSI)
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #MOSI
  STA PORTA
  LDA #(SCK | MOSI)
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  ;;; to recieve ;;;
  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  LDA #0
  STA PORTA
  LDA #SCK
  STA PORTA

  ; exit
  LDA #CS
  STA PORTA

  JMP init_loop

  .ORG $FFFC
  .WORD init_loop
  .WORD $0000