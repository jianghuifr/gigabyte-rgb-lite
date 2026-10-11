@echo off
schtasks /Run /TN "GccLiteFx-DFlash" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-DFlash) else (echo OK - DFlash applied)

