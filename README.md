# Mini Jump

A simple, polished 2D offline mobile game built with Godot 4.x.

## Gameplay

- A cute ball automatically moves forward
- Tap anywhere to jump
- Avoid obstacles
- Earn 1 point for every obstacle passed
- Game over screen with Restart button
- Best score saved locally
- Gradually increasing difficulty

## Features

- **Minimalist premium design** with smooth animations
- **Modern clean UI** with responsive iPhone screen layout
- **Portrait orientation** optimized for mobile
- **Procedural sound effects** - no external audio files needed
- **Completely offline** - no internet connection required
- **Local high score persistence** using JSON storage
- **No ads, analytics, or online services**

## Requirements

- Godot 4.7.2 or later
- For iOS build: macOS with Xcode (for device) or macOS with Xcode Command Line Tools (for simulator)

## Project Structure

```
minijump/
├── scenes/
│   └── main.tscn          # Main game scene
├── scripts/
│   ├── game_manager.gd    # Game state, scoring, persistence
│   ├── audio_manager.gd   # Procedural sound generation
│   ├── player.gd          # Player character (jumping ball)
│   ├── obstacle.gd        # Obstacle objects
│   ├── obstacle_spawner.gd # Obstacle spawning with difficulty scaling
│   ├── background.gd      # Animated parallax background
│   └── main.gd            # Main game controller
├── theme/
│   ├── theme.tres         # Custom UI theme
│   └── fonts/
│       └── Inter-Regular.ttf
├── ios/
│   ├── Info.plist         # iOS app configuration
│   ├── Entitlements.plist # iOS entitlements
│   └── LaunchScreen.storyboard
├── export/
│   └── export_presets.cfg # iOS export configuration
├── .github/workflows/
│   └── build-ios.yml      # GitHub Actions CI/CD
├── project.godot          # Project configuration
└── icon_*.png             # App icons (generated)
```

## Running the Game

### Desktop (Testing)

```bash
# Install Godot 4.7.2+
# Run the project
godot --path minijump
```

### iOS Export

1. **Install export templates** (Godot 4.7.2 stable)
2. **Configure export preset** in `export/export_presets.cfg`
3. **Export from Godot Editor**:
   - Project → Export
   - Select "iOS" preset
   - Click "Export Project..."
   - Choose output folder

Or via command line:
```bash
cd minijump
godot --headless --export-release "iOS" ../build/ios
```

## Building IPA (Free Solutions)

### Option 1: GitHub Actions (Free for Public Repos)

This repository includes a GitHub Actions workflow that:
1. Validates the project on Ubuntu
2. Exports iOS project on macOS runner
3. Builds unsigned IPA using Xcode
4. Uploads IPA as downloadable artifact

**To trigger a build:**
1. Push to main/master branch, or
2. Go to Actions tab → "Build iOS IPA" → "Run workflow"

**Artifacts produced:**
- `MiniJump-IPA` - Device build (requires signing for device install)
- `MiniJump-Simulator-IPA` - Simulator build (runs on iOS Simulator)

### Option 2: Local macOS Build

```bash
# On macOS with Xcode installed
cd minijump
godot --headless --export-release "iOS" ../build/ios
cd ../build/ios
xcodebuild -project "Mini Jump.xcodeproj" \
  -scheme "Mini Jump" \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

# Create IPA
mkdir -p Payload
cp -r build/Release-iphoneos/Mini\ Jump.app Payload/
zip -r MiniJump.ipa Payload
```

### Option 3: ShipThis (Free Open Beta)

[ShipThis](https://shipthis.io) provides free iOS builds without a Mac:
1. Connect your GitHub repository
2. Configure build settings
3. Get IPA artifacts automatically

## Installing on iPhone

### For Unsigned IPA (Test Builds)

**Using AltStore (Recommended):**
1. Install [AltStore](https://altstore.io) on your computer
2. Connect iPhone via USB
3. Install AltStore on iPhone
4. In AltStore, tap "+" → Select the IPA file
5. Enter Apple ID credentials (for signing)
6. App will be installed on device

**Using Sideloadly:**
1. Download [Sideloadly](https://sideloadly.io) on Windows/macOS
2. Connect iPhone
3. Drag IPA to Sideloadly
4. Enter Apple ID credentials
5. Click "Start"

**Using Xcode (macOS only):**
1. Open Xcode → Window → Devices and Simulators
2. Connect iPhone
3. Drag IPA to "Installed Apps" list

### For Simulator Build

1. Download `MiniJump-Simulator.ipa` artifact
2. Unzip to get `.app` bundle
3. Drag `.app` to iOS Simulator
4. Or use `xcrun simctl install booted path/to/Mini\ Jump.app`

## Game Controls

- **Tap/Click/Space/Up/W** - Jump
- **Start Screen** - Tap "TAP TO START" to begin
- **Game Over** - Tap "PLAY AGAIN" to restart

## Configuration

### App Identity
- **App Name**: Mini Jump
- **Bundle ID**: com.iafandiyev.minijump
- **Version**: 1.0.0

### Export Settings
- Target: iPhone (portrait only)
- Rendering: Forward+
- Texture Compression: ASTC (iOS)
- No encryption, no debug export

## License

MIT License - Feel free to use, modify, and distribute.

## Credits

- Built with [Godot Engine](https://godotengine.org) 4.7.2
- Font: [Inter](https://rsms.me/inter/) by Rasmus Andersson
- Icons: Generated programmatically
- Sounds: Generated procedurally