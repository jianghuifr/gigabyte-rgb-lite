@echo off
schtasks /Run /TN "GccLiteFx-Random" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Random) else (echo OK - Random applied)

