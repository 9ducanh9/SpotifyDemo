# PowerShell Scripts Guide

This project includes PowerShell scripts to simplify common Flutter development tasks on Windows.

## Available Scripts

### 1. `setup.ps1` - Initial Project Setup
Sets up the project, installs dependencies, and verifies everything is working.

```powershell
.\setup.ps1
```

**What it does:**
- Checks Flutter installation
- Verifies project structure
- Cleans previous builds
- Installs dependencies
- Analyzes code
- Runs tests

### 2. `run.ps1` - Run the App
Starts the Flutter app on a device or emulator.

```powershell
# Run on default device
.\run.ps1

# Run on specific device
.\run.ps1 -Device <device-id>
```

**Example:**
```powershell
# List available devices first
flutter devices

# Then run on specific device
.\run.ps1 -Device emulator-5554
```

### 3. `test.ps1` - Run Tests
Runs all unit tests for the project.

```powershell
# Run tests
.\test.ps1

# Run tests with coverage
.\test.ps1 -Coverage
```

### 4. `build.ps1` - Build the App
Builds the app for different platforms.

```powershell
# Build APK (Android)
.\build.ps1 apk

# Build App Bundle (for Play Store)
.\build.ps1 appbundle

# Build for iOS (macOS only)
.\build.ps1 ios

# Build for Web
.\build.ps1 web
```

### 5. `check.ps1` - Health Check
Performs a comprehensive health check of the project.

```powershell
.\check.ps1
```

**What it checks:**
- Flutter installation
- Project structure
- Dependencies
- Code analysis
- Test files

## Usage Examples

### First Time Setup
```powershell
# 1. Navigate to project directory
cd C:\path\to\workspace

# 2. Run setup script
.\setup.ps1

# 3. Start emulator or connect device

# 4. Run the app
.\run.ps1
```

### Daily Development Workflow
```powershell
# Check project health
.\check.ps1

# Run tests
.\test.ps1

# Run app
.\run.ps1
```

### Before Building Release
```powershell
# Run all checks
.\check.ps1

# Run tests
.\test.ps1

# Build APK
.\build.ps1 apk
```

## Troubleshooting

### Script Execution Policy Error

If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Not Found

Make sure you're in the project root directory:
```powershell
# Check current directory
Get-Location

# Should show the directory containing pubspec.yaml
ls pubspec.yaml
```

### Flutter Not Found

Ensure Flutter is in your PATH:
```powershell
# Check Flutter installation
flutter --version

# If not found, add Flutter to PATH or use full path
C:\path\to\flutter\bin\flutter --version
```

## Manual Commands (Alternative)

If you prefer not to use scripts, here are the manual commands:

### Setup
```powershell
flutter clean
flutter pub get
flutter doctor
```

### Run
```powershell
flutter devices
flutter run
# or
flutter run -d <device-id>
```

### Test
```powershell
flutter test
flutter test --coverage
```

### Build
```powershell
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

### Analyze
```powershell
flutter analyze
flutter format .
```

## Quick Reference

| Task | Script | Manual Command |
|------|--------|----------------|
| Setup | `.\setup.ps1` | `flutter pub get` |
| Run | `.\run.ps1` | `flutter run` |
| Test | `.\test.ps1` | `flutter test` |
| Build APK | `.\build.ps1 apk` | `flutter build apk` |
| Health Check | `.\check.ps1` | `flutter doctor` |

## Notes

- All scripts assume you're running from the project root directory
- Scripts will show colored output for better readability
- Scripts exit with error code 1 if something fails
- You can combine scripts: `.\setup.ps1; .\run.ps1`

---

**Tip**: Create aliases in your PowerShell profile for even faster access:
```powershell
# Edit profile
notepad $PROFILE

# Add aliases
function FlutterSetup { .\setup.ps1 }
function FlutterRun { .\run.ps1 }
function FlutterTest { .\test.ps1 }
```
