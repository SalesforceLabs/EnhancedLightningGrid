/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
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