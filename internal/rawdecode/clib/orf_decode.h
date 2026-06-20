#ifndef ORF_DECODE_H
#define ORF_DECODE_H
typedef struct
{
    unsigned char *data;
    int width;
    int height;
    int colors;
    int bits;
    char error[256];
} OrfImage;
OrfImage orf_decode(const char *path);
void orf_free(OrfImage *img);
#endif
