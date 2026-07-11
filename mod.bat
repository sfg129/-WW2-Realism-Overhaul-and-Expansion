
@echo off
chcp 65001 >nul

set "SRC=C:\Users\sfg1.DESKTOP-N02A6BA\Desktop\mymod"
set "DST=C:\Users\sfg1.DESKTOP-N02A6BA\Desktop\ww2mod\media\packages\Realism Overhaul and Expansion"

if not exist "%DST%" (
    mkdir "%DST%"
)

robocopy "%SRC%" "%DST%" /E /R:1 /W:1 /XF game.bat mod.bat

echo.
echo 完成 / Finished
echo 按任意键退出... / Press any key to exit...
pause >nul
```
