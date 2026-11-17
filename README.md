# Mini Jump

A simple, polished 2D offline mobile game built with Swift 6, SwiftUI, and SpriteKit.

## Gameplay

- A cute ball automatically moves forward
- Tap anywhere to jump
- Avoid obstacles
- Earn 1 point for every obstacle passed
- Game over screen with Restart button
- Best score saved locally using UserDefaults
- Gradually increasing difficulty

## Features

- **Premium minimalist design** with smooth animations
- **Native SwiftUI menus** with SpriteKit gameplay
- **Portrait orientation** optimized for iPhone
- **Smooth 60 FPS physics** and animations
- **Completely offline** - no internet connection required
- **Local high score persistence** using UserDefaults
- **No ads, analytics, or online services**
- **No external game engine** - pure native iOS

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 6.0

## Project Structure

```
MiniJump/
├── MiniJump.xcodeproj/           # Xcode project
│   └── xcshareddata/
│       └── xcschemes/
│           └── MiniJump.xcscheme
├── MiniJump/
│   ├── MiniJumpApp.swift         # App entry point
│   ├── ContentView.swift         # SwiftUI views (menus, HUD, game over)
│   ├── GameScene.swift           # SpriteKit gameplay scene
│   ├── Info.plist                # App configuration
│   └── LaunchScreen.storyboard   # Launch screen
├── .github/workflows/
│   └── build-ios.yml             # GitHub Actions CI/CD
└── README.md
```

## Building and Running

### Local Development

```bash
# Open in Xcode
open MiniJump.xcodeproj

# Or build from command line
xcodebuild -project MiniJump.xcodeproj \
  -scheme MiniJump \
  -configuration Release \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  build
```

### GitHub Actions CI/CD

The repository includes a complete CI/CD pipeline (`.github/workflows/build-ios.yml`):

#### Triggers
- Push to `main` or `master`
- Pull requests to `main` or `master`
- Manual workflow dispatch

#### Jobs
1. **Build iOS Device** (macos-latest): Builds unsigned device IPA
2. **Build iOS Simulator** (macos-latest): Builds unsigned simulator IPA

#### Artifacts
- `MiniJump-IPA` - Unsigned iOS device build (requires signing to install on device)
- `MiniJump-Simulator-IPA` - Unsigned simulator build (runs in iOS Simulator)

### To trigger a build:
1. Push to main/master, or
2. Go to Actions tab → "Build iOS IPA" → "Run workflow"

## Building IPA Locally (macOS)

```bash
# Build for device
xcodebuild -project MiniJump.xcodeproj \
  -scheme MiniJump \
  -configuration Release \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath ./DerivedData \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

# Package IPA
APP=$(find ./DerivedData -name "MiniJump.app" -type d | head -1)
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
3. Drag the `.app` bundle (from `Payload/MiniJump.app`) to "Installed Apps"
4. Xcode will prompt for signing

### For Simulator Build

1. Download `MiniJump-Simulator.ipa` artifact
2. Unzip to get `.app` bundle
3. Drag `.app` to iOS Simulator window
4. Or use CLI: `xcrun simctl install booted path/to/MiniJump.app`

## Game Controls

- **Tap anywhere** - Jump
- **Start Screen** - Tap "TAP TO START" to begin
- **Game Over** - Tap "PLAY AGAIN" to restart

## Configuration

### App Identity
- **App Name**: Mini Jump
- **Bundle ID**: com.iafandiyev.minijump
- **Version**: 1.0.0

### Build Settings
- Target: iPhone (portrait only)
- Deployment Target: iOS 16.0
- Swift Version: 6.0
- No code signing required for CI builds

## License

MIT License - Feel free to use, modify, and distribute.

## Credits

- Built with Swift 6, SwiftUI, and SpriteKit
- No external game engine
- No external dependencies