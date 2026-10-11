@echo off
schtasks /Run /TN "GccLiteFx-Starry" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Starry) else (echo OK - Starry applied)

