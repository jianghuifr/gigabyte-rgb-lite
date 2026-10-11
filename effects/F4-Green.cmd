@echo off
schtasks /Run /TN "GccLiteFx-ColGreen" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColGreen) else (echo OK - ColGreen applied)

