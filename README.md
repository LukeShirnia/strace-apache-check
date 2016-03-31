# strace-apache-check
The script is used to automate an apache troubleshooting step (there are many steps in the process of troubleshooting slow responses from apache)

The script:

    -Established connection to apache using telnet
    -Uses strace and the pid of the established telnet connection to monitor apache process
    -Sends a GET request and HOST name (user specified host) to apache
    -Outputs the strace command with timestamps into a file
    
Once you have this information you are then able to analyse apache and the domain in question.
Using a simple sort command you can see the top 10 longest running system calls and start the investigation:


       $ sort -k2rn /tmp/output | head
       

Note:  

    -Currently ONLY works with apache and php
    -NOT testest on nginx or apache with php-fpm/fast-cgi (currently IN-PROGRESS - strace will attach to nginx process but will not detach)
    -Currently ONLY works for standard http (port 80) websites

