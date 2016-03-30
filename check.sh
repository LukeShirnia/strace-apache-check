#!/bin/bash
default="output"
validation=0

function organise {
test=$(awk '{print $2 }' /tmp/$default | sort -rn | head -5)
grep "$test" /tmp/$default > /tmp/stracetop
}

while [ "$validation" -le 0 ]; do
        read -p "What site would you like to check? " sitecheck
        validation=$( /usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
        echo $validation
done

while [[ ! ("$filenameyn" =~ (y|ye|yes)$ ) ]]; do
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
} |  telnet 127.0.0.1 80 || organise
