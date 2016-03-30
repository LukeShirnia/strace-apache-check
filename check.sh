#!/bin/bash
read -p "What site would you like to check? " sitecheck
{  sleep 2; \
( strace -o /tmp/output -f -r -s4096 -p `pidof telnet` &  ) ; \
printf "GET / HTTP/1.1\n"; \
printf "Host: $sitecheck\n"; echo ""; \
sleep 2; } |  telnet 127.0.0.1 80
