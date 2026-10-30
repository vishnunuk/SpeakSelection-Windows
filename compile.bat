@echo off
setlocal EnableDelayedExpansion
title Compile SpeakSelection-Windows

cd /d "%~dp0"

echo ====================================================
echo        SpeakSelection-Windows Compiler
echo ====================================================
echo.

set "AHK2EXE="
set "BASE_BIN="

:: Detect System Architecture
set "SYS_ARCH=%PROCESSOR_ARCHITECTURE%"
if defined PROCESSOR_ARCHITEW6432 (
    set "SYS_ARCH=%PROCESSOR_ARCHITEW6432%"
)

:: 1. Search for Ahk2Exe
if exist "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" (
    set "AHK2EXE=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
) else if exist "%LocalAppData%\Programs\AutoHotkey\Compiler\Ahk2Exe.exe" (
    set "AHK2EXE=%LocalAppData%\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"
) else (
    for %%X in (Ahk2Exe.exe) do (set "AHK2EXE=%%~$PATH:X")
)

:: 2. Search for AutoHotkey v2 base binary (native ARM64 if on ARM64, else 64-bit x64, then 32-bit)
set "BASE_ARCH="
if /i "%SYS_ARCH%"=="ARM64" (
    if exist "C:\Program Files\AutoHotkey\v2\AutoHotkeyARM64.exe" (
        set "BASE_BIN=C:\Program Files\AutoHotkey\v2\AutoHotkeyARM64.exe"
        set "BASE_ARCH=ARM64 (Native)"
    ) else if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkeyARM64.exe" (
        set "BASE_BIN=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkeyARM64.exe"
        set "BASE_ARCH=ARM64 (Native)"
    ) else if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64a.exe" (
        set "BASE_BIN=C:\Program Files\AutoHotkey\v2\AutoHotkey64a.exe"
        set "BASE_ARCH=ARM64 (Native)"
    )
)

if not defined BASE_BIN (
    if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" (
        set "BASE_BIN=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
        if /i "%SYS_ARCH%"=="ARM64" (
            set "BASE_ARCH=x64 (Prism Emulation)"
        ) else (
            set "BASE_ARCH=x64"
        )
    ) else if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
        set "BASE_BIN=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
        if /i "%SYS_ARCH%"=="ARM64" (
            set "BASE_ARCH=x64 (Prism Emulation)"
        ) else (
            set "BASE_ARCH=x64"
        )
    ) else if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe" (
        set "BASE_BIN=C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"
        set "BASE_ARCH=x86 (32-bit)"
    )
)

if not defined AHK2EXE (
    echo [ERROR] Ahk2Exe compiler was not found.
    echo.
    echo Please ensure AutoHotkey v2 and its compiler are installed:
    echo   1. Official Site: https://www.autohotkey.com/
    echo   2. Winget: winget install AutoHotkey.AutoHotkey
    echo   3. Launch "AutoHotkey Dash" from the Start menu and select "Compile" to install Ahk2Exe if prompted.
    echo.
    pause
    exit /b 1
)

echo Detected Arch:  %SYS_ARCH%
echo Found Compiler: "!AHK2EXE!"
if defined BASE_BIN (
    echo Found Base v2:  "!BASE_BIN!" [!BASE_ARCH!]
    echo Compiling SpeakSelection-Windows.ahk ...
    "!AHK2EXE!" /in "%~dp0SpeakSelection-Windows.ahk" /out "%~dp0SpeakSelection-Windows.exe" /base "!BASE_BIN!"
) else (
    echo Compiling SpeakSelection-Windows.ahk ...
    "!AHK2EXE!" /in "%~dp0SpeakSelection-Windows.ahk" /out "%~dp0SpeakSelection-Windows.exe"
)

if %errorLevel% equ 0 (
    echo.
    echo ====================================================
    echo [SUCCESS] SpeakSelection-Windows.exe compiled!
    echo ====================================================
) else (
    echo.
    echo [ERROR] Compilation failed with exit code: %errorLevel%
)

echo.
pause
