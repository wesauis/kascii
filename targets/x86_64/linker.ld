ENTRY(start)

SECTIONS
{
  . = 1M;

  .boot : /* multibot header 1MB in */
  {
    KEEP(*(.multiboot2_header))
  }

  .text : /* kernel code */
  {
    *(.text)
  }
}