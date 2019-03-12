// Sample Apex setup code!
// Replace with whatever anonymous Apex you want to run on setup!

Id defaultScratchOrgUserId = UserInfo.getUserId();
list<UserRole> defaultRoles = [SELECT Id FROM UserRole];

// Bonus protip: Due to some strange Salesforce/SFDX bug the default roles in the scratch org are unusuable so they must be deleted and replaced
delete defaultRoles;
UserRole ceoRole = new UserRole(Name = 'CEO', DeveloperName = 'CEO', ParentRoleId = null);
insert ceoRole;
UserRole vpSalesRole = new UserRole(Name = 'VP Sales', DeveloperName = 'VPSales', ParentRoleId = ceoRole.Id);
insert vpSalesRole;

User defaultScratchOrgUser = [SELECT Id, UserRoleId FROM User WHERE Id = :defaultScratchOrgUserId];
defaultScratchOrgUser.UserRoleId = vpSalesRole.Id;
update defaultScratchOrgUser;
