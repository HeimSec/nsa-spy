# nsa-spy

A Windows batch script that captures login context and key system details for auditing. The script writes a structured entry to `logs/login_log.txt` whenever it is executed (for example, at user logon via Task Scheduler or Group Policy).

## What it records
- Timestamp (UTC offset included) and session metadata (computer, domain, username, session name, admin status)
- Network configuration (`ipconfig /all`)
- Network adapters summary (`getmac /v`)
- Installed software from the local machine registry
- Recent system event log entries
- Logical drive information (filesystem, size, free space)

## Usage
1. Copy `access_insights.bat` to the target machine.
2. Run the script manually or configure it to run at logon:
   - Task Scheduler: create a new task, trigger **At log on**, action **Start a program** pointing to the batch file.
   - Group Policy: add the batch file under **User Configuration → Windows Settings → Scripts (Logon/Logoff)**.
3. Review collected entries in `logs/login_log.txt`. The script auto-rotates the log file when it exceeds 1 MB.

## Privacy and safety
- Ensure execution complies with your organization’s policies and applicable regulations.
- Run in a test environment first to confirm that required Windows commands (PowerShell, `wevtutil`, `wmic`, `getmac`) are available.
- The script does not transmit data; it only writes to the local `logs` directory.
