/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgSecurityTest {

     public   static User CreateUser(String partialUserName)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String username=UserInfo.getOrganizationId() + partialUserName + 'standarduser@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName=username);
        return u;
    }

    static testmethod void CanQuery()
    {
        //Test Admin can see stuff:
        //
        Boolean userCanQuery = false; 
        userCanQuery = sdgSecurity.CanQuery('sdgSecurityTest:CanQuery', 'sdg__c', 'is_valid__c', 'name', sdgNamespaceUtility.GetNamespace(), false);
        system.assertEquals(true, userCanQuery, 'Admin should be able to query sdg__c' );

        userCanQuery = sdgSecurity.CanQuery('sdgSecurityTest:CanQuery','sdg__c', 'is_invalid_field__c', 'name', sdgNamespaceUtility.GetNamespace(), false);
        system.assertEquals(false, userCanQuery, 'Admin should not be able to query an invalid field on sdg__c' );
		Boolean isGoodError = false;
        boolean isBadError = false;
        try
        {
           userCanQuery = sdgSecurity.CanQuery('sdgSecurityTest:CanQuery','sdg__c', 'is_invalid_field__c', 'name', sdgNamespaceUtility.GetNamespace(), true);
         
        }
        catch(sdgSecurity.sdgInvalidPermissionsException sdgex)
        {
            isGoodError = true;
        }
        catch(exception ex)
        {
            isBadError = true;
        }
        system.assertEquals(false, userCanQuery, 'Admin should not be able to query an invalid field on sdg__c (2)' );
        system.assertEquals(true, isGoodError, 'Should receive sdgInvalidPermissionsException if Admin query an invalid field on sdg__c' );
        system.assertEquals(false, isBadError, 'Received raw exception on Admin query an invalid field on sdg__c' );
        
		
        User u = CreateUser('1');
        system.runAs(u) {
            userCanQuery = sdgSecurity.CanQuery('sdgSecurityTest:CanQuery', 'sdg__c', 'is_valid__c', 'name', sdgNamespaceUtility.GetNamespace(), false);
        }
        system.assertEquals(false, userCanQuery, 'Normal user should not be able to query sdg__c' );

    }
}