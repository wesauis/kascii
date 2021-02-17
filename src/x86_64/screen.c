#include "screen.h"

const static size_t COLS = 80;
const static size_t ROWS = 25;

struct Char {
  uint8_t character;
  uint8_t color;
};

struct Char* buffer = (struct Char*) 0xb8000;

// defaults
size_t c_col = 0;
size_t c_row = 0;
uint8_t color = COLOR_WHITE | COLOR_BLACK << 4;

void clear_row(size_t row) {
  struct Char empty = (struct Char) {
    character: ' ',
    color: color,
  };

  for(size_t col = 0; col < COLS; col++) {
    buffer[col + row * COLS] = empty;
  }
}

void clear() {
  for(size_t row = 0; row < ROWS; row++) {
    clear_row(row);
  }
}

void write_nl() {
  c_col = 0;

  if (c_row = ROWS - 1) {
    c_row++;
    return;
  }

  for (size_t row = 1; row < ROWS; row++) {
    for (size_t col = 0; col < COLS; col++) {
      struct Char c = buffer[col + row * COLS];
      buffer[col + (row - 1) * COLS] = c;
    }
  }

  clear_row(COLS - 1);
}

void write_chr(char c) {
  if (c == '\n') {
    write_nl();
    return;
  }
  
  if (c_col > COLS) {
    write_nl();
  }

  buffer[c_col + c_row * COLS] = (struct Char) {
    character: (uint8_t) c,
    color: color,
  };

  c_col++;
}

void write_str(char* str) {
  for (size_t i = 0; 1; i++) {
    char c = (uint8_t) str[i];

    if (c == '\0') {
      return;
    }

    write_chr(c);
  }
}

void set_color(uint8_t fg, uint8_t bg) {
  color = fg + (bg << 4);
}
