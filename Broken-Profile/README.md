# The specified user does not have valid profile

# Overview
This project demonstrates the how to solve broken profile.

## Problem
The file unable to open.

# Diagnosis
- All files unable to open.
- Download the file in other location file but issue persists.

# Solution
Steps performed:
1. Run these commands as adminstrator
2. Restart the PC

# Commands Used
DISM.exe /Online /Cleanup /Restorehealth
sfc /scannow

# Result
The File able to open as normal

# Notes
This setup was performed for meeting room operational purposes.
