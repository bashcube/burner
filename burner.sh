#!/bin/bash

URL=""
USB=""
ISO_PATH=""
ISO_URL=""

get_fedora() {
read -p "DOWNLOAD FEDORA(Y/n): " choice
if [ "$choice" = "Y" ]
then
 curl $ISO_URL > source.html
 echo
 cat source.html | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' >> urls.txt 
 input="urls.txt"
 while IFS= read -r line
 do
   if [[ "$line" == *iso ]]
   then
    URL=$line
    break
   fi
   done < "$input"
   rm -rf urls.txt
   rm -rf source.html
 echo "DOWNLOADING FEDORA ISO...................."
 echo
 wget $URL
 ISO_PATH="$(ls | grep 'Fedora')"
 else
  echo "CANCELLING INSTALLATION."
  exit
 fi
}

chk_usb() {
echo "Detecting USB DRIVE...................."
CHK="$(ls /dev/sd* | awk '{print $1}' | awk 'NR==1 {first = $0} END {print;}')"
echo "Found USB DRIVE...................."$CHK
USB=$CHK
}

chk_sum(){
echo "CREATING CHECKSUM...................."
sha256sum $ISO_PATH > chksum.txt
echo "VERIFYING CHECKSUM...................."
if [[ "$(sha256sum --check test.txt)" == *OK ]]
then
  echo "CHECKSUM VERIFIED...................."
  echo "THE SCRIPT CAN CONTINUE...................."
  rm -rf chksum.txt
else
  echo "COULD NOT VERIFY THE CHECKSUM...................."
  echo "EXITING NOW...................."
  rm -rf chksum.txt
  exit
fi
}

burn_usb() {
echo "BURNING THE ISO TO THE USB DRIVE...................."
dd bs=4M if=$ISO_PATH of=$USB status=progress oflag=sync
}

copy_iso() {
echo "FORMATTING USB_DRIVE...................."
DRIVE="$(echo $USB | cut -c1-8 )"
echo $DRIVE
mkfs.fat -F32 -I $DRIVE
NAME="$(ls /media/$USER/)"
7z x $ISO_PATH -o/media/$USER/$DRIVE"/"
}

umount_usb() {
echo "UMOUNTING DISK...................."
umount $USB
}

banner() {
echo ' ___ ____   ___        ____  _   _ ____  _   _ _____ ____'
echo '|_ _/ ___| / _ \      | __ )| | | |  _ \| \ | | ____|  _ \'
echo ' | |\___ \| | | |_____|  _ \| | | | |_) |  \| |  _| | |_) |'
echo ' | | ___) | |_| |_____| |_) | |_| |  _ <| |\  | |___|  _ <'
echo '|___|____/ \___/      |____/ \___/|_| \_\_| \_|_____|_| \_\'
echo
}

menu() {
 clear
  banner
  echo "CHOOSE FROM THE LIST GIVEN: "
  echo "1.FEDORA"
  echo "2.KDE-PLASMA FEDORA"
  echo "3.XFCE FEDORA"
  echo "4.LXQT FEDORA"
  echo "5.MATE-COMPIZ FEDORA"
  echo "6.CINNAMON FEDORA"
  echo "7.LXDE FEDORA"
  echo "8.SOAS FEDORA"
  read -p "ENTER CHOICE: " CHOICE
  if [ "$CHOICE" = "1" ]
  then
    ISO_URL=' https://getfedora.org/en/workstation/download/'
  fi
  if [ "$CHOICE" = "2" ]
  then
    ISO_URL='https://spins.fedoraproject.org/kde/download/index.html'
  fi
  if [ "$CHOICE" = "3" ]
  then
    ISO_URL='https://spins.fedoraproject.org/xfce/download/index.html'
  fi
  if [ "$CHOICE" = "4" ]
  then
    ISO_URL='https://spins.fedoraproject.org/lxqt/download/index.html'
  fi
  if [ "$CHOICE" = "5" ]
  then
    ISO_URL='https://spins.fedoraproject.org/mate-compiz/download/index.html'
  fi
  if [ "$CHOICE" = "6" ]
  then
    ISO_URL='https://spins.fedoraproject.org/cinnamon/download/index.html'
  fi
  if [ "$CHOICE" = "7" ]
  then
    ISO_URL='https://spins.fedoraproject.org/lxde/download/index.html'
  fi
  if [ "$CHOICE" = "8" ]
  then
    ISO_URL='https://spins.fedoraproject.org/soas/download/index.html'
  fi
  get_fedora
  chk_sum
  chk_usb
  read "DOES YOUR SYSTEM SUPPORT UEFI(Y/n): " UCHOICE
  if [ $UCHOICE = "Y"]
  then
    copy_iso
  fi
  if [ $UCHOICE = "n"]
  then
    burn_usb
  fi
  umount_usb
 clear
}

menu
