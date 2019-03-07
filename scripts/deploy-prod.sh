#Convert to MDAPI format for deployment to prod
echo "Converting to MDAPI format..."
sfdx force:source:convert -d deploy_prod -r force-app 
#Deploy to prod & run all tests
echo "Deploying to production & running all tests..."
sfdx force:mdapi:deploy -d deploy_prod -u Prod -l RunLocalTests -w -1