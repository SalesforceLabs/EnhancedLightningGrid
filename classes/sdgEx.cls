/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
public class sdgEx {

    public static Boolean RaiseNew(Exception ex)
    {
        boolean raise = false;
        if (ex instanceof sdgException)
        {
            throw ex;
        }
        else
        {
            raise = true;
        }
        return raise;
    }
}