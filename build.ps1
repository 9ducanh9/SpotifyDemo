# PowerShell script to build the Local Music Player app
# Usage: .\build.ps1 [apk|appbundle|ios|web]

param(
    [ValidateSet("apk", "appbundle", "ios", "web")]
    [string]$BuildType = "apk"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Music Player - Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    flutter --version | Out-Null
} catch {
    Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Verify project structure
if (-not (Test-Path "lib\main.dart")) {
    Write-Host "✗ main.dart not found!" -ForegroundColor Red
    exit 1
}

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Build based on type
Write-Host "Building $BuildType..." -ForegroundColor Yellow
Write-Host ""

switch ($BuildType) {
    "apk" {
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ APK built successfully!" -ForegroundColor Green
            Write-Host "Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray
        }
    }
    "appbundle" {
        flutter build appbundle --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ App Bundle built successfully!" -ForegroundColor Green
            Write-Host "Location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Gray
        }
    }
    "ios" {
        flutter build ios --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ iOS build completed!" -ForegroundColor Green
            Write-Host "Location: build\ios\Release" -ForegroundColor Gray
        }
    }
    "web" {
        flutter build web --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ Web build completed!" -ForegroundColor Green
            Write-Host "Location: build\web" -ForegroundColor Gray
        }
    }
}

Write-Host ""

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}
