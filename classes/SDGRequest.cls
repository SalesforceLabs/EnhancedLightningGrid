/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class SDGRequest
{
    global String RelationshipName = '';
    global String FieldSetName = '';
    global String SDGTag = '';
    global String ParentRecordID = '';
    global String ParentFieldName = '';
    global List<SDGFilter> Filters;

    global SDGRequest()
    {

    }

    global integer PageID  = 1;
    global integer PageSize  = 10;
    global String SortColumn = '';
    global String SortOrder = '';
}