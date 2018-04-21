/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class SDGResult
{
    global List<sObject> data;
    global string query;
    global integer FullQueryCount;
    global integer pagecount;
    global Boolean isFiltered;
    global Boolean isError;
    global String ErrorMessage;
}