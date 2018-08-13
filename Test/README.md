# Testing

To test a list of CLSIDs use [test_clsid.bat](test_clsid.bat).

**NOTE** All our tests were conducted impersonating the `NT AUTHORITY\LOCAL SERVICE`. To have a shell as `NT AUTHORITY\Local Service`, use `psexec` (as Administrator)
```
.\PsExec64.exe -i -u "nt authority\local service" cmd.exe
```

Some CLSIDs impersonate the current logged-in user in first session, interesting if the DA is logged in ;-)
