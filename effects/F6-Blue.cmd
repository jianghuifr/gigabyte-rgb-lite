@echo off
schtasks /Run /TN "GccLiteFx-ColBlue" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColBlue) else (echo OK - ColBlue applied)

