# SpeakSelection for Windows

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg)](https://www.microsoft.com/windows)
[![Runtime: AutoHotkey v2](https://img.shields.io/badge/Runtime-AutoHotkey%20v2.0+-334455.svg)](https://www.autohotkey.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Architecture: x64 | ARM64](https://img.shields.io/badge/Architecture-x64%20%7C%20ARM64-lightgrey.svg)]()

A lightweight, system-wide text-to-speech utility for Windows inspired by the macOS **Speak Selection** accessibility feature. Highlight text in any application (including web browsers, PDF viewers, office suites, and text editors) and have it read aloud instantly using the native Windows Speech API (SAPI).

---

## Key Features

- **System-Wide Compatibility**: Works across any Windows application supporting standard text selection.
- **Native Speech Synthesis**: Built on the native Microsoft SAPI COM interface (`SAPI.SpVoice`), requiring no third-party cloud APIs, external runtimes, or internet connectivity.
- **Non-Blocking Asynchronous Audio**: Audio streams asynchronously, preventing UI freezes or application lockups.
- **Clipboard Preservation**: Captures selected text and restores the original clipboard state seamlessly.
- **Multi-Architecture Support**: Built for standard x64 systems and validated on Windows 11 on ARM (ARM64 devices including Snapdragon X Elite/Plus Copilot+ PCs) with zero runtime lag or configuration needed.
- **Minimal Resource Overhead**: Extremely lightweight background footprint with negligible CPU and memory usage (~10–20 MB RAM).
- **Turnkey Setup**: Includes preconfigured scripts for automated installation, startup registration, compilation, and removal.

---

## Default Shortcuts

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Alt</kbd> + <kbd>S</kbd> | **Speak Selection** | Copies highlighted text and begins reading it aloud asynchronously. |
| <kbd>Alt</kbd> + <kbd>Q</kbd> | **Stop Speaking** | Immediately terminates active speech playback and clears the voice queue. |

---

## Installation and Setup

### Automated Installation (Recommended)

1. Right-click `install.bat` and select **Run as administrator** (or double-click to execute with automatic elevation prompt).
2. The installation script will:
   - Deploy `SpeakSelection-Windows.exe` and supporting files to `C:\SpeakSelection\`.
   - Register a startup shortcut in the user's Startup directory (`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`).
   - Launch the application background process immediately.

### Uninstallation

To remove SpeakSelection from your system:
1. Run `uninstall.bat`.
2. The script terminates active processes, deletes the startup shortcut, and removes the `C:\SpeakSelection` directory.

---

## Development and Building from Source

The standalone executable (`SpeakSelection-Windows.exe`) runs independently without requiring AutoHotkey to be installed. If you wish to inspect, modify, or recompile the script from source, follow the instructions below.

### Prerequisites

AutoHotkey **v2.0 or higher** is required. AutoHotkey v1.x is not supported.

Install AutoHotkey v2 using any of the following package managers or official installers:

#### Windows Package Manager (`winget`)
```powershell
winget install AutoHotkey.AutoHotkey
```

#### Chocolatey
```powershell
choco install autohotkey
```

#### Scoop
```powershell
scoop install autohotkey
```

#### Official Installer
Download and install the latest v2 release from the [AutoHotkey Official Website](https://www.autohotkey.com/).

> [!NOTE]
> Ensure AutoHotkey v2 is installed. The script uses modern v2 syntax and is incompatible with legacy AutoHotkey v1.1.

---

### Compilation

#### Method 1: Automated Script (`compile.bat`)
Run `compile.bat`. The script automatically detects your system architecture (x64 or ARM64), locates `Ahk2Exe.exe`, selects the optimal base binary (native ARM64 if present, or 64-bit under Windows 11 Prism emulation), and compiles `SpeakSelection-Windows.exe`.

#### Method 2: Command Line (CLI)
From Command Prompt or PowerShell, execute:
```cmd
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "SpeakSelection-Windows.ahk" /out "SpeakSelection-Windows.exe" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

#### Method 3: Ahk2Exe GUI
1. Open the Start menu, search for **AutoHotkey Dash**, and launch it.
2. Select **Compile** (if Ahk2Exe is not installed, the dashboard will prompt you to install it).
3. Configure compilation parameters:
   - **Source (script file)**: Select `SpeakSelection-Windows.ahk`.
   - **Destination (.exe)**: Set to `SpeakSelection-Windows.exe`.
   - **Base File (.bin)**: Select `AutoHotkey64.exe` (v2 64-bit) or `AutoHotkeyARM64.exe` if available.
4. Click **Convert**.

---

## Configuration and Customization

Configuration can be edited directly in `SpeakSelection-Windows.ahk`. After modifying the script, run `compile.bat` followed by `install.bat` to apply changes.

### Custom Hotkeys

Hotkeys can be customized using standard AutoHotkey key modifier syntax:
- `!` : <kbd>Alt</kbd>
- `^` : <kbd>Ctrl</kbd>
- `+` : <kbd>Shift</kbd>
- `#` : <kbd>Win</kbd>

Examples:
```ahk
; Change Speak hotkey to Ctrl + Alt + S
^!s:: { ... }

; Change Speak hotkey to Win + Shift + S
+#s:: { ... }
```

### Voice Rate and Volume

Voice playback speed and volume can be configured on the COM instance:

```ahk
global voice := ComObject("SAPI.SpVoice")

; Rate ranges from -10 (slowest) to 10 (fastest). Default: 0
voice.Rate := 1

; Volume ranges from 0 (silent) to 100 (maximum). Default: 100
voice.Volume := 90
```

### Voice Selection

Windows includes several default voices (e.g., Microsoft David, Microsoft Zira). You can select a specific voice by index:

```ahk
; Select the second installed voice
voice.Voice := voice.GetVoices().Item(1)
```

---

## Technical Details

- **COM Automation**: Instantiates the Microsoft Speech API using `ComObject("SAPI.SpVoice")`.
- **Speech Flags**:
  - `voice.Speak(text, 1)`: Executes asynchronously (`SVSFlagsAsync = 1`), allowing execution to continue without blocking the host system.
  - `voice.Speak("", 3)`: Passes flag `3` (`SVSFlagsAsync | SVSFPurgeBeforeSpeak`), instantly terminating active audio output and clearing pending speech queues.
- **Clipboard Management**: Uses `ClipboardAll()` to take a snapshot of the current clipboard state, sends a synthetic `Ctrl+C` keystroke, awaits text capture via `ClipWait(1)`, and restores the previous clipboard buffer following a 500 ms safety delay.

---

## Windows on ARM (ARM64) Support

SpeakSelection is verified and supported on **Windows on ARM (ARM64)** devices (such as Qualcomm Snapdragon X Elite, Snapdragon X Plus, Surface Pro Copilot+ PCs, and ARM64 Windows VMs):

- **Seamless Emulation**: The standalone 64-bit executable runs immediately under Windows 11's built-in **Prism** emulation layer with near-native performance, zero input lag, and minimal RAM footprint.
- **Native SAPI Voices**: Windows on ARM provides full compatibility with the native Microsoft SAPI COM interface, enabling access to desktop voices like Microsoft David and Microsoft Zira.
- **Intelligent Compiler**: `compile.bat` detects ARM64 environments automatically (`%PROCESSOR_ARCHITECTURE%==ARM64`). If an ARM64 native AutoHotkey binary is present (`AutoHotkeyARM64.exe`), it prioritizes native compilation; otherwise, it compiles with the 64-bit binary for seamless Prism execution.

---

## Project Structure

```text
SpeakSelection-Windows/
├── SpeakSelection-Windows.ahk   # Source AutoHotkey v2 script
├── SpeakSelection-Windows.exe   # Standalone compiled executable (x64 / ARM64 compatible)
├── compile.bat                  # Automated multi-arch compilation script (Ahk2Exe)
├── install.bat                  # Deployment script (copies files & registers startup)
├── uninstall.bat                # Cleanup script (removes files & startup entry)
└── README.md                    # Project documentation
```

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
