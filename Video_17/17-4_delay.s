;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;    Vector table: init_loop function is mapped at 0xFFFC.
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      All pins of port B is for data output when using LCD monitor connected.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code shows delay w/ I/O controller timer1, in free-run mode.
;
;  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
;  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
;  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
;  ..........................................................................................

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ; T1 Low-Order Counter
T1CH = $6005 ; T1 High-Order Counter
ACR = $600B ; Auxiliary Control Register
IFR = $600D ; Interrupt Flag Register
IER = $600E ; Interrupt Enable Register

ticks = $00 ; interrupt counter, 4-bytes
elapsed_time = $04 ; when we toggle LED, 1-byte

  .org $8000

init:
  ; set direction
  LDA #%11111111 ; set all pins on port A to output
  STA DDRA

  LDA #0
  STA PORTA
  STA elapsed_time

  JSR init_timer

loop:
  JSR toggle_led

  ;; can do other works while clock ticks ;;

  JMP loop

toggle_led:
  SEC ; set carry bit to use it when subtract
  LDA ticks
  SBC elapsed_time
  CMP #25 ; have 250ms elapsed? -> carry bit is set
  BCC exit_toggle_led ; if carry bit is low(if not elapsed)

  ; toggle LED
  LDA #$01
  EOR PORTA
  STA PORTA

  ; update elapsed_time
  LDA ticks
  STA elapsed_time

exit_toggle_led
  RTS

  ;;; subrutines ;;;
init_timer:
  ; initialize variables
  LDA #0
  STA ticks
  STA ticks + 1
  STA ticks + 2
  STA ticks + 3

  ; timer setting as free-run mode
  LDA #%01000000
  STA ACR

  ; 9998 is 0x270E -> 10ms
  LDA #$0E
  STA T1CL
  LDA #$27
  STA T1CH

  ; timer setting to enable interrupt signal for timer1
  LDA #%11000000
  STA IER
  CLI ; clear interrupt disable

  RTS

  ;;; interrupt handlers ;;;
nmi_handler:

  RTI ; return from interrupt

irq_handler:
  BIT T1CL ; read T1CL -> automatically clear interrupt
  INC ticks
  BNE exit_irq_handler
  INC ticks + 1
  BNE exit_irq_handler
  INC ticks + 2
  BNE exit_irq_handler
  INC ticks + 3

exit_irq_handler:
  RTI ; return from interrupt

  ; from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFA
  .word nmi_handler
  .word init
  .word irq_handler