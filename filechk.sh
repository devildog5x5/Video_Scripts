#!/bin/sh
#Author:Robert Foster
#Date:01/24/2021
#Set Directory Locations
#LDATE=2020
date >> error.log
VIDEO_DIR=/media/lvt-linux/LVT_DAT_RW/video_archive
#VIDEO_DIR=/home/rfoster/Desktop/tdata/LVT_DAT_RW/video_archive_bad
#VIDEO_DIR=/home/lvt-linux/LVT_DAT_RW/video_archive
#VIDEO_DIR=/home/lvt-linux/LVT_DAT_RW/video_archive_mix
#VIDEO_DIR=/home/lvt-linux/LVT_DAT_RW/video_archive_bad
#yourfilenames=`ls $VIDEO_DIR/*.mp4`
echo $yourfilenames
yourfilenames=`find $VIDEO_DIR`
#yourfilenames=find $VIDEO_DIR/ -name '*.mp4'
for eachfile in $yourfilenames
do
   echo $eachfile
ffmpeg -v error -i $eachfile -f null - 2>>error.log
done
date >> error.log
