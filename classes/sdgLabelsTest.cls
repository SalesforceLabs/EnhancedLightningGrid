/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@isTest
public with sharing class sdgLabelsTest {
    //Instantiate teh sdgLabels object
  static testMethod void GetLabels()
  {
      List<String> labels = new List<String>();
      labels = sdgLabels.strings;
      system.assert(labels.size()>0);
  }
}