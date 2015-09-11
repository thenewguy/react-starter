@ECHO OFF

SETLOCAL

set WHERE_CMD=where.exe git

REM set WHERE_CMD=where.exe gitdoesnotexist
REM echo WHERE_CMD: %WHERE_CMD% 

FOR /F "tokens=* USEBACKQ" %%F IN (`%WHERE_CMD%`) DO (
    SET GIT_PATH=%%F
)

IF NOT EXIST "%GIT_PATH%" (
    ECHO %WHERE_CMD%
    ECHO git not found
    EXIT /B
)

REM echo GIT_PATH: %GIT_PATH%

set REL_BIN_DIR=%GIT_PATH%\..\..\bin

REM echo REL_BIN_DIR: %REL_BIN_DIR%

pushd %REL_BIN_DIR%

set ABS_BIN_DIR=%CD%

popd

REM echo ABS_BIN_DIR: %ABS_BIN_DIR%

SET PATH=%ABS_BIN_DIR%;%PATH%

REM echo PATH: %PATH%

@ECHO ON

@vagrant ssh