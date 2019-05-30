#!/bin/sh

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=ExtraCurricular
DEVHUB_NAME="${PROJECT_NAME}DevHub"

echo ""
echo "Authorizing you with the ${PROJECT_NAME} Dev Hub org..."
echo ""
sfdx force:auth:web:login --setalias ${DEVHUB_NAME} --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Can't authorize you with the ${PROJECT_NAME} Dev Hub org!"
	exit
fi
echo "SUCCESS: You've been authorized with the ${PROJECT_NAME} Dev Hub org!"

echo ""
echo "Building your scratch org, please wait..."
echo ""
sfdx force:org:create --targetdevhubusername ${DEVHUB_NAME} -f config/project-scratch-def.json --setdefaultusername -a ${PROJECT_NAME} --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Can't create your org!"
	exit
fi
echo "SUCCESS: Scratch org created!"

echo ""
echo "Pushing source to the scratch org, this may take a while so now might be a good time to stretch your legs and/or grab some coffee..."
echo ""
sfdx force:source:push --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Pushing source to the scratch org failed!"
	exit
fi
echo "SUCCESS: Source pushed successfully to the scratch org!"

echo ""
echo "Opening scratch org for development, may the Flow be with you!"
echo ""
sleep 3
sfdx force:org:open
