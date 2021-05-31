#include "splash.h"

#define SCREENW 320
#define SCREENH 200

unsigned char* video = (unsigned char*) 0xa0000;
void draw (int frame) 
{
    int xoffset = (SCREENW - splash_gif_w) / 2;
    int yoffset = (SCREENH - splash_gif_h) / 2;
    for (int y = 0; y < splash_gif_h; ++y)
    {
        unsigned char* destination = video 
            + SCREENW * (y + yoffset)
            + xoffset;
        unsigned char* source = splash_gif
            + splash_gif_w * splash_gif_h * frame 
            + splash_gif_w * y;
        for (int x = 0; x < splash_gif_w; ++x)
            *(destination++) = *(source++) / 4; // scale to 6-bit color palette
    }
}

void main () 
{
    // text mode
    //char* video_memory = (char*) 0xb8000;
    //*video_memory = 'X';

    while (1)
        for (int i = 0; i < splash_gif_frames; ++i)
        {
            draw(i);
            asm("hlt");
        }
}
