@echo off
schtasks /Run /TN "GccLiteFx-StaticRed" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-StaticRed) else (echo OK - StaticRed applied)

