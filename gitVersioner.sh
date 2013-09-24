#!/bin/bash
#DEFAULT TAG
printHelp() {
	echo -e "\tup\t[number]\tUps the version. Default by one"
	echo -e "\tdown\t[number]\tDowns the version by one. Default by one"
	echo -e "\thelp\t\t\tShows this message"
}
MANIFEST="./AndroidManifest.xml"
WORKING_COPY="input.xml"
BACKUP="AndroidManifest.xml.orig"
VERSION_PREFIX="version-"
GIT_CONFIG="./.git/config"
if [ ! -f $MANIFEST ]; then
	echo "Did not find $MANIFEST!"
	exit 1
fi
cp $MANIFEST $WORKING_COPY
mv $MANIFEST $BACKUP
XML_ANDROID_VERSION_CODE="android:versionCode"
XML_ANDROID_VERSION_NAME="android:versionName"
DELIMINATOR='"'

CURRENT_VERSION_CODE=`cat $WORKING_COPY | grep "$XML_ANDROID_VERSION_CODE" | cut -f 2 -d $DELIMINATOR`
CURRENT_VERSION_NAME=`cat $WORKING_COPY | grep "$XML_ANDROID_VERSION_NAME" | cut -f 2 -d $DELIMINATOR`
if [ $# > 0 ]; then	 
	if [[ $1 == "down" ]]; then		
		if [[ ! -z $2 ]]; then 
			echo "Version goes down by $2"		
			NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE -$2 | bc`
		else
			echo "Version goes down"		
			NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE -1 | bc`
		fi
	elif [[ $1 == "up" ]]; then			
		if [[ ! -z $2 ]]; then 
			echo "Version goes up by $2"
			NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE + $2 | bc`
		else 
			echo "Version goes up"
			NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE +1 | bc`
		fi 
	elif [[ $1 == "help" ]]; then
			printHelp
			exit 0
	else
		echo "Version goes up"
		NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE +1 | bc`
	fi
else
	NEW_VERSION_CODE=`echo $CURRENT_VERSION_CODE +1 | bc`	
fi 
echo -e "Old version code\t$CURRENT_VERSION_CODE"
#echo -e "\nOld version name\t$CURRENT_VERSION_NAME"
#NEW_VERSION_NAME=${CURRENT_VERSION_NAME/CURRENT_VERSION_NAME/NEW_VERSION_CODE}
#echo $NEW_VERSION_NAME
echo $CURRENT_VERSION_NAME | sed s/$CURRENT_VERSION_CODE/$NEW_VERSION_CODE/ $WORKING_COPY > $MANIFEST
echo -e "New version code\t$NEW_VERSION_CODE" 
#echo -e "\nNew version name\t$NEW_VERSION_NAME"
if hash git 2>/dev/null; then
	if [ -f $GIT_CONFIG ]; then
		git tag $VERSION_PREFIX$NEW_VERSION_NAME
		echo "Tagging this commit as $VERSION_PREFIX$NEW_VERSION_NAME"
	else
		echo "We are not in an git initialized directory!"
	fi
else 
	echo "Git not installed"
fi
rm $WORKING_COPY
rm $BACKUP
rm 0
exit 0