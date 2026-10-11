@echo off
schtasks /Run /TN "GccLiteFx-CometRainbow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-CometRainbow) else (echo OK - CometRainbow applied)

