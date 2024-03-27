/*
  EEPROM is mapped from 0x8000 to 0xFFFF.
*/

/*
  Make same code of video 2 using Assembly language.

  Cautions at '.org' and '.word'.
*/

  # origin directive: tells assembler where this codes below should be placed in memory
  .org $8000

  # init
  LDA #$FF
  STA $6002

  # loop
  LDA #$55
  STA $6000

  LDA #$AA
  STA $6000

  JMP $8005

  # from 0xFFFC we save 0x00 and 0x80 which is starting execution address
  .org $FFFC
  .word $8000

  # to save last 2-byte of EEPROM (any data is okay)
  .word $0000