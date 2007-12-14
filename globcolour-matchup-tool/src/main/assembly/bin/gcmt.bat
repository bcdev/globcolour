@ECHO OFF

REM If you have problems running this script try to set
REM the absolute path of GCTOOLS_HOME here:
REM SET GCTOOLS_HOME="/usr/var/globcolour-tools-${project.version}"

REM Only set GCTOOLS_HOME if not already set

SET CURRENT_DIR=%cd%
IF NOT "%GCTOOLS_HOME%" == "" GOTO gotHome
SET GCTOOLS_HOME=%CURRENT_DIR%
IF EXIST "%GCTOOLS_HOME%\bin\gcmt.bat" GOTO okHome
CD ..
SET GCTOOLS_HOME=%cd%
CD %CURRENT_DIR%

:gotHome
IF EXIST "%GCTOOLS_HOME%\bin\gcmt.bat" GOTO okHome
ECHO The GCTOOLS_HOME environment variable is not defined correctly
ECHO This environment variable is needed to run this program
GOTO end

:okHome
java -Xms64m -Xmx256m -jar "%GCTOOLS_HOME%/lib/globcolour-tools.jar" %1 %2 %3 %4 %5 %6 %7 %8 %9

:end
