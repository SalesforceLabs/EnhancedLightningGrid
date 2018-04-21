/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class SDGFilter
{
    global string SDGFieldID;
    global string FilterOperator;
    global string FilterValue;

global SDGFilter()
{

}
    global SDGFilter(string SDGFieldID, string FilterOperator, string FilterValue)
    {
        this.SDGFieldID = SDGFieldID;
        this.FilterOperator = FilterOperator;
        this.FilterValue = FilterValue;
    }


}