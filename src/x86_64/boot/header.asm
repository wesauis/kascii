;; 
;; multiboot2 header following the especification
;;
;; https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-magic-fields
;;
section .multiboot2_header
header_start:
  dd 0xE85250D6 ; magic number ; multiboot2
  dd 0          ; architecture ; protected mode i386
  dd header_end - header_start ; header_lenght

  ; checksum
  dd 0x100000000 - (0xE85250D6 + 0 + header_end - header_start) 

  ; end tag
  dw 0
  dw 0
  dd 8
header_end: