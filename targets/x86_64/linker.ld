ENTRY(start)

SECTIONS
{
  /* set the current adress to 1MB */
  /* this means that all of out OS data will start 1MB in */
  /* this is a convension for kernels to be loaded by the bootloader */
  . = 1M;

  /* place the header at the boot section */
  .boot :
  {
    KEEP(*(.multiboot2_header))
  }

  /* code section */
  .text :
  {
    *(.text)
  }
}