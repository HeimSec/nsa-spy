@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Script Name: access_insights.bat
REM Version: 1.1
REM Author: Jan Gebser
REM
REM Description:
REM - Logs user login details, system information, and network configuration upon each login.
REM - Adds safeguards such as log rotation, consistent timestamps, and richer context for each entry.
REM
REM Disclaimer:
REM Always ensure script execution adheres to company policies and complies with relevant security and privacy regulations.
REM Test scripts in a controlled environment before deployment. The author is not responsible for any errors or issues caused
REM by the usage of this script. In case of issues, users can open a ticket for assistance, subject to availability and
REM schedule.

set "LOG_DIR=logs"
set "LOG_FILE=%LOG_DIR%\login_log.txt"
set "MAX_LOG_SIZE=1048576"

call :ensure_log_directory || exit /b 1
call :set_context
call :rotate_if_needed

call :log_line "============================================================"
call :log_line "Login record: %HUMAN_TIMESTAMP%"
call :log_line "Machine: %COMPUTERNAME% | Domain: %USERDOMAIN% | User: %USERNAME%"
call :log_line "Session: %SESSIONNAME% | Admin: %IS_ADMIN%"
call :log_line "------------------------------------------------------------"

call :run_and_log "IP configuration" ipconfig /all
call :run_and_log "Network adapters (GETMAC)" getmac /v /fo list
call :run_and_log "Installed software" powershell -NoProfile -Command "Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*' | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -AutoSize"
call :run_and_log "Recent system event logs" wevtutil qe System /c:20 /rd:true /f:text
call :run_and_log "Drive information" wmic logicaldisk get Name, FileSystem, FreeSpace, Size, VolumeName /format:list

call :log_line ""
exit /b 0

:ensure_log_directory
if not exist "%LOG_DIR%" (
  mkdir "%LOG_DIR%" 2>nul
  if errorlevel 1 (
    echo Failed to create log directory "%LOG_DIR%".
    exit /b 1
  )
)
if not exist "%LOG_FILE%" type nul > "%LOG_FILE%"
exit /b 0

:set_context
for /f "usebackq" %%i in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')"`) do set "HUMAN_TIMESTAMP=%%i"
for /f "usebackq" %%i in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "FILE_TIMESTAMP=%%i"
net session >nul 2>&1
if %errorlevel%==0 (set "IS_ADMIN=Yes") else (set "IS_ADMIN=No")
exit /b 0

:rotate_if_needed
if exist "%LOG_FILE%" (
  for %%A in ("%LOG_FILE%") do (
    if %%~zA GTR %MAX_LOG_SIZE% (
      set "ARCHIVE=%LOG_DIR%\login_log_%FILE_TIMESTAMP%.txt"
      move "%LOG_FILE%" "!ARCHIVE!" >nul
      type nul > "%LOG_FILE%"
      call :log_line "Log rotated to !ARCHIVE! due to size > %MAX_LOG_SIZE% bytes."
    )
  )
)
exit /b 0

:log_line
echo %~1>> "%LOG_FILE%"
exit /b 0

:run_and_log
set "SECTION_TITLE=%~1"
shift
set "CMD=%*"
call :log_line "---- %SECTION_TITLE% ----"
!CMD! >> "%LOG_FILE%" 2>&1
if errorlevel 1 call :log_line "[warning] %SECTION_TITLE% command returned error code %ERRORLEVEL%"
call :log_line ""
exit /b 0
