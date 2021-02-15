section .multiboot2_header
; https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-magic-fields
header_start:
  ; magic number
  dd 0xE85250D6 ; multiboot2
  ; architecture
  dd 0 ; protected mode i386
  ; header_lenght
  dd header_end - header_start
  ; checksum
  dd 0x100000000 - (0xE85250D6 + 0 + header_end - header_start)

  ; end tag
  dw 0
  dw 0
  dd 8
header_end: