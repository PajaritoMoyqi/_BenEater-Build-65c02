;  ..........................................................................................
;  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
;    Vector table: inm handler is mapped at 0xFFFA, init function is mapped at 0xFFFC, irq handler is mapped at 0xFFFE.
;  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
;    I/O controller setting registers for LCD monitor are mapped from 0x6000 to 0x600F.
;      All pins of port B is for data output when using LCD monitor connected.
;    I/O controller setting registers for UART chip are mapped from 0x5000 to 0x5003.
;    Now address from 0x7000 to 0x7FFF is forbidden.
;  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
;    Stack is mapped for 0x0100 to 0x01FF.
;  ..........................................................................................

;  ..........................................................................................
;  This code connects CPU to UART chip which is connected to RS-232 serial interface.
;
;  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
;  Now all pins of port A is connected to UART chip which is connected to DTE using RS-232 protocol,
;  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
;  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
;  ..........................................................................................

;;; I/O controller ;;;
; LCD monitor
PORTB = $6000 ; I/O signal through port B
PORTA = $6001 ; I/O signal through port A
DDRB = $6002 ; Data direction setting register for port B
DDRA = $6003 ; Data direction setting register for port A

; UART
ACIA_DATA = $5000 ; data RT register
ACIA_STATUS = $5001 ; status register
ACIA_CMD = $5002 ; command register
ACIA_CTRL = $5003 ; control register

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

  ;;; set data directions ;;;
  ; set all pins on port B to output(to LCD monitor)
  LDA #%11111111
  STA DDRB
  ; set index-6 pin on port A to input(from DTE)
  LDA #%10111111
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

  ; serial idle
  LDA #1
  STA PORTA

  LDA #"*"
  STA $0200

  LDA #$01
  TRB PORTA

  LDX #8 ; write_bit loop index
write_bit:
  JSR baud_rate_delay ; maybe it's not correct, but it's gonna work somehow :)

  ROR $0200 ; rotate right the next bit into carry flag
  BCS send_1
  ; if carry bit is 0 -> signal is 0
  ; make signal 0 not touching other ports
  TRB PORTA ; PORTA 'AND' ~Accumulator(11111110) and store the result into PORTA
  JMP write_done

send_1:
  ; if carry bit is 1 -> signal is 1
  ; make signal 1 not touching other ports
  ; LDA #$01 ; actually don't need, but to make it clear
  TSB PORTA ; PORTA 'OR' Accumulator(00000001) and store the result into PORTA

write_done:
  DEX
  BNE write_bit

  JSR baud_rate_delay ; maybe it's not correct, but it's gonna work somehow :)
  TSB PORTA ; Accumulator still '00000001'
  JSR baud_rate_delay ; maybe it's not correct, but it's gonna work somehow :)

loop:
  BIT PORTA ; PA6 to overflow flag
  BVS loop ; if the bit is 1

  JSR half_baud_rate_delay

  LDX #8 ; read_bit loop index
read_bit:
  JSR baud_rate_delay ; to skip the start bit from DTE

  BIT PORTA ; PA6 to overflow flag

  BVS set_carry_bit ; overflow flag is 1 -> carry bit 1
  CLC ; else, clear carry bit
  JMP bit_rotate_right
set_carry_bit:
  SEC

  ; to make execution time same when carry bit differs
  ; it's important because we should read data keeping baud rate
  ; also see 'baud_rate_delay' label below
  NOP
  NOP

bit_rotate_right:
  ROR ; rotate Accumultor right, carry flag is new MSB

  DEX
  BNE read_bit

  ; every 8 bits are now in Accumulator in sequence
  JSR lcd_print_char

  JSR baud_rate_delay ; to skip the end bit from DTE
  JMP loop

  ;;; subrutines ;;;
baud_rate_delay:
  PHX

  LDX #13 ; 39(total loop cycle) + 5 * X = 104 -> X = 13
baud_rate_delay_loop: ; 5 additional clock cycle
  DEX ; 2 clock cycle
  BNE baud_rate_delay_loop ; 3 clock cycle

  PLX
  RTS

half_baud_rate_delay:
  PHX

  LDX #6 ; 39(total loop cycle) + 5 * X = 104 / 2 -> X = 6.5
half_baud_rate_delay_loop: ; 5 additional clock cycle
  DEX ; 2 clock cycle
  BNE half_baud_rate_delay_loop ; 3 clock cycle

  PLX
  RTS

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