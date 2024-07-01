@echo off

if [%1]==[] goto error
set hexfile=%1
set comportA=NONE
set comportB=NONE

if [%2]==[] goto DETECT
GOTO LIST2

:DETECT
echo.
echo Looking for Pro Micro COM port
for /f "usebackq" %%B in (`wmic path Win32_SerialPort Where "Caption LIKE '%%Leonardo%%' or PNPDeviceID like '%%0E8F%%'" Get DeviceID ^| findstr "COM"`) do set comportA=%%B
if %comportA%==NONE goto LIST
GOTO RESET


:LIST
echo Could not auto locate Leonardo. Select from list manually.
:LIST2
echo.
wmic path Win32_SerialPort Where "Caption LIKE '%%COM%%'" Get Description, DeviceID
set inum=
set /p inum=Select the COM port to reset (0 to skip):
if %inum%==0 GOTO SKIP
for /f "usebackq" %%B in (`wmic path Win32_SerialPort Where "Caption LIKE '%%COM%%'" Get DeviceID ^| findstr "COM"%inum%`) do set comportA=%%B
if %comportA%==NONE goto nodevice 
GOTO RESET

:SKIP
echo.
set inum2=None
set /p inum2=Reset device manually and press enter. (or type 1 and Reset to list and define com port yourself):
if %inum2%==1 goto MANUALBL else set inum2=None
goto LOCATEBL

:MANUALBL
timeout 1 > NUL
wmic path Win32_SerialPort Where "Caption LIKE '%%COM%%'" Get Description, DeviceID
set inum=
set /p inum=Select the COM port number to attempt update on after reset:
set comportB=COM%inum%
GOTO PROG

:RESET
echo.
echo Reseting board on %comportA% into bootloader mode
mode %ComportA%: baud=12 > nul
timeout 2 > NUL

:LOCATEBL
echo Looking for COM port to program
for /f "usebackq" %%B in (`wmic path Win32_SerialPort Where "Caption LIKE '%%bootloader%%'" Get DeviceID ^| FIND "COM"`) do set comportB=%%B
if %comportB%==NONE goto nobldevice

:PROG
Echo Connecting to bootloader on %comportB%
echo.
avrdude.exe -pm32u4 -cavr109 -D -P%comportB% -b57600 -Uflash:w:%hexfile%
goto upgradedone

:nobldevice
echo Unable to locate bootloader. Try manual reset. Process failed.
goto end

:nodevice
echo No such com port. aborted. 
goto end

:error
Echo Missing file name. Provide the full filename of an existing .hex file you want to use.
goto end

:upgradedone
echo Upgrade done!
echo.
:end