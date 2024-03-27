"""
  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer
  I/O controller(W65C22) is mapped from 0x6000 to 0x7FFF. - to make output data meaningful

  Make all EEPROM memory data as nop instruction
  except 0x7FFC and 0x7FFD where CPU reads the start address.
  And write some basic looping instructions which is started from 0x8000.
"""

# some instructions
code = bytearray([
  # only run once
  0xA9, 0xFF, # LDA #$FF
  0x8D, 0x02, 0x60, # STA $6002

  # loop
  0xA9, 0x55, # LDA #$55
  0x8D, 0x00, 0x60, # STA $6000
  0xA9, 0xAA, # LDA #$AA
  0x8D, 0x00, 0x60, # STA $6000

  0x4C, 0x05, 0x80, # JMP $8005
])

# write 'nop' instruction every EEPROM except code part
rom = bytearray([0xEA] * (32768 - len(code)))

# start address 0x8000 - little endian
rom[0x7FFC] = 0x00
rom[0x7FFD] = 0x80

with open("rom.bin", "wb") as out_file:
  out_file.write(rom)