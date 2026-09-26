# Bloom Core

<p align="center">
  <a href="https://github.com/Yato-Works/Bloom_Core"><img src="https://img.shields.io/badge/C%2B%2B-20-blue.svg?style=flat-square&logo=c%2B%2B" alt="C++20" /></a>
  <a href="https://www.qt.io/"><img src="https://img.shields.io/badge/Qt-6.5%2B-41CD52.svg?style=flat-square&logo=qt" alt="Qt 6" /></a>
  <a href="https://github.com/Yato-Works/Bloom_Core/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-orange.svg?style=flat-square" alt="License" /></a>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey.svg?style=flat-square" alt="Platform" />
</p>

<p align="center">
  <strong>English | <a href="README.ja.md">日本語</a></strong>
</p>

<p align="center">
  <img src="assets/bloom_core_preview.png" alt="Bloom Core Desktop Shell Overview" width="92%" />
</p>

<p align="center">
  <em>Bloom Core — Top Status Bar, Virtual Workspace Switcher, and Smart Bottom Media & Spectrum Dock</em>
</p>

<p align="center">
  <img src="assets/bloom_core_launcher.png" alt="Bloom Core Smart Launcher Modal" width="92%" />
</p>

<p align="center">
  <em>Smart Launcher Modal — Instant App Search, Embedded Calculator, and Command Execution</em>
</p>

---

**Bloom Core** is a high-performance, next-generation desktop shell runtime engine designed for Windows.  
Built on **C++20** and **Qt 6 (Qt Quick / QML)**, it features a native **OS Compatibility Bridge** that allows declarative QML widgets and shell configurations originally crafted for Arch Linux (Hyprland / Quickshell / Caelestia Shell) to run natively on Windows with zero friction.

---

## Key Features

### 1. Iconic "Hold-to-Arm" Activation Model
- **`Ctrl + Win` (Hold)**: Instantly dims the desktop and summons the overlay shell with smooth cyber-glow transitions. Releasing the keys instantly returns you to your previous workflow without stealing window focus.
- **`Ctrl + Win + Space`**: Locks the overlay in place (stays visible when keys are released).
- **`Esc` Key / Backdrop Click**: Immediately dismisses active modals and disarms the shell.
- Zero-focus-stealing architecture ensures your active workspace and typing are never interrupted.

### 2. High-Precision Real-Time WASAPI Loopback FFT Spectrum
- Directly captures the Windows default audio rendering endpoint via WASAPI Loopback.
- **1024-point Hann window Cooley-Tukey FFT** computes logarithmic frequency spectrum bands (40 Hz – 16 kHz) in real-time across 24 and 96 bands.
- **Universal PCM Decoding**: Full native support for **16-bit, 24-bit, and 32-bit signed PCM**, as well as **IEEE 32-bit Float**.
- **Bulletproof Failsafe**: Automatic audio device invalidation detection and transparent 300ms auto-reconnect recovery on headphone unplug / audio interface switching.

### 3. Smart Bottom Media & Spectrum Dock
- **Context-Aware Presence**: Slides in and fades in automatically whenever music/media is playing.
- **Smooth Decay & Auto-Hide**: When audio stops, the spectrum smoothly decays and the dock automatically slides out of view to keep your desktop clean.
- **Pinning Support**: Pin the dock with a single click if you prefer it permanently on-screen.

### 4. Smart Launcher Modal
- Summon via the rocket icon (🚀) or configured hotkeys.
- **Unified Query Bar**: Instant fuzzy application search, inline live calculator (`>calc` or direct math expressions like `(1280 * 720) / 1024`), and system CLI command runner.
- Sleek frosted glass (glassmorphism) aesthetic with dynamic ambient lighting.

### 5. Dynamic Wallpaper Palette Engine (`PaletteEngine`)
- Native Windows replacement for Linux's `matugen`.
- Real-time color extraction from your current Windows desktop wallpaper.
- Automatically generates harmonized **Material Design 3** color palettes (`Colours.m3primary`, `Colours.m3surface`, `Colours.m3outline`, etc.) and delivers them directly into QML singletons.

### 6. Arch / Linux (Quickshell & Hyprland) Compatibility Bridge
Effortlessly port your Linux dotfiles and Caelestia Shell QML components to Windows:
- **`import Quickshell.Hyprland`**: Seamlessly translates `Hyprland.workspaces`, `Hyprland.activeWsId`, and `Hyprland.dispatch("workspace N")` to Windows 11 Virtual Desktop APIs.
- **`import Quickshell.Services.Mpris`**: Bridges Linux MPRIS media controls (Spotify, YouTube in Chrome/Firefox) to Windows native Media Transport Controls.
- **`import Quickshell.Services.Pipewire`**: Maps audio volume sliders and mute states to Windows WASAPI endpoints.
- **`import Caelestia`**: Transparently maps Linux tokens and dynamic theme colors to the Windows engine.

### 7. Native QML Engine Services (`import Bloom`)
| Service | Description |
| :--- | :--- |
| `Bloom.Colours` | Dynamic Material You / M3 color tokens extracted from wallpaper |
| `Bloom.Shell` | Overlay arm/lock state, modal visibility, and window management |
| `Bloom.Workspaces` | Windows 11 Virtual Desktops inspection and instant switching |
| `Bloom.SysInfo` | Hardware telemetry (CPU %, RAM %, Battery %, Uptime, Master Volume) |
| `Bloom.Players` | Active media metadata (Track title, Artist, Album, Play/Pause/Skip) |
| `Bloom.Audio` | Low-latency WASAPI loopback FFT spectrum analysis (CAVA compatible) |
| `Bloom.Weather` | Real-time weather, temperature, humidity, and condition metrics |

---

## Quick Start & CLI Usage

```powershell
# Launch the default reference shell (Hold Ctrl+Win to summon)
.\BloomCore.exe

# Launch with a custom QML shell
.\BloomCore.exe path/to/my_shell.qml
.\BloomCore.exe -s path/to/my_shell.qml

# Summon / toggle an already running instance
.\BloomCore.exe --show
.\BloomCore.exe --toggle

# Launch in headless preview / capture mode
.\BloomCore.exe --preview
```

> **Note**: If `%USERPROFILE%/.config/bloom/shell.qml` exists, Bloom Core automatically prioritizes and loads it. Otherwise, it launches the built-in reference shell (`DefaultShell.qml`).

---

## Building from Source

### Prerequisites
- **Qt 6.5+** (Core, Gui, Qml, Quick, QuickControls2, QuickLayouts, Network)
- **C++20 compliant compiler** (MinGW-w64 64-bit or MSVC 2022)
- **CMake 3.21+** and **Ninja**

### Build Commands (PowerShell)

```powershell
# Configure with Ninja (specify your Qt installation path)
cmake -S . -B build-mingw -G Ninja -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/mingw_64"

# Compile Release build
cmake --build build-mingw --config Release
```

Alternatively, simply execute `.\build.bat` in the repository root.  
Once built, you can run `.\run_bloom_core.bat` for instant testing.

---

## Project Structure

```
Bloom_Core/
├── assets/                  # High-res UI previews, fonts, and icons
├── qml/
│   ├── caelestia/           # Linux Caelestia Shell compatibility modules
│   ├── components/          # Reusable glassmorphic UI widgets & modals
│   ├── demo/                # Reference shells (DefaultShell.qml)
│   └── services/            # QML-side bridges and singleton abstractions
├── src/
│   ├── core/                # Engine runtime, QML models, crash handlers
│   ├── platforms/windows/   # Win32 APIs (Virtual Desktops, Media, Audio)
│   └── services/            # C++ WASAPI CAVA FFT, PaletteEngine, Hotkeys
├── CMakeLists.txt           # Modern CMake C++20 build definition
└── README.md
```

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
See the [LICENSE](LICENSE) file for more details.
