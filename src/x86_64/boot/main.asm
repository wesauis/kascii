global start
extern long_mode_start

;;
;; this module will check and, if avaliable, enter 64 bit long mode
;;
;; FAIL CONDITIONS:
;;   M : not loaded using multiboot2
;;   C : no cpuid support
;;   E : no extended mode support
;;   L : no long mode support
;;
section .text ; code section
bits 32
start:
  ; saves the addr of the stack_top at the stack register
  mov esp, stack_top

  ; check long mode support
  call check_multiboot2
  call check_cpuid
  call check_long_mode

  call setup_page_tables ; create and setup pages for enabling 64 bits
  call enable_paging     ; enables paging and enters 32 bit compatibility submode

  lgdt [gdt64.pointer]                          ; load global descriptor table
  jmp gdt64.code_segment_offset:long_mode_start ; load code segment into the code selector
  hlt

;; 
;; check if was loaded using multiboot2
;;
;; https://www.gnu.org/software/grub/manual/multiboot2/html_node/Machine-state.html
;;
check_multiboot2:
  cmp eax, 0x36d76289 ; magic value
  jne .no_multiboot
  ret
.no_multiboot:
  mov al, "M"
  jmp error

;; 
;; check if cpuid is avaliable
;; 
;; for it we will flip a bit on the flags register
;; if the cpu allows this action cpuid is avaliable
;; before exiting we will undo the changes to the flags
;;
check_cpuid:
  pushfd            ; push flags register into the stack
  pop eax           ; pop from the stack into the eax register
  mov ecx, eax      ; backup to ecx
  xor eax, 1 << 21  ; flip the id bit
  push eax          ; push to the stack
  popfd             ; put back on the flags register
  pushfd            ; push the flags into the stack to verify worked
  pop eax           ; save updated flags to eax

  ; reset changes to the flags
  push ecx
  popfd 

  ; compare the updated against the original flags
  ; if equal cpuid is not avaliable
  ; return otherwise
  cmp eax, ecx
  je .no_cpuid
  ret
.no_cpuid:
  mov al, "C"
  jmp error

;; 
;; check if long mode is avaliable
;;
;; 64 bit long mode is our target
;; to check is it is avaliable we need to use cpuid
;; cpuid has slowly been extended over time
;; so we need to check for extended processor info first
;; if avaliable check for long mode
;; if avaliable return
;;
check_long_mode:
  ; extended processor info
  mov eax, 0x80000000            ; load this magic number to eax to serve as argument to cpuid
  cpuid                          ; cpuid will return a number to eax
  cmp eax, 0x80000001            ; we will compare the output with 0x80000001
  jb .no_extended_processor_info ; if not is not supported and we will jump

  ; long mode
  mov eax, 0x80000001 ; load this magic number to eax to serve as argument to cpuid
  cpuid               ; cpuid will return to edx this time
  test edx, 1 << 29   ; if the bit 29 is set long mode is avaliable
  jz .no_long_mode    ; if not is not supported and we will jump
  ret
.no_extended_processor_info:
  mov al, "E"
  jmp error
.no_long_mode:
  mov al, "L"
  jmp error

;;
;; error handler
;;
;; displays ERR: X on the screen
;;
;; ENTRY CONDITIONS:
;;   Registy `al` must contain a char that will represent what went wrong
;;
error:
  ; spells `ERR:  `
  mov dword [0x8000], 0x4f524f45 ; "RE"
  mov dword [0x8004], 0x4f3a4f52 ; ":R"
  mov dword [0x8008], 0x4f204f20 ; "  "
  mov byte [0x800a], al          ; error letter
  hlt                            ; enter idle mode (stops)

;; 
;; setup paging so we can enter 64 bit long mode
;;
;; we will identity map the first GB
;; the firts 12 bits of every entry will be used by the cpu to store flags
;; this can be calculated by the following formula: `log2 algnment`, resulting on the bits
;; alingment refers to the page alignment, in this case 4096, that results in 12 bits
;;
;; we will set some flags along the way
;; this pdf explain what this flags mean in detail
;; http://www.cs.albany.edu/~sdc/CSI500/Spr10/Classes/C15/intelpaging83-94.pdf
;; but I will add a sumarry here for better understanding
;;
;; present flag, first bit
;;   Indicates whether the page or page table being pointed to by the entry is
;;   currently loaded in physical memory. When the flag is set, the page is in 
;;   physical memory and address translation is carried out. When the flag is 
;;   clear, the page is not in memory and, if the processor attempts to access 
;;   the page, it generates a page-fault exception
;;
;; r/w (redable/writable) flag, second bit
;;   Specifies the read-write privileges for a page or group of pages (in the case of
;;   a page-directory entry that points to a page table). When this flag is clear, the
;;   page is read only; when the flag is set, the page can be read and written into.
;;
;; huge page (Page size (PS)) flag, bit 7
;;   this will allow for the l2 table to point directly to the physical memory 
;;   the spere 9 bits will act as a offset into the huge page, rather that as 
;;   an index on the l1, this will remove the need for l1 page and will make our
;;   life easyer
;;
setup_page_tables:
  mov eax, page_table_l3   ; get the addr of l3
  or eax, 0b11             ; enable present and r/w
  mov [page_table_l4], eax ; save the l3 addr in the first entry of l4

  mov eax, page_table_l2   ; get the addr of l2
  or eax, 0b11             ; enable present and r/w
  mov [page_table_l3], eax ; save the l2 addr in the first entry of l3

  ; use the huge page flag trick
  ; we will fill all 512 entries of the l2 table
  ; for this lets use a for loop :)
  mov ecx, 0 ; i=0
.loop:

  mov eax, 0x200000                   ; 2MiB
  mul ecx                             ; eax * ecx == addr of the next page
  or eax, 0b10000011                  ; present, r/w and huge page
  mov [page_table_l2 + ecx * 8], eax  ; save the data into the right index
  
  inc ecx         ; increment counter ; i++
  cmp ecx, 512    ; checks if the whole table is mapped
  jne .loop       ; if not -> repeat
  ret

;;
;; enable pages and enters 32 bit compatibility submode
;;
;; for entering 64 bit long mode we need to enable paging
;; the tables, setup with `setup_page_tables` now need to be activated
;; to do it we will need to store the addr of l4 into cr3
;; the cr4 registry is used by the cpu for locating the outer page (l4)
;;
enable_paging:
  mov eax, page_table_l4  ; get the addr of l4
  mov cr3, eax            ; store the addr of l4 into cr3

  ; enable PAE(Physical Address Extension)
  ; when active the page size flag will became 2MiB long
  ; this will allow the trick that we used on the l2 page to work
  mov eax, cr4    ; load paging options
  or eax, 1 << 5  ; enable pae
  mov cr4, eax    ; save

  ; enable 32 bit compatibility submode
  mov ecx, 0xC0000080  ; magic number
  rdmsr                ; read module specific registers
  or eax, 1 << 8       ; enable long mode
  wrmsr                ; write module specific registers

  ; enable paging 
  mov eax, cr0
  or eax, 1 << 31
  mov cr0, eax

  ret

;;
;; static allocated variables
;;
;; will contain out page tables and our stack
;;
section .bss
align 4096      ; align tables to 4KiB
page_table_l4:
  resb 4096
page_table_l3:
  resb 4096
page_table_l2:
  resb 4096
stack_bottom:
  resb 4096 * 4 ; reserve 16KiB
stack_top:

;;
;; readonly data
;;
;; we will store here our 64 bit global descriptor table (gdt64)
;; this is needed to enter the 64 bit long mode
;;
section .rodata
gdt64:
  dq 0
.code_segment_offset: equ $ - gdt64
  ;  excecutable 
  ;  |           descriptor type 1 for code and data segments 
  ;  |           |           present flag 
  ;  |           |           |           64 bit flag
  dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) 
.pointer:
  ; longer pointer that also holds two bytes for the lenght of the table
  dw $ - gdt64 - 1 ; length - 1: $(start) - gdt64(end)
  dq gdt64
