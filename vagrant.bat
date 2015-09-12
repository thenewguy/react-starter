@ECHO OFF
setlocal EnableDelayedExpansion

set ABS_DIR=%~dp0
set ABS_PATH=%~f0
set DO_ELEVATE=""
set NEEDS_ELEVATE="0"
set IS_ELEVATED="0"
set PROXY_ARGS=%*
set CLOSE_WINDOW="0"

if "%1" == "up" (
    REM // UP NEEDS TO BE ELEVATED FOR SYMLINKS TO WORK
    REM // ALSO REQUIRED FOR NPM-DEBUG.LOG TO BE WRITTEN
    REM // /vagrant ON BOX FILESYSTEM
    set NEEDS_ELEVATE="1"
)

:: Check if we are elevated
FSUTIL dirty query %systemdrive% >nul
If !errorLevel! EQU 0 (
   set IS_ELEVATED="1"
)

::Remove the elevation tag
IF '%1'=='ELEV' (
    for /f "tokens=1,* delims= " %%a in ("%*") do set PROXY_ARGS=%%b
    
    IF !IS_ELEVATED! EQU "0" (
        ECHO ISSUE ELEVATING PRIVILEGES. CANNOT PROCEED.
        PAUSE
        EXIT /B
    )
    
    set CLOSE_WINDOW="1"
)

IF !IS_ELEVATED! EQU "0" IF !NEEDS_ELEVATE! EQU "1" (
    set DO_ELEVATE="1"
)

set "QUOTED_PATH=%~f0"
set "QUOTED_ARGS=ELEV"

::Add quotes to the batch path, if needed
set "script=%0"
set script=%script:"=%
IF '%0'=='!script!' ( GOTO PathQuotesDone )
    set "QUOTED_PATH=""%QUOTED_PATH%"""
:PathQuotesDone

::Add quotes to the arguments, if needed.
:ArgLoop
IF '%1'=='' ( GOTO EndArgLoop ) else ( GOTO AddArg )
    :AddArg
    set "arg=%1"
    set arg=%arg:"=%
    IF '%1'=='!arg!' ( GOTO NoQuotes )
        set "QUOTED_ARGS=%QUOTED_ARGS% "%1""
        GOTO QuotesDone
        :NoQuotes
        set "QUOTED_ARGS=%QUOTED_ARGS% %1"
    :QuotesDone
    shift
    GOTO ArgLoop
:EndArgLoop


if !DO_ELEVATE! EQU "1" (
    ::Create and run the vb script to elevate the batch file
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
    ECHO UAC.ShellExecute "cmd", "/k ""!QUOTED_PATH! !QUOTED_ARGS!""", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
    ECHO "%temp%\OEgetPrivileges.vbs"
    "%temp%\OEgetPrivileges.vbs"
    EXIT /B
)


REM // ENSURE CWD IS SCRIPT DIR - ELEVATING CHANGES CWD
cd /d %ABS_DIR%

pushd vagrant-bin
set PATH=%CD%;%PATH%
popd

@ECHO ON
@vagrant.exe !PROXY_ARGS!

@ECHO OFF
IF !CLOSE_WINDOW! EQU "1" (
    PAUSE
    EXIT
)
