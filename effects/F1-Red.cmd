@echo off
schtasks /Run /TN "GccLiteFx-ColRed" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColRed) else (echo OK - ColRed applied)

