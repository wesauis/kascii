global long_mode_start
extern kernel_main

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
  ; hello c
  call kernel_main

  ; sets the cpu to idle state
  ; https://en.wikipedia.org/wiki/HLT_(x86_instruction)
  hlt
