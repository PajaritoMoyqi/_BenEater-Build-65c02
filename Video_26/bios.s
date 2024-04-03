.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

LOAD:
  RTS
SAVE:
  RTS

; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed.
; If a key was pressed, the key value will be in the A register.
;
; Modifies: flag, A
MONRDKEY:
CHRIN:
  LDA ACIA_STATUS
  AND #$08
  BEQ @no_keypressed
  LDA ACIA_DATA
  JSR CHROUT ; echo
  SEC
  RTS
@no_keypressed:
  CLC
  RTS

; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
MONCOUT:
CHROUT:
  PHA
  STA ACIA_DATA
  LDA #$FF
@tx_delay:
  DEC
  BNE @tx_delay
  PLA
  RTS

.include "adapted_wozmon.s"

               .segment "RESETVEC" ; to tell linker where this code should be located by 'bios.cfg' file
              ;  .org $FFFA
               .word $0F00      ; NMI verctor
               .word RESET      ; RESET vector
               .word $0000      ; IRQ vector