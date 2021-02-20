#pragma once

#include <stdint.h>
#include <stddef.h>

extern size_t WIDTH;
extern size_t HEIGHT;

enum {
  COLOR_BLACK       =  0,
	COLOR_BLUE        =  1,
	COLOR_GREEN       =  2,
	COLOR_CYAN        =  3,
	COLOR_RED         =  4,
	COLOR_MAGENTA     =  5,
	COLOR_BROWN       =  6,
	COLOR_LIGHT_GRAY  =  7,
	COLOR_DARK_GRAY   =  8,
	COLOR_LIGHT_BLUE  =  9,
	COLOR_LIGHT_GREEN = 10,
	COLOR_LIGHT_CYAN  = 11,
	COLOR_LIGHT_RED   = 12,
	COLOR_PINK        = 13,
	COLOR_YELLOW      = 14,
	COLOR_WHITE       = 15,
};

void    rect      ( size_t  x0, size_t  y0, size_t x1, size_t y1, char chr );
void    border    ( size_t  x0, size_t  y0, size_t x1, size_t y1, char chr );
void    set_color ( uint8_t fg, uint8_t bg );
uint8_t get_color ( size_t   x, size_t   y );
void    write_chr ( size_t   x, size_t   y, char chr );
char    get_chr   ( size_t   x, size_t   y );
void    write_str ( size_t   x, size_t   y, char* str );