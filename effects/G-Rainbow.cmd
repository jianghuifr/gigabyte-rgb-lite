@echo off
schtasks /Run /TN "GccLiteFx-Rainbow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Rainbow) else (echo OK - Rainbow applied)

