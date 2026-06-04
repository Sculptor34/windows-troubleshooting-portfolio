@echo off

net use F: /delete /y

net use F: \\server\share-folder /user:CREDENTIALS PASSWORD /persistent:yes

exit