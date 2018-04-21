/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global class sdgProperties  extends VisualEditor.DynamicPickList{
    public static final string DefaultLabel = '--Select--';
    private  VisualEditor.DynamicPickListRows getDataRows()
    {
        List<SDG__c> sdgs = [select id, sdg_tag__c from sdg__c order by sdg_tag__c];
        VisualEditor.DynamicPickListRows  Values = new VisualEditor.DynamicPickListRows();
        set<String> existing = new set<string>();
        values.addrow(new VisualEditor.DataRow(DefaultLabel,null));
        values.addrow(new VisualEditor.DataRow(sdgDataProviderType.Relationship.name(),sdgDataProviderType.Relationship.name()));
        for (SDG__c sdg: sdgs)
        {
            values.addrow(new VisualEditor.DataRow(sdgDataProviderType.CustomObject.name() + ':' + sdg.sdg_tag__c, sdgDataProviderType.CustomObject.name() + ':' + sdg.sdg_tag__c));
            existing.add(sdg.sdg_tag__c);
        }

        for (SDGDefaults__mdt d:  [SELECT MasterLabel, DeveloperName FROM SDGDefaults__mdt])
        {
            values.addrow(new VisualEditor.DataRow(sdgDataProviderType.Metadata.name() + ':' + d.MasterLabel, sdgDataProviderType.Metadata.name() + ':' + d.DeveloperName));
        }
        List<String> custominterfaces = InterfaceImplementors();
        for(String s: custominterfaces)
        {
             values.addrow(new VisualEditor.DataRow(sdgDataProviderType.Apex.name() + ':' + s, sdgDataProviderType.Apex.name() + ':' + s));

        }

        return Values;
    }

    private static List<ApexClass> searchedclasses;

    private List<ApexClass> SearchClasses(string interfacename)
    {
        if (searchedclasses==null)
        {
            searchedclasses = (ApexClass[])[FIND :interfacename
                                            IN ALL FIELDS
                                            RETURNING ApexClass(Id, Name)][0];
        
        }

        return searchedclasses;
    }

    private List<String> InterfaceImplementors()
    {
        String interfacename = 'sdgIDataProvider';
    	List<ApexClass> classes = SearchClasses(interfacename);

        List<String> dataproviders = new List<String>();
        //Don't know how to test this:
        try
        {
                for (ApexClass ac : classes)
                {
                    if (ac.Name.toLowerCase() != interfacename.ToLowerCase())
                    {
                        Object o = Type.forName(ac.Name).newInstance();
                        if (o instanceOf sdgIDataProvider)
                        {
                            sdgIDataProvider dp = (sdgIDataProvider)o;
                            if ( dp.isUserSelectable())
                            {
                                dataproviders.add( ac.name);
                            }
                        }
                    }
                }
        }
        catch (Exception ex) {
            //Ignore this - I don't  know how to recover this:
            system.debug(LoggingLevel.ERROR, 'Unable to parse custom interfaces: sdgProperties.InterfaceImplementors');
        }
        return dataproviders;

    }
    global override VisualEditor.DataRow getDefaultValue(){

        VisualEditor.DataRow defaultValue = getDataRows().get(0);
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return getDataRows();
    }
}