@echo off
schtasks /Run /TN "GccLiteFx-Off" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Off) else (echo OK - Off applied)

