/*
* @Author: David M. Baumann and Patrick Kernan this is a test
* @Description: APEX Server Side Controller: ActivityTimelineController 
* sets up the actdata referenced by the client Side Controller
*/

public class ActivityTimelineController {

    
/******************************
* @Method Name: SearchActivities
* @Description : This method is uded to search Article in salesforce
* @Param1: This method accepts a String paramter which is used to search articles in salesforce 
* @Return Type: This method returns the list of Sobject (KnowledgeArticleVersion) 
* ***************************/

    @AuraEnabled
    public static List<Task> getActivities(String recordId) {
        List<Task> searchResult = new List<Task>();
        searchResult = [SELECT Id, AccountId, ActivityDate, Subject FROM Task WHERE WhatId=:recordId];
        System.debug('hello world');
        System.debug('hello world4');
        return searchResult;
    }

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
   
}