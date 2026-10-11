@echo off
schtasks /Run /TN "GccLiteFx-On" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-On) else (echo OK - On applied)

