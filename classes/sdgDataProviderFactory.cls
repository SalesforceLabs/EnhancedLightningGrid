/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgDataProviderFactory  {
    public class sdgDataProviderFactoryException extends Exception {}
    public class sdgInvalidConfigurationNameException extends Exception {}
    private static final string delim = ':';

    public static Boolean isNameValid(String name)
    {
        boolean isOK = false;
        if (name.startswithignoreCase(sdgDataProviderType.Apex.name() + delim) || name.startswithignoreCase(sdgDataProviderType.Metadata.name() + delim) || name.startswithignoreCase(sdgDataProviderType.CustomObject.name() + delim) || name.startswithignoreCase(sdgDataProviderType.Relationship.name() + delim))
        {
            String[] parts = name.split(delim);
            if (parts.size()>1)
            {
                isOK = true;
            }
        }
        if (!isOK)
        {
            throw new sdgInvalidConfigurationNameException('Invalid configuration: ' + name);
        }
        return isOk;
    }

    @TestVisible
    private  static sdgIDataProvider getClass(String name)
    {
        sdgIDataProvider ret;
        try
        {
            sdgDataProviderType sdgtype = getType(name);


            String tag = GetTag(name);
            if (sdgtype == sdgDataProviderType.Relationship)
            {
                system.debug('sdgDataProviderFactory:getClass: SDGRelationshipDataProvider');

                SDGDataProviderRelationship relation = new SDGDataProviderRelationship();
                ret = relation ;
            }
            else if (sdgtype== sdgDataProviderType.Apex)
            {
                system.debug('sdgDataProviderFactory:getClass: ' + name);

                //Test it:
                try
                {
                    Type customType = Type.forName(tag);
                    Object a = customType.newInstance();
                    //is this a valid type that implements the correct interface
                    if (a instanceof sdgIDataProvider)
                    {
                        //all ok
                        ret = (sdgIDataProvider)a;
                    }
                }
                catch (sdgException sdgex)
                {
                    throw sdgex;
                }
                catch(Exception ex)
                {
                    //Invalid class name
                    throw new sdgDataProviderFactoryException('Unable to instantiate class: ' + name,ex);
                }

            }
            else if (sdgtype ==sdgDataProviderType.CustomObject)
            {
                //use the normal data provider:
                system.debug('sdgDataProviderFactory:getClass: SDGNativeDataProvider');

                SDGDataProviderNative native = new SDGDataProviderNative();
                ret= native;
            }
            else if ( sdgtype==sdgDataProviderType.Metadata)
            {
                system.debug('sdgDataProviderFactory:getClass: SDGMetadataDataProvider');
                SDGDataProviderMetadata meta = new SDGDataProviderMetadata();
                ret= meta;
            }

            if (ret!=null)
            {
                return ret;
            }
            else
            {
                throw new sdgDataProviderFactoryException('sdgDataProviderFactory:getClass: No provider available: ' + name);
            }
        }
        catch (Exception ex)
        {
            if (ex instanceof sdgException)
            {
                throw ex;
            }
            else
            {
                throw new sdgDataProviderFactoryException('Unable to get class', ex);
            }
        }
        return null;
    }
    private static sdgDataProviderType GetType(String tag)
    {
        sdgDataProviderType ret =sdgDataProviderType.Relationship; //default
        if (tag.startsWithIgnoreCase(sdgDataProviderType.Apex.name() + delim))
            ret = sdgDataProviderType.Apex;
        if (tag.startsWithIgnoreCase(sdgDataProviderType.CustomObject.name() + delim))
            ret = sdgDataProviderType.CustomObject;
        if (tag.startsWithIgnoreCase(sdgDataProviderType.Relationship.name() + delim))
            ret = sdgDataProviderType.Relationship;
        if (tag.startsWithIgnoreCase(sdgDataProviderType.Metadata.name() + delim))
            ret = sdgDataProviderType.Metadata;

        return ret;
    }

    private static string GetTag(String tag)
    {
        List<String> parts = tag.split(delim);
        parts.remove(0);

        string ret = String.join(parts,delim);

        return ret;
    }

    public  static SDGResult getData( SDGRequest request)
    {
        return getData(request, null);
    }
    public  static SDGResult getData( SDGRequest request, SDG coreSDG)
    {

        system.debug('sdgDataProviderFactory:getData: ' + request.SDGTag);
        SDGResult result = new SDGResult();
        if (coreSDG == null)
            coreSDG = LoadSDG(request.SDGTag, request.ParentRecordId, request.RelationshipName, request.FieldSetName);
        sdgIDataProvider handler = sdgDataProviderFactory.getClass(request.SDGTag);
        system.debug('sdgDataProviderFactory:getData preparing page size');
        //Fix potential problems in the request:
        if (request.pageid ==null)
            request.pageid = 1;
        if (request.pagesize ==null)
            request.pagesize = 10;

        if (handler!=null)
        {
            try
            {
                result = handler.getData(coreSDG, request);
            }
            catch (exception ex)
            {
                if (sdgEx.RaiseNew(ex))
                    throw new sdgDataProviderFactoryException('Unable to get data from the data provider: ' + coreSDG.sObjectName + ' - ' + ex.getMessage(), ex);
            }
        }
        else
        {
            throw new sdgDataProviderFactoryException('Invalid data provider on SDG: ' + coreSDG.sObjectName);
        }

        return result;
    }

    public static SDG LoadSDG(String SDGTag, String ParentRecordId, String RelationshipName, String FieldsetName)
    {

        SDG CoreSDG;

        if (GetType(SDGTag) == sdgDataProviderType.Relationship)
        {
            system.debug('sdgDataProviderFactory:LoadSDG:Loading from Fieldset');
            system.debug('RelationshipName: ' + RelationshipName);

            //sdgLoaderFieldSet l = new sdgLoaderFieldset();
            sdgDataProviderRelationship dp = new sdgDataProviderRelationship();
            coreSDG = dp.LoadSDG(ParentRecordID, RelationshipName, FieldSetName);
        }
        else
        {
            system.debug('sdgDataProviderFactory:LoadSDG: ' + SDGTag);

            coreSDG = getClass(SDGTag).LoadSDG(getTag(SDGTag), ParentRecordId);

        }
        return coreSDG;

    }

}