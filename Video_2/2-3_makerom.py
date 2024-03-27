"""
  EEPROM is mapped 0x8000 to 0xFFFF.

  Make all EEPROM memory data as nop instruction
  except 0x7FFC and 0x7FFD where CPU reads the start address.
  And write some basic instructions which is started from 0x8000.
"""

rom = bytearray([0xEA] * 32768)

# LDA #$42
rom[0] = 0xA9
rom[1] = 0x42

# STA $6000
rom[2] = 0x8D
rom[3] = 0x00
rom[4] = 0x60

# start address 0x8000 which is same as rom[0]
rom[0x7FFC] = 0x00
rom[0x7FFD] = 0x80

with open("rom.bin", "wb") as out_file:
  out_file.write(rom)