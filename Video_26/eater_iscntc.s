ISCNTC:
  JRS MONRDKEY
  BCC not_cntc ; if carry flag is cleared, which means that no key pressed

  CMP #3 ; ascii code of ctrl+c
  BNE not_cntc
  JMP is_cntc

not_cntc:
  RTS

is_cntc:
  ; fall through