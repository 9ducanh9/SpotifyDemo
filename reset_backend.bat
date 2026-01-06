@echo off
chcp 65001 >nul
echo ========================================
echo    RESET BACKEND DATABASE
echo ========================================
echo.

REM Lay thu muc chua script
set "SCRIPT_DIR=%~dp0"
set "BACKEND_DIR=%SCRIPT_DIR%backend"

REM Kiem tra thu muc backend co ton tai khong
if not exist "%BACKEND_DIR%" (
    echo [ERROR] Khong tim thay thu muc backend tai: %BACKEND_DIR%
    pause
    exit /b 1
)

cd /d "%BACKEND_DIR%"
echo [INFO] Dang lam viec tai: %BACKEND_DIR%
echo.

echo [1/2] Dang kiem tra Dart...
dart --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dart chua duoc cai dat hoac chua co trong PATH
    echo [INFO] Vui long cai dat Dart SDK: https://dart.dev/get-dart
    pause
    exit /b 1
)
dart --version
echo.

echo [2/2] Dang reset database...
echo.
echo [WARNING] Se xoa TAT CA du lieu trong database!
echo [WARNING] Bao gom: tracks, users, va tat ca tables
echo.
echo ========================================
echo.

dart run bin/reset_backend.dart

echo.
echo ========================================
echo [INFO] Reset hoan tat!
echo [INFO] Ban co the chay init_tables.dart de them du lieu mau (neu can)
echo ========================================
echo.

pause

