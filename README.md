# strace-apache-check




# IN PROGRESS!!!! WILL UPDATE SOON



<br />
<br/>
<br />
<br/><br />
<br/><br />
<br/>






```
bash <( curl -s https://raw.githubusercontent.com/luke7858/strace-apache-check/master/check.sh)
```

## Summary
The script uses strace to follow an apache child process (prefork) and record the system calls
It can be used to quickly troubleshoot/rule-out if the issue is website/code related.
<br />
<br/>

The script can be used to automate one apache troubleshooting step (there are many steps in the process of troubleshooting issues)
<br />
The script:

    -Established connection to apache using telnet
    -Obtain the correct PID for the apache process
    -Uses strace and the PID to monitor apache process
    -Sends a GET request and HOST name (user specified host) to apache
    -Outputs the strace command with timestamps into a file (/home/rack/output)

<br />

<br />

### Speed Issues

If you are using this script to investigate site speed issues, you can run the following command to simply order the strace output into the highest time consuming system calls (top 10):


       $ sort -k2rn /home/rack/output | head
       

Note:  

    -Currently ONLY works with apache and php
    -Works on Ubuntu/CentOS/RHEL
    -NOT testest on nginx or apache with php-fpm/fast-cgi
    -Currently ONLY works for standard http (port 80) sites
