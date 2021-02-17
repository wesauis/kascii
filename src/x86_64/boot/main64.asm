global long_mode_start
extern kernel_main

;;
;; 64 bit code
;;
;; here we will do some resets (setting null) and calling our c main
;; goodby assembly (for now)
;; hello c
;;
section .text
bits 64
long_mode_start:
  ; load null into all data segment registers
  mov ax, 0
  mov ss, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  call kernel_main

  hlt
