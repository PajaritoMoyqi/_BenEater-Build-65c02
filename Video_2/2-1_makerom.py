"""
  EEPROM is mapped 0x8000 to 0xFFFF.

  Make all EEPROM memory data as nop instruction.
"""

rom = bytearray([0xEA] * 32768)

with open("rom.bin", "wb") as out_file:
  out_file.write(rom)