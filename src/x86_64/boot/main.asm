global start
extern long_mode_start

section .text ; code section
bits 32 ; for now is 32 bit mode, we will fix it later
start:
  ; stores the adress of the top of the stack on the stack register
  mov esp, stack_top

  ; switch the cpu to 64 bit mode (long mode)
  call check_multiboot2
  call check_cpuid
  call check_long_mode

  ; 64 bit long mode is avaliable
  ; to enter we need to fist setup paging
  call setup_page_tables
  call enable_paging ; enables paging and enters 32 bit compatibility submode

  ; load global descriptor table
  lgdt [gdt64.pointer]
  ; load code segment into the code selector
  jmp gdt64.code_segment_offset:long_mode_start
  hlt

; https://www.gnu.org/software/grub/manual/multiboot2/html_node/Machine-state.html
check_multiboot2:
  cmp eax, 0x36d76289 ; magic value
  jne .no_multiboot
  ret
.no_multiboot:
  mov al, "M"
  jmp error

check_cpuid:
  ; attemp to flip the id bit of the flags register
  ; if works cpuid is avaliable
  pushfd ; push flags register to the stack
  pop eax ; pop from the stack into the eax register
  mov ecx, eax ; copy to ecx
  xor eax, 1 << 21 ; flip id bit (21)
  push eax ; push to the stack
  popfd ; put on the flags register
  pushfd ; get the flags register into the stack
  pop eax ; save updated flags to eax
  push ecx
  popfd ; reset changes to the flags
  cmp eax, ecx ; if equal cpuid is not avaliable
  je .no_cpuid
  ret
.no_cpuid:
  mov al, "C"
  jmp error

check_long_mode:
  ; cpuid has slowly been extended over time
  ; so we need to check for extended processor info first
  mov eax, 0x80000000
  cpuid ; loads eax and outputs to eax
  cmp eax, 0x80000001 ; if less then this value is not supported
  jb .no_extended_processor_info

  mov eax, 0x80000001
  cpuid ; loads eax and outputs to edx
  test edx, 1 << 29 ; if lm bit (29) is set, long mode is avaliable
  jz .no_long_mode
  ret
.no_extended_processor_info:
  mov al, "E"
  jmp error
.no_long_mode:
  mov al, "L"
  jmp error

setup_page_tables:
  ; identity mapping the first GB
  mov eax, page_table_l3
  ; the pages are aligned to 4096B
  ; log2 4096 = 12
  ; this tells us that the fist 12 bits of every entry will always going to be 0
  ; the cpu will use this bits to store flags
  or eax, 0b11 ; enable present(0b1) and r/w(0b10) flags
  ; http://www.cs.albany.edu/~sdc/CSI500/Spr10/Classes/C15/intelpaging83-94.pdf
  ; present (first bit)
  ;   Indicates whether the page or page table being pointed to by the entry is
  ;   currently loaded in physical memory. When the flag is set, the page is in physical memory and address translation is carried out. When the flag is clear, the
  ;   page is not in memory and, if the processor attempts to access the page, it
  ;   generates a page-fault exception
  ; r/w (second bit)
  ;   Specifies the read-write privileges for a page or group of pages (in the case of
  ;   a page-directory entry that points to a page table). When this flag is clear, the
  ;   page is read only; when the flag is set, the page can be read and written into.
  mov [page_table_l4], eax ; place this adress as the fist entry on the l4 page table

  ; repeat for level 3
  mov eax, page_table_l2
  or eax, 0b11
  mov [page_table_l3], eax

  ; use the huge page flag
  ; this will allow for the l2 table to point to the physical memory directly
  ; the spere 9 bits will act as a offset into the huge page, rather that as an index on the l1
  ; fill all 512 entries of the l2 table
  ; lets use a for loop :)
  mov ecx, 0 ; i=0
.loop:

  mov eax, 0x200000 ; 2MiB
  mul ecx ; multiplying eax by ecx returns the adress for the next page
  or eax, 0b10000011 ; present(0b1), r/w(0b10), hugepage(0b10000000)
  mov [page_table_l2 + ecx * 8], eax
  
  inc ecx ; i++
  cmp ecx, 512 ; checks if the whole table is mapped
  jne .loop

  ret

enable_paging:
  ; pass page table location to cpu
  mov eax, page_table_l4
  mov cr3, eax

  ; enable PAE (needed for 64 bit paging)
  mov eax, cr4
  or eax, 1 << 5 ; PAE flag (5)
  mov cr4, eax

  ; enable long mode
  mov ecx, 0xC0000080
  rdmsr ; read module specific registers
  or eax, 1 << 8 ; enable long mode
  wrmsr ; write module specific registers

  ; enable paging 
  mov eax, cr0
  or eax, 1 << 31 ; enable paging bit
  mov cr0, eax

  ret

error:
  ; print ERR: X; where X is the error code char stored on the `al` register
  mov dword [0x8000], 0x4f524f45 ; "RE"
  mov dword [0x8004], 0x4f3a4f52 ; ":R"
  mov dword [0x8008], 0x4f204f20 ; "  "
  mov byte [0x800a], al
  ; stops
  hlt

; contains static allocated variables
section .bss
align 4096 ; align tables to 4KiB
page_table_l4:
  resb 4096
page_table_l3:
  resb 4096
page_table_l2:
  resb 4096
; the stack (first in, last out)
stack_bottom:
  ; reserve 16KiB
  resb 4096 * 4
stack_top:

; readonly data
section .rodata
; 64 bit global descriptor table
gdt64:
  dq 0 ; zero entry
.code_segment_offset: equ $ - gdt64 ; store offset inside the desciptor table intead of adress
  ;  excecutable 
  ;  |           descriptor type 1 for code and data segments 
  ;  |           |           present flag 
  ;  |           |           |           64 bit flag
  dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) 
.pointer:
  ; longer pointer that also holds two bytes for the lenght of the table
  dw $ - gdt64 - 1 ; length - 1: $(start) - gdt64(end)
  dq gdt64
