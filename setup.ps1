# PowerShell script to set up the Local Music Player Flutter project
# Run this script from the project root directory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Music Player - Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Flutter is installed" -ForegroundColor Green
        Write-Host $flutterVersion[0] -ForegroundColor Gray
    } else {
        throw "Flutter not found"
    }
} catch {
    Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Check Flutter doctor
Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Verify project structure
Write-Host "Verifying project structure..." -ForegroundColor Yellow
if (Test-Path "lib\main.dart") {
    Write-Host "✓ main.dart found" -ForegroundColor Green
} else {
    Write-Host "✗ main.dart not found!" -ForegroundColor Red
    Write-Host "Make sure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

if (Test-Path "pubspec.yaml") {
    Write-Host "✓ pubspec.yaml found" -ForegroundColor Green
} else {
    Write-Host "✗ pubspec.yaml not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host "✓ Clean completed" -ForegroundColor Green
Write-Host ""

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Analyze code
Write-Host "Analyzing code..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Code analysis passed" -ForegroundColor Green
} else {
    Write-Host "⚠ Code analysis found issues (check above)" -ForegroundColor Yellow
}

Write-Host ""

# Run tests
Write-Host "Running tests..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ All tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠ Some tests failed (check above)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start an Android emulator or connect a device" -ForegroundColor White
Write-Host "2. Run: flutter run" -ForegroundColor White
Write-Host "3. Or run: flutter run -d chrome (for web)" -ForegroundColor White
Write-Host ""
