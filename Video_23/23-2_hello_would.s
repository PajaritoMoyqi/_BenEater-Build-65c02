;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;    Vector table: inm handler is mapped at 0xFFFA, init function is mapped at 0xFFFC, irq handler is mapped at 0xFFFE.
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      All pins of port B is for data output when using LCD monitor connected.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code shows "Hello, would!".
;  The typo is intentional.
;
;  ¡ Note that now we are using port B to transfer flag bits !
;  All pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
;  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
;  ..........................................................................................

;;; I/O controller ;;;
PORTB = $6000 ; I/O signal through port B
DDRB = $6002 ; Data direction setting register for port B

; flags for PORTB
E = %01000000
RW = %00100000
RS = %00010000

  ; origin directive: tells assembler where this codes below should be placed in memory
  .org $1000

init:
  ;;; set data directions ;;;
  ; set all pins on port B to output(to LCD monitor)
  LDA #%FF
  STA DDRB

  ;;; set initial setting for display of LCD monitor ;;;
  JSR lcd_init ; set 4-bits mode
  LDA #%00101000 ; 4-bits mode, 2-line display, 5x8 font
  JSR lcd_send_instruction
  LDA #%00001110 ; display on, cursor on, blink off
  JSR lcd_send_instruction
  LDA #%00000110 ; increment and shift cursor, do not shift display
  JSR lcd_send_instruction
  LDA #%00000001 ; Clear display
  JSR lcd_send_instruction

  LDX #$00
print:
  LDA message, x
  BEQ halt
  JSR lcd_print_char
  INX
  JMP print

halt:
  JMP $FF00 ; return to wozmon program

message: .asciiz "Hello, would!"

lcd_init:
  ; sending instruction protocol
  LDA #%00000010 ; set 4-bits mode
  STA PORTB
  ORA #E ; send instruction
  STA PORTB
  AND #%00001111 ; clear setting protocol
  STA PORTB

  RTS

lcd_send_instruction:
  ; PHA ; put current value of Accumulator in Stack if needed

  JSR lcd_check_busy_flag ; wait for previous instruction does one's job done
  PHA

  ; need to write twice, because we are in 4-bits mode
  ; Send high 4 bits of Accumulator to zero
  LSR
  LSR
  LSR
  LSR

  ; sending instruction protocol
  STA PORTB ; clear dummy setting protocol, just in case
  ORA #E ; send instruction
  STA PORTB
  ORA #E ; clear setting protocol
  STA PORTB

  PLA

  ; Send low 4 bits to Accumulator
  AND #%00001111 

  ; sending instruction protocol
  STA PORTB ; clear dummy setting protocol, just in case
  ORA #E ; send instruction
  STA PORTB
  ORA #E ; clear setting protocol
  STA PORTB

  ; PLA ; pull value in Stack to Accumulator if needed

  RTS ; return from subrutine

lcd_print_char:
  JSR lcd_check_busy_flag ; wait for previous instruction does one's job done
  PHA

  ; need to write twice, because we are in 4-bits mode
  ; Send high 4 bits to Accumulator
  LSR
  LSR
  LSR
  LSR

  ; sending data protocol
  ORA #RS ; clear dummy data protocol, just in case
  STA PORTB
  ORA #E ; send data
  STA PORTB
  ORA #E ; clear data protocol
  STA PORTB

  PLA

  ; Send low 4 bits to Accumulator
  AND #%00001111 ; Send low 4 bits to Accumulator

  ORA #RS ; clear dummy data protocol, just in case
  STA PORTB
  ORA #E ; send data
  STA PORTB
  ORA #E ; clear data protocol
  STA PORTB

  RTS ; return from subrutine

lcd_check_busy_flag:
  PHA ; put current value of Accumulator in Stack

  ; change data direction of port B to use it as read result
  LDA #%11110000 ; last 4-bits are data input
  STA DDRB

check_busy_flag_loop:
  ; ask whether busy flag is set or not
  LDA #RW
  STA PORTB
  LDA #(RW | E)
  STA PORTB

  ; read result
  LDA PORTB ; read low nibble
  PHA ; and put it onto stack since it has the busy flag

  ; need to read twice, because we are in 4-bits mode
  LDA #RW
  STA PORTB
  LDA #(RW | E)
  STA PORTB

  LDA PORTB ; read low nibble which we are not gonna use becuase it doesn't have the busy flag
  PLA ; abandon previous data and get high nibble off stack

  AND #%00001000 ; MSB of last 4-bits(nibble) is where LCD monitor gives the result of busy flag
  BNE check_busy_flag_loop ; if not zero, in other words, if zero flag is not set after AND operation, that is, if LCD is busy

  ;;; clear instructions ;;;
  ; turn off enable bit
  LDA #RW
  STA PORTB

  ; change data direction of port B to output mode
  LDA #%11111111
  STA DDRB

  PLA ; pull value in Stack to Accumulator

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