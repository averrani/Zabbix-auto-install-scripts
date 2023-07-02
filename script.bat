@echo off
echo -----------------------------------------------------------
echo Starting Zabbix agent installation and configuration script
echo -----------------------------------------------------------

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:CheckOS
echo -----------------------------------------------------------
echo Detecting OS processor type
echo -----------------------------------------------------------
echo PROCESSOR_ARCHITECTURE var:
echo %PROCESSOR_ARCHITECTURE% | find /i "x86" > nul

set netpath=\\10.243.100.203\data-deploy-script-lgc\Zabbix
echo ----Path set to 64bit----

for /F "tokens=2 delims=:" %%G in ('ipconfig ^| findstr /i "IPv4 Address"') do (
    set "IPAddress=%%G"
    call set "IPAddress=%%IPAddress: =%%"
)

set localpath=C:\Zabbix

GOTO FOLDER_CHECK

:FOLDER_CHECK
echo -----------------------------------------------------------
echo Checking if the directory exists
echo -----------------------------------------------------------
if exist "C:\Zabbix" (
	echo "Directory already exists"
	GOTO COPY
) else (
	echo "Directory does not exist"
	mkdir "C:\Zabbix"
	echo "Directory has been created"
)
GOTO COPY

:COPY
echo -----------------------------------------------------------
echo Copying contents from the Net Path to the Local Path
echo -----------------------------------------------------------
xcopy %netpath% %localpath%\  /z /y /e
GOTO CONFIG_AGENT

:CONFIG_AGENT
echo -----------------------------------------------------------
echo Configuring Zabbix agent..........
echo. > "C:\Zabbix\conf\zabbix_agent2.conf"
echo Server=10.243.100.241 >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo Hostname=%COMPUTERNAME% >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo ServerActive=10.243.100.241 >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo HostMetadata=Windows >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo HostInterface=%IPAddress% >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo LogFile=C:\Zabbix\zabbix_agent2.log >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo Timeout=5 >> "C:\Zabbix\conf\zabbix_agent2.conf"

echo ControlSocket=\\.\pipe\agent.sock >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo Include=.\zabbix_agent2.d\plugins.d\*.conf >> "C:\Zabbix\conf\zabbix_agent2.conf"
echo Zabbix Agent configuration appended in zabbix_agent2.conf.........
GOTO INSTALL_AGENT

:INSTALL_AGENT
runas admin
echo -----------------------------------------------------------
echo Installing Zabbix agent service
echo -----------------------------------------------------------
cd C:\Zabbix\bin
zabbix_agent2.exe --config "C:\Zabbix\conf\zabbix_agent2.conf" --install
GOTO ADD_FIREWALL

:ADD_FIREWALL
echo -----------------------------------------------------------
echo Adding 10050/tcp firewall rule for Zabbix Service
echo -----------------------------------------------------------
netsh advfirewall firewall add rule name="zabbix agent" protocol=TCP localport=10050 action=allow dir=IN
GOTO START_AGENT

:START_AGENT
echo -----------------------------------------------------------
echo Starting Zabbix agent
echo -----------------------------------------------------------
net start "Zabbix Agent 2"

echo -----------------------------------------------------------
echo Starting Zabbix agent installation and configuration script - FINISHED
echo -----------------------------------------------------------
pause 