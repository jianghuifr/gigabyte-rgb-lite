@echo off
schtasks /Run /TN "GccLiteFx-SlowBreath" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-SlowBreath) else (echo OK - SlowBreath applied)

