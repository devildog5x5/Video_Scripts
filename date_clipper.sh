#!/bin/bash
#Author:Robert Foster
#Date:01/15/2021
#Color Text Output Schema.
#echo -e "\e[31mPLACE TEXT HERE.\e[0m"
#echo -e "\e[32mPLACE TEXT HERE.\e[0m"
#UpdateLog
#Update:01/15/2021 Help the user find the oldest and newest files in preparation for running clipper.sh.
PARAM_1=00
PARAM_2=00
PARAM_3=00
PARAM_4=00
PPARAM=
pwd > PPARAM.txt
PPARAM="$(< PPARAM.txt)"
echo -e "\e[32mThese are the first two parameters, or OLDEST date you can use.\e[0m"
ls -lt /media/lvt-linux/LVT_DAT_RW/video_archive/ | tail -1 | awk -F'[_.]' '{print $2}' > PARAM_1.txt
PARAM_1="$(< PARAM_1.txt)"
ls -lt /media/lvt-linux/LVT_DAT_RW/video_archive/ | tail -1 | awk -F'[_.]' '{print $3}' > PARAM_2.txt
cat PARAM_2.txt | cut -b -4 PARAM_2.txt > PARAM_2a.txt 
mv PARAM_2a.txt PARAM_2.txt
PARAM_2="$(< PARAM_2.txt)"
echo $PARAM_1 $PARAM_2
echo -e "\e[32mThese are the third and fourth parameter or NEWEST date you can use.\e[0m"
ls -ltr /media/lvt-linux/LVT_DAT_RW/video_archive/ | tail -1 | awk -F'[_.]' '{print $2}' > PARAM_3.txt
PARAM_3="$(< PARAM_3.txt)"
ls -ltr /media/lvt-linux/LVT_DAT_RW/video_archive/ | tail -1 | awk -F'[_.]' '{print $3}' > PARAM_4.txt
cat PARAM_4.txt | cut -b -4 PARAM_4.txt > PARAM_4a.txt 
mv PARAM_4a.txt PARAM_4.txt
PARAM_4="$(< PARAM_4.txt)"
echo $PARAM_3 $PARAM_4

echo -e "\e[32mSo your clippit.sh command is:\e[0m"
echo -e "\e[29m$PPARAM/clippit.sh $PARAM_1 $PARAM_2 $PARAM_3 $PARAM_4\e[0m"
echo -e "\e[32mUse this as a baseline, or starting point in your video search.\e[0m"
rm PARAM_1.txt
rm PARAM_2.txt
rm PARAM_3.txt
rm PARAM_4.txt
rm PPARAM.txt
