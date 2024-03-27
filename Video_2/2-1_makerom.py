"""
  EEPROM(AT28C256) is mapped from 0x8000 to 0xFFFF. - to program a computer

  Make all EEPROM memory data as nop instruction.
"""

rom = bytearray([0xEA] * 32768)

with open("rom.bin", "wb") as out_file:
  out_file.write(rom)