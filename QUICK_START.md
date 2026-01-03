# Quick Start Guide

## For Windows/PowerShell Users

### 1. Navigate to Project Directory
```powershell
cd C:\path\to\workspace
# or if you're in a different location, navigate to where the project is
```

### 2. Verify Flutter Installation
```powershell
flutter --version
flutter doctor
```

### 3. Install Dependencies
```powershell
flutter pub get
```

### 4. Verify Project Structure
```powershell
# Check that main.dart exists
Test-Path lib\main.dart
# Should return: True

# List main files
Get-ChildItem lib\main.dart
```

### 5. Run the App
```powershell
# For Android emulator
flutter run

# For specific device
flutter devices
flutter run -d <device-id>

# For Chrome/Edge (web)
flutter run -d chrome
flutter run -d edge
```

### 6. Run Tests
```powershell
flutter test
```

## Troubleshooting

### Error: "Target file lib\main.dart not found"

**Solution 1**: Verify you're in the correct directory
```powershell
# Check current directory
Get-Location

# Navigate to project root (where pubspec.yaml is)
cd C:\path\to\workspace

# Verify main.dart exists
ls lib\main.dart
```

**Solution 2**: Check Flutter project structure
```powershell
# Should see:
# - pubspec.yaml
# - lib/
#   - main.dart
# - test/
```

**Solution 3**: Clean and rebuild
```powershell
flutter clean
flutter pub get
flutter run
```

### Error: "No devices found"

**Solution**: Start an emulator or connect a device
```powershell
# List available devices
flutter devices

# Start Android emulator (if Android Studio is installed)
# Or connect a physical device via USB
```

### Error: "Package not found"

**Solution**: Reinstall dependencies
```powershell
flutter pub cache repair
flutter pub get
```

## Project Structure Verification

Your project should have this structure:
```
workspace/
├── lib/
│   ├── main.dart          ← Entry point (MUST EXIST)
│   ├── core/
│   ├── data/
│   └── features/
├── test/
├── pubspec.yaml
└── README.md
```

## Common Commands

```powershell
# Check Flutter setup
flutter doctor -v

# Analyze code
flutter analyze

# Format code
flutter format .

# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS (macOS only)
flutter build ios
```

## Next Steps

1. ✅ Verify `lib/main.dart` exists
2. ✅ Run `flutter pub get`
3. ✅ Run `flutter doctor` to check setup
4. ✅ Start emulator or connect device
5. ✅ Run `flutter run`

---

**Note**: If you're working in a different directory than `/workspace`, make sure to:
- Copy the project files to your working directory, OR
- Navigate to the `/workspace` directory in your terminal
