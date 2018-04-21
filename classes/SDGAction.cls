/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class SDGAction  implements Comparable 
{
    global string Id;
    global string Label;
    global string Event;
    global string Type;
    global string Payload;
    global string Icon;
    global integer actionOrder;

    global sdgAction()
    {
    }
  
    global sdgAction(String Id, String Label, String Event, String Type, String Payload, String Icon)
    {
        this.Id = Id;
        this.Label = Label;
        this.Event = Event;
        this.Type = Type;
        this.Payload = Payload;
        this.Icon = Icon;
    }
    global sdgAction(String Id, String Label, String Event, String Type, String Payload, String Icon, integer actionorder)
    {
        this.Id = Id;
        this.Label = Label;
        this.Event = Event;
        this.Type = Type;
        this.Payload = Payload;
        this.Icon = Icon;
        this.actionOrder = actionOrder;
    }
    // Compare action based on the actionorder.
    public Integer compareTo(Object compareTo) {
        // Cast argument to wrapper
        sdgAction compareToAction = (sdgAction)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (actionorder > compareToAction.actionOrder) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (actionorder < compareToAction.actionorder) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}
