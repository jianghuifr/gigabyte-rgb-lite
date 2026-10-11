@echo off
schtasks /Run /TN "GccLiteFx-YoYo" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-YoYo) else (echo OK - YoYo applied)

