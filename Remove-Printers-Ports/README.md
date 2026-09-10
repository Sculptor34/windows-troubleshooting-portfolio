# To remove printer port 

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

# Commands Used
Method 2
- get-printer | select-object name, portname 
- remove-printer -name "printername"

# Result
The Printer able to print 
