# PowerShell Scripts Overview

This project includes helpful PowerShell scripts for Windows users to streamline Flutter development.

## Quick Start

1. **Setup Project** (first time only):
   ```powershell
   .\setup.ps1
   ```

2. **Run the App**:
   ```powershell
   .\run.ps1
   ```

3. **Run Tests**:
   ```powershell
   .\test.ps1
   ```

## Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup.ps1` | Initial project setup | `.\setup.ps1` |
| `run.ps1` | Run the app | `.\run.ps1` or `.\run.ps1 -Device <id>` |
| `test.ps1` | Run tests | `.\test.ps1` or `.\test.ps1 -Coverage` |
| `build.ps1` | Build for release | `.\build.ps1 apk\|appbundle\|web` |
| `check.ps1` | Health check | `.\check.ps1` |

## Documentation

- **`POWERSHELL_GUIDE.md`** - Complete guide with examples
- **`QUICK_START.md`** - Quick start instructions
- **`README.md`** - Project overview

## Notes

- All scripts must be run from the project root directory
- Scripts provide colored output for better readability
- Scripts exit with error codes for automation compatibility

---

For detailed usage and examples, see `POWERSHELL_GUIDE.md`.
