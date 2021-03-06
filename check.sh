#!/bin/bash
default="output"
validation=0
neat="###########################"
function sitelist {
sites=$(/usr/sbin/httpd -t -D DUMP_VHOSTS 2>&1 | grep "port " | awk '{print $4}')
}

function sitelistubuntu {
sites=$(/usr/sbin/apache2 -S 2>&1 | grep "port 80 namevhost" | awk '{print $4}')
}
function telnetcommands {
        sleep 1
        echo "GET / HTTP/1.1"
        sleep 2
        httpd_pid=$(netstat -pant | awk '/httpd/ && /127.0.0.1/ {print $7}' | awk -F'/' '{print $1}')
        ( strace -o /home/rack/$default -r -yy -v -s4096 -p $httpd_pid &  )
        sleep 1
        echo "Host: $sitecheck"
        echo ""
#sleep 2
}
function checktelnet {

if  [ $Distro == "Ubuntu" ] || [ $Distro == "Debian" ]; then
        if [ `dpkg -l | grep -i telnet | wc -l` -lt 1 ] && [ `dpkg -l | grep -i strace | wc -l` -lt 1 ]; then
                while [[ ! ("$telnetyn" =~ (y|ye|yes)$ ) ]]; do
                        installtelnet
                done
                while [[ ! ("$straceyn" =~ (y|ye|yes)$ ) ]]; do
                        installstrace
                done
        elif [ `dpkg -l | grep -i telnet | wc -l` -lt 1 ]; then
                while [[ ! ("$telnetyn" =~ (y|ye|yes)$ ) ]]; do
                        installtelnet
                done
        elif [ `dpkg -l | grep -i strace | wc -l` -lt 1 ]; then
                while [[ ! ("$straceyn" =~ (y|ye|yes)$ ) ]]; do
                        installstrace
                done
        fi


elif [ $Distro == "CentOS" ] || [ $Distro == "Red Hat" ]; then

        if [ `rpm -qa | grep -i telnet | wc -l` -lt 1  ] && [ `rpm -qa | grep -i strace | wc -l` -lt 1  ]; then
                while [[ ! ("$telnetyn" =~ (y|ye|yes)$ ) ]]; do
                        installtelnet
                done
                while [[ ! ("$straceyn" =~ (y|ye|yes)$ ) ]]; do
                        installstrace
                done
        elif [ `rpm -qa | grep -i telnet | wc -l` -lt 1  ] ; then
                while [[ ! ("$telnetyn" =~ (y|ye|yes)$ ) ]]; do
                        installtelnet
                done
        elif [ `rpm -qa | grep -i strace | wc -l` -lt 1  ]; then
                while [[ ! ("$straceyn" =~ (y|ye|yes)$ ) ]]; do
                        installstrace
                done
        fi

else

        printf "Unsupported OS\n"
        exit

fi
}
function installtelnet {
read -p "REQUIRED: TELNET - Would you like to Install Telnet? (y/N) " telnetyn
  case $telnetyn in
    y|ye|yes )
        if  [ $Distro == "Ubuntu" ] || [ $Distro == "Debian" ]; then
                apt-get install telnet -y | grep -i 'Total download\|Installed:' -A1
        elif [ $Distro == "CentOS" ] || [ $Distro == "Red Hat" ]; then
                echo $neat
                yum install telnet -y | grep -i 'Total download\|Installed:' -A1
        fi
    ;;
    n|N|no )
      break
    ;;
    * )
      printf "Please enter a valid option"
      printf "\n----------------------------------------------\n"

    ;;
    esac
}
function installstrace {
read -p "REQUIRED: STRACE - Would you like to Install Strace? (y/N) " straceyn
  case $straceyn in
    y|ye|yes )
        echo $neat
        if  [ $Distro == "Ubuntu" ] || [ $Distro == "Debian" ]; then
                apt-get install strace -y | grep -i 'Total download\|Installed:' -A1
        elif [ $Distro == "CentOS" ] || [ $Distro == "Red Hat" ]; then
                yum install strace -y | grep -i 'Total download\|Installed:' -A1
        fi
    ;;
    n|N|no )
      break
    ;;
    * )
      printf "Please enter a valid option"
      printf "\n----------------------------------------------\n"

    ;;
    esac
}


function organise {
        sort -rn /home/rack/$default | head > /home/rack/stracesort
        echo $neat
        echo ""
        echo "Top 10 slowest system calls:"
        cat /tmp/stracesort
}
check_distro() {
if [ ! -f /etc/redhat-release ]; then
        Distro=$(cat /etc/issue | head -1 | cut -d' ' -f1)
        if  [ $Distro == "Ubuntu" ] || [ $Distro == "Debian" ]; then
                case $Distro in
                "Ubuntu" )
                        Version=$(cat /etc/issue | head -1 | cut -d' ' -f2 | cut -d'.' -f1)
                ;;
                "Debian" )
                        Version=$( cat /etc/issue | head -1 | cut -d' ' -f3 )
                ;;
                esac
        fi
elif [ `cat /etc/redhat-release | grep -i "hat" | wc -l` -gt 0 ]; then
                Distro="Red Hat"
                Version=$(cat /etc/redhat-release | grep -Eo '[0-9]{1,4}' | head -1)
elif  [ `cat /etc/redhat-release | grep -i "centos" | wc -l` -gt 0 ]; then
                Distro="CentOS"
                Version=$(cat /etc/redhat-release | grep -Eo '[0-9]{1,4}' | head -1)
fi

}
function http_or_https {

# check to see if port is 443
if [ "$port_check" == "443" ]; then
    echo "This script does not currently work for 443...coming soon"
    echo ""
    exit
else
    domain_location=$(/bin/curl -svo /dev/null localhost:$port_check -H "Host: $sitecheck" -H "X-Forwarded-Proto: https" 2>&1 | grep -o "Location\|200 OK" | sed "s/< Location: //g")
fi

echo "port check " "$port_check"

if [[ "$domain_location" == *"200 OK"*  ]] && [[ "$domain_location" != *"Location"*  ]]; then
    echo "$domain_location" "- No redirect"
    echo "Location matched"
elif [[ "$domain_location" == *"200 OK"* ]] && [[  "$domain_location" = *"Location"*  ]]; then
    echo "There is a redirect"
    echo "Domain location after redirects: " "$domain_location"
    domain_location_strip=$(echo "$domain_location" | awk -F'Location' '{print $1}')
fi

# if $domain_location = Location and https not in line
if [  "$domain_location" == *"https"* ]; then
    echo "Site is HTTPS not HTTP...exiting"
elif [ ! "$domain_location" == "200 OK" ]; then
    echo "Location is not standard http...exiting" 
    exit
fi

}

function whichsite {

while [ "$validation" -le 0 ]; do
        printf "Site(s) available: \n\n"
        printf "$sites\n\n"
        read -p "What local site would you like to check? " sitecheck
if [ $Distro == "CentOS" ] || [ $Distro == "Red Hat" ]; then
        validation=$( /usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
        port_check=$( /usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | awk -F':' '{print $1} '| sed 's/[^0-9]*//g')
        http_or_https 
elif [ $Distro == "Ubuntu" ] || [ $Distro = 'Debian' ]; then
        validation=$( /usr/sbin/apache2 -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
        port_check=$( /usr/sbin/apache2 -S 2>&1 | grep "namevhost $sitecheck" | awk -F':' '{print $1} '| sed 's/[^0-9]*//g')
        http_or_https 
fi
#        echo $validation
done
}

function outputfilename {
read -p "Use Default file for output: (/home/rack/output (y/N)) " filenameyn
  case $filenameyn in
    y|ye|yes )
        break
    ;;
    n|N|no )
        read -p "What filename would you like? /tmp/ " default
    ;;
    * )
      printf "Please enter a valid option"
      printf "\n----------------------------------------------\n"

    ;;
    esac
}
        check_distro
        checktelnet
        if [ $Distro == "CentOS" ] && [ $Version -lt 7 ] || [ $Distro == "Red Hat" ] && [ $Version -lt 7 ]; then
                sitelist
                echo $neat
                whichsite
        elif [ $Distro == "CentOS" ] && [ $Version -ge 7 ] || [ $Distroi == "Red Hat" ] &&  [ $Version -ge 7 ]; then
                sitelist
                echo $neat
                whichsite
        elif [ $Distro == "Ubuntu" ] && [ $Version -gt 12 ] && [ $Version -lt 14 ]; then
                sitelist
                echo $neat
                whichsite
        elif [ $Distro = 'Debian' ] && [ $Version = 7 ]; then
                sitelist
                echo $neat
                whichsite
        fi

        while [[ ! ("$filenameyn" =~ (y|ye|yes)$ ) ]]; do
                outputfilename
        done

        telnetcommands | telnet 127.0.0.1 "$port_check" | grep 'HTTP/1.1\|Date:\|Server:\|Last-Modified:\|Content-Type:'
#        telnetcommands | telnet 127.0.0.1 8080 | grep 'HTTP/1.1\|Date:\|Server:\|Last-Modified:\|Content-Type:'
        echo ""
        echo "Check /home/rack/"$default " for the output of strace"
        echo "Check /home/rack/stracesort for a list of the syscalls in time order"

#add php specific section:
# function docroot {
# vhost=$(/usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | awk '{print $5}' | awk -F':' '{print $1}' | sed 's/(//')
#}
#docroot
#if [ "/usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | awk '{print $5}' | awk -F':' '{print $1}' | sed 's/(// | wc -l" -le 1 ]; then
# root=$( grep -i "DocumentRoot" $vhost  )

########Actual Command########
#HTTP_HOST=$sitecheck REQUEST_URI=/ strace -o /tmp/phptrace -r -e trace=sendto,connect,open,write,read php "$docroot""index.php" > /dev/null
#HTTP_HOST=www.domain.com REQUEST_URI=/ strace -tt -e trace=sendto,connect,open,write,read php /home/username/public_html/index.php

#else
#dont do it
#fi
# nc -v --SSL -C localhost 443
# send headers
