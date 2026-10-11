@echo off
schtasks /Run /TN "GccLiteFx-ColdRainbow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColdRainbow) else (echo OK - ColdRainbow applied)

