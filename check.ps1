# PowerShell script to check project health
# Usage: .\check.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Music Player - Health Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check Flutter installation
Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   ✓ Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Flutter not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Check project structure
Write-Host "2. Checking project structure..." -ForegroundColor Yellow

$requiredFiles = @(
    "lib\main.dart",
    "pubspec.yaml",
    "lib\core\routing\app_router.dart",
    "lib\data\database\database_helper.dart",
    "lib\features\tracks\presentation\screens\home_screen.dart"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file (missing)" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""

# Check dependencies
Write-Host "3. Checking dependencies..." -ForegroundColor Yellow
if (Test-Path "pubspec.lock") {
    Write-Host "   ✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Dependencies not installed (run: flutter pub get)" -ForegroundColor Yellow
}

Write-Host ""

# Run Flutter doctor
Write-Host "4. Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Analyze code
Write-Host "5. Analyzing code..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Code analysis passed" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Code analysis found issues" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# Check tests
Write-Host "6. Checking tests..." -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path "test" -Filter "*.dart" -ErrorAction SilentlyContinue
if ($testFiles) {
    Write-Host "   ✓ Found $($testFiles.Count) test file(s)" -ForegroundColor Green
    foreach ($test in $testFiles) {
        Write-Host "     - $($test.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠ No test files found" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "✓ All checks passed!" -ForegroundColor Green
} else {
    Write-Host "⚠ Some issues found. Please review above." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
