<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alpha_Order_Reminder_Email</fullName>
        <description>Alpha Order Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>alpha@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Alpha_Templates/Order_Reminder</template>
    </alerts>
    <rules>
        <fullName>Alpha Order Reminder Email</fullName>
        <active>false</active>
        <description>Sends the Order Reminder Email to leads that have a reg code that hasn&apos;t been used after 1 week from DATE TO BE SPECIFIED</description>
        <formula>AND(Invitation_Code_Used__c = FALSE, 
NOT(Invitation_Code__c =&quot;&quot;), not(isblank( Welcome_Email_Send_Date__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alpha_Order_Reminder_Email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lead.Welcome_Email_Send_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
