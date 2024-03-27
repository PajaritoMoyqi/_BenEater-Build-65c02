/*
  EEPROM is mapped from 0x8000 to 0xFFFF.
*/

/*
  This code Makes LED bulbs blink left to right.

  Cautions at '.org', '.word' and lable.
*/

  # origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

  # init
init:
  LDA #$FF
  STA $6002

  LDA #$50
  STA $6000

  # loop
loop:
  ROR # rotate value in accumulator which is #$50 in 'init' label
  STA $6000

  JMP loop

  # from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFC
  .word init

  # to save last 2-byte of EEPROM (any data is okay)
  .word $0000