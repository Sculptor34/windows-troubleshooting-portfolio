# Windows 7 Password Reset Guide

# Overview
This project demonstrates how to reset a forgotten password in Windows 7 using administrative recovery techniques.

## Problem
User unable to log in due to forgotten password.

# Diagnosis
- No access to user account
- No password hint available
- System still accessible via recovery options

# Solution
Steps:
1. Insert Windows 7 installation media (USB/CD/DVD)
2. Boot into recovery mode
3. Access Command Prompt
4. Replace utilman.exe with cmd.exe
5. Reset password using command line

# Commands Used
net user username newpassword

# Result
User successfully regained access to system.

# Notes
This method should only be used for authorized system recovery.
