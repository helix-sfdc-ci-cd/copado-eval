/* Controller associated with pages rendering the survey.
 * Used by SurveyPage, ResultsPage, TakeSurvey
 */
global virtual without sharing class ViewSurveyController {
    
    public List<Question> allQuestions{get;set;}
    public String  surveyThankYouText{get;set;}
    public String surveyContainerCss {get;set;}
    public Boolean thankYouRendered{get;set;}
    
    public String surveyId;
    public String  caseId;
    public String contactId;
    public String surveyTakerId;
    
    /* Retrieves the list of questions, the survey name, after retrieving the 
       necessary parameters from the url.
    */
 //------------------------------------------------------------------------------// 
    public viewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
    
        if(caseId == null || caseId.length() < 15){
            caseId = 'none';
        }
        if(contactId == null || contactId.length() < 15){
            contactId = 'none';
        }
        init();
    } 
    
    public void init() {
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<Question>();
            setupQuestionList();
            setSurveyCSSAndThankYou(surveyId);
            thankYouRendered = false;
        }       
    }
    
    
   /** Sets the survey's css and thank you text
    *  param: sID   The survey ID as specified in the DB
    */
    public void setSurveyCSSAndThankYou(String sId){
        Survey__c s = [SELECT Thank_You_Text__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
        
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null) {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyContainerCss = s.Survey_Container_CSS__c;
    }

  /** Fills up the List of questions to be displayed on the Visualforce page
   */   
    public void setupQuestionList() {
        
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name, s.Choices__c 
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
        
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (Survey_Question__c q : allQuestionsObject){ 
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            Question theQ = new Question(q);
            allQuestions.add(theQ);
        }
    }   
    
    public void submitResults() {
        try {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            
            for (Question q : allQuestions) {
                
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                if (q.renderSelectRadio == true) {

                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }

                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } else if (q.renderFreeText == true) {
                    if (q.required && q.choices == '') {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }
                    
                    sqr.Response__c = q.choices;
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } else if (q.renderSelectCheckboxes == true) {
                    if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }

                    for (String opt : q.selectedOptions) {
                        sqr = new SurveyQuestionResponse__c();
                        if (opt == '' || opt == null) {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    }
                } else if (q.renderSelectRow == true) {
                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                        return;
                    }

                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            if(AddSurveyTaker()) {
                for (SurveyQuestionResponse__c sqr : sqrList) {
                    sqr.SurveyTaker__c = surveyTakerId;
                }
                
                insert sqrList;
                thankYouRendered=true;
            }
        } catch(Exception e){
            
                System.debug('Exception: ' + e.getMessage());
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'));
            
        }
    }
    
    private Boolean AddSurveyTaker() {
        String userId;
        
        if (surveyId == null) {
            return false;
        }
        if(caseId.toUpperCase() == 'NONE' || caseId.length() < 15)
          caseId = null;    
        if(contactId.toUpperCase() == 'NONE' || contactId.length() < 15)
          contactId = null;         
        
        userId = UserInfo.getUserId();
        
        if(contactId != null && caseId != null) {
            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c 
                    From SurveyTaker__c Where Contact__c = :contactId and Survey__c = :surveyId 
                    and Case__c = :caseId and User__c = :userId];
            if(check != null && check.size() > 0) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));
                return false;       
            }
        }
        
        SurveyTaker__c st = new SurveyTaker__c();
        st.Contact__c = contactId;
        st.Survey__c = surveyId;
        st.Taken__c = 'false';
        st.Case__c = caseId;
        st.User__c = userId;
        insert st;  
        surveyTakerId = st.Id;
        return true;    
    }
}