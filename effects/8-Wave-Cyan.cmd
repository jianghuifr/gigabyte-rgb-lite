@echo off
schtasks /Run /TN "GccLiteFx-Wave" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Wave) else (echo OK - Wave applied)

