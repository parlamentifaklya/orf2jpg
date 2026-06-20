package main

/*
#cgo CFLAGS: -I${SRCDIR}
#cgo LDFLAGS: -L${SRCDIR} -lmyheader
#include "myheader.h"
*/
import "C"
import "fmt"

func main() {
	fmt.Println(C.add(2, 3))
}
