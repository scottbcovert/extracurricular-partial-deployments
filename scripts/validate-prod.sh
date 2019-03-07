#Convert to MDAPI format for validation against prod
echo "Converting to MDAPI format..."
sfdx force:source:convert -d validate_prod -r force-app 
#Simulate deployment to prod & run all tests
echo "Validating against production by simulating a deployment & running all tests..."
sfdx force:mdapi:deploy -c -d validate_prod -u Prod -l RunLocalTests -w -1