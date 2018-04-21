/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
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