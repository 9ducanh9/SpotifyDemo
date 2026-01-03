# PowerShell script to run tests for Local Music Player
# Usage: .\test.ps1 [--coverage]

param(
    [switch]$Coverage = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Music Player - Test Script" -ForegroundColor Cyan
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
if (-not (Test-Path "test")) {
    Write-Host "✗ test directory not found!" -ForegroundColor Red
    exit 1
}

# Run tests
if ($Coverage) {
    Write-Host "Running tests with coverage..." -ForegroundColor Yellow
    flutter test --coverage
    Write-Host ""
    Write-Host "Coverage report generated in: coverage/lcov.info" -ForegroundColor Green
} else {
    Write-Host "Running tests..." -ForegroundColor Yellow
    flutter test
}

Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ All tests passed!" -ForegroundColor Green
} else {
    Write-Host "✗ Some tests failed" -ForegroundColor Red
    exit 1
}
