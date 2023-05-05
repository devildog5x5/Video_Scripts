#!/bin/bash 
#Author:Robert Foster 
#Date:11/04/2020 
#Color Text Output Schema.
#Code	Color		Example					Preview
#31	Red		echo -e "Default \e[31mRed"		Default Red
#32	Green		echo -e "Default \e[32mGreen"		Default Green
#33	Yellow		echo -e "Default \e[33mYellow"		Default Yellow
#34	Blue		echo -e "Default \e[34mBlue"#		Default Blue
#35	Magenta		echo -e "Default \e[35mMagenta"		Default Magenta
#36	Cyan		echo -e "Default \e[36mCyan"		Default Cyan
#37	Light gray	echo -e "Default \e[37mLight gray"	Default Light gray
#90	Dark gray	echo -e "Default \e[90mDark gray"	Default Dark gray
#91	Light red	echo -e "Default \e[91mLight red"	Default Light red
#92	Light green	echo -e "Default \e[92mLight green"	Default Light green
#93	Light yellow	echo -e "Default \e[93mLight yellow"	Default Light yellow
#94	Light blue	echo -e "Default \e[94mLight blue"	Default Light blue
#95	Light magenta	echo -e "Default \e[95mLight magenta"	Default Light magenta
#96	Light cyan	echo -e "Default \e[96mLight cyan"	Default Light cyan
#97	White 		echo -e "Default \e[97mWhite"		Default White
#echo -e "\e[31mPLACE TEXT HERE.\e[0m"
#echo -e "\e[32mPLACE TEXT HERE.\e[0m"
#UpdateLog
#Update:01/14/2021 Move all processing data to the removeable, processing SSD and add intercept for Crl C and final cleanup on event. Less likely to run out of space for video data.
#Update:01/13/2020 Color messages for output to user, and validate that myfile.txt is not null or zero byte in size, meaning there is data in the selected timeline. If null then red message gives user some added guidance.
#Update:11/20/2020 Added some logic to ensure that the SSD is installed and recognized.
#Update:Added some use input checking to ensure that the camera ID presented and the user input entered match the camera ID in the array before further processing.
#Description: clippit.sh start_date(YYYYMMDD) start_time(HHMM) end_date(YYYYMMDD) end_time(HHMM) 
#Example: ./clippit.sh 20201102 0000 20201102 0010 
        echo "Subtract 13 hours from your target date/time"
#Set Directory Locations
VIDEO_DIR=/media/lvt-linux/LVT_DAT_RW/video_archive
PROCESS_DIR=/media/lvt-linux/xfer/Processing
#Check to see the directory exists
	if [ ! -d $VIDEO_DIR ] 
		then
		echo -e "\e[31mError: Directory $VIDEO_DIR does not exists.\e[0m"
		echo -e "\e[31mPlease plug the SSD drive into the Lenovo ThinkCentre USB port.\e[0m"
		exit	
		else
		echo -e "\e[32mThe SSD appears to be plugged in and ready.\e[0m"
#Change to the working directory
	cd $VIDEO_DIR 
	fi
#Create the list of files and then cut the file off at the first "_", then sort the list for unique values.
###	ls > "$PROCESS_DIR/mycamlist.txt"
	find $VIDEO_DIR -type f -printf "%f\n" > $PROCESS_DIR/mycamlist.txt
	cat $PROCESS_DIR/mycamlist.txt | cut -f1 -d"_" | sort | uniq > $PROCESS_DIR/mycams.txt
	echo "Here is your camera list:"
#Show the list of camera numbers
	cat $PROCESS_DIR/mycams.txt
#Get input from the user.
	echo "Enter The Camera ID you want:"
	read
	CAMID="$REPLY"
#Create an array from the camera file and use it to validate user input. 
        IFS=$'\n' read -d '' -r -a lines < $PROCESS_DIR/mycams.txt
#Ensure the camera ID is in the list of camera ID's.
        if [[ " ${lines[@]} " =~ " ${CAMID} " ]]; then
		echo -e "\e[32mSUCCESS: The number you entered is in the camera id list.\e[0m"; else
		echo -e "\e[31mFAILURE!: The camera ID entered is NOT in the camera ID list.\e[0m"
		exit
        fi
#Cleanup created files to this point.
	cd $PROCESS_DIR 
	rm -irf mycamlist.txt
	rm -irf mycams.txt
#Create a new destination directory
        mkdir  $CAMID-$1$2-$3$4
	echo "Making this directory:" $CAMID-$1$2-$3$4
#Change to the current working directory
	cd $PROCESS_DIR/$CAMID-$1$2-$3$4
	echo Preparing files for concatenation.
#Create list of files for manipulation
#build_video_list
	find $VIDEO_DIR -type f -newermt $1T$2 \! -newermt $3T$4 > $1$2-$3$4mylist.txt
# then sort on unique value.
#Cut the cameras out that you don't want to see video from.
	sed "/$CAMID/!d;" $1$2-$3$4mylist.txt > $1$2-$3$4mylist.txt.$$ && mv -f $1$2-$3$4mylist.txt.$$ $1$2-$3$4mylist.txt
#Copy matching files to the new_directory 
	cd $PROCESS_DIR 
	cat $CAMID-$1$2-$3$4/$1$2-$3$4mylist.txt | xargs -I% cp % $CAMID-$1$2-$3$4
#Give rw permissions to all copied files
###        chmod 666 $CAMID-$1$2-$3$4/*.mp4
#THIS WORKED!	find | xargs chmod 666
###        chmod 666 $CAMID-$1$2-$3$4/*.mp4
	find $CAMID-$1$2-$3$4/*.mp4 | xargs chmod 666
#Create your list of video files.
###	ls $CAMID-$1$2-$3$4/*.mp4 > myfile.txt
	find $CAMID-$1$2-$3$4 -type f -printf "%f\n" > myfile.txt
#Verify that there is content and that myfile.txt is not empty.
        if [ ! -s myfile.txt ]
        	then
		echo -e "\e[31mError: No content found within the timeframe on the camera selected.\e[0m"
		echo -e "\e[31mChange the date/time parameters to a date/time that has video content.\e[0m"
#Cleanup if we are going to exit
		cd $PROCESS_DIR 
		rm -irf $CAMID-$1$2-$3$4/*.mp4
		rm -irf $CAMID-$1$2-$3$4/$1$2-$3$4mylist.txt
		rm -irf myfile.txt
		rmdir $CAMID-$1$2-$3$4
		exit
        	else
        	echo "Concatenating video content from disk, please wait..."
        fi
#Create the list of files to paste together
	find $CAMID-$1$2-$3$4/*.mp4 -printf "file '%p'\n" > myfile.txt
TIMEFORMAT='It took %R seconds to complete this task...'
time {
#Will produce Parameters_out.mp4 and cleanup
        ffmpeg -f concat -safe 0 -i myfile.txt -c copy $PROCESS_DIR/$CAMID-$1$2-$3$4_out.mp4
#Cleanup
	cd $PROCESS_DIR 
	rm -irf $CAMID-$1$2-$3$4/*.mp4
	rm -irf $CAMID-$1$2-$3$4/$1$2-$3$4mylist.txt
	rm -irf myfile.txt
#Move the mp4 file to the download directory
	echo hvcomputer | sudo -S mv $PROCESS_DIR/$CAMID-$1$2-$3$4_out.mp4 $CAMID-$1$2-$3$4
	cd $PROCESS_DIR/$CAMID-$1$2-$3$4
}
#Provide a download location
	sudo python3 -m http.server 80
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
}

for i in `seq 1 5`; do
    sleep 1
    echo -n "."
done

#Cleanup the the last of the residiual files and directories.
	cd $PROCESS_DIR
	rm -irf $CAMID-$1$2-$3$4/*.mp4
	rmdir $CAMID-$1$2-$3$4
exit
