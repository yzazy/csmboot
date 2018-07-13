#!/bin/bash
### Update nodeservice 
/bin/lsblk -n -d|grep -v rom|awk '{print $1}'>/tmp/lsblk1
####Check if SSD Disk not mounted
while read line
do
   tmp=`cat /sys/block/$line/queue/rotational`
   if [ $tmp -eq 0 ]; then
       if /bin/lsblk -o NAME,FSTYPE,MOUNTPOINT | grep $line | grep "/" > /dev/null ; then 
          sleep 1
       else
          disk=/dev/$line
       fi
   fi
done</tmp/lsblk1

if [ -z $disk ]; then /usr/bin/zenity --info --title "SSD Initial" --text="You just have 1 SSD Drive, and you used it";
else
###Ask that User want to use SSD Disk or not
   /usr/bin/zenity --question --title "SSD Initial" --text="A SSD Disk is not mounted, Do you want to use it?"
   if [ $? -eq 1 ]; then sleep 1;
   else
###Detect Disk
      while true; do
         input=$(/usr/bin/zenity --entry --title "SSD Initial" --text="Physical Device of Addition SSD Disk?" --entry-text="$disk")
         tmp=`echo $input |sed "s/\/dev\///"`
         if /bin/lsblk -o NAME,FSTYPE,MOUNTPOINT | grep $tmp | grep "/" > /dev/null ; then
	    echo /bin/lsblk -o NAME,FSTYPE,MOUNTPOINT | grep $input | grep "/"
            /usr/bin/zenity --question --title "SSD Initial" --text="$input is mounted, Are you sure to use this Disk, $input will be formatted?"
         else
            /usr/bin/zenity --question --title "SSD Initial" --text="$input will be formatted, Are you sure?"
         fi
         if [ $? -eq 0 ]; then break; fi
      done
###Format Disk
      (echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo 4; echo n; echo p; echo 1; echo; echo; echo w;)|fdisk $input
      /sbin/mkfs.ext4 "$input"1
      mountpoint=$(/usr/bin/zenity --entry --title "SSD Initial" --text="Mount Point?" --entry-text="/writeback2")
      mkdir -p $mountpoint
      mount "$input"1 $mountpoint
#     Add ssd csmboot2.0 
#     cat /etc/mtab |grep $input>>/etc/fstab
      sed -i 's/exit 0//g' /etc/rc.local
      echo "mount -o discard,defaults "$input"1 $mountpoint" >> /etc/rc.local
      echo "" >> /etc/rc.local
      echo "exit 0" >> /etc/rc.local
      sync; echo 3 > /proc/sys/vm/drop_caches
      /usr/bin/zenity --info --title "SSD Initial" --text="Addition SSD Disk is Added, Mount Point $mountpoint"
   fi
fi
