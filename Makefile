CC = gcc
CLIBDIR = internal/rawdecode/clib
BINNAME = orf2jpg
BINEXT = .exe

all: $(CLIBDIR)/liborfdecode.a
	go build -ldflags "-H windowsgui" -o orf2jpg.exe ./cmd/orf2jpg

$(CLIBDIR)/liborfdecode.a: $(CLIBDIR)/orf_decode.c $(CLIBDIR)/orf_decode.h
	$(CC) -c $(CLIBDIR)/orf_decode.c -o $(CLIBDIR)/orf_decode.o
	ar rcs $(CLIBDIR)/liborfdecode.a $(CLIBDIR)/orf_decode.o

test-c:
	$(CC) $(CLIBDIR)/test_main.c $(CLIBDIR)/orf_decode.c -o $(CLIBDIR)/test_decode.exe -lraw
	$(CLIBDIR)/test_decode.exe $(FILE) $(CLIBDIR)/out.ppm

clean:
	rm -f $(CLIBDIR)/orf_decode.o $(CLIBDIR)/liborfdecode.a $(CLIBDIR)/test_decode.exe $(CLIBDIR)/out.ppm $(BINNAME)$(BINEXT)