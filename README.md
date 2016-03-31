# strace-apache-check

- bash <( curl -s https://raw.githubusercontent.com/luke7858/strace-apache-check/master/check.sh)

Summary: The script uses strace to follow an apache child process (prefork) and record the system calls
It can be used to quickly troubleshoot/rule-out if the issue is website/code related

The script is used to automate one apache troubleshooting step (there are many steps in the process of troubleshooting slow responses from apache)

The script:

    -Established connection to apache using telnet
    -Uses strace and the pid of the established telnet connection to monitor apache process
    -Sends a GET request and HOST name (user specified host) to apache
    -Outputs the strace command with timestamps into a file
    
Once you have this information you are then able to analyse apache and the domain in question.
Using a simple sort command you can see the top 10 slowest system calls to help start the investigation:


       $ sort -k2rn /tmp/output | head
       

Note:  

    -Currently ONLY works with apache and php
    -NOT testest on nginx or apache with php-fpm/fast-cgi (currently IN-PROGRESS - strace will attach to nginx process but will not detach)
    -Currently ONLY works for standard http (port 80) websites

