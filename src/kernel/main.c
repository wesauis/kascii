#include "screen.h"

void kernel_main() {
  // clear screen
  set_color(COLOR_WHITE, COLOR_BLACK);
  rect(0, 0, WIDTH, HEIGHT, ' ');

  size_t x = 21;
  size_t y = 9;

  set_color(COLOR_CYAN, COLOR_BLACK);
  write_str(x, y - 1, "welcome to");

  set_color(COLOR_BLACK, COLOR_YELLOW);
  char kascii[5][37] = {
    "#  ##   #    ####   ####   #### #####",
    "# ##   # #  #      #      #       #  ",
    "##    #   #  ###   #      #       #  ",
    "# ##  #####     #  #      #       #  ",
    "#  ## #   # ####    ####   #### #####"
  };
  for(size_t i = 0; i < 37; i++) {
    for (size_t j = 0; j < 5; j++) {
      if (kascii[j][i] == '#') {
        write_chr(x + i, y + j, ' ');
      }
    }
  }
}
