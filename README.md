# CS-51015N
Repository for activities and tasks


Good Game / GG
A game I'd like to try to work on is a cozy open-world life simulation game for players who wants to relax, explore, and enjoy their own virtual world.
In a previous attempt to make a rage-inducing platformer or a rogue-like stage/level PvE, I decided to make a game wherein it gives players the freedom to decide how they want to spend their time. Players can freely roam around a peaceful world, complete simple tasks for characters, discover new areas, and earn in-game currency along the way.

The game will be developed as a means to feel like a digital escape. Players can walk around town while listening to relaxing music, stop by shops, interact with NPCs, or complete small jobs. As players continue exploring and completing activities, they gradually unlock more ways to express themselves and customize their virtual life. They can also sit somewhere and enjoy the scenery, or simply wander around without having to accomplish anything.

There is no pressure to be the strongest or the fastest. The world is there for you to enjoy at your own pace.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/50f236e8-19c8-40ae-b595-4dd077025537" />


Week 2: Core mechanic + juice (with animations for play testing)
<img width="1152" height="647" alt="image" src="https://github.com/user-attachments/assets/71c988d6-f193-4060-8c6b-12de87606816" />

Week 3: Level Design
<img width="922" height="517" alt="image" src="https://github.com/user-attachments/assets/04966d4a-7a14-4166-b799-102e9845eb00" />
<img width="922" height="517" alt="image" src="https://github.com/user-attachments/assets/0b2614f1-6a1f-4a12-9914-04d36625dba0" />


Week 6: AI & Finite State Machine (Enemy Knight)
- Implemented Finite State Machine (FSM) AI with `PATROL` and `CHASE` states.
- Offscreen optimization with `VisibleOnScreenEnabler2D`.

Week 7: Game Juice, Save/Load Persistence, & Sound
- Added screen shake (`add_screen_shake`) and hit-stop (`hit_stop`) during mining and combat.
- Implemented disk save & load system (`user://savegame.json`) for inventory, quests, and character data.
- Built interactive loading transition with animated funny status messages.

---

## Week 8: Multi-Platform Export & Team Git
**Deliverable**: Multi-platform export configurations (Windows PC + Web HTML5) + platform-specific tweaks + team Git collaborative branching and merge conflict practice.

### 1. Platform Exports & Presets (`gg/export_presets.cfg`)
Configured Godot 4 export templates for two distinct platforms:
- **Platform 1: Windows Desktop PC (x86_64)**
  - Native 60 FPS, windowed/fullscreen support, desktop resolution scaling.
  - Quit button enabled with application shutdown handling.
  - Persistent savegame saved to local user appdata directory (`user://savegame.json`).
- **Platform 2: Web (HTML5 / WebAssembly)**
  - Browser-ready canvas build with WebAssembly and WebGL 2.0.
  - Web audio context unlock handling on initial user canvas interaction.

### 2. Platform-Specific Tweaks
- **On-Screen Touch / Web Controls (`gg/scenes/touch_controls.tscn`)**:
  - Dynamically activates when `OS.has_feature("web")` or `DisplayServer.is_touchscreen_available()` is detected.
  - Features a translucent virtual D-Pad (Up, Down, Left, Right) and an Action button (E / Interact) so the game can be fully played in browser on touchscreen devices without requiring physical keyboard input.
- **Dynamic Platform Detection (`gg/scenes/main_menu.gd`)**:
  - Detects runtime environment via `OS.has_feature("web")`.
  - Automatically hides the desktop "Quit" button on Web builds (due to browser sandbox security restrictions).
  - Adds an in-menu "Toggle Fullscreen" button and F11 support on Web.
  - Displays dynamic platform badge: `🌐 Web (HTML5) Build` vs `💻 Windows Desktop PC Build`.

### 3. Team Git Practice (Branching, PR & Merge Conflict Resolution)
- **Branching Workflow**:
  - Created feature branch `feature/platform-exports` for platform-specific exports and virtual controls.
  - Created peer branch `team/mobile-focus` to simulate parallel teammate contributions.
- **Deliberate Merge Conflict**:
  - Both branches edited line 5 of `team_git_practice.md` with conflicting platform priority goals.
  - Executing `git merge team/mobile-focus` triggered `CONFLICT (content): Merge conflict in team_git_practice.md`.
- **Conflict Resolution**:
  - Inspected conflict markers (`<<<<<<< HEAD`, `=======`, `>>>>>>>`).
  - Integrated both sets of priorities (Web fullscreen canvas scaling + mobile touch controls) into a unified architecture.
  - Staged and committed the resolved merge commit, then merged the feature branch cleanly into `main`.
