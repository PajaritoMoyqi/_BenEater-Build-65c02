;  The WOZ Monitor for the Ben Eater 6502 Compu
;  Written by Steve Wozniak in 1976 and adapted & introduced by Ben Eater in 2023
;  Some annotations added by PajaritoMoyqi
.setcpu "65C02"
.segment "WOZMON" ; to tell linker where this code should be located by 'bios.cfg' file
;;  Don't need .org in most cases because specifing address is job for the linker not for the assembler.
; .org $8000
; .org $FF00

; Page 0 Variables
XAML            = $24           ;  Last "opened" location Low
XAMH            = $25           ;  Last "opened" location High
STL             = $26           ;  Store address Low
STH             = $27           ;  Store address High
L               = $28           ;  Hex value parsing Low
H               = $29           ;  Hex value parsing High
YSAV            = $2A           ;  Used to see if hex value is given
MODE            = $2B           ;  $00=XAM, $74=STOR, $B8=BLOCK XAM

;; Now it is defined in 'bios.s' which is linked to this file
; Other Variables
; IN              = $0200         ;  Input buffer to $027F
; ACIA_DATA       = $5000         ;  data RT register
; ACIA_STATUS     = $5001         ;  status register
; ACIA_CMD        = $5002         ;  command register
; ACIA_CTRL       = $5003         ;  control register

RESET:          CLD             ; Clear decimal arithmetic mode.
                CLI
                LDA #$1F        ; one stop bit, word length 8 bit, receiver baud rate same, 19200 baud rate
                STA ACIA_CTRL
                ; make trick to get rid of 1-line code (LDY, 0B->8B)
                LDY #$8B        ; parity mode disable, not use echo mode, disable interrupt, IRQB disable, data terminal ready although we don't use it
                STA ACIA_CMD

NOTCR:          CMP #$80        ; Backspace key?
                BEQ BACKSPACE   ; Yes.
                CMP #$1B        ; ESC?
                BEQ ESCAPE      ; Yes.
                INY             ; Advance text index.
                BPL NEXTCHAR    ; Auto ESC if > 127.

ESCAPE:         LDA #$5C        ; "\".
                JSR ECHO        ; Output it.

GETLINE:        LDA #$0D        ; Send CR.
                JSR ECHO        ; Output it.
                LDA #$0A        ; Send LF.
                JSR ECHO        ; Output it.

                LDY #$01        ; Initialize text index.
BACKSPACE:      DEY             ; Back up text index.
                BMI GETLINE     ; Beyond start of line, reinitialize.

NEXTCHAR:       LDA ACIA_STATUS ; Check status.
                AND #$08        ; Key ready?
                BEQ NEXTCHAR    ; Loop until ready
                ; we change this B7 always 1 to 0, so we need to change all keyboard values, that is -8 for all of MSB value
                ; we can do this more programmer-freindly code, but our 1st goal is keep this code in same amount of original code.
                LDA ACIA_DATA   ; Load character. B7 will be '0'.
                STA IN,Y        ; Add to text buffer.
                JSR ECHO        ; Display character.
                CMP #$0D        ; CR?
                BNE NOTCR       ; No.

                LDY #$FF        ; Reset text index.
                LDA #$00        ; For XAM mode.
                TAX             ; 0->X.
SETBLOCK:       ASL             ; to shift left twice
SETSTOR:        ASL             ; Leaves $7B if setting STOR mode.
                STA MODE        ; $00=XAM, $74=STOR, $B8=BLOCK XAM.
BLSKIP:         INY             ; Advance text index.
NEXTITEM:       LDA IN,Y        ; Get character.
                CMP #$0D        ; CR?
                BEQ GETLINE     ; Yes, done this line.
                CMP #$2E        ; "."?
                BCC BLSKIP      ; Skip delimiter.
                BEQ SETBLOCK    ; Set BLOCK XAM mode.
                CMP #$3A        ; ":"?
                BEQ SETSTOR     ; Yes. Set STOR mode.
                CMP #$52        ; "R"?
                BEQ RUNPROG     ; Yes. Run user program.
                STX L           ; $00->L.
                STX H           ;  and H.
                STY YSAV        ; Save Y for comparison.
NEXTHEX:        LDA IN,Y        ; Get character for hex test.
                EOR #$30        ; Map digits to $0-9.
                CMP #$0A        ; Digit?
                BCC DIG         ; Yes.
                ADC #$88        ; Map letter "A"-"F" to $FA-FF.
                CMP #$FA        ; Hex letter?
                BCC NOTHEX      ; No, character not hex.
DIG:            ASL
                ASL             ; Hex digit to MSD of A.
                ASL
                ASL

                LDX #$04        ; Shift count.
HEXSHIFT:       ASL             ; Hex digit left, MSB to carry.
                ROL L           ; Rotate into LSD.
                ROL H           ; Rotate into MSD’s.
                DEX             ; Done 4 shifts?
                BNE HEXSHIFT    ; No, loop.
                INY             ; Advance text index.
                BNE NEXTHEX     ; Always taken. Check next character for hex.
NOTHEX:         CPY YSAV        ; Check if L, H empty (no hex digits).
                BEQ ESCAPE      ; Yes, generate ESC sequence.
                BIT MODE        ; Test MODE byte.
                BVC NOTSTOR     ; B6=0 STOR, 1 for XAM and BLOCK XAM
                LDA L           ; LSD’s of hex data.
                STA (STL,X)     ; Store at current ‘store index’.
                INC STL         ; Increment store index.
                BNE NEXTITEM    ; Get next item. (no carry).
                INC STH         ; Add carry to ‘store index’ high order.
TONEXTITEM:     JMP NEXTITEM    ; Get next command item.
RUNPROG:        JMP (XAML)      ; Run at current XAM index.
NOTSTOR:        BMI XAMNEXT     ; B7=0 for XAM, 1 for BLOCK XAM.

                LDX #$02        ; Byte count.
SETADR:         LDA L-1,X       ; Copy hex data to
                STA STL-1,X     ;  ‘store index’.
                STA XAML-1,X    ; And to ‘XAM index’.
                DEX             ; Next of 2 bytes.
                BNE SETADR      ; Loop unless X=0.
NXTPRNT:        BNE PRDATA      ; NE means no address to print.
                LDA #$0D        ; CR.
                JSR ECHO        ; Output it.
                LDA #$0A        ; Send LF.
                JSR ECHO        ; Output it.
                LDA XAMH        ; ‘Examine index’ high-order byte.
                JSR PRBYTE      ; Output it in hex format.
                LDA XAML        ; Low-order ‘examine index’ byte.
                JSR PRBYTE      ; Output it in hex format.
                LDA #$3A        ; ":".
                JSR ECHO        ; Output it.
PRDATA:         LDA #$20        ; Blank.
                JSR ECHO        ; Output it.
                LDA (XAML,X)    ; Get data byte at ‘examine index’.
                JSR PRBYTE      ; Output it in hex format.
XAMNEXT:        STX MODE        ; 0->MODE (XAM mode).
                LDA XAML
                CMP L           ; Compare ‘examine index’ to hex data.
                LDA XAMH
                SBC H
                BCS TONEXTITEM  ; Not less, so no more data to output.
                INC XAML
                BNE MOD8CHK     ; Increment ‘examine index’.
                INC XAMH
MOD8CHK:        LDA XAML        ; Check low-order ‘examine index’ byte
                AND #$07        ; For MOD 8=0
                BPL NXTPRNT     ; Always taken.
PRBYTE:         PHA             ; Save A for LSD.
                LSR
                LSR
                LSR             ; MSD to LSD position.
                LSR
                JSR PRHEX       ; Output hex digit.
                PLA             ; Restore A.
PRHEX:          AND #$0F        ; Mask LSD for hex print.
                ORA #$30        ; Add "0".
                CMP #$3A        ; Digit?
                BCC ECHO        ; Yes, output it.
                ADC #$06        ; Add offset for letter.
; should be $FFEF in memory to match the given condition from apple 1
; jump to subrutine in $FFEF, test program prints ascii characters
ECHO:           PHA             ; store Acccumulator
                STA ACIA_DATA   ; Ouput character.
                LDA #$FF        ; Initialize delay loop.
TXDELAY:        DEC             ; Decrement A.
                BNE TXDELAY     ; Until A gets to 0.
                PLA             ; Restore Accumulator.
                RTS             ; Return.

              ;; also it goes to 'bios.s' file
              ;  .segment "RESETVEC" ; to tell linker where this code should be located by 'bios.cfg' file
              ; ;  .org $FFFA
              ;  .word $0F00      ; NMI verctor
              ;  .word RESET      ; RESET vector
              ;  .word $0000      ; IRQ vector