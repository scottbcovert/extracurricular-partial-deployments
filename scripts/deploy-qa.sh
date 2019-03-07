#Convert to MDAPI format for deployment to prod
echo "Converting to MDAPI format..."
sfdx force:source:convert -d deploy_qa -r force-app 
#Deploy to prod & run all tests
echo "Deploying to QA, skipping all tests as validation should have already occurred..."
sfdx force:mdapi:deploy -d deploy_qa -u QA -l NoTestRun -w -1