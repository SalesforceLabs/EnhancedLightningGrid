/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@istest
public class sdgExTest {
public  class NotsdgException extends Exception {}

private static testmethod void RaiseNew()
    {
        Boolean NeedToRaiseNew = false;

        try
        {
            NeedToRaiseNew = sdgEx.raiseNew(new NotsdgException('test'));

        }
        catch(Exception ex)
        {

        }
        system.assertEquals(true, NeedToRaiseNew, 'sdgEx:RaiseNewTrue: Expected to be told to raise sdgException');
    }
    private static testmethod void RaiseNew2()
    {
        Boolean isError = false;

        try
        {
            sdgEx.raiseNew(new sdgException('test'));

        }
        catch(Exception ex)
        {

                if (ex instanceof sdgException)
                    isError = true;
        }
        system.assertEquals(true, isError, 'sdgEx:RaiseNewTrue: Expected sdgException');
    }
}