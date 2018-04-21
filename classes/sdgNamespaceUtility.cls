/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public class sdgNamespaceUtility {
    //Self referential finds the current namespace
    private static string namespace = '';
    private static boolean isloaded = false;
    public static string GetNamespace()
    {
        if (!isloaded)
        {
            ApexClass ac = [SELECT Id, NamespacePrefix,name FROM ApexClass where name = 'sdgNamespaceUtility' limit 1];
            if (ac!=null)
            {
                if (String.isNotBlank(ac.NamespacePrefix))
                 {
                   namespace = ac.NamespacePrefix + '__';
                 }
                isloaded = true;
            }

        }
        return namespace;

    }
}