#!/bin/bash

#Reach out to @MakMahlawat for any issues.

# Step 1 = Determines the OS Distribution
# Step 2 = Determines the OS Version ID
# Step 3 = Downloads Zabbix-Agent Repository & Installs the Zabbix-Agent
# Step 4 = Update Zabbix-Agent Config, Enable Service to auto start post Boot & Restart Zabbix-Agent
# Step 5 = Installation Completion Greeting


function editzabbixconf()
{
echo ========================================================================
echo Step 3 = Downloading Zabbix Repository and Installing Zabbix-Agent	
echo !! 3 !! Zabbix-Agent Installed
echo ========================================================================

# mv /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.original
# cp /etc/zabbix/zabbix_agent2.conf.original /etc/zabbix/zabbix_agent2.conf	
sed -i "s+Server=127.0.0.1+Server=10.243.100.241+g" /etc/zabbix/zabbix_agent2.conf
sed -i "s+ServerActive=127.0.0.1+ServerActive=10.243.100.241+g" /etc/zabbix/zabbix_agent2.conf
sed -i "s+Hostname=Zabbix server+Hostname=$(hostname)+g" /etc/zabbix/zabbix_agent2.conf
sed -i 's/# HostMetadata=/HostMetadata=Linux/g' /etc/zabbix/zabbix_agent2.conf
sed -i "s/# HostInterface=/HostInterface=$(ip -o -4 addr show scope global | awk '{split($4,a,"/");print a[1];exit}';)/g" /etc/zabbix/zabbix_agent2.conf
# sed -i "s+# Timeout=3+Timeout=30+g" /etc/zabbix/zabbix_agent2.conf

echo ========================================================================
echo Step 4 = Working on Zabbix-Agent Configuration
echo !! 4 !! Updated Zabbix-Agent conf file at /etc/zabbix/zabbix_agent2.conf
echo !! 4 !! Enabled Zabbix-Agent Service to Auto Start at Boot Time
echo !! 4 !! Restarted Zabbix-Agent post updating conf file
echo ========================================================================
}


function ifexitiszero()
{
if [[ $? == 0 ]];
then editzabbixconf
else echo :-/ Failed at Step 3 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0

fi
}


function rhel8()
{
rpm -Uvh http://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function rhel7()
{
rpm -Uvh http://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function rhel6()
{
rpm -Uvh http://repo.zabbix.com/zabbix/5.0/rhel/6/x86_64/zabbix-release-5.0-1.el6.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
chkconfig zabbix-agent on
service zabbix-agent restart
}

function rhel5()
{
rpm -Uvh http://repo.zabbix.com/zabbix/4.4/rhel/5/x86_64/zabbix-agent-4.4.9-1.el5.x86_64.rpm
ifexitiszero
chkconfig zabbix-agent on
service zabbix-agent restart
}

function ubuntu22()
{
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update
apt install zabbix-agent2 zabbix-agent2-plugin-*
ifexitiszero
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
}

function ubuntu20()
{
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
apt update
apt install zabbix-agent2 zabbix-agent2-plugin-*
ifexitiszero
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
}

function ubuntu18()
{
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu18.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu18.04_all.deb
apt update
apt install zabbix-agent2 zabbix-agent2-plugin-*
ifexitiszero
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
}

function debian11()
{
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
dpkg -i zabbix-release_6.4-1+debian11_all.deb
apt update
apt install zabbix-agent2 zabbix-agent2-plugin-*
ifexitiszero
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
}

#VERSION ID FUNCTION'S LISTED BELOW


function version_id_centos()
{
c1=$(cat /etc/redhat-release)
echo !! 2 !! OS Version determined as $c1

if [[ $c1 == *"8."* ]];     then rhel8
elif [[ $c1 == *"7."* ]];   then rhel7
elif [[ $c1 == *"6."* ]];   then rhel6
elif [[ $c1 == *"5."* ]];   then rhel5
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}

function version_id_ubuntu()
{
u1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $u1  #prints os version id like this : VERSION_ID="8.4"

u2=$(echo $u1 | cut -c13- | rev | cut -c2- |rev)
#echo $u2        #prints os version id like this : 8.4

u3=$(echo $u2 | awk '{print int($1)}')
#echo $u3       #prints os version id like this : 8

if [[ $u3 -eq 22 ]];      then ubuntu22
elif [[ $u3 -eq 20 ]];    then ubuntu20
elif [[ $u3 -eq 18 ]];    then ubuntu18
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}


function version_id_debian()
{
d1=$(cat /etc/os-release | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $d1  #prints os version id like this : VERSION_ID="8.4"

d2=$(echo $d1 | cut -c13- | rev | cut -c2- |rev)
#echo $d2        #prints os version id like this : 8.4

d3=$(echo $d2 | awk '{print int($1)}')
#echo $d3       #prints os version id like this : 8

if [[ $d3 -eq 11 ]];     then debian11
#else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
else debian11
fi
}

function version_id_amazon()
{
d1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $d1  #prints os version id like this : VERSION_ID="8.4"

d2=$(echo $d1 | cut -c13- | rev | cut -c2- |rev)
#echo $d2        #prints os version id like this : 8.4

d3=$(echo $d2 | awk '{print int($1)}')
#echo $d3       #prints os version id like this : 8

if [[ $d3 -eq 2 ]];     then rhel8

else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}


#STEP 1 - SCRIPT RUNS FROM BELOW


echo Starting Zabbix-Agent Installation Script
echo ========================================================================
echo Step 1 = Determining OS Distribution Type

if [[ $(cat /etc/redhat-release) == *"CentOS"*  ]]
	then echo !! 1 !!  OS Distribution determined as CentOS Linux
	echo Step 2 = Determining OS Version ID now
	version_id_centos

elif [[ $(cat /etc/*release*) == *"Amazon Linux"*  ]]
        then echo !! 1 !!  OS Distribution determined as Amazon Linux
        echo Step 2 = Determining OS Version ID now
        version_id_amazon

elif [[ $(cat /etc/*release*) == *"ubuntu"* ]];
	then echo !! 1 !! OS Distribution determined as Ubuntu Linux
	echo Step 2 = Determining OS Version ID now
        version_id_ubuntu

elif [[ $(cat /etc/*release*) == *"debian"* ]];
	then echo !! 1 !! OS Distribution determined as Debian Linux
	echo Step 2 = Determining OS Version ID now
        version_id_debian

else echo :-/ Failed at Step 1 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi



#STEP 5
echo ========================================================================
echo Congrats. Zabbix-Agent Installion is completed successfully.
echo Zabbix-Agent is installed, started and enabled to be up post reboot on this machine.
echo You can now add the host $(hostname -f) with IP $(hostname -i) on the Zabbix-Server Front End.
echo Thanks for using Mak Mahlawat"'"s zabbix-agent installation script.
echo ========================================================================
echo To check zabbix-agent service status, you may run : service zabbix-agent status
echo To check zabbix-agent config, you may run : egrep -v '"^#|^$"' /etc/zabbix/zabbix_agent2.conf
echo To check zabbix-agent logs, you may run : tail -f /var/log/zabbix/zabbix_agent2.log
echo ========================================================================
