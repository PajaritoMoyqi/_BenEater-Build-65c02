"""
  make all EEPROM memory data as nop instruction
  except 0x7FFC and 0x7FFD where CPU reads the start address
"""

rom = bytearray([0xEA] * 32768)

# start address 0x8000
rom[0x7FFC] = 0x00
rom[0x7FFD] = 0x80

with open("rom.bin", "wb") as out_file:
  out_file.write(rom)