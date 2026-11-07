#!/bin/sh
#
# i-MSCP ConfigScript Debian
# Version: 0.6,0
# License: GPLv2
# Author : i-MSCP Team, DragonZX
# Credits: i-MSCP Development Team
#----------------------------------
# Variables and functions

read -p "Which version of i-MSCP do you want to install (i.e. 1.5.3-2018120800)?: " version
case $version in 
'1.2.'*|'1.3.'*|'1.4.'*|'1.5.'*|'2.0.'*) version=$version;;
'trunk') read -p 'choose a version of trunk 1.5/1.5: ' trunkver ;;
'master') version= 'master' ;;
*) version='1.5.3-2018120800';;
esac

clear
echo '
--------------------------------
Welcome to i-MSCP (' $version $trunkver') installation.
--------------------------------
Choose what you want to do:
1) Install an i-MSCP 
2) Reconfigure i-MSCP
3) Debug mode
4) Uninstall an i-MSCP
5) Full backup of i-MSCP (experimental)
6) Full restore of i-MSCP (experimental)
7) Exit the installer'
read -p "Enter your choice [1-7] " choice
# Installation of a version
if [ $choice -eq 1 ] ; then
    #==== Start i-MSCP installer ====
	apt update && apt -y dist-upgrade
    apt -y install bzip2 wget tar unzip ca-certificates xz-utils
	clear
	if [ -f /usr/local/src/imscp/imscp-$version/imscp-autoinstall || /usr/local/src/imscp/imscp-$trunkver.x/imscp-autoinstall ]; then
		echo "Installation file exists"
	else
		mkdir -p /usr/local/src/imscp
		cd /usr/local/src/imscp
		case $version in
		'master') apt install git 
		mkdir imscp-$version 
		cd imscp-$version
		git clone https://github.com/appstars-dev/imscp.git;;
		'trunk')
			echo '#### Your trunk version is' $trunkver'.x ####';
			wget https://github.com/appstars-dev/imscp/archive/$trunkver.x.zip
			unzip $trunkver.x.zip
			cd imscp-$trunkver.x ;;

		'1.2.'*|'1.3.'*|'1.4.'*|'1.5.'*|'2.0.'*)
			echo '#### DOWNLOADING the latest i-MSCP version ####'
			wget https://github.com/appstars-dev/imscp/archive/$version.tar.gz
			tar xvfz $version.tar.gz
			cd imscp-$version;;
			esac
		clear
		
		perl imscp-autoinstall "$@"
	fi
    exit
	# Redownload i-MSCP
elif [ $choice -eq 2 ] ; then
	rm -fR /usr/local/src/imscp/
    mkdir -p /usr/local/src/imscp
    cd /usr/local/src/imscp
    apt update && apt -y dist-upgrade
    apt -y install bzip2 wget tar ca-certificates xz-utils
case $version in
		'master') apt install git 
		mkdir imscp-$version 
		cd imscp-$version
		git clone https://github.com/appstars-dev/imscp.git;;
		'trunk')
			echo '#### Your trunk version is' $trunkver'.x ####';
			wget https://github.com/appstars-dev/imscp/archive/$trunkver.x.zip
			unzip $trunkver.x.zip
			cd imscp-$trunkver.x ;;
		'1.2.'*|'1.3.'*|'1.4.'*|'1.5.'*|'2.0.'*)
			echo '#### DOWNLOADING the latest i-MSCP version ####'
			wget https://github.com/appstars-dev/imscp/archive/$version.tar.gz
			tar xvfz $version.tar.gz
			cd imscp-$version;;
			esac
    #==== Start i-MSCP installer ====
    perl imscp-autoinstall -r "$@"
    exit
	# Uninsall i-MSCP
elif [ $choice -eq 3 ] ; then
	rm -fR /usr/local/src/imscp/
	mkdir -p /usr/local/src/imscp
    cd /usr/local/src/imscp
    apt update && apt -y safe-upgrade
    apt -y install bzip2 wget tar ca-sertificates xz-utils
case $version in
		'master') apt install git 
		mkdir imscp-$version 
		cd imscp-$version
		git clone https://github.com/appstars-dev/imscp.git;;
		'trunk')
			echo '#### Your trunk version is' $trunkver'.x ####';
			wget https://github.com/appstars-dev/imscp/archive/$trunkver.x.zip
			unzip $trunkver.x.zip
			cd imscp-$trunkver.x ;;

		'1.2.'*|'1.3.'*|'1.4.'*|'1.5.'*|'2.0.'*)
			echo '#### DOWNLOADING the latest i-MSCP version ####'
			wget https://github.com/appstars-dev/imscp/archive/$version.tar.gz
			tar xvfz $version.tar.gz
			cd imscp-$version;;
			esac
			
    #==== Start i-MSCP installer ====
    perl imscp-autoinstall -d "$@"
    exit
		# Uninstall i-MSCP
elif [ $choice -eq 4 ] ; then
	echo '#### UNINSTALLING an i-MSCP ####'
	read -p "Continue (y/n)?" choice
	case "$choice" in 
	y|Y ) 	cd /var/www/imscp/engine/setup
			perl imscp-uninstall
			exit;;
	n|N ) echo "no";;
	* ) echo "invalid";;
	esac
elif [ $choice -eq 5 ] ; then
	echo '#### Backuping an i-MSCP ####'
	read -p 'Anonymus root login [Y/n]' anonsql
	apt -y install bzip2 xz-utils
	mkdir /tmp/imscpbkp
	cd /tmp/imscpbkp
	case "$anonsql" in
	n|N ) 	read -p 'Please enter the superuser login [root]: ' myuser
			if [ -z $myuser ]; then myuser="root"
			fi
			read -p 'Please enter the MySQL superuser password: ' mypass
			mysqldump -u $myuser --password=$mypass --all-databases > imscp.sql;;
	* ) mysqldump --all-databases > imscp.sql;;
	esac
	tar cvfJ www.txz /var/www/virtual
	tar cvfJ mail.txz /var/mail/virtual
	tar cvfJ config.txz /etc/imscp 
	cd ..
	tar cvf imscp.bkp imscpbkp
	cp imscp.bkp /root/imscp.bkp
	cd /root
	clear
	echo Take it from root directory
	exit
elif [ $choice -eq 6 ] ; then
	echo '#### Restoring an i-MSCP ####'
	read -p 'Please enter the superuser login [root]: ' myuser
	if [ -z $myuser ]; then myuser="root"
	fi
	read -p 'Please enter the MySQL root password: ' mypass
	apt -y install bzip2 xz-utils
	mkdir /tmp/imscpbkp
	cp /root/imscp.bkp /tmp/imscp.bkp
	cd /tmp
	tar xvf imscp.bkp
	cd /tmp/imscpbkp
	tar xvfJ www.txz -C /
	tar xvfJ mail.txz -C /
	tar xvfJ config.txz -C / 
	mysql -u $myuser --password=$mypass < imscp.sql
	rm -f /root/imscp.bkp
	cd /root
	clear
	echo Restoring complete
	exit
else
exit
fi