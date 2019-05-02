#!/bin/bash

#Time check, Starting timer
scriptTimer="$SECONDS"
startTime="$(date +%R:%S)"
#
#Taking in the users name
#
fullUser=""
while [[ -z "$fullUser" ]]; do

	read -p "What is your user name?: "  userName

	#Gets full user entry
	fullUser=$(getent passwd "$userName")

	if [[ -z "$fullUser" ]]; then #Error trap
		#Converts to lower if user isn't found
		echo "Checking for lower case names"
		userName="${userName,,}"
		fullUser=$(getent passwd "$userName")
	fi

	#Getent get infomation about entered user | Awk gets first word | Awk sets : as divider and gets 5th word
	userForename=$(getent passwd "$userName" | awk '{print $1;}' | awk -F ":" '{print $5}')
	#Getent get infomation about entered user | Awk gets second word to end, for users with multiple names | Awk sets , and ; as divider and
	#prints first word
	userSurname=$(getent passwd "$userName" | awk '{print $2,$NF;}' | awk -F "[,:]" '{print $1}')
	#Gets home directory of entered users | awk uses : as a devider, then gets 6th field
	homeDir=$(getent passwd "$userName" | awk -F ":" '{print $6}')
done

#
#Checking the time
#

currentTime=$(date +%R) #Gives time in 24hour:Minutes format

if [[ "$currentTime" > "00:00" ]] && [[ "$currentTime" < "11:59" ]]; then
	echo "Good Morning $userSurname"
elif [[ "$currentTime" > "12:00" ]] && [[ "$currentTime" < "16:59" ]]; then
	echo "Good afternoon $userSurname"
elif [[ "$currentTime" > "17:00" ]] && [[ "$currentTime" < "19:59" ]]; then
	echo "Good evening $userSurname"
elif [[ "$currentTime" > "20:00" ]] && [[ "$currentTime" < "23:59" ]]; then
	echo "Good Night $userSurname"
fi

#
#User options
#

#Takes in user options
read -p "Please enter 'NonBlank', 'Number', 'Ends', or 'Nends' " answer
answerLower="${answer,,}" #Sets input to lowercase

#This is commented out, doesn't look like it, but it is!
#Check that the input is valid
: ' while [[ "$answerLower" != "nonblank" ]] && [[ "$answerLower" != "number" ]] &&
 [[ "$answerLower" != "ends" ]] && [[ "$answerLower" != "nends" ]]; do
	echo "Please enter a valid option"
	read answer
	answerLower="${answer,,}"
done
'

processedBash="" #Holder variable, used to check if bashrc is used
if [[ "$answerLower" == "nonblank" ]]; then
	#Numbers non-blank numbers
	processedBash=$(cat -b ~/.bashrc)
elif [[ "$answerLower" == "number" ]]; then
	#Numbers all Lines
	processedBash=$(cat -n ~/.bashrc)
elif [[ "$answerLower" == "ends" ]]; then
	#Adds $ to end  of all lines
	processedBash=$(cat -E ~/.bashrc)
elif [[ "$answerLower" == "nends" ]]; then
	#Numbers all lines and adds $ to end of lines
	processedBash=$(cat -En ~/.bashrc)
else
	#Exits script if not valid
        echo "You did not enter a valid option!"
        exit 0
fi
#Tells user that cant use the file
if [[ "$processedBash" == "" ]]; then
	echo "Not able to process .bashrc file"
fi

#Creates a new file/overrides the users.txt file.
echo "--------------------User file!--------------------" > users.txt

#Writes bashrc file to file
echo "$processedBash" #>> users.txt #Adds the processed bash to the file

#
#Write User details to file
#

echo "-------------------User Details-------------------" >> users.txt
echo "Script started at :" "$startTime" >> users.txt
echo "Username: ""$userName" >> users.txt
echo "Full name: ""$userForename" "$userSurname" >> users.txt
echo "Home directory: " "$homeDir" >> users.txt
echo "Current Date and time is: $(date +%R:%S\ %A\ %d/%B/%Y)" >> users.txt
#Time format is time:Seconds-day-month-day of the month-year
echo "--------------------------------------------------" >> users.txt

#
#Time counter
#

endTimer="$SECONDS"
duration=$(( endTimer - scriptTimer )) #Calulates the duration of the session

#Says goodbye and tells user the duration of the session
echo "Thank yo for using catbash! You have been using it for $duration seconds"

#Exit
exit 0
