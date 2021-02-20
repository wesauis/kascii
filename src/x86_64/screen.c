#include "screen.h"

// we are in VGA text mode
// https://en.wikipedia.org/wiki/VGA_text_mode

size_t WIDTH = 80;
size_t HEIGHT = 25;

struct Char {
  uint8_t character;
  uint8_t color;
};

struct Char* buffer = (struct Char*) 0xb8000;

uint8_t color = COLOR_WHITE + (COLOR_BLACK << 4);

size_t __index(size_t x, size_t y) {
  if (x >= WIDTH || y >= HEIGHT) {
    return -1;
  } else {
    return x + y * WIDTH;
  }
}

void rect(size_t x0, size_t y0, size_t x1, size_t y1, char chr) {
  size_t xs, xi, xe, ys, yi, ye;
  if (x0 < x1) {    xs =  1;    xi = x0;    xe = x1; } 
  else {            xs = -1;    xi = x1;    xe = x0; }
  if (y0 < y1) {    ys =  1;    yi = y0;    ye = y1; } 
  else {            ys = -1;    yi = y1;    ye = y0; }

  for (size_t x = xi; x < xe; x += xs) {
    for (size_t y = yi; y < ye; y += ys) {
      write_chr(x, y, chr);
    }
  }
}

void border(size_t x0, size_t y0, size_t x1, size_t y1, char chr) {
  size_t xs, xi, xe, ys, yi, ye;
  if (x0 < x1) {    xs =  1;    xi = x0;    xe = x1; } 
  else {            xs = -1;    xi = x1;    xe = x0; }
  if (y0 < y1) {    ys =  1;    yi = y0;    ye = y1; } 
  else {            ys = -1;    yi = y1;    ye = y0; }

  for (size_t x = xi; x <= xe; x += xs) {
    write_chr(x, y0, chr);
    write_chr(x, y1, chr);
  }

  for (size_t y = yi; y <= ye; y += ys) {
    write_chr(x0, y, chr);
    write_chr(x1, y, chr);
  }
}

void set_color(uint8_t fg, uint8_t bg) {
  color = fg + (bg << 4);
}

uint8_t get_color(size_t x, size_t y) {
  return buffer[__index(x, y)].color;
}

void write_chr(size_t x, size_t y, char chr) {
  size_t index = __index(x, y);
  if (index == -1) return;

  buffer[index] = (struct Char) {
    character: (uint8_t) chr,
    color: color,
  };
}

char get_chr(size_t x, size_t y) {
  return (char) buffer[__index(x, y)].character;
}

void write_str(size_t x, size_t y, char* str) {
  for (size_t i = 0; 1; i++) {
    char chr = (uint8_t) str[i];

    size_t _x = x + i;
    if (chr == '\0' || _x >= WIDTH) {
      break;
    }

    write_chr(_x, y, chr);
  }
}
