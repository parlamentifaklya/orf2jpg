#include "orf_decode.h"
#include <stdio.h>

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s input.orf output.ppm\n", argv[0]);
        return 1;
    }

    const char *in_path = argv[1];
    const char *out_path = argv[2];

    printf("starting decode of %s\n", in_path);
    fflush(stdout);

    OrfImage img = orf_decode(in_path);

    printf("orf_decode returned, data=%p\n", (void*)img.data);
    fflush(stdout);

    if (!img.data) {
        fprintf(stderr, "decode failed: %s\n", img.error);
        return 1;
    }

    printf("decoded: %dx%d, %d channels, %d bits/channel\n",
           img.width, img.height, img.colors, img.bits);
    fflush(stdout);

    FILE *f = fopen(out_path, "wb");
    if (!f) {
        fprintf(stderr, "could not open %s for writing\n", out_path);
        orf_free(&img);
        return 1;
    }

    fprintf(f, "P6\n%d %d\n255\n", img.width, img.height);

    size_t n = (size_t)img.width * img.height * img.colors;
    printf("writing %zu bytes\n", n);
    fflush(stdout);

    fwrite(img.data, 1, n, f);
    fclose(f);

    printf("wrote %s\n", out_path);
    orf_free(&img);
    return 0;
}