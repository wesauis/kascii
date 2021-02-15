global start

section .text ; code section
bits 32 ; for now is 32 bit mode, we will fix it later
start:
  ; print `OK`
  ; 0xb8000: video memory adress
  ; 0x2f4b2f4f: OK with green bg and white fg
  mov dword [0xb8000], 0x2f4b2f4f 

  ; sets the cpu to idle state
  ; https://en.wikipedia.org/wiki/HLT_(x86_instruction)
  hlt

; https://www.youtube.com/watch?v=wz9CZBeXR6U&list=PLZQftyCk7_SeZRitx5MjBKzTtvk0pHMtp&index=2