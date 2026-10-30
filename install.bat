@echo off
setlocal EnableDelayedExpansion
title Install SpeakSelection to C: Drive and Startup

:: Ensure script operates in its own directory
cd /d "%~dp0"

echo ==========================================================
echo           SpeakSelection-Windows Installer
echo ==========================================================
echo.

set "TARGET_DIR=C:\SpeakSelection"
set "EXE_NAME=SpeakSelection-Windows.exe"
set "AHK_NAME=SpeakSelection-Windows.ahk"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\SpeakSelection.lnk"

:: 1. Check if the executable exists, otherwise try to compile if ahk is present
if not exist "%EXE_NAME%" (
    if exist "%AHK_NAME%" (
        echo [INFO] "%EXE_NAME%" not found. Attempting to compile from script...
        if exist "compile.bat" (
            call compile.bat
        )
    )
)

if not exist "%EXE_NAME%" (
    echo [ERROR] "%EXE_NAME%" was not found and could not be compiled.
    echo Please make sure AutoHotkey v2 is installed, or run compile.bat first.
    echo.
    pause
    exit /b 1
)

:: 2. Check permissions for creating C:\SpeakSelection
mkdir "%TARGET_DIR%" >nul 2>&1
if not exist "%TARGET_DIR%" (
    echo [INFO] Administrative permissions required to create "%TARGET_DIR%".
    echo Requesting elevation...
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"\"%~f0\"\"\"' -Verb RunAs"
    exit /b
)

:: 3. Terminate running instance if any to allow file replacement
echo [1/4] Stopping any existing SpeakSelection process...
taskkill /F /IM "%EXE_NAME%" >nul 2>&1

:: 4. Copy files to C:\SpeakSelection
echo [2/4] Copying files to %TARGET_DIR% ...
copy /Y "%EXE_NAME%" "%TARGET_DIR%\" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy %EXE_NAME% to %TARGET_DIR%.
    pause
    exit /b 1
)

if exist "%AHK_NAME%" (
    copy /Y "%AHK_NAME%" "%TARGET_DIR%\" >nul
)
if exist "README.md" (
    copy /Y "README.md" "%TARGET_DIR%\" >nul
)
if exist "uninstall.bat" (
    copy /Y "uninstall.bat" "%TARGET_DIR%\" >nul
)

:: 5. Create Startup Shortcut
echo [3/4] Adding SpeakSelection to Windows Startup...
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = '%TARGET_DIR%\%EXE_NAME%'; $s.WorkingDirectory = '%TARGET_DIR%'; $s.Description = 'Speak Selection for Windows (Alt+S to speak, Alt+Q to stop)'; $s.Save()"

if not exist "%SHORTCUT_PATH%" (
    echo [WARNING] Could not create shortcut in:
    echo   %STARTUP_FOLDER%
) else (
    echo [SUCCESS] Startup shortcut created at:
    echo   %SHORTCUT_PATH%
)

:: 6. Launch the program
echo [4/4] Starting SpeakSelection in background...
start "" "%TARGET_DIR%\%EXE_NAME%"

echo.
echo ==========================================================
echo           INSTALLATION COMPLETED SUCCESSFULLY!
echo ==========================================================
echo Installed Location : %TARGET_DIR%
echo Windows Startup    : ENABLED (starts automatically on login)
echo Current Status     : RUNNING
echo.
echo Hotkeys:
echo   [Alt + S]  - Read selected text aloud
echo   [Alt + Q]  - Stop reading immediately
echo ==========================================================
echo.
pause
