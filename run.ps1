# PowerShell script to run the Local Music Player app
# Usage: .\run.ps1 [device]

param(
    [string]$Device = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Music Player - Run Script" -ForegroundColor Cyan
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
    Write-Host "Make sure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

# List available devices
Write-Host "Available devices:" -ForegroundColor Yellow
flutter devices
Write-Host ""

# Run the app
if ($Device -eq "") {
    Write-Host "Starting app on default device..." -ForegroundColor Yellow
    Write-Host "To specify a device, use: .\run.ps1 -Device <device-id>" -ForegroundColor Gray
    Write-Host ""
    flutter run
} else {
    Write-Host "Starting app on device: $Device" -ForegroundColor Yellow
    Write-Host ""
    flutter run -d $Device
}
