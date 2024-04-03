;;; configuration ;;;
CONFIG_2A := 1

; CONFIG_CBM_ALL := 1

; CONFIG_DATAFLG := 1
; CONFIG_EASTER_EGG := 1
; CONFIG_FILE := 1; support PRINT#, INPUT#, GET#, CMD
; CONFIG_NO_CR := 1; terminal doesn't need explicit CRs on line ends
; CONFIG_NO_LINE_EDITING := 1; support for "@", "_", BEL etc.
; CONFIG_NO_READ_Y_IS_ZERO_HACK := 1
; CONFIG_PEEK_SAVE_LINNUM := 1
CONFIG_SCRTCH_ORDER := 2 ; just follow the setting of cbm2

;;; zero page ;;;
ZP_START1 = $00 ; 4 variables, 10-bytes
ZP_START2 = $0A ; 5 variables, 6-bytes and also input buffer exists(give it $50)
ZP_START3 = $60 ; 10 variables, at most 11-bytes
ZP_START4 = $6B

;;; extra/override ZP variables ;;;
; CURDVC			:= $000E
; TISTR			:= $008D
; Z96				:= $0096
; POSX			:= $00C6
; TXPSV			:= LASTOP
USR				:= GORESTART ; XXX

;;; inputbuffer ;;;
; INPUTBUFFER     := $0200

;;; constants ;;;
SPACE_FOR_GOSUB := $3E
STACK_TOP		:= $FA
WIDTH			:= 40
WIDTH2			:= 30

RAMSTART2		:= $0400 ; where ram starts, not counting zero page or stack, etc

;;; magic memory locations ;;;
; ENTROPY = $E844

;;; monitor functions ;;;
; OPEN	:= $FFC0
; CLOSE	:= $FFC3
; CHKIN	:= $FFC6
; CHKOUT	:= $FFC9
; CLRCH	:= $FFCC
; CHRIN	:= $FFCF
; CHROUT	:= $FFD2
; VERIFY	:= $FFDB
; SYS		:= $FFDE
; GETIN	:= $FFE4
; CLALL	:= $FFE7
; LE7F3	:= $E7F3; for CBM1

; labels added to 'bios.s' directly, no more need to define it
; LOAD	:= $FFD5
; SAVE	:= $FFD8
; ISCNTC	:= $FFE1
; MONCOUT	:= CHROUT
; MONRDKEY := CHRIN