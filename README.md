# Mini Jump

A simple, polished 2D offline mobile game built with Godot 4.7.2.

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

- Godot 4.7.2 (stable)
- For iOS build: macOS with Xcode 15+

## Project Structure

```
.
├── .github/workflows/
│   └── build-ios.yml          # GitHub Actions CI/CD
├── export/
│   └── export_presets.cfg     # iOS export configuration (duplicate)
├── export_presets.cfg         # iOS export configuration (used by CI)
├── ios/
│   ├── Info.plist             # iOS app configuration
│   ├── Entitlements.plist     # iOS entitlements
│   └── LaunchScreen.storyboard
├── scenes/
│   └── main.tscn              # Main game scene
├── scripts/
│   ├── game_manager.gd        # Game state, scoring, persistence
│   ├── audio_manager.gd       # Procedural sound generation
│   ├── player.gd              # Player character (jumping ball)
│   ├── obstacle.gd            # Obstacle objects
│   ├── obstacle_spawner.gd    # Obstacle spawning with difficulty scaling
│   ├── background.gd          # Animated parallax background
│   └── main.gd                # Main game controller
├── theme/
│   ├── theme.tres             # Custom UI theme
│   └── fonts/
│       └── Inter-Regular.ttf
├── icon_*.png                 # App icons (20-1024px)
├── project.godot              # Project configuration
└── README.md
```

## Running the Game

### Desktop (Testing)

```bash
# Install Godot 4.7.2 stable
# Run the project from repository root
godot --path .
```

Or open the project in Godot Editor and press F5.

## GitHub Actions CI/CD

The repository includes a complete CI/CD pipeline (`.github/workflows/build-ios.yml`):

### Triggers
- Push to `main` or `master`
- Pull requests to `main` or `master`
- Manual workflow dispatch

### Jobs
1. **Validate** (ubuntu-latest): Checks project syntax and loads without errors
2. **Build iOS Device** (macos-latest): Exports Xcode project, builds unsigned device IPA
3. **Build iOS Simulator** (macos-latest): Builds unsigned simulator IPA

### Artifacts
- `MiniJump-IPA` - Unsigned iOS device build (requires signing to install on device)
- `MiniJump-Simulator-IPA` - Unsigned simulator build (runs in iOS Simulator)

### To trigger a build:
1. Push to main/master, or
2. Go to Actions tab → "Build iOS IPA" → "Run workflow"

## Building IPA Locally (macOS)

```bash
# Export Xcode project
godot --headless --export-release "iOS" build/ios

# Find and build
cd build/ios
PROJECT=$(find . -name "*.xcodeproj" -type d | head -1)
xcodebuild -project "$PROJECT" \
  -scheme "Mini Jump" \
  -configuration Release \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath ./DerivedData \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

# Package IPA
APP=$(find ./DerivedData -name "Mini Jump.app" -type d | head -1)
mkdir -p Payload && cp -r "$APP" Payload/
zip -r MiniJump.ipa Payload
```

## Installing on iPhone

### ⚠️ Important: Unsigned IPA Limitations

The GitHub Actions builds produce **unsigned IPAs**. An unsigned IPA **cannot be installed directly on an iPhone**. You must sign it first using your Apple ID.

### Option 1: AltStore (Recommended, Free)

1. Install [AltStore](https://altstore.io) on your computer (Windows/macOS/Linux)
2. Connect iPhone via USB
3. Install AltStore on iPhone (follow AltStore instructions)
4. In AltStore on iPhone, tap "+" → Select the downloaded `MiniJump.ipa`
5. Enter your Apple ID credentials when prompted
6. AltStore will sign and install the app (valid for 7 days with free Apple ID, 1 year with paid Developer Program)

### Option 2: Sideloadly (Windows/macOS)

1. Download [Sideloadly](https://sideloadly.io)
2. Connect iPhone via USB
3. Drag `MiniJump.ipa` to Sideloadly
4. Enter Apple ID credentials
5. Click "Start" to sign and install

### Option 3: Xcode (macOS only)

1. Open Xcode → Window → Devices and Simulators
2. Connect iPhone
3. Drag the `.app` bundle (from `Payload/Mini Jump.app`) to "Installed Apps"
4. Xcode will prompt for signing

### For Simulator Build

1. Download `MiniJump-Simulator.ipa` artifact
2. Unzip to get `.app` bundle
3. Drag `.app` to iOS Simulator window
4. Or use CLI: `xcrun simctl install booted path/to/Mini\ Jump.app`

## Game Controls

- **Tap / Click / Space / Up / W** - Jump
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

## Troubleshooting

### Build fails with "No export_presets.cfg found"
Ensure you're running from the repository root where `export_presets.cfg` exists.

### Xcode build fails
- Ensure Xcode Command Line Tools installed: `xcode-select --install`
- Check that the scheme name matches "Mini Jump" (case sensitive)
- Verify export templates match Godot version (4.7.2)

### IPA won't install
- Unsigned IPAs require signing via AltStore/Sideloadly
- Free Apple ID: 7-day signing, 3 apps max
- Paid Developer Program: 1-year signing, more apps

### Best score not persisting
- On iOS, `user://` maps to app sandbox Documents folder
- Ensure app has write permissions (it does by default)

## License

MIT License - Feel free to use, modify, and distribute.

## Credits

- Built with [Godot Engine](https://godotengine.org) 4.7.2
- Font: [Inter](https://rsms.me/inter/) by Rasmus Andersson
- Icons: Generated programmatically
- Sounds: Generated procedurally