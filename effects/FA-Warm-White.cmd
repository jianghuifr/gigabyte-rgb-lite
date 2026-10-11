@echo off
schtasks /Run /TN "GccLiteFx-ColWarm" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColWarm) else (echo OK - ColWarm applied)

