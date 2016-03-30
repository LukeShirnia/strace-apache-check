#!/bin/bash
default="ouput"
read -p "What site would you like to check? " sitecheck

while [[ ! ("$filenameyn" =~ (y|ye|yes)$ ) ]]; do
#if sitecheck exits; then
read -p "Specify strace file name? (y/N) " filenameyn
  case $filenameyn in

    y|ye|yes )

     read -p "What filename would you like? " default

    ;;
    n|N|no )
      break
    ;;
    * )
      printf "Please enter a valid option"
      printf "\n----------------------------------------------\n"

    ;;
    esac
done
{  sleep 2; \
( strace -o /tmp/$default -f -r -s4096 -p `pidof telnet` &  ) ; \
printf "GET / HTTP/1.1\n"; \
printf "Host: $sitecheck\n"; echo ""; \
sleep 2; } |  telnet 127.0.0.1 80
#else
#fi
