@echo off
setlocal EnableDelayedExpansion
title Uninstall SpeakSelection-Windows

echo ==========================================================
echo          SpeakSelection-Windows Uninstaller
echo ==========================================================
echo.

set "TARGET_DIR=C:\SpeakSelection"
set "EXE_NAME=SpeakSelection-Windows.exe"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\SpeakSelection.lnk"

:: 1. Stop running process
echo [1/3] Terminating SpeakSelection process if running...
taskkill /F /IM "%EXE_NAME%" >nul 2>&1

:: 2. Remove Startup Shortcut
echo [2/3] Removing from Windows Startup...
if exist "%SHORTCUT_PATH%" (
    del /f /q "%SHORTCUT_PATH%" >nul 2>&1
    echo   Startup shortcut removed.
) else (
    echo   No startup shortcut found.
)

:: 3. Remove C:\SpeakSelection directory
echo [3/3] Removing %TARGET_DIR% ...
if exist "%TARGET_DIR%" (
    rmdir /S /Q "%TARGET_DIR%" >nul 2>&1
    if exist "%TARGET_DIR%" (
        echo [INFO] Administrative permissions may be required to delete %TARGET_DIR%.
        echo Requesting elevation...
        powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"\"\"%~f0\"\"\"' -Verb RunAs"
        exit /b
    )
    echo   Folder removed successfully.
) else (
    echo   Target folder does not exist.
)

echo.
echo ==========================================================
echo       UNINSTALLATION COMPLETED SUCCESSFULLY!
echo ==========================================================
echo SpeakSelection has been removed from your C: drive and Startup.
echo ==========================================================
echo.
pause
