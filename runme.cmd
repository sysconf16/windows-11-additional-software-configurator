@echo off
setlocal DisableDelayedExpansion
title Windows 11 Additional Software Configurator
color f0
cls
echo Please close qBittorrent, Ableton Live and OBS Studio before continuing.
echo.
pause
set /a errors=0
set "failures="
cls
echo Setting configuration files...
call :CopyFile "%~dp0bin\qBittorrent.ini" "%AppData%\qBittorrent\qBittorrent.ini"
cls
echo Setting configuration files...
set "AbletonFound="
if exist "%AppData%\Ableton\" (
  for /D %%D in ("%AppData%\Ableton\Live *") do (
    if exist "%%D\Preferences\" (
      set "AbletonFound=1"
      call :CopyFile "%~dp0bin\Options.txt" "%%D\Preferences\Options.txt"
    )
  )
)
if not defined AbletonFound (
  set /a errors+=1
  call :RecordFailure "Ableton Live Preferences folder not found"
)
cls
echo Setting configuration files...
if exist "%~dp0bin\obs-studio\" (
  dir /A-D /B /S "%~dp0bin\obs-studio" 2>nul | findstr /R "." >nul
  if errorlevel 1 (
    set /a errors+=1
    call :RecordFailure "OBS Studio source folder is empty"
  ) else (
    robocopy "%~dp0bin\obs-studio" "%AppData%\obs-studio" /E /R:2 /W:1 >nul 2>&1
    if errorlevel 8 (
      set /a errors+=1
      call :RecordFailure "OBS Studio configuration copy failed"
    )
  )
) else (
  set /a errors+=1
  call :RecordFailure "OBS Studio source folder not found"
)
cls
if %errors% NEQ 0 goto Failed
echo All software has now been configured.
goto Finished
:Failed
color 4f
cls
echo Configuration completed with %errors% error(s).
echo.
echo Failed operations:
echo %failures%
:Finished
echo.
echo Visit https://sysconf16.github.io/ for more resources.
pause
exit /b %errors%

:CopyFile
if not exist "%~1" goto CopyFailed
if not exist "%~dp2" mkdir "%~dp2" >nul 2>&1
copy /Y "%~1" "%~2" >nul 2>&1
if errorlevel 1 goto CopyFailed
exit /b
:CopyFailed
set /a errors+=1
call :RecordFailure "Copy: %~nx1"
exit /b

:RecordFailure
if defined failures (
  set "failures=%failures% - %~1;"
) else (
  set "failures=- %~1;"
)
exit /b