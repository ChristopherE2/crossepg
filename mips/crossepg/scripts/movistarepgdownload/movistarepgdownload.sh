#!/bin/sh
# ---------------------
#
# Puerto del WebIf
#     Indica en PORTWEBIF el puerto que utilices
#     Ejemplo: PORTWEBIF="8123"
PORTWEBIF=""

# Password de root
#     Indica en PASSROOT tu password de root
#     Ejemplo: PASSROOT="mipass"
PASSROOT=""
#
# ---------------------
rm -rf /media/usb/epg.dat
rm -rf /media/hdd/epg.dat
rm -rf /media/usb/crossepg
rm -rf /media/hdd/crossepg
		
URL="localhost"

if [ "$PASSROOT" != "" ]; then
    URL=root:$PASSROOT@$URL
fi

if [ "$PORTWEBIF" != "" ]; then
    URL=$URL:$PORTWEBIF
fi

PATHMHW2=/usr/crossepg/scripts/movistarepgdownload

# obtiene estado inicial del receptor
INSTANDBY="$(wget -Y off -O- -q http://$URL/web/powerstate | grep e2instandby | sed 's/<e2instandby>//' | sed 's/<\/e2instandby>//' | sed '/^\s*$/d'  |  sed 's/[ \t\n\l]*$//')"
CURRENTCHANNEL="$(wget -Y off -O- -q http://$URL/web/subservices | grep e2servicereference | sed 's/<e2servicereference>//' | sed 's/ //' | sed 's/<\/e2servicereference>//' | sed 's/\t//g')"    

# zap a canal datos EPG
REFCHANEPG=$1
wget -Y off -O- -q http://$URL/web/zap?sRef=$REFCHANEPG > /dev/null

sleep 1

# Ejecutar movistarepgdownload
$PATHMHW2/movistarepgdownload $2

sleep 1

# si es correcto zap a canal anterior
if [ "$CURRENTCHANNEL" != "N/A" ]; then
	 wget -Y off -O- -q http://$URL/web/zap?sRef=$CURRENTCHANNEL > /dev/null
fi		

# si estaba en estado STANDBY vuelve para parar la decodificacion
if [ "$INSTANDBY" == "true" ]; then
    wget -Y off -O- -q http://$URL/web/powerstate?newstate=5 > /dev/null
fi

sleep 1

