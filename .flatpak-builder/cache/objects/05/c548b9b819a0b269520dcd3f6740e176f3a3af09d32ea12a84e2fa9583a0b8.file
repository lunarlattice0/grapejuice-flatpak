title: Accessing Grapejuice Logs
---
Grapejuice logs information to both the terminal and local files. These files can be used to troubleshoot issues with
the program.

## Log storage and access

Logs are stored at `~/.local/var/log/grapejuice`. You can also access logs through the Grapejuice UI by clicking
on the hamburger button (the button with 3 lines) and clicking "Open logs directory".

## Special mechanics

The log level can be set by setting the `LOG_LEVEL` environment variable. The following log levels are supported:

- INFO
- DEBUG
- WARNING
- ERROR

## Log cleanup

If the number of logs in the logs directory reaches 50, the number of logs will be reduced to 10. These logs are kept in
an archive directory as zip files. The archival files are removed after a week.
