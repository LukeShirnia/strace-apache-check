#!/bin/bash
default="output"
validation=0

function sitelist {
sites=$(/usr/sbin/httpd -S 2>&1 | grep "port 80 namevhost" | awk '{print $4}')
}

function sitelistubuntu {
sites=$(/usr/sbin/apache2 -S 2>&1 | grep "port 80 namevhost" | awk '{print $4}')
}
function telnetcommands {
echo "GET / HTTP/1.1"
sleep 2
( strace -o /tmp/$default -f -r -s4096 -p `pidof telnet` &  )
#( strace -o /tmp/$default -f -r -s4096 -e trace=sendto,connect,open,write,read -p `pidof telnet` &  )
sleep 1
echo "Host: $sitecheck"
echo ""
#sleep 2
}
function organise {
sort -k2rn /tmp/$default | head > /tmp/stracesort
echo "Top 10 slowest system calls:"
cat /tmp/stracesort
}
check_distro() {
if [ ! -f /etc/redhat-release ]; then
        Distro=$(cat /etc/issue | head -1 | cut -d' ' -f1)
        if  [ $Distro == "Ubuntu"] || [ $Distro == "Debian" ]; then
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
function whichsite {

while [ "$validation" -le 0 ]; do
        printf "Port 80 sites: \n\n"
        printf "$sites\n\n"
        read -p "What local site would you like to check? " sitecheck
if [ $Distro == "CentOS" ] || [ $Distro == "Red Hat" ]; then
        validation=$( /usr/sbin/httpd -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
elif [ $Distro == "Ubuntu" ] || [ $Distro = 'Debian' ]; then
        validation=$( /usr/sbin/apache2 -S 2>&1 | grep "namevhost $sitecheck" | wc -l )
fi
        echo $validation
done
}

function outputfilename {
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
}

        check_distro
        if [ $Distro == "CentOS" ] && [ $Version -lt 7 ] || [ $Distro == "Red Hat" ] && [ $Version -lt 7 ]; then
                sitelist
                whichsite
        elif [ $Distro == "CentOS" ] && [ $Version -ge 7 ] || [ $Distroi == "Red Hat" ] &&  [ $Version -ge 7 ]; then
                sitelist
                whichsite
        elif [ $Distro == "Ubuntu" ] && [ $Version -gt 12] && [ $Version -lt 14 ]; then
                sitelist
                whichsite
        elif [ $Distro = 'Debian' ] && [ $Version = 7 ]; then
                sitelist
                whichsite
        fi

        while [[ ! ("$filenameyn" =~ (y|ye|yes)$ ) ]]; do
                outputfilename
        done


        telnetcommands | telnet 127.0.0.1 80 | grep 'HTTP/1.1\|Date:\|Server:\|Last-Modified:\|Content-Type:'
        organise

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
