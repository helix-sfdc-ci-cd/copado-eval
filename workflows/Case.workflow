<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Integration_Errors_Queue_Email_Alert</fullName>
        <description>Integration Errors Queue Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>allen.wang@helix.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>accounts@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Beta_Templates/Integration_Error_Alert</template>
    </alerts>
    <alerts>
        <fullName>Send_Customer_Satisfaction_Survey_to_Customer</fullName>
        <description>Send Customer Satisfaction Survey to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_templates/CS_Survey</template>
    </alerts>
    <alerts>
        <fullName>TestNotify</fullName>
        <description>TestNotify</description>
        <protected>false</protected>
        <recipients>
            <recipient>jwoodbury@thirdwaveanalytics.com.helix.prd</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/TestNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Email_Field</fullName>
        <field>Email__c</field>
        <formula>SuppliedEmail</formula>
        <name>Update Email Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_From_contact</fullName>
        <description>Update email address from contact record</description>
        <field>Email__c</field>
        <formula>Contact.Email</formula>
        <name>Update Email From contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_from_Web_Email</fullName>
        <field>Email__c</field>
        <formula>SuppliedEmail</formula>
        <name>Update Email from Web Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_First_Name</fullName>
        <field>First_Name__c</field>
        <formula>Contact.FirstName</formula>
        <name>Update First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Has_Been_Closed_Checkbox</fullName>
        <field>Has_been_closed__c</field>
        <literalValue>1</literalValue>
        <name>Update Has Been Closed Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Name</fullName>
        <description>Pushes last name from Contact into Case</description>
        <field>Last_Name__c</field>
        <formula>Contact.LastName</formula>
        <name>Update Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Phone_Field</fullName>
        <field>Phone__c</field>
        <formula>Contact.Phone</formula>
        <name>Update Phone Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Trigger</fullName>
        <field>Check_Order_Registration__c</field>
        <literalValue>1</literalValue>
        <name>Update Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>3 Days after the Case Created Date</fullName>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Trigger</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.created_date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Email Field Update</fullName>
        <actions>
            <name>Update_Email_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Email_from_Web_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Email field with contents of &quot;Web Email&quot; if &quot;Email&quot; field is blank and &quot;Web Email&quot; field is NOT blank</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Update from Contact</fullName>
        <actions>
            <name>Update_Email_From_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Email field when Email and Web Email fields are blank but a Contact exists</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Integration Error Queue Notification</fullName>
        <actions>
            <name>Integration_Errors_Queue_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Integration Errors</value>
        </criteriaItems>
        <description>If a case is assigned to the Integration Errors queue, the specified distribution will be notified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Phone Number Update</fullName>
        <actions>
            <name>Update_Phone_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Phone__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactPhone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update phone number with Contact number if  &quot;phone&quot; field is blank and &quot;Contact Phone&quot; field is NOT blank</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Case First Name</fullName>
        <actions>
            <name>Update_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.First_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.FirstName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>populates First Name from Contact Record</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Case Last Name</fullName>
        <actions>
            <name>Update_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Last_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates Last Name field with Contact&apos;s last name (if case is associated with a Contact)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send CSAT Survey After Case Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Lab Process,Automation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Has_been_closed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>24 hours after Case is closed, send link to survey. Excludes automated cases.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Customer_Satisfaction_Survey_to_Customer</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Has Been Closed Checkbox</fullName>
        <actions>
            <name>Update_Has_Been_Closed_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the Case is closed, check the &quot;Has been closed&quot; box. This prevents customers from receiving a customer satisfaction link more than once for a single case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>testnotification</fullName>
        <actions>
            <name>TestNotify</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Allen</value>
        </criteriaItems>
        <description>for error trapping</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
