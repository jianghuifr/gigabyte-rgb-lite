@echo off
schtasks /Run /TN "GccLiteFx-MovingFlash" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-MovingFlash) else (echo OK - MovingFlash applied)

