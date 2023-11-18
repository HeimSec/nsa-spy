REM Script Name: access_insights.bat
REM Version: 1.0 (initial release)
REM Author: Jan Gebser
REM
REM Description:
REM - This batch script logs user login details, system information, and network configuration upon each login. The script helps in tracking user sessions and system status.

REM Initial Code Snippet:
REM The initial code snippet captures basic user and system information, including IP configuration and some network details. To improve the script's functionality, additional data can be collected:

REM Further Ideas for Collection:
REM - Network Adapter Details: Fetch information about each network adapter, such as IP address, MAC address, and DHCP status.
REM - Installed Software: Retrieve a list of installed software for comprehensive system analysis.
REM - Recent Event Logs: Gather recent event logs to monitor system activities around login times.
REM - Drive Information: Collect data about available drives, disk space, and utilization.

REM Disclaimer:
REM Always ensure script execution adheres to company policies and complies with relevant security and privacy regulations. Test scripts in a controlled environment before deployment.
REM I am not responsible for any errors or issues caused by the usage of this script. Users are encouraged to test this script in a controlled environment before deploying it in a production setting.
REM In case of issues, users can open a ticket for assistance, subject to my availability and schedule.


@echo off
echo %DATE% %TIME% - User: %USERNAME% >> login_log.txt
ipconfig /all >> login_log.txt
echo. >> login_log.txt
