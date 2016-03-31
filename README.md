# strace-apache-check
The script is used to automate an apache troubleshooting step (there are many steps in the process of troubleshooting slow responses from apache)

Note:  

    -Currently ONLY works with apache and php
    -NOT testest on nginx or apache with php-fpm/fast-cgi (currently IN-PROGRESS - strace will attach to nginx process but will not detach)
    -Currently ONLY works for standard http (port 80) websites

The script:

    -Connects to apache using telnet
    -Uses strace to monitor apache response (connects to the telnet PID that is established with apache)
    -Sends a GET request to a specific domain hosted on the server
    -Outputs the strace command with timestamps
        
This then allows you to analyse slow system calls or slow responses from apache
