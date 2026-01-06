@echo off
chcp 65001 >nul
echo ========================================
echo    KHOI DONG BACKEND SERVER
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

echo [1/3] Dang kiem tra Dart...
dart --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dart chua duoc cai dat hoac chua co trong PATH
    echo [INFO] Vui long cai dat Dart SDK: https://dart.dev/get-dart
    pause
    exit /b 1
)
dart --version
echo.

echo [2/3] Dang kiem tra dependencies...
dart pub get
if %errorlevel% neq 0 (
    echo [ERROR] Loi khi cai dat dependencies
    pause
    exit /b 1
)

echo.
echo [3/3] Dang khoi dong server...
echo.
echo [INFO] Server se chay tai: http://localhost:8080
echo [INFO] Nhan Ctrl+C de dung server
echo.
echo ========================================
echo.

dart run bin/server.dart

pause
