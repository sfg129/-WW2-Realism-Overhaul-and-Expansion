@echo off
chcp 65001 >nul

pushd "%~dp0"

set "SRC=%CD%"
set "PACKAGES=D:\steam\steamapps\common\RunningWithRifles\media\packages"
set "DST_MAIN=%PACKAGES%\ww2_base"

REM 创建目标目录
if not exist "%PACKAGES%" (
    mkdir "%PACKAGES%"
)

if not exist "%DST_MAIN%" (
    mkdir "%DST_MAIN%"
)

REM 第一步：复制除 pacific 和 edelweiss 外的全部内容到 ww2_base
robocopy "%SRC%" "%DST_MAIN%" /E /R:1 /W:1 /XF *.bat /XD "%SRC%\pacific" "%SRC%\edelweiss"

REM 第二步：复制 pacific
robocopy "%SRC%\pacific" "%PACKAGES%\pacific" /E /R:1 /W:1

REM 第三步：复制 edelweiss
robocopy "%SRC%\edelweiss" "%PACKAGES%\edelweiss" /E /R:1 /W:1

popd

echo.
echo 完成 / Finished
echo 按任意键退出... / Press any key to exit...
pause >nul