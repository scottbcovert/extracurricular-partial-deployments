#!/bin/sh

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=ExtraCurricular
# SAMPLE DATA: Define your sample data, uncomment below while updating comma-separated data file names
# DATA_IMPORT_FILES=data/SomeObjects1.json,data/MySettings.json,data/EtcEtc.json
DEVHUB_NAME="${PROJECT_NAME}DevHub"
PERMSET_NAME="${PROJECT_NAME}UserPermissions"

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
echo "Assigning the project permission set to the default scratch org user..."
echo ""
echo "TODO: Define app permission sets then uncomment the below."
# sfdx force:user:permset:assign -n ${PERMSET_NAME} --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Assigning the project permission set to the default scratch org user failed!"
	exit
fi
echo "SUCCESS: Project permission set was assigned successfully to the default scratch org user!"

echo ""
echo "Importing default data to the scratch org..."
echo ""
echo "TODO: Data import!!! Create your sample data and uncomment below!"
# sfdx force:data:tree:import -f ${DATA_IMPORT_FILES} --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Importing default data to the scratch org failed!"
	exit
fi
echo "SUCCESS: Default data was successfully imported to the scratch org!"

echo ""
echo "Running anonymous Apex scripts against the scratch org for additional configuration..."
echo ""
echo "TODO: Setup any objects e.g. user roles, if needed! Needs external apex script!"
# sfdx force:apex:execute -f config/setup.apex --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Running anonymous Apex scripts against the scratch org failed!"
	exit
fi
echo "SUCCESS: Successfully ran anonymous Apex scripts against the scratch org!"

echo ""
echo "Opening scratch org for development, may the Flow be with you!"
echo ""
sleep 3
sfdx force:org:open
