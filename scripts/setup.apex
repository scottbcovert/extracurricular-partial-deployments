// Sample Apex setup code!
// In this case, setting up user role hierarchy
// Replace with whatever anonymous Apex you want to run on setup!

Id defaultScratchOrgUserId = UserInfo.getUserId();
list<UserRole> defaultRoles = [SELECT Id FROM UserRole];

// Due to some strange Salesforce/SFDX bug the default roles in the scratch org are unusuable so they must be deleted and replaced
delete defaultRoles;
UserRole ceoRole = new UserRole(Name = 'CEO', DeveloperName = 'CEO', ParentRoleId = null);
insert ceoRole;
UserRole vpSalesRole = new UserRole(Name = 'VP Sales', DeveloperName = 'VPSales', ParentRoleId = ceoRole.Id);
insert vpSalesRole;
UserRole eastSalesRole = new UserRole(Name = 'Eastern Sales', DeveloperName = 'EasternSales', ParentRoleId = vpSalesRole.Id);
insert eastSalesRole;
UserRole westSalesRole = new UserRole(Name = 'Western Sales', DeveloperName = 'WesternSales', ParentRoleId = vpSalesRole.Id);
insert westSalesRole;

// Set Channel field to true for default scratch org user and assign the VP Sales role to pull the user into FunnelSource
User defaultScratchOrgUser = [SELECT Id, UserRoleId, amorgan__Channel__c FROM User WHERE Id = :defaultScratchOrgUserId];
defaultScratchOrgUser.amorgan__Channel__c = 'Channel';
defaultScratchOrgUser.UserRoleId = vpSalesRole.Id;
update defaultScratchOrgUser;