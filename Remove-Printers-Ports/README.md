# To remove printer port and driver references

# Overview
This project demonstrates the how to force remove printer port

## Problem
The windows create a lot port numbers.

# Diagnosis
- The Printer has many unnecessary port numbers for the same printer.

# Solution
Steps performed:
- Retry deleting the port from Printer Properties if an error occurs (method 1)
- Run PowerShell as Administrator and use the command to display and remove the printer port (method 2)
- Run the provided script in PowerShell as Administrator if the first and second methods fail (method 3)
- Run CMD as administrator run this command (Remove Driver via cmd)

# Commands Used
Method 2
- Get-Printer | Select-Object Name, Portname 
- Remove-Printer -Name "printername"
- Remove-Printerport -Name "port"

Remove Driver via CMD
- printui /s /t2

# Result
The Printer able to print 
