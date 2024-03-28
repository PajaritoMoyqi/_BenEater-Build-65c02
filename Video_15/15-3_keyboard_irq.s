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
  This code shows string data from keyboard continuously using irq handler w/ I/O controller.
  Effect of duplicated data, with release key data of PS/2 protocol, has been removed.
  Effect of shift key now operates as we expect.

  ¡ Note that now we are using port B to transfer flag bits, and port A as a main route where data transmition occurs !
  Now all pins of port A is connected to shift register which is connected to keyboard,
  all pins of port B is connected to LCD monitor where PB0 to PB3 is connected to DB4 to DB7 of LCD monitor,
  PB4 to RS, PB5 to RW and PB6 to E of LCD. I have no idea where PB7 is connected to.
*/

; I/O controller
PORTB = $6000 # I/O signal through port B
PORTA = $6001 # I/O signal through port A
DDRB = $6002 # Data direction setting register for port B
DDRA = $6003 # Data direction setting register for port A
PCR = $600C # Peripheral control register which decide where to detect as an interrupt (falling-edge, rising-edge...)
IFR = $600D # Interrupt flag register that CPU can see what cause the interrupt
IER = $600E # Interrupt enable register

; keyboard
kb_buffer = $0200 # 256-byte kb buffer, from 0x0200 to 0x02FF
# 8-bit pointer, so kb_buffer is now automatically circular list
kb_wptr = $0000
kb_rptr = $0001
# to check it's duplicated data or not
kb_flags = $0002

RELEASE = %00000001
SHIFT = %00000010

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

  LDA #$00
  STA kb_rptr
  STA kb_wptr
  STA kb_flags

loop:
  SEI # set interrupt disable bit
  # read two pointers
  LDA kb_rptr
  CMP kb_wptr
  CLI # clear interrupt disable bit

  BNE print_pressed_key # if kb_rptr and kb_wptr are different, that is, key is pressed
  JMP loop

print_pressed_key:
  LDX kb_rptr
  LDA kb_buffer, x
  JSR lcd_print_char
  INC kb_rptr
  JMP loop

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

  RTI # return from interrupt

irq_handler:
  # store original value of Accumulator and X register
  PHA
  TXA
  PHA

  # check release flag
  LDA kb_flags
  AND #RELEASE
  BEQ read_key # if we are not in state where key released

  # flip release flag
  LDA kb_flags
  EOR #RELEASE
  STA kb_flags

  # read duplicated data which is released just now
  LDA PORTA
  CMP #$12 # left shift
  BEQ releasing_shift_key_handler
  CMP #$59 # right shift
  BEQ releasing_shift_key_handler

  JMP exit_irq_handler

releasing_shift_key_handler:
  # flip shift flag
  LDA kb_flags
  EOR #SHIFT
  STA kb_flags
  JMP exit_irq_handler

read_key:
  # read data, clearing the interrupt systematically
  LDA PORTA

  # check whether it's release key signal or not
  CMP #$F0
  BEQ released_key_handler # if the data is released key data
  # check whether it's shift key signal or not
  CMP #$12 # left shift key
  BEQ shifted_key_handler # if the data is left shift key data
  CMP #$59 # right shift key
  BEQ shifted_key_handler # if the data is right shift key data

  # store offset to X register
  TAX

  # 
  LDA kb_flags
  AND #SHIFT
  BNE convert_to_shited_ascii

  # change scan code to ascii code using keymap
  LDA keymap, x
  JMP push_key

convert_to_shited_ascii:
  # change scan code to shifted ascii code using shifted_keymap
  LDA shifted_keymap, x

push_key:
  LDX kb_wptr # offset
  STA kb_buffer, x # store it into kb_buffer list
  # our loop is printing a character in kb_buffer continuously

  INC kb_wptr
  JMP exit_irq_handler

shifted_key_handler:
  # set shift flag
  LDA kb_flags
  ORA #SHIFT
  STA kb_flags
  JMP exit_irq_handler

released_key_handler:
  # set release flag
  LDA kb_flags
  ORA #RELEASE
  STA kb_flags

exit_irq_handler:
  # restore original value of Accumulator and X register from the stack
  PLA
  TAX
  PLA

  RTI # return from interrupt

  ; scan code to ascii code
  .org $FD00
  # question marks in keymaps mean 'not defined' or '?' itself
keymap:
  .byte "????????????? `?" # 00-0F
  .byte "?????q1???zsaw2?" # 10-1F
  .byte "?cxde43?? vftr5?" # 20-2F
  .byte "?nbhgy6???mju78?" # 30-3F
  .byte "?,kio09??./l;p-?" # 40-4F
  .byte "??'?[=?????]?\??" # 50-5F
  .byte "?????????1?47???" # 60-6F
  .byte "0.2568???+3-*9??" # 70-7F
  .byte "????????????????" # 80-8F
  .byte "????????????????" # 90-9F
  .byte "????????????????" # A0-AF
  .byte "????????????????" # B0-BF
  .byte "????????????????" # C0-CF
  .byte "????????????????" # D0-DF
  .byte "????????????????" # E0-EF
  .byte "????????????????" # F0-FF
shifted_keymap:
  .BYTE "????????????? ~?" # 00-0F
  .BYTE "?????Q!???ZSAW@?" # 10-1F
  .BYTE "?CXDE$#?? VFTR%?" # 20-2F
  .BYTE "?NBHGY^???MJU&*?" # 30-3F
  .BYTE "?<KIO)(??>?L:P_?" # 40-4F
  .BYTE "??"?{+?????}?|??" # 50-5F
  .BYTE "?????????!?47???" # 60-6F
  .BYTE "0.2568???+3-*9??" # 70-7F
  .BYTE "????????????????" # 80-8F
  .BYTE "????????????????" # 90-9F
  .BYTE "????????????????" # A0-AF
  .BYTE "????????????????" # B0-BF
  .BYTE "????????????????" # C0-CF
  .BYTE "????????????????" # D0-DF
  .BYTE "????????????????" # E0-EF
  .BYTE "????????????????" # F0-FF

  # from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFA
  .word nmi_handler
  .word init
  .word irq_handler