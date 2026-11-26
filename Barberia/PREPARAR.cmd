@echo off
setlocal
cd /d "%~dp0"
if not exist "Bin" mkdir "Bin"
for %%V in (6.4.4 6.5.2) do (
 if exist "%USERPROFILE%\.nuget\packages\entityframework\%%V\lib\net45\EntityFramework.dll" if exist "%USERPROFILE%\.nuget\packages\entityframework\%%V\lib\net45\EntityFramework.SqlServer.dll" (
  copy /y "%USERPROFILE%\.nuget\packages\entityframework\%%V\lib\net45\EntityFramework.dll" "Bin\" >nul
  copy /y "%USERPROFILE%\.nuget\packages\entityframework\%%V\lib\net45\EntityFramework.SqlServer.dll" "Bin\" >nul
  goto verify
 )
)
set "TMPDIR=%TEMP%\BarberiaEF_%RANDOM%_%RANDOM%"
mkdir "%TMPDIR%" || goto fail
curl.exe --fail --location --retry 2 "https://api.nuget.org/v3-flatcontainer/entityframework/6.4.4/entityframework.6.4.4.nupkg" -o "%TMPDIR%\ef.zip" || goto fail
tar.exe -xf "%TMPDIR%\ef.zip" -C "%TMPDIR%" lib/net45/EntityFramework.dll lib/net45/EntityFramework.SqlServer.dll || goto fail
copy /y "%TMPDIR%\lib\net45\EntityFramework.dll" "Bin\" >nul || goto fail
copy /y "%TMPDIR%\lib\net45\EntityFramework.SqlServer.dll" "Bin\" >nul || goto fail
rmdir /s /q "%TMPDIR%"
:verify
if not exist "Bin\EntityFramework.dll" goto fail
if not exist "Bin\EntityFramework.SqlServer.dll" goto fail
echo Entity Framework listo. Abra el sitio web en Visual Studio.
pause
exit /b 0
:fail
echo No se pudieron preparar las dependencias. Compruebe Internet o copie las DLL desde el sitio anterior.
pause
exit /b 1
