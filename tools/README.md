ioscrashreporter
================

logs of release version apps dont have symbols, so we may use symbolicatecrash to symbolize the logs

OR crashproc.py is a simple crashlog process script

usage:
1.put crashproc.py and xxx.dSYM and xxx.crash/xxx2.crash... into a same directory
2.run crashproc.py in the dircetory
3.symbolized logs now at ./output

welcome mailto:gdier.zh@gmail.com for suggesting and bug report