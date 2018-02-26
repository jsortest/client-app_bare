@echo off
Setlocal EnableDelayedExpansion

WHERE dotnet
IF %ERRORLEVEL% NEQ 0 (
 ECHO .NET Core is not installed
 pause
 goto exit
)


set CURR_DIR=%~dp0

Set _RNDLength=32
Set _Alphanumeric=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
Set _Str=%_Alphanumeric%987654321
:_LenLoop
IF NOT "%_Str:~18%"=="" SET _Str=%_Str:~9%& SET /A _Len+=9& GOTO :_LenLoop
SET _tmp=%_Str:~9,1%
SET /A _Len=_Len+_tmp
Set _count=0
SET _RndAlphaNum=
:_loop
Set /a _count+=1
SET _RND=%Random%
Set /A _RND=_RND%%%_Len%
SET _RndAlphaNum=!_RndAlphaNum!!_Alphanumeric:~%_RND%,1!
If !_count! lss %_RNDLength% goto _loop

set /p siteId=<"%CURR_DIR%\site.txt"
set CLIENT_ID=!_RndAlphaNum!%siteId%

echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@ Client ID is !CLIENT_ID! @@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


CMD.exe /C net stop "SorcererClientService"

if [%1]==[] (
for /r "%CURR_DIR%" %%a in (*.msi) do set msifile=%%~dpnxa
) else (
set msifile=%1
)

echo Installing "%msifile%" ...
cmd /C msiexec /i "%msifile%" /q CLIENT_ID=!CLIENT_ID!

if [%2]==[] pause

:exit
