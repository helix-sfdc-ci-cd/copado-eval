<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_SuperOrder_Alert</fullName>
        <ccEmails>c6q3t3v1d4l4c7i5@myhelix.slack.com</ccEmails>
        <description>New SuperOrder Alert</description>
        <protected>false</protected>
        <senderAddress>accounts@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Launch_Templates/Order_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Netsuite_SuperOrder_Integration_Trigger</fullName>
        <field>Netsuite_SuperOrder_Integration_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Netsuite SuperOrder Integration Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New SuperOrder  Alert</fullName>
        <actions>
            <name>New_SuperOrder_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>$Organization.Id =&quot;00D7A000000DEEa&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SuperOrder Integration Trigger - Normal Flow</fullName>
        <actions>
            <name>Netsuite_SuperOrder_Integration_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets checkbox to trigger integration when conditions are met</description>
        <formula>/*Normal Progression for SuperOrder Netsuite Integration Trigger */ /*Triggers for TransactionID changes handled separately */  AND(  /*Is the account 1st Party? */ OR(Partner_Channel__r.Name  =&quot;Helix&quot;, Partner_Channel__r.Name =&quot;Helix Promotional&quot;),   /*Is Payment Captured in SFDC but not NS? */  AND(Payment_Captured__c =TRUE,  Payment_Captured_in_Netsuite__c =FALSE),   /*Is order fully shipped? */  Fully_Shipped__c =TRUE,  /*Is Transaction ID Present?*/  transactionid__c &lt;&gt;&quot;&quot;,  /*Is Payment Not Yet Captured in NS?*/  Payment_Captured_in_Netsuite__c = FALSE,  /*Are there integration errors, if yes then don&apos;t integrate*/  Netsuite_Integration_Error_Details__c =&quot;&quot;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SuperOrder Integration Trigger - Reintegration Required</fullName>
        <actions>
            <name>Netsuite_SuperOrder_Integration_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This is for situations that require a re-integration with NS, such as a change to transaction ID. Sets checkbox to trigger integration when conditions are met</description>
        <formula>/*TransactionID Changed and update to NS required */   AND(  /*Is the account 1st Party? */ OR(Partner_Channel__r.Name  =&quot;Helix&quot;, Partner_Channel__r.Name =&quot;Helix Promotional&quot;),   /*Is Payment Captured in SFDC? */  Payment_Captured__c =TRUE,   /*Is order fully shipped? */  Fully_Shipped__c =TRUE,  /*Was Transaction ID Present?*/   PRIORVALUE(transactionid__c )&lt;&gt;&quot;&quot; ,  /*Has TransactionID been updated?*/    ISCHANGED(transactionid__c ),   /*Is TransactionID present?*/  transactionid__c &lt;&gt;&quot;&quot;,  /*Are there integration errors? if yes then don&apos;t integrate*/  Netsuite_Integration_Error_Details__c =&quot;&quot;,  /*Is flag for integration already set?*/   Netsuite_SuperOrder_Integration_Trigger__c =FALSE  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
