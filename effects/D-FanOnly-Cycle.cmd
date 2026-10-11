@echo off
schtasks /Run /TN "GccLiteFx-FanOnly" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-FanOnly) else (echo OK - FanOnly applied)

