.setcpu "65C02"
.debuginfo

.zeropage ; faster and limited space
.org ZP_START0
READ_PTR: .res 1
WRITE_PTR: .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100

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
  PHX ; to not touch X register

  JSR RETURN_BUFFER_SIZE
  BEQ @no_keypressed
  JSR READ_BUFFER

  JSR CHROUT ; echo

  PLX ; to not touch X register
  SEC
  RTS
@no_keypressed:
  PLX ; to not touch X register
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

; initialize the circular input buffer
; modifies: flags, A
INIT_BUFFER:
  LDA READ_PTR ; store same random value to read ptr and write ptr
  STA WRITE_PTR
  RTS

; write buffer using the value in Accumulator
; modifies: flags, X
WRITE_BUFFER:
  LDX WRITE_PTR
  STA INPUT_BUFFER, x
  INC WRITE_PTR
  RTS

; read buffer into Accumulator
; modifies: flags, A, X
READ_BUFFER:
  LDX READ_PTR
  LDA INPUT_BUFFER, x
  INC READ_PTR
  RTS

; check the size of the string that still is waiting to be read
; modifies: flags, A
RETURN_BUFFER_SIZE:
  LDA WRITE_PTR
  SEC
  SBC READ_PTR
  RTS

;;; interrupt handler ;;;
IRQ_HANDLER: ; about 60 clock cycle(60ms)
  PHA
  PHX

  ; let UART chip know that we are handling interrupt, so that the interrupt signal goes high disable
  ; actually we are assuming that the only source of interrupt is incoming data
  ; to make it clear, we connect DCDB pin and DSRB pin into ground voltage.
  LDA ACIA_STATUS

  LDA ACIA_DATA
  JSR WRITE_BUFFER

  PLX
  PLA
  RTI

.include "adapted_wozmon.s"

.segment "RESETVEC" ; to tell linker where this code should be located by 'bios.cfg' file

.word $0F00       ; NMI verctor
.word RESET       ; RESET vector
.word IRQ_HANDLER ; IRQ vector