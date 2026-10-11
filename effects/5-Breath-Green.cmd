@echo off
schtasks /Run /TN "GccLiteFx-Breath" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Breath) else (echo OK - Breath applied)

