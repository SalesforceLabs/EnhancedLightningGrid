/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgQueryEngine {
    public virtual class sdgQueryEngineException extends sdgException {}
    public  class sdgInvalidFilterException extends sdgException {}
    public  class sdgInvalidSortException extends sdgException {}
    public  class sdgInvalidQueryException extends sdgException {}
    public  class sdgInvalidEngineRequestException extends sdgException {}

    public static SDGRequest InsertDefaults(SDGRequest request)
    {
 
        //If there are no filters - then create a dummy record:
        if (request.filters==null)
            request.filters = new list<SDGFilter>();
        //default pagesize and pageid if not set
        if (request.PageSize ==null)
            request.PageSize = 10;
        if (request.PageID ==null)
            request.PageID = 1;
        return request;
    }

    public static void VerifyRequest(SDGRequest request, Map<String, SDGField> mFields)
    {
        //Check if any of the filters aren't in the original set of ids for fields
        for (SDGFilter filter : request.filters)
        {
            //Note that mfields only has fields that are already checked for FLS so this is in effect an FLS check
            if (!mfields.containsKey(filter.SDGFieldID))
            {
                throw new sdgInvalidFilterException('Invalid SDGRequest.Filters');
            }
        }

        //And the sort order - can't sort by a field that you can't select...
        if (!String.isBlank(request.SortColumn))
        {
            if (!mfields.containsKey(request.SortColumn))
            {
                throw new sdgInvalidSortException('Invalid SDGRequest.SortColumn');
            }
        }
    }

    public static map<String, SDGField> GetSelectFieldsMap(sdg sdgObject)
    {

        Map<String, SDGField> results = new Map<String, SDGField>();
        //Get all the fields for the select clause
        for (SDGField field : sdgObject.SDGFields)
        {
            results.put(field.id,field);
        }
        return results;
    }
 
    public static List<String> GetUniqueSelectFieldsList(sdg sdgObject)
    {
        Set<String> fieldset = new Set<String>();
        //Get all the fields for the select clause
        for (SDGField field : sdgObject.SDGFields)
        {

            //Add the selectable field to the list of select names
            if (String.isNotBlank(field.columnName))
            {
                String colname = field.columnName;
                //Translate any picklist values
                if (field.FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
                {
                    colname = 'tolabel(' + colname + ')';
                }
                if (field.FieldType ==String.valueof(Schema.DisplayType.CURRENCY))
                {
                    //if (field.FieldStyle == 'ShowCurrencyCode')
                    fieldset.add(String.escapeSingleQuotes(colname));
                    colname = 'FORMAT(' + colname + ') ' + colname + 'Formatted';

                }

                fieldset.add(String.escapeSingleQuotes(colname));
            }

        }
        List<String> res = new List<STring>();
        res.addall(fieldset);
        return res;
    }

    public static SDGResult getSDGResultRaw(SDG newSDG, SDGRequest request)
    {
        system.debug('QueryEngine:getSDGResultRaw');
        system.debug(json.serialize(request));
        system.debug(json.serialize(newsdg));
        //Verify against the database, and escape everything - including the config values

        Boolean bInvalidRequest = false;
        integer internalpageid=0;
        decimal internalPageSize =0;
        String sAllWhereClause = '';
        String sCoreWhereClause = '';
        String pageQuery = '';
        Boolean DisableSharing = true;
        List<String> UserWhereClauses = new List<String>();
        List<String> CoreWhereClauses = new List<String>();
        String sCountLimit = ' limit 1000';
        String AllRows  = '';

        //Lots of steps:
        //0 Test if this is an apex call instead:
        //1 Verify that the data is valid for searching
        //2 Get the core query constructed
        //3 Do parent record id
        //4 Get where clause
        //5 handle pagination

        //load the SDG and fields:

        SDGResult result = new SDGResult();


        Map<String, SDGField> mFields = new Map<String, SDGField>();

        result.isError = true;
        result.ErrorMessage = 'No SDG found';
        //Validate that the request is safe:
        if (newSDG!=null)
        {
            //The SDG record exists
            try
            {
                mFields = GetSelectFieldsMap(newSDG);
                //Fix any blank data for paging and null filters
                request = InsertDefaults(request);

                //check there's nothing wrong - will throw an exception
                VerifyRequest(request, mFields);

                //Everything looks oK so far so save the filters
                sdgPreferences.SaveFilters(request, newSDG.InternalData.sUniqueKey);

                //and generate the query
                List<String> AllSelectFields = GetUniqueSelectFieldsList(newSDG);

                // Note FLS checks done on AllSelectFields when retrieving SDG (in e.GetSDG()) above - actually in GetSDGFields and GetSDGFieldsFromFieldSet
                // Also - filters can only exist for fields - so this auto filters based on FLS
                pageQuery = 'SELECT ' + String.join(AllSelectFields,',') + ' FROM ' +  String.escapeSingleQuotes(newSDG.internalData.sObjectName);

                internalpageid =Integer.valueOf(request.PageID);
                internalPageSize = integer.valueOf(request.PageSize);
                internalpageid = internalpageid-1;
                String sSortClause;

                 sSortClause = BuildSortClause(newSDG, request, mFields);

                //support where it's blank so we can use on non related lists
                if (!String.isBlank(newSDG.InternalData.ParentFieldName))
                {
                    CoreWhereClauses.add( ' ' + String.escapeSingleQuotes(newSDG.InternalData.ParentFieldName) + ' = \'' + String.escapeSingleQuotes(request.ParentRecordID) + '\' ');
                }

                //Add the serverside default filter:
                if (!String.isBlank(newSDG.InternalData.sFilter))
                {
                    CorewhereClauses.add(' ' + newSDG.InternalData.sFilter + ' ');
                }

                //Loop through each filter clause
                UserWhereClauses = AddFilters(request, mfields);

                //Now merge all parts together
                List<STring> AllWhereClauses = new List<String>();
                AllWhereClauses.AddAll(CoreWhereClauses);
                AllWhereClauses.AddAll(UserWhereClauses);

                if (AllWhereClauses.size()>0)
                    sAllWhereClause = ' WHERE ' + String.join( AllWhereClauses, ' AND ');
                if (CoreWhereClauses.size()>0)
                    sCoreWhereClause = ' WHERE ' + String.join( CoreWhereClauses, ' AND ');

                sAllWhereClause = sdgQueryBuilder.ProcessMergeFields(sAllWhereClause, request.ParentRecordId);
                sCoreWhereClause = sdgQueryBuilder.ProcessMergeFields(sCoreWhereClause, request.ParentRecordId);

                pageQuery = pageQuery + sAllWhereClause;
                integer offset =integer.valueOf( internalPageSize * internalpageid);
                String sPagination = ' limit ' + internalPageSize + ' offset  ' + offset;

                if (newSDG.InternalData.AllRows)
                {
                    AllRows = ' ALL ROWS';
                }

                pageQuery = pageQuery +  sSortClause + sPagination + AllRows;
                system.debug('getSDGResultRaw:pageQuery: ' + pageQuery);
            }
            catch (Exception ex)
            {
                throw new sdgInvalidEngineRequestException(ex);
            }

            try
            {
              
                //now evaluate the count
                String countQuery = 'select count() from ' + String.escapeSingleQuotes(newSDG.InternalData.sObjectName) + ' ' + sAllWhereClause + sCountLimit + AllRows;
                DisableSharing = newSDG.internalData.DisableSharing;

                Integer countFull = sdgDatabase.CountQuery(countQuery, DisableSharing);

                result.FullQueryCount =countFull;
                result.pagecount = (integer) math.ceil(countFull/internalPageSize);

                result.data = sdgDatabase.Query(pageQuery, DisableSharing);
                system.debug('Query complete - pagesize: ' + result.data.size());
                result.query = pageQuery;
                result.isFiltered = UserWhereClauses.size()>0;
                result.isError = false;
                result.ErrorMessage = '';
            }
            catch (exception ex)
            {
                result.query = pageQuery;
                throw new SDGInvalidQueryException('Unable to query: ' + pageQuery, ex);
            }

        }

        return  result;
    }
    private static String BuildSortClause(SDG sdg, SDGRequest request, Map<String, SDGField> mFields)
    {

        //Default input:
        String sSortColumn = 'Id';
        String sSortOrder = 'A';
        String sSortClause = '';
        try
        {
            if (!String.isBlank(request.SortColumn)) {
                try
                {
                    sSortColumn = String.escapeSingleQuotes(((SDGField)mFields.get(request.SortColumn)).ColumnName);
                    sSortOrder = request.SortOrder;
                }
                catch(Exception ex)
                {
                    //bad sort - remove sort:
                    sSortColumn = '';
                    sSortOrder = '';
                }

            }
            else
            {
                //NO FLS check here for internal sorts
                String defaultSort = sdg.InternalData.sDefaultSort;

                if (String.isNotBlank( defaultSort))
                {
                    String[] sSortClauseParts = defaultSort.trim().toLowerCase().split(' ');
                    sSortColumn = sSortClauseParts[0];
                
                    sSortOrder = 'A';
                    if (sSortClauseParts.size()==2)
                    {
                        if (((sSortClauseParts[1]).left(1).toLowerCase() == 'd'))
                            sSortOrder = 'D';
                    }

                }
            }

            //Now build the actual clause:
            sSortClause = sdgQueryBuilder.buildSortClause(sSortColumn, sSortOrder);
            
        }
        catch (Exception ex)
        {
            if (sdgEx.RaiseNew(ex))
                throw new sdgInvalidSortException('Invalid sort clause', ex);
        }
        return sSortClause;
    }
    private static List<String> AddFilters(SDGRequest request, Map<String, SDGField> mfields)
    {
        system.debug('sdgQueryEngine:AddFilters ' + JSON.serialize(request.filters));
        List<String> UserWhereClauses = new List<String>();
        for (SDGFilter filter : request.filters)
        {
            if (string.isblank(filter.filteroperator))
                filter.filteroperator = '=';

            SDGField databasefield = mfields.get(filter.SDGFieldID);
            if (databasefield.canFilter)
            {
                String clause = sdgQueryBuilder.BuildFilterClause( databasefield.ColumnName, databasefield.FieldType, filter.filterOperator, filter.filterValue);
                if (!String.isBlank(clause))
                     UserWhereClauses.add(clause);
            }
        }
        return UserWhereClauses;
    }

}