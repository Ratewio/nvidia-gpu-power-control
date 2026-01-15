@echo off

fltmc >nul 2>&1 || (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

goto :Menu

:Menu
cls
call :Logo
echo [1] View power log
echo [2] Change Power Limit
echo [3] Install Script at StartUp
echo [4] Open GitHub
echo [0] Exit

choice /c 01234 /m "choose"

if errorlevel 5 call :OpenGitHub
if errorlevel 4 call :InstallScript
if errorlevel 3 call :PowerLimit
if errorlevel 2 call :NVSMI-LOG
if errorlevel 1 exit


:NVSMI-LOG
	cls
    nvidia-smi -q -d POWER
	pause >nul
	goto :Menu
	
:PowerLimit
	cls
	call :GetLimit
	powershell -NoProfile -ExecutionPolicy Bypass -Command "%~dp0scripts\Set-GpuPL.ps1 %value%"
	timeout /t 5 >nul
	goto :Menu
	
:InstallScript
	cls
	robocopy "%~dp0scripts" "%ProgramData%\Ratewio\NvidiaGpuPowerControl" "Set-GpuPL.ps1" /IS >nul
	call :GetLimit
	schtasks ^
		/Create ^
		/TN "Nvidia Gpu Power Change" ^
		/TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File '%ProgramData%\Ratewio\NvidiaGpuPowerControl\Set-GpuPL.ps1' %value%" ^
		/SC ONSTART ^
		/RL HIGHEST ^
		/RU SYSTEM ^
		/F
	timeout /t 5 >nul
	goto :Menu

:OpenGitHub
	cls
	start https://github.com
	goto :Menu


::UTILS

:Logo
	echo.    _  __________  _____
	echo.   / ^|/ / ___/ _ \/ ___/
	echo.  /    / (_ / ___/ /__
	echo. /_/^|_/\___/_/   \___/
	echo.
	exit /b

:GetLimit
	set value=
	set /p value="Enter a numeric value (e.g., 215.5) or max, min, default: "
	exit /b