; ¡ WARNING: This code is not working !

;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;    Vector table: init function is mapped at 0xFFFC.
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers are mapped from 0x6000 to 0x600F.
;      All pins of port A is for sensor(BME280) I/O, all pins of port B is for data output when using LCD monitor connected.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code receives data sent from sensor continuously.
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
PCR = $600C ; Peripheral control register which decide where to detect as an interrupt (falling-edge, rising-edge...)
IFR = $600D ; Interrupt flag register that CPU can see what cause the interrupt
IER = $600E ; Interrupt enable register

;;; binary to decimal ;;;
value = $0200 ; 2-bytes of number that we want to convert
mod10 = $0202 ; 2-bytes of number space where we operate '- 10' operation
message = $0204 ; 6-bytes of string in maximum, because we are working with 2-bytes number which has its maximum value 65535 in decimal, and also null character included

;;; counter ;;;
counter = $020A ; 2-bytes of number that counts the number of interrupt

; flags for PORTB
E = %01000000
RW = %00100000
RS = %00010000

  ; origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

init:
  ; initialize stack pointer to 0x01FF
  LDX #$FF
  TXS

  ; clear interrupt disable bit
  CLI

  ; initialize interrupt enable register - Set, CA1
  LDA #$82
  STA IER
  ; initialize peripheral control register - CA1 to rising edge
  ; when it goes to high, it means that keyboard scan code transfer has been done
  LDA #$01
  STA PCR

  ;;; set data directions ;;;
  ; set all pins on port B to output(to LCD monitor)
  LDA #%11111111
  STA DDRB
  ; set all pins on port A to input(from keyboard)
  LDA #%00000000
  STA DDRA

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

  STZ PORTA ; begin packet
  LDA #$D0
  JSR spi_transceive ; send D0 instruction
  JSR spi_transceive ; read result into A
  STA value
  STZ value + 1
  LDA #CS
  STA PORTA ; end packet

  STZ PORTA ; begin packet
  LDA #$75
  JSR spi_transceive ; send 75 instruction
  LDA #%00010000
  JSR spi_transceive ; send parameter
  LDA #$74
  JSR spi_transceive ; send 74 instruction
  LDA #%00110111
  JSR spi_transceive ; send parameter
  LDA #CS
  STA PORTA ; end packet

  JSR lcd_print

loop:
  LDA timer
  AND #$20
  BEQ loop ; wait until timer reaches a value
  STZ timer ; reset timer

  STZ PORTA ; begin packet
  LDA #$FA
  JSR spi_transceive ; send FA instruction
  JSR spi_transceive ; read result into A
  STA value + 1
  JSR spi_transceive ; read result into A
  STA value
  LDA #CS
  STA PORTA ; end packet

  LDA #%00000001 ; clear display
  JSR lcd_send_instruction
  JSR lcd_print
  JMP loop

spi_transceive:
  STZ spiin ; clear the input buffer
  STA spiout ; store the value of Accumulator(output data)

  LDY #8 ; bit counter
  LDA #MOSI ; Accumulator = MOSI bit mask

spi_loop:
  ASL spiout ; shift left Accumulator and MSB is going to carry bit
  BCS spi_1 ; if carry bit is 1
  TRB PORTA ; set MOSI low
  JMP spi_2

spi_1:
  TSB PORTA ; set MOSI high

spi_2:
  INC PORTA ; set SCK high
  BIT PORTA
  CLC
  BVC spi_3
  SEC

spi_3:
  ROL spiin
  DEC PORTA
  DEY
  BNE spi_loop
  LDA spiin
  CLC
  RTS

lcd_print:
  ; load next character
  LDA message, x
  BEQ loop ; if zero flag is set, that is, if character is null character

  ; print character
  JSR lcd_print_char
  INX
  JMP lcd_print

number: .word 0

  ;;; subrutines ;;;

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
  ; store original value of Accumulator
  PHA

  ; read data, clearing the interrupt
  LDA PORTA
  STA counter ; store it into counter variable
  ; our loop is printing counter continuously, so counter value is gonna be printed out to LCD monitor

  ; restore original value of Accumulator from the stack
  PLA

  RTI ; return from interrupt

  ; from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFA
  .word nmi_handler
  .word init
  .word irq_handler