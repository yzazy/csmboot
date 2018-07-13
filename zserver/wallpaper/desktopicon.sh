#!/usr/bin/env bash
cat /etc/passwd | awk -F ":" '{if ($3 >= 1000) print $1}' | while read line;
do
cp -f /zserver/wallpaper/*.desktop /root/Desktop/
if [ -d /home/$line ];then
sleep 3
cp -f /zserver/wallpaper/*.desktop /home/$line/Desktop/;
fi ;
done
