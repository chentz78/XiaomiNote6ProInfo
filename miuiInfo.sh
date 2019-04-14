#!/bin/bash

#ikconfig from https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-ikconfig
#unpackbooimg from https://github.com/osm0sis/mkbootimg

fr=$1
if [ ! -f "$fr" ]; then
  echo "Arquivo invalido!"
fi

DT=`date +'%d%H%M%S'`
tf="/tmp/miui_$DT"

#echo "Criando pasta temp $tf ..."
mkdir $tf
openssl md5 $fr
unzip -d $tf $fr boot.img META-INF/com/android/metadata firmware-update/NON-HLOS.bin

cf=$PWD
cd $tf

unpackbootimg -i boot.img
echo 
cat META-INF/com/android/metadata

tsb=`grep 'post-timestamp' META-INF/com/android/metadata | cut -d '=' -f 2`
echo -e "Build Date:\c" 
date -d "@$tsb"
ikconfig.sh boot.img-zImage | head -3 | tail -1

#Extract Firmware info
echo -e "\nExtraindo informacao firmware:"
echo
mkdir tmpfw
sudo mount -ro loop firmware-update/NON-HLOS.bin tmpfw

if [ -f "tmpfw/verinfo/ver_info.txt" ]; then #Miui baseada em Android 8.1
  cat tmpfw/verinfo/ver_info.txt
else #Android 9
  dd if=tmpfw/image/mba.mbn bs=1 status=none skip=$((0x0002e200)) count=400 | grep -a -o 'MPSS.*modem' | cut -d '/' -f1
fi
sudo umount tmpfw

cd $cf

#echo "\nExcluindo $tf ..."
rm -rf $tf