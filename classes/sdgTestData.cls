/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgTestData {
    public static String TestSDGName = 'TestSDG';
    public static String TestSampleSDGName = 'SampleDataSDG';

    private  static string GenerateTestData(String SDGName)
    {
        //self referential - sdg showing sdg fields...
        string sdgid = GenerateCoreSDG(SDGName);
        List<SDG_Field__c> fields = new List<SDG_Field__c>();
        GenerateTestSDGFieldString(sdgid, 'name', 1);
        GenerateTestSDGFieldString(sdgid, sdgNamespaceUtility.GetNamespace() + 'apiname__c',2);

        return sdgid;
    }
    public static string GenerateCoreSDG(String SDGName)
    {
        SDG__c a = new SDG__c(Name=SDGName, sdg_tag__c = SDGName, is_valid__c=true, sobjectname__c=sdgNamespaceUtility.GetNamespace() + 'sdg_field__c', parent_field_name__c = sdgNamespaceUtility.GetNamespace() + 'sdg__r.id');
        insert a;
        system.debug('CreatedSDG: id: ' + a.id + ' - Name: ' + SDGName);
        return a.id;
    }
    public static string GenerateTestSampleData()
    {
        return GenerateTestData(TestSampleSDGName);
    }
    public static String GenerateTestSDG()
    {
        //Create a custom SDG:
        String id = GenerateTestData(TestSDGName);
        GenerateAction(id);

        return Id;

    }
    public static string GenerateTestSDGFieldStringName(String SDGID)
    {
        return GenerateTestSDGFieldString(sdgid, 'Name',1);
    }

    public static string GenerateTestSDGFieldString(String SDGID)
    {
        return GenerateTestSDGFieldString(sdgid, sdgNamespaceUtility.GetNamespace() + 'APIname__c',1);
    }

    public static string GenerateTestSDGFieldString(String SDGID, String fieldName, integer fieldorder)
    {
        //String Field
        SDG_Field__c field = new SDG_Field__c( apiname__c=fieldName, fieldOrder__c = fieldorder, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;
    }

    /*public static string GenerateTestSDGFieldTraverseString(String SDGID)
    {
        //String Field
        SDG_Field__c field = new SDG_Field__c( apiname__c=sdgNamespaceUtility.GetNamespace() + 'sdg__r.name', fieldOrder__c = 2, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;
    }
*/
    public static string GenerateTestSDGFieldNumber(String SDGID)
    {
        //String Field
        SDG_Field__c field = new SDG_Field__c( apiname__c=sdgNamespaceUtility.GetNamespace() + 'fieldorder__c', fieldOrder__c = 3, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;

    }

    public static string GenerateTestSDGFieldDate(String SDGID)
    {
        //Date
        SDG_Field__c field = new SDG_Field__c( apiname__c='createddate', fieldOrder__c = 4, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;

    }
    public static string GenerateTestSDGFieldDateTime(String SDGID)
    {
        //Date
        SDG_Field__c field = new SDG_Field__c( apiname__c='lastmodifieddate', fieldOrder__c = 5, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;
    }
    public static string GenerateTestSDGFieldBoolean(String SDGID)
    {
        SDG_Field__c field = new SDG_Field__c( apiname__c=sdgNamespaceUtility.GetNamespace() + 'is_valid_field__c', fieldOrder__c = 6, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;
    }
    public static string GenerateTestSDGFieldPicklist(String SDGID)
    {
        SDG_Field__c field = new SDG_Field__c( apiname__c=sdgNamespaceUtility.GetNamespace() + 'field_style__c', fieldOrder__c = 7, sdg__c=sdgid, is_valid_field__c=true );
        insert field;
        return field.id;
    }



    public static string GenerateAction(String sdgid)
    {
        SDG_Action__c act = new SDG_Action__c();
        act.requires_createable__c = true;
        act.Requires_Editable__c= true;
        act.Action_Type__c = 'List';
        act.event_payload__c = '{ dummy payload}';
        act.Action_Order__c=1;
        act.sdg__c = sdgid;
        act.Event__c='c.force:editRecord';
        insert act;
        return act.id;
    }
}