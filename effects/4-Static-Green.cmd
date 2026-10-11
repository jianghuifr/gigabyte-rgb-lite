@echo off
schtasks /Run /TN "GccLiteFx-StaticGreen" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-StaticGreen) else (echo OK - StaticGreen applied)

