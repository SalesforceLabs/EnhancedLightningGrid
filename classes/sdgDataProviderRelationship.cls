/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgDataProviderRelationship implements sdgIDataProvider {
    global static Boolean isUserSelectable()
    {
        return false;
    }
    global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {
        SDGResult result =  sdgQueryEngine.getSDGResultRaw(CoreSDG, request);
        return result;
    }

        global   SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        throw new SDGException('Branching logic incorrect in sdgDataProviderRelationship');

    }
    global   SDG LoadSDG(String ParentRecordID, String RelationshipName, String FieldSetName)
    {

        ID objId ;
        system.debug('sdgDataProviderRelationship:LoadSDG:' + Relationshipname);

        Schema.SObjectType sobjectTypeParent;
        Schema.SObjectType sobjectTypeChild;

        Schema.DescribeSobjectResult descresult;
        Schema.sObjectField  ParentFieldObj;

        Schema.ChildRelationship relationship;
        Map<String, Schema.FieldSet> FsMap;
        Schema.FieldSet fieldsetobj;
        List<Schema.ChildRelationship> cs;

        try
        {
            objId = ID.valueOf( ParentRecordID);
            sobjectTypeParent = objId.getSObjectType();
            descresult = sobjectTypeParent.getDescribe();
            cs = descResult.getChildRelationships();
            system.debug('sdgDataProviderRelationship:LoadSDG: ParentObject:' + descresult.getName());
        }
        catch (exception e)
        {
            throw new SDGException ('sdgDataProviderRelationship:LoadSDG: Unable to identify & describe the sObjectType of this record.  This component can only be configured to use a relationship when it exists on an Record Detail page.');
        }

        List<String> RelationshipNames = new List<STring>();
        List<String> FieldsetNames = new List<STring>();

        for(Schema.ChildRelationship c : cs)
        {
            if (STring.isNotBlank(c.GetRelationshipName()))
            {
                RelationshipNames.add(c.GetRelationshipName());
            }
            if (c.GetRelationshipName() ==RelationshipName)
            {
                relationship = c;
                sObjectTypeChild = c.getChildsObject();
                system.debug('sdgDataProviderRelationship:Found:' + sobjectTypeChild);
                ParentFieldObj = c.getField();
            }
        }

        if(relationship == null)
        {
            throw new SDGException('sdgDataProviderRelationship: Unable to get the Relationship details.  Valid values for RelationshipName for this record are: ' + String.join(RelationshipNames,', '));
        }
        SDG e = new  SDG( sObjectTypeChild.getDescribe().Name, ParentFieldObj.getDescribe().Name,  sObjectTypeChild.getDescribe().Name, '', '', sdgDataProviderType.Relationship.name() + ':' + Relationshipname + ':' + FieldSetName, false);

        fsMap = sObjectTypeChild.getDescribe().FieldSets.getMap();
        for (string key : fsMap.keySet()) {
            FieldsetNames.add(key);
        }

        if (fsMap.containsKey(fieldsetname))
        {
            fieldSetObj = fsMap.get(fieldsetname);
            e.SDGFields = GetSDGFieldsFromFieldSet(fieldsetobj, sObjectTypeChild);
        }
        else if (String.isblank(fieldsetname))
        {
            e.SDGFields = GetSDGDefaultField(sObjectTypeChild);
        }
        else
        {
            throw new SDGException ('Unable to get fieldset and fields for this relationship type.  Valid values for the fieldsetname are: ' + STring.join(FieldsetNames,', '));
        }

        system.debug('sdgDataProviderRelationship:LoadSDG: sObjectName:' + e.sObjectName);
        return e;
    }
    private List<SDGField> GetSDGDefaultField(sObjectType sotChild)
    {
        List<SDGField> SDGFields = new List<SDGField>();
        SDGField idfield;

        Map<String, Schema.SObjectField> FieldMap =  sotChild.getDescribe().fields.getMap();
        for(SObjectField sof: fieldmap.values())
        {
            DescribeFieldResult dfr = sof.getDescribe();
            if (dfr.isNameField())
            {
                SDGField namefield = sdgMapper.MapField(dfr,dfr.getName(), dfr.getName(), false,'', null, 1);
                if (namefield!=null)
                {
                    sdgFields.add(namefield);
                }
            }

        }
        if (sdgFields.size()==0)
        {
            //Didn't find a name so add the id:
            Schema.DescribeFieldResult dr = new SDGPathParser('Id', sotChild).getDescribe();

            SDGField newfield = sdgMapper.MapField(dr,'Id', 'Id', false,'', null, 1);
            if (newfield!=null)
            {
                SDGFields.add(newfield);
            }
        }

        return SDGFields;
    }

    private  List<SDGField> GetSDGFieldsFromFieldSet(Schema.FieldSet fieldSetObj, SobjectType sotChild)
    {
        List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        List<SDGField> SDGFields = new List<SDGField>();
        SDGField newfield;
        double iFieldCounter = 0;
        for (Schema.FieldSetMember fsm: fieldsetmemberList)
        {
            try
            {
                Schema.DescribeFieldResult dr = new SDGPathParser(fsm.FieldPath, sotChild).getDescribe();
                //Only allow access if current field is user visible
                if (dr.isAccessible())
                {
                    iFieldCounter++;
                    newfield = sdgMapper.MapField(dr,fsm.FieldPath, fsm.FieldPath, false,'', null, ifieldCounter);
                    if (newfield!=null)
                    {
                        SDGFields.add(newfield);
                    }
                }
            }
            catch (exception ex)
            {
                //This error could be because the package is restricted so let user know this:
                throw new sdgException('sdgDataProviderRelationship:GetSDGFieldsFromFieldSet Could not access fields listed in the field set - are restrictions on the package enabled?');
            }

        }
        return SDGFields;
    }

}