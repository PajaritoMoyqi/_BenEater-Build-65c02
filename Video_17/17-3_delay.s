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
;  This code shows delay w/ I/O controller timer1, in one-shot mode.
;
;  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
;  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
;  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
;  ..........................................................................................

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004
T1CH = $6005
ACR = $600B
IFR = $600D

  .org $8000

init:
  ; set direction
  LDA #%11111111 ; set all pins on port A to output
  STA DDRA

  LDA #0
  STA PORTA
  STA ACR ; one-shot mode

loop:
  INC PORTA ; turn LED on
  JSR delay
  DEC PORTB ; turn LED off
  JSR delay
  JMP loop

  ;;; subrutines ;;;
delay:
  ; 50000 is 0xC350
  LDA #$50
  STA T1CL
  LDA #$C3
  STA T1CH

wait_interrupt_signal:
  ;; can do other works while clock ticks ;;

  BIT IFR ; store timer1 interrupt siganl to overflow flag
  BVC wait_interrupt_signal ; if overflow flag is 0

  LDA T1CL ; clear interrupt flag

  RTS

  ;;; interrupt handlers ;;;
nmi_handler:

  RTI ; return from interrupt

irq_handler:

  RTI ; return from interrupt

  ; from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFA
  .word nmi_handler
  .word init
  .word irq_handler