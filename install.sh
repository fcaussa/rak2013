#!/bin/sh
# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi


echo "\n\n Intalling Rak2013 LTE Module"

#$1 => APN 
#$2 => Serial Port: /dev/ttyS0
#$3 => baudrate: 115200

#$4: pin5
#$5: pin6
#$6: pin13
#$7: pin18
#$8: pin19
#$9: pin21
#$10: pin26

echo "Updating repositories..."

apt update

echo "Install ppp"

apt-get install ppp

#echo "creating directories"
#mkdir -p /etc/chatscripts
#mkdir -p /etc/ppp/peers

#Delete folder and content if already exists!
rm -rf /usr/local/rak 2>/dev/null

rm /etc/chatscripts/quectel-chat-connect 2>/dev/null

rm /etc/chatscripts/quectel-chat-disconnect 2>/dev/null

rm /etc/ppp/peers/gprs 2>/dev/null

mkdir -p /usr/local/rak

echo "creating script file : /etc/chatscripts/quectel-chat-connect"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK ATE0
OK ATI;+CSUB;+CSQ;+COPS?;+CGREG?;&D2
# Insert the APN provided by your network operator, default apn is $1
OK AT+CGDCONT=1,\"IPV4V6\",\"\",\"0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0\",0,0,0,0
OK ATD*99#
CONNECT" > /etc/chatscripts/quectel-chat-connect


echo "creating script file : /etc/chatscripts/quectel-chat-disconnect"
echo "
ABORT \"ERROR\"
ABORT \"NO DIALTONE\"
SAY \"\nSending break to the modem\n\"
""  +++
""  +++
""  +++
SAY \"\nGoodbay\n\"" > /etc/chatscripts/quectel-chat-disconnect


echo "creating script file : /etc/ppp/peers/gprs"
echo "
#/dev/ttyS0 115200
$2 $3
# The chat script, customize your APN in this file
connect 'chat -s -v -f /etc/chatscripts/quectel-chat-connect -T $1'
# The close script
disconnect 'chat -s -v -f /etc/chatscripts/quectel-chat-disconnect'
# Hide password in debug messages
hide-password
# The phone is not required to authenticate
noauth
# Debug info from pppd
debug
# If you want to use the HSDPA link as your gateway
defaultroute
# pppd must not propose any IP address to the peer
noipdefault
# No ppp compression
novj
novjccomp
noccp
ipcp-accept-local
ipcp-accept-remote
local
# For sanity, keep a lock on the serial line
lock
modem
dump
nodetach
# Hardware flow control
nocrtscts
remotename 3gppp
ipparam 3gppp
ipcp-max-failure 30
# Ask the peer for up to 2 DNS server addresses

usepeerdns" > /etc/ppp/peers/gprs


pin5=$4
pin6=$5
pin13=$6
pin18=$7
pin19=$8
pin21=$9
pin26=${10}


echo "
#!/bin/sh

#Controller is gpio512
#inputs must be 512 + pin number
# 5     -> 517
# 6     -> 518
# 13    -> 525
# 19    -> 531
# 21    -> 533
# 26    -> 538

# 18 (PWR)-> 530

cleanup_gpio()
{
    if [ -d /sys/class/gpio/gpio\$1 ]
    then
        echo \"\$1\" > /sys/class/gpio/unexport; sleep 0.2
    fi
}

cd /sys/class/gpio/

if [ ! -d /sys/class/gpio/gpio$pin5 ]; then
    echo 517 > export
fi

if [ ! -d /sys/class/gpio/gpio$pin6 ]; then
    echo 518 > export
fi

if [ ! -d /sys/class/gpio/gpio$pin13 ]; then
    echo 525 > export
fi

if [ ! -d /sys/class/gpio/gpio$pin19 ]; then
    echo 531 > export
fi

if [ ! -d /sys/class/gpio/gpio$pin21 ]; then
    echo 533 > export
fi

if [ ! -d /sys/class/gpio/gpio$pin26 ]; then
    echo 538 > export
fi


echo out > gpio$pin5/direction
echo out > gpio$pin6/direction
echo out > gpio$pin13/direction
echo out > gpio$pin19/direction
echo in > gpio$pin21/direction
echo out > gpio$pin26/direction

echo 0 > gpio$pin5/value
echo 0 > gpio$pin6/value
echo 0 > gpio$pin13/value
echo 0 > gpio$pin21/value
echo 0 > gpio$pin26/value


#
cd /sys/class/gpio/

if [ ! -d /sys/class/gpio/gpio$pin18 ]; then
    echo \"$pin18\" > /sys/class/gpio/export
fi
echo \"out\" > /sys/class/gpio/gpio$pin18/direction
echo 0 > /sys/class/gpio/gpio$pin18/value
sleep 0.2
echo 1 > /sys/class/gpio/gpio$pin18/value
sleep 0.2
echo 0 > /sys/class/gpio/gpio$pin18/value

sleep 20

sudo pppd call gprs &

sleep 10

route add default ppp0

" > /usr/local/rak/activate_lte



echo "*********************************************************"
echo "*  The RAKwireless for RAK2013 is successfully installed!   *"
echo "*********************************************************"

echo "\n\n Please reboot board!"
