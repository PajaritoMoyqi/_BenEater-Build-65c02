/*
  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
    Vector table: inm handler is mapped at 0xFFFA, init function is mapped at 0xFFFC, irq handler is mapped at 0xFFFE.
  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful
    I/O controller setting registers are mapped from 0x6000 to 0x600F.
      All pins of port A is for keyboard input, all pins of port B is for data output when using LCD monitor connected.
  RAM(HM62256B) is mapped from 0x0000 to 0x3FFF. - to get memory for stack(in W65C02S, stack has address from 0x0100 to 0x01FF)
    Stack is mapped for 0x0100 to 0x01FF.
*/

/*
  This code shows transmitted data from keyboard continuously using irq handler w/ I/O controller.

  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
  Now all pins of port A is connected to shift register which is connected to keyboard,
  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.

  Cautions at 'LSR'.
*/

; I/O controller
PORTB = $6000 # I/O signal through port B
PORTA = $6001 # I/O signal through port A
DDRB = $6002 # Data direction setting register for port B
DDRA = $6003 # Data direction setting register for port A
PCR = $600C # Peripheral control register which decide where to detect as an interrupt (falling-edge, rising-edge...)
IFR = $600D # Interrupt flag register that CPU can see what cause the interrupt
IER = $600E # Interrupt enable register

; binary to decimal
value = $0200 # 2-bytes of number that we want to convert
mod10 = $0202 # 2-bytes of number space where we operate '- 10' operation
message = $0204 # 6-bytes of string in maximum, because we are working with 2-bytes number which has its maximum value 65535 in decimal, and also null character included

; counter
counter = $020A # 2-bytes of number that counts the number of interrupt

# flags for PORTB
E = %01000000
RW = %00100000
RS = %00010000

  # origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

init:
  # initialize stack pointer to 0x01FF
  LDX #$FF
  TXS

  # clear interrupt disable bit
  CLI

  # initialize interrupt enable register - Set, CA1
  LDA #$82
  STA IER
  # initialize peripheral control register - CA1 to rising edge
  # when it goes to high, it means that keyboard scan code transfer has been done
  LDA #$01
  STA PCR

  ; set data directions
  # set all pins on port B to output(to LCD monitor)
  LDA #%11111111
  STA DDRB
  # set all pins on port A to input(from keyboard)
  LDA #%00000000
  STA DDRA

  ; set initial setting for display of LCD monitor
  JSR lcd_init # set 4-bits mode
  LDA #%00101000 # 4-bits mode, 2-line display, 5x8 font
  JSR lcd_send_instruction
  LDA #%00001110 # display on, cursor on, blink off
  JSR lcd_send_instruction
  LDA #%00000110 # increment and shift cursor, do not shift display
  JSR lcd_send_instruction
  LDA #%00000001 # Clear display
  JSR lcd_send_instruction

  ; initialization of counter variable
  LDA #0
  STA counter
  STA counter + 1

  ; loop for printing counter continuously
  ; algorithm for binary division included
loop:
  ; initialization
  LDA #0
  STA message # empty string

  LDA counter
  STA value
  LDA counter + 1
  STA value + 1

div_start:
  LDA #0
  STA mod10
  STA mod10 + 1

  CLC # clear the carry bit

  LDX #16 # index of div_loop
div_loop:
  ; rotate left 1-bit quotient and remainder
  ROL value
  ROL value + 1
  ROL mod10
  ROL mod10 + 1

  ; a, y = dividend - divisor
  SEC # set carry bit to check the '- 10' operation result is negative or not
  LDA mod10
  SBC #10
  TAY # store value of Accumulator to Y register
  LDA mod10 + 1
  SBC #0

  BCC decrement_index # branch if carry is clear, that is, if dividend < divisor
  # when if carry bit is 1
  STY mod10 # store Y register value to memory(mod10)
  STA mod10 + 1 # store Accumulator value to memory(mod10 + 1)

decrement_index:
  DEX
  BNE div_loop

  # shift in the last bit of the quotient
  ROL value
  ROL value + 1

  # get number character
  LDA mod10
  CLC # because of how ADC instruction works
  ADC #"0" # add memory to Accumulator with Carry bit

  # print out
  JSR ram_push_char

  # check value is zero or not
  LDA value
  ORA value + 1

  BNE div_start # if value is not zero

  ; write letters in LCD monitor
  LDX #0
lcd_print:
  # load next character
  LDA message, x
  BEQ loop # if zero flag is set, that is, if character is null character

  # print character
  JSR lcd_print_char
  INX
  JMP lcd_print

number: .word 0

  ; subrutines
ram_push_char:
  PHA # push new character onto stack
  LDY #0 # start index of string

push_char_loop:
  # get original character
  LDA message, y
  TAX # store it in X register

  # put previous character at current position
  PLA
  STA message, y

  # put current character onto stack
  INY
  TXA
  PHA

  BNE push_char_loop # if current character is not zero
  
  # put null character at the end of the string
  PLA
  STA message, y

  RTS

lcd_init:
  # sending instruction protocol
  LDA #%00000010 # set 4-bits mode
  STA PORTB
  ORA #E # send instruction
  STA PORTB
  AND #%00001111 # clear setting protocol
  STA PORTB

  RTS

lcd_send_instruction:
  # PHA # put current value of Accumulator in Stack if needed

  JSR lcd_check_busy_flag # wait for previous instruction does one's job done
  PHA

  # need to write twice, because we are in 4-bits mode
  # Send high 4 bits of Accumulator to zero
  LSR
  LSR
  LSR
  LSR

  # sending instruction protocol
  STA PORTB # clear dummy setting protocol, just in case
  ORA #E # send instruction
  STA PORTB
  ORA #E # clear setting protocol
  STA PORTB

  PLA

  # Send low 4 bits to Accumulator
  AND #%00001111 

  # sending instruction protocol
  STA PORTB # clear dummy setting protocol, just in case
  ORA #E # send instruction
  STA PORTB
  ORA #E # clear setting protocol
  STA PORTB

  # PLA # pull value in Stack to Accumulator if needed

  RTS # return from subrutine

lcd_print_char:
  JSR lcd_check_busy_flag # wait for previous instruction does one's job done
  PHA

  # need to write twice, because we are in 4-bits mode
  # Send high 4 bits to Accumulator
  LSR
  LSR
  LSR
  LSR

  # sending data protocol
  ORA #RS # clear dummy data protocol, just in case
  STA PORTB
  ORA #E # send data
  STA PORTB
  ORA #E # clear data protocol
  STA PORTB

  PLA

  # Send low 4 bits to Accumulator
  AND #%00001111 # Send low 4 bits to Accumulator

  ORA #RS # clear dummy data protocol, just in case
  STA PORTB
  ORA #E # send data
  STA PORTB
  ORA #E # clear data protocol
  STA PORTB

  RTS # return from subrutine

lcd_check_busy_flag:
  PHA # put current value of Accumulator in Stack

  # change data direction of port B to use it as read result
  LDA #%11110000 # last 4-bits are data input
  STA DDRB

check_busy_flag_loop:
  # ask whether busy flag is set or not
  LDA #RW
  STA PORTB
  LDA #(RW | E)
  STA PORTB

  # read result
  LDA PORTB # read low nibble
  PHA # and put it onto stack since it has the busy flag

  # need to read twice, because we are in 4-bits mode
  LDA #RW
  STA PORTB
  LDA #(RW | E)
  STA PORTB

  LDA PORTB # read low nibble which we are not gonna use becuase it doesn't have the busy flag
  PLA # abandon previous data and get high nibble off stack

  AND #%00001000 # MSB of last 4-bits(nibble) is where LCD monitor gives the result of busy flag
  BNE check_busy_flag_loop # if not zero, in other words, if zero flag is not set after AND operation, that is, if LCD is busy

  ; clear instructions
  # turn off enable bit
  LDA #RW
  STA PORTB

  # change data direction of port B to output mode
  LDA #%11111111
  STA DDRB

  PLA # pull value in Stack to Accumulator

  RTS

  ; interrupt handlers
nmi_handler:
irq_handler:
  # store original value of Accumulator
  PHA

  # read data, clearing the interrupt
  LDA PORTA
  STA counter # store it into counter variable
  # our loop is printing counter continuously, so counter value is gonna be printed out to LCD monitor

  # restore original value of Accumulator from the stack
  PLA

  RTI # return from interrupt

  # from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFA
  .word nmi_handler
  .word init
  .word irq_handler