/*
* @Author: Steven M. Giangrasso
* @Description: APEX Server Side Controller: SearchArticleController 
* sets up the Knowledge Article and Voting data referenced by the client Side Controller
*/

public class SearchArticleController {

    
/******************************
* @Method Name: SearchArticles
* @Description : This method is uded to search Article in salesforce
* @Param1: This method accepts a String paramter which is used to search articles in salesforce 
* @Return Type: This method returns the list of Sobject (KnowledgeArticleVersion) 
* ***************************/
    
    @AuraEnabled
    public static List<Record> SearchArticles(String searchKey) {
        if(searchKey.length() < 3) return null;
        String name = '%' + searchKey + '%';
        
        String language = 'en_US';
        String objectType = 'KnowledgeArticleVersion';
        Integer nbResult = 5;
        
        Search.SuggestionOption options = new Search.SuggestionOption();
        Search.KnowledgeSuggestionFilter filters = new Search.KnowledgeSuggestionFilter();
        
        filters.setLanguage(language);
        filters.setPublishStatus('Online');
        
        options.setFilter(filters);
        options.setLimit(nbResult);
        
        
        Search.SuggestionResults suggestionResults = Search.suggest(searchKey, objectType, options);
        
        
        List<Record> searchResult = new List<Record>();
        for(Search.SuggestionResult result : suggestionResults.getSuggestionResults()) {
            searchResult.add(new Record(result.getSobject()));
            System.debug('id ' + result.getSobject());
        }
        
        
        return searchResult; 
    }
    
    
    
    
/******************************
* @Method Name: ArticleDetails
* @Description : This method is uded to return articles with the FAQ__kav TYPE
* @Param1: This method accepts the articledID as a String parameter
* @Return Type: This method returns the list of Sobject (KnowledgeArticleVersion) 
* ***************************/
    @AuraEnabled
    public static Record ArticleDetails(String articleid) {
        Record rec = new Record();
        FAQ__kav faq = [Select id, Title, Summary from FAQ__kav where id =: articleid];
        rec.Title = faq.Title;
        rec.Body = faq.Summary;
        List<Vote> lstVote = [SELECT Id,IsDeleted,Type FROM Vote where ParentId =: articleid and CreatedById =:userinfo.getUserId()];
        rec.Liked = false;
        if(!lstVote.isEmpty()!=true)
        {
            rec.Liked = true;
            rec.VoteType=lstVote[0].Type;
            rec.VoteId=lstVote[0].Id;
        }
        
        return rec;
    }
    
    
    
    
    
        
/******************************
* @Method Name: getArticleDetails
* @Description : This method is uded to return the detail of an article: Titie, Boby, Summary from the Article
* @Description:  This method also returns the Voting data related to the standard VOTE object
* @Param1: This method accepts the articledID as a String parameter
* @Return Type: This method returns the list of Sobject (KnowledgeArticleVersion) 
* ***************************/
    @AuraEnabled
    public static Record getArticleDetails(String articleid) {
        Record rec = new Record();
        KnowledgeArticleVersion objKnowledgeArticleVersion = [SELECT ArticleNumber,ArticleType,CreatedDate,FirstPublishedDate,Id,IsLatestVersion,
                                                                        IsVisibleInPrm,KnowledgeArticleId,Language,OwnerId,PublishStatus,
                                                                        SourceId,Summary,Title,UrlName,VersionNumber
                                                                        FROM KnowledgeArticleVersion WHERE Id =: articleid];
        
        rec.Title = objKnowledgeArticleVersion.Title;
        rec.Body = objKnowledgeArticleVersion.Summary;
        rec.SourceArticleId=objKnowledgeArticleVersion.KnowledgeArticleId;
        rec.KnowldgeVersionId=articleid;
        rec.ArticleType=objKnowledgeArticleVersion.ArticleType;
        
        //Query the Standard Vote object from the Knowledge article
        List<Vote> lstVote = [SELECT Id,IsDeleted,Type FROM Vote where ParentId =: objKnowledgeArticleVersion.KnowledgeArticleId and CreatedById =:userinfo.getUserId()];
        //Query the Article Type 
        //List<Vote> lstVote = [SELECT Id, KnowledgeArticleId, Title, Summary FROM :rec.ArticleType where PublishStatus = ‘Online’ and Language = ‘en_US’ and ID ];
        rec.Liked = false;
        if(lstVote.isEmpty()!=true)
        {
            rec.Liked = true;
            rec.VoteType=lstVote[0].Type;
            rec.VoteId=lstVote[0].Id;
        }
        
        return rec;
    }
    
    /*
    *
    *@Description: This method persists the users Vote selection to the Vote object
    */
    @auraEnabled
    public static record CreateVote(string jsonstring,string VoteType)
    {
        
        system.debug('jsonstring-->'+jsonstring);
        system.debug('VoteType-->'+VoteType);
        
        Record  objRecord = (record)JSON.deserialize(jsonstring, record.class);
        string articleid='';
        system.debug('objRecord-->'+objRecord);
        if(objRecord!=null)
        {
            articleid=objRecord.KnowldgeVersionId;
            if(objRecord.Liked==true)
            {
                
                vote objVote=new vote(id=objRecord.VoteId);
                delete objVote;
                
                
            }
            vote objVoteCreate=new vote(parentId= objRecord.SourceArticleId,type=VoteType);
            insert objVoteCreate;
        }
        
        record rec=getArticleDetails(articleid);
        
        return rec;
        
    }
    
    public class Record {
        @AuraEnabled
        public string KAId { get; set; }
        
        @AuraEnabled
        public Boolean Liked { get; set; }
        
        @AuraEnabled
        public string VoteType{get;set;}
        
        @auraEnabled
        public string VoteId{get;set;}
        
        @AuraEnabled
        public string Title { get; set; }
        
        @AuraEnabled
        public string SourceArticleId{get;set;}
        
        @AuraEnabled
        public string KnowldgeVersionId{get;set;}
        
        @AuraEnabled
        public string Body { get; set; }

        @AuraEnabled
        public string ArticleType { get; set; }
        
        public Record() {}
        public Record(SObject objRecord) {
            KAId = (String)objRecord.get('Id');
            Title = (String)objRecord.get('Title');
            Body = (String)objRecord.get('summary');
            ArticleType = (String)objRecord.get('ArticleType');
        }
    }
    
    /*
    @AuraEnabled
    public static List<Record> getTrendingArticles() {
    ConnectApi.KnowledgeArticleVersionCollection  KACollect  = 
    ConnectApi.Knowledge.getTrendingArticles('', 5);
    return null;
} */

}