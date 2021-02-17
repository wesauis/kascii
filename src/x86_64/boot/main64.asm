global long_mode_start

section .text
bits 64 ; finally!
long_mode_start:
  ; load null into all data segment registers
  mov ax, 0
  mov ss, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; 64 bit ftw!

  ; print `OK`
  ; 0xb8000: video memory adress
  ; 0x2f4b2f4f: OK with green bg and white fg
  mov dword [0xb8000], 0x2f4b2f4f 

  ; sets the cpu to idle state
  ; https://en.wikipedia.org/wiki/HLT_(x86_instruction)
  hlt
