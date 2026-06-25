; orf2jpg Installer
; Build with: makensis installer.nsi

!define APP_NAME "ORF to JPG Converter"
!define APP_EXE "orf2jpg.exe"
!define APP_VERSION "1.0"
!define INSTALL_DIR "$PROGRAMFILES64\orf2jpg"

Name "${APP_NAME}"
OutFile "orf2jpg-setup.exe"
InstallDir "${INSTALL_DIR}"
InstallDirRegKey HKLM "Software\orf2jpg" "InstallDir"
RequestExecutionLevel admin
SetCompressor lzma

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install"
    SetOutPath "$INSTDIR"

    File "orf2jpg.exe"
    File "libraw-25.dll"
    File "libgcc_s_seh-1.dll"
    File "liblcms2-2.dll"
    File "libjpeg-8.dll"
    File "libgomp-1.dll"
    File "zlib1.dll"
    File "libwinpthread-1.dll"
    File "libstdc++-6.dll"

    WriteUninstaller "$INSTDIR\uninstall.exe"

    WriteRegStr HKLM "Software\orf2jpg" "InstallDir" "$INSTDIR"

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\orf2jpg" \
        "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\orf2jpg" \
        "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\orf2jpg" \
        "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\orf2jpg" \
        "Publisher" "Andor"

    CreateShortcut "$DESKTOP\ORF to JPG Converter.lnk" "$INSTDIR\${APP_EXE}"

    CreateDirectory "$SMPROGRAMS\orf2jpg"
    CreateShortcut "$SMPROGRAMS\orf2jpg\ORF to JPG Converter.lnk" "$INSTDIR\${APP_EXE}"
    CreateShortcut "$SMPROGRAMS\orf2jpg\Uninstall.lnk" "$INSTDIR\uninstall.exe"

SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\orf2jpg.exe"
    Delete "$INSTDIR\libraw-25.dll"
    Delete "$INSTDIR\libgcc_s_seh-1.dll"
    Delete "$INSTDIR\liblcms2-2.dll"
    Delete "$INSTDIR\libjpeg-8.dll"
    Delete "$INSTDIR\libgomp-1.dll"
    Delete "$INSTDIR\zlib1.dll"
    Delete "$INSTDIR\libwinpthread-1.dll"
    Delete "$INSTDIR\libstdc++-6.dll"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"

    Delete "$DESKTOP\ORF to JPG Converter.lnk"
    Delete "$SMPROGRAMS\orf2jpg\ORF to JPG Converter.lnk"
    Delete "$SMPROGRAMS\orf2jpg\Uninstall.lnk"
    RMDir "$SMPROGRAMS\orf2jpg"

    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\orf2jpg"
    DeleteRegKey HKLM "Software\orf2jpg"

SectionEnd