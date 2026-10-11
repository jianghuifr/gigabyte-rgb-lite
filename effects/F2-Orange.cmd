@echo off
schtasks /Run /TN "GccLiteFx-ColOrange" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColOrange) else (echo OK - ColOrange applied)

