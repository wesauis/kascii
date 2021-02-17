#include "screen.h"

void kernel_main() {
  clear();
  set_color(COLOR_YELLOW, COLOR_BLACK);
  write_str("welcome to kascii!");
}