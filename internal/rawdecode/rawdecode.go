package rawdecode

/*
#cgo CFLAGS: -I${SRCDIR}/clib
#cgo LDFLAGS: -L${SRCDIR}/clib -lorfdecode -Wl,-Bstatic -lraw -lgomp -lz -ljpeg -llcms2 -lstdc++ -Wl,-Bdynamic -lws2_32
#include "orf_decode.h"
#include <stdlib.h>
*/
import "C"
import (
	"fmt"
	"image"
	"unsafe"
)

func DecodeORF(path string) (image.Image, error) {
	cPath := C.CString(path)
	defer C.free(unsafe.Pointer(cPath))
	result := C.orf_decode(cPath)
	defer C.orf_free(&result)

	if result.data == nil {
		return nil, fmt.Errorf("libraw decode failed: %s", C.GoString(&result.error[0]))
	}
	if result.colors != 3 {
		return nil, fmt.Errorf("unexpected color channel count: %d (expected 3/RGB)", result.colors)
	}

	width := int(result.width)
	height := int(result.height)

	srcLen := width * height * 3
	src := unsafe.Slice((*byte)(result.data), srcLen)

	img := image.NewRGBA(image.Rect(0, 0, width, height))
	dst := img.Pix
	for i, j := 0, 0; i < srcLen; i, j = i+3, j+4 {
		dst[j+0] = src[i+0]
		dst[j+1] = src[i+1]
		dst[j+2] = src[i+2]
		dst[j+3] = 255
	}

	return img, nil
}
