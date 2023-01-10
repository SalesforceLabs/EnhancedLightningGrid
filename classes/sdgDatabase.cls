/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
public with sharing class sdgDatabase {

    public static integer CountQuery(string query, Boolean DisableSharing)
    {
        system.debug('disable sharing: ' + DisableSharing);
        if (DisableSharing)
        {
            sdgDatabaseWithoutSharing ws = new sdgDatabase.sdgDatabaseWithoutSharing();
            return ws.CountQuery(query );
        }
        else
        {
            sdgDatabaseWithSharing ws = new sdgDatabase.sdgDatabaseWithSharing();
            return ws.CountQuery(query );
        }
        
    }
    public static List<SObject> Query(string query, Boolean DisableSharing)
    {
        system.debug('disable sharing: ' + DisableSharing);
        if (DisableSharing)
        {
            sdgDatabaseWithoutSharing ws = new sdgDatabase.sdgDatabaseWithoutSharing();
            return ws.Query(query );
        }
        else
        {
            sdgDatabaseWithSharing ws = new sdgDatabase.sdgDatabaseWithSharing();
            return ws.Query(query );
        }
        
    }
    public with sharing class sdgDatabaseWithSharing {
        public integer CountQuery(string query)
        {
            return database.countQuery(query);
        }

        public List<SObject> Query(string query)
        {
            return database.Query(query);
        }
    }

    private without sharing class sdgDatabaseWithoutSharing{
        public integer CountQuery(string query)
        {
            return database.countQuery(query);
        }

        public List<SObject> Query(string query)
        {
            return database.Query(query);
        }
    }

}