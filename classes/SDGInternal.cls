/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class SDGInternal
{
    public string ParentFieldName;
    public string sObjectName;
    public string sDefaultSort;
    public string sFilter;
    public string sUniqueKey;
    public boolean AllRows = false;
    public boolean DisableSharing = false;
}