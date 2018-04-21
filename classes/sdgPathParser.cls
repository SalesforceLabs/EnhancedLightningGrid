/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgPathParser {
    //Class to navigate a path string from a starting object to get to the ultimate field.  eg type=Contact, and fieldpath = Account.Owner.Name
    List<String> path;
    private List<String> NewPath = new List<String>();
    Schema.SObjectType type;


    public SDGPathParser(String fieldpath, Schema.SObjectType type)
    {
        this.path = fieldpath.split('\\.');
        this.type = type;
    }

    public String FixCase()
    {
        String newpath ='';
        while (path.size() > 1)
        {
            newpath += traverse() + '.';
        }
        newpath +=  describe(path[0]).getName();
        return newpath;
    }

    public Schema.DescribeFieldResult getDescribe()
    {
        // could possibly make this recursive
        while (path.size() > 1)
        {
            traverse();
        }
        return describe(path[0]);
    }

    private string traverse()
    {
        if (path.size() == 1) return path[0];
        String field = path.remove(0);
        String lookupName = getLookupName(field);
        //get the field
        Schema.DescribeFieldResult describe = describe(lookupName);
        //and now the reference to the foreign object
        this.type = describe.getReferenceTo()[0];
        //return the relationshipname
        return describe.getRelationshipName();
    }

    Schema.DescribeFieldResult describe(String field)
    {
        Map<string, Schema.SObjectField > fieldmap = type.getDescribe().fields.getMap();
        Map<string, string> insensitivemap = new Map<string, string>();
        //get case insensitive map:
        for (String s : fieldmap.keyset())
        {
            insensitivemap.put(s.toLowerCase(), s);
        }
        Schema.DescribeFieldResult d =  fieldmap.get(insensitivemap.get(field.toLowerCase())).getDescribe();
        return d;
    }

    static String getLookupName(String crossObjectReference)
    {
        // TODO:/  need to think about this more if there are managed packages
        //If it ends with __r (it's a custom relationship) then return the object name (ie __c), otherwise it's just the name+ID = like AccountID
        return crossObjectReference.endsWith('__r') ? crossObjectReference.replace('__r', '__c') : crossObjectReference + 'Id';
    }
}