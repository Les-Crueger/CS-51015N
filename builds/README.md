# Multi-Platform Builds (Week 8)

This directory contains the export configurations and release build setups for the two target platforms specified in the Week 8 learning objectives:

---

## 1. Platform 1: Windows Desktop PC (x86_64)
- **Target File**: `builds/windows/GoodGame.exe`
- **Engine Preset**: Windows Desktop (x86_64)
- **Features & Tweaks**:
  - Native 60 FPS rendering
  - Full desktop resolution & window controls
  - Functional Quit button with confirmation
  - Direct keyboard & gamepad input mapping (WASD / Arrows, E to interact, I/Tab for inventory)
  - Full savegame persistence to `user://savegame.json`

---

## 2. Platform 2: Web Browser (HTML5 / WebAssembly)
- **Target File**: `builds/web/index.html`
- **Engine Preset**: Web (HTML5)
- **Features & Platform-Specific Tweaks**:
  - **Virtual Touch / D-Pad Controls**: Translucent on-screen directional buttons and an Action button enable smooth gameplay on touchscreens and web browsers without a physical keyboard.
  - **Quit Button Suppression**: The desktop "Quit" button is dynamically hidden on Web builds since browser security sandboxes disallow closing tabs directly via script.
  - **Fullscreen Toggle**: In-menu fullscreen toggle button and F11 support so the game can fill the browser viewport.
  - **Web Audio Unblocker**: Responsive canvas click capture unlocks audio context seamlessly on all major browsers.
  - **Platform Badge**: Main menu automatically detects Web execution via `OS.has_feature("web")` and indicates browser mode.
