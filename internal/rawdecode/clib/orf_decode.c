#include "orf_decode.h"

#include <libraw/libraw.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void set_error(OrfImage *res, const char *stage, int code) {
    snprintf(res->error, sizeof(res->error), "%s: %s", stage, libraw_strerror(code));
}

OrfImage orf_decode(const char *path) {
    OrfImage res;
    memset(&res, 0, sizeof(res));

    libraw_data_t *raw = libraw_init(0);
    if (!raw) {
        snprintf(res.error, sizeof(res.error), "libraw_init failed");
        return res;
    }

    int ret = libraw_open_file(raw, path);
    if (ret != LIBRAW_SUCCESS) {
        set_error(&res, "open_file", ret);
        libraw_close(raw);
        return res;
    }

    ret = libraw_unpack(raw);
    if (ret != LIBRAW_SUCCESS) {
        set_error(&res, "unpack", ret);
        libraw_close(raw);
        return res;
    }

    raw->params.output_bps = 8;
    raw->params.output_color = 1;
    raw->params.use_camera_wb = 1;
    raw->params.no_auto_bright = 0;

    ret = libraw_dcraw_process(raw);
    if (ret != LIBRAW_SUCCESS) {
        set_error(&res, "process", ret);
        libraw_close(raw);
        return res;
    }

    int err = 0;
    libraw_processed_image_t *img = libraw_dcraw_make_mem_image(raw, &err);
    if (!img || err != 0) {
        set_error(&res, "make_mem_image", err);
        libraw_close(raw);
        return res;
    }

    size_t n = (size_t)img->width * (size_t)img->height * (size_t)img->colors;
    res.data = (unsigned char *)malloc(n);
    if (!res.data) {
        snprintf(res.error, sizeof(res.error), "out of memory copying image (%zu bytes)", n);
        libraw_dcraw_clear_mem(img);
        libraw_close(raw);
        return res;
    }
    memcpy(res.data, img->data, n);

    res.width = img->width;
    res.height = img->height;
    res.colors = img->colors;
    res.bits = img->bits;

    libraw_dcraw_clear_mem(img);
    libraw_close(raw);
    return res;
}

void orf_free(OrfImage *img) {
    if (img && img->data) {
        free(img->data);
        img->data = NULL;
    }
}