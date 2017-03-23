@isTest
private class Question_Test {
    @isTest
    private static void testQuestionController(){
        Survey_Question__c sq= new Survey_Question__c();
        
        sq.Question__c = 'Question';
        sq.Choices__c = 'Test1\nTest2';
        sq.Type__c = 'Single Select--Vertical';
        sq.Required__c = True;
        sq.OrderNumber__c = 2;

        Question q = new Question(sq);
        System.assertEquals(q.singleOptions.size(), 2);
        
        Survey_Question__c sqHorizontal = new Survey_Question__c();
        
        sqHorizontal.Question__c = 'Question';
        sqHorizontal.Choices__c = 'Test1\nTest2';
        sqHorizontal.Type__c = 'Single Select--Horizontal';
        sqHorizontal.Required__c = True;
        sqHorizontal.OrderNumber__c = 2;

        Question qh = new Question(sqHorizontal);
        
        System.assertEquals(qh.rowOptions.size(), 2);
    }
}