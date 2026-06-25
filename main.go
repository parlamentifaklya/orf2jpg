package main

import (
	"fmt"
	"image/jpeg"
	"os"
	"path/filepath"
	"strings"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/storage"
	"fyne.io/fyne/v2/widget"

	"orf2jpg/internal/rawdecode"
)

const jpegQuality = 95

func main() {
	a := app.New()
	w := a.NewWindow("ORF to JPG Converter")
	w.Resize(fyne.NewSize(480, 220))

	inputPathLabel := widget.NewLabel("No file selected")
	inputPathLabel.Wrapping = fyne.TextWrapBreak

	statusLabel := widget.NewLabel("")
	statusLabel.Wrapping = fyne.TextWrapBreak

	var selectedPath string

	chooseBtn := widget.NewButton("Choose .ORF file…", func() {
		fd := dialog.NewFileOpen(func(uc fyne.URIReadCloser, err error) {
			if err != nil {
				dialog.ShowError(err, w)
				return
			}
			if uc == nil {
				return
			}
			defer uc.Close()

			selectedPath = uc.URI().Path()
			inputPathLabel.SetText(selectedPath)
			statusLabel.SetText("")
		}, w)
		fd.SetFilter(storage.NewExtensionFileFilter([]string{".orf", ".ORF"}))
		fd.Show()
	})

	convertBtn := widget.NewButton("Convert to JPG", func() {
		if selectedPath == "" {
			dialog.ShowInformation("No file", "Choose an .ORF file first.", w)
			return
		}

		statusLabel.SetText("Decoding RAW data, please wait…")

		go func() {
			outPath, err := convert(selectedPath)
			if err != nil {
				statusLabel.SetText("Error: " + err.Error())
				return
			}
			statusLabel.SetText("Saved: " + outPath)
		}()
	})

	content := container.NewVBox(
		widget.NewLabelWithStyle("ORF → JPG Converter", fyne.TextAlignCenter, fyne.TextStyle{Bold: true}),
		chooseBtn,
		inputPathLabel,
		convertBtn,
		statusLabel,
	)

	w.SetContent(container.NewPadded(content))
	w.ShowAndRun()
}

func convert(srcPath string) (string, error) {
	img, err := rawdecode.DecodeORF(srcPath)
	if err != nil {
		return "", fmt.Errorf("decoding %s: %w", filepath.Base(srcPath), err)
	}

	ext := filepath.Ext(srcPath)
	outPath := strings.TrimSuffix(srcPath, ext) + ".jpg"

	f, err := os.Create(outPath)
	if err != nil {
		return "", fmt.Errorf("creating output file: %w", err)
	}
	defer f.Close()

	opts := &jpeg.Options{Quality: jpegQuality}
	if err := jpeg.Encode(f, img, opts); err != nil {
		return "", fmt.Errorf("encoding jpeg: %w", err)
	}

	return outPath, nil
}