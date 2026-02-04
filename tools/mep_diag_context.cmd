@echo off
setlocal
set PR=%1
if "%PR%"=="" set PR=0
where pwsh >nul 2>nul
if errorlevel 1 (
  echo [NG] pwsh not found
  exit /b 2
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0mep_diag_context.ps1" -PrNumber %PR%
endlocal
