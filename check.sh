#!/bin/bash
default="output"
validation=0

function organise {
test=$(awk '{print $2 }' /tmp/$default | sort -rn | head -5)
grep "$test" /tmp/$default > /tmp/stracetop
#echo "top offenders: $test"
}
function sitelist {

sites=$(/usr/sbin/httpd -S 2>&1 | grep "port 80 namevhost" | awk '{print $4}')

}

sitelist
while [ "$validation" -le 0 ]; do
        printf "Port 80 sites: \n\n"
        printf "$sites\n\n"
        read -p "What local site would you like to check? " sitecheck
        validation=$( /usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
        echo $validationo
done

while [[ ! ("$filenameyn" =~ (y|ye|yes)$ ) ]]; do
read -p "Specify strace file name? (Default: /tmp/output) (y/N) " filenameyn
  case $filenameyn in
    y|ye|yes )
     read -p "What filename would you like? /tmp/ " default
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

{ printf "GET / HTTP/1.1\n"; \
sleep 2 ;\
( strace -o /tmp/$default -f -r -s4096 -p `pidof telnet` &  ) ; \
sleep 2 ;\
printf "Host: $sitecheck\n"; echo ""; \
} |  telnet 127.0.0.1 80 | grep 'HTTP/1.1\|Date:\|Server:\|Last-Modified:\|Content-Type:'  || organise

#add php specific section:
# function docroot {
# vhost=$(/usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | awk '{print $5}' | awk -F':' '{print $1}' | sed 's/(//')
#}
#docroot
#if [ "/usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | awk '{print $5}' | awk -F':' '{print $1}' | sed 's/(// | wc -l" -le 1 ]; then
# root=$( grep -i "DocumentRoot" $vhost  )

########Actual Command########
#HTTP_HOST=$sitecheck REQUEST_URI=/ strace -o /tmp/phptrace -r -e trace=sendto,connect,open,write,read php "$docroot""index.php" > /dev/null



#else
#dont do it
#fi
