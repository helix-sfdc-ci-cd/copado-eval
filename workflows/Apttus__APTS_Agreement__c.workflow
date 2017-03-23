<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>APTS_Change_Status_Auth</fullName>
        <description>Status to Author Contract</description>
        <field>Apttus__Status__c</field>
        <literalValue>Author Contract</literalValue>
        <name>APTS_Change_Status_Auth</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APTS_Change_Status_Category</fullName>
        <field>Apttus__Status_Category__c</field>
        <literalValue>In Authoring</literalValue>
        <name>APTS_Change_Status_Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APTS_Reset_Workflow_trigger</fullName>
        <field>Apttus__Workflow_Trigger_Viewed_Final__c</field>
        <literalValue>0</literalValue>
        <name>APTS_Reset Workflow trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APTS_Set_Agreement_Value</fullName>
        <field>Apttus__Total_Contract_Value__c</field>
        <formula>CASE(Text(APTS_Fees__c), &apos;Time &amp; Material Basis&apos;,  APTS_Time_Material_Fee__c, &apos;Fixed Fee Basis&apos;,  APTS_Fixed_Fee__c,APTS_Total_Milestone_Fee__c)</formula>
        <name>APTS_Set Agreement Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APTS_Set_Status_to_Request</fullName>
        <field>Apttus__Status__c</field>
        <literalValue>Request</literalValue>
        <name>APTS_Set Status to Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APTS_Set_Termination_Date</fullName>
        <field>Apttus__Termination_Date__c</field>
        <formula>TODAY()</formula>
        <name>APTS_Set Termination Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SearchFieldUpdate</fullName>
        <description>Update the account search field with Account Name</description>
        <field>Apttus__Account_Search_Field__c</field>
        <formula>Apttus__Account__r.Name  &amp;  Apttus__FF_Agreement_Number__c</formula>
        <name>Search Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetAgreementNumber</fullName>
        <description>Set agreement number from the auto generated contract number</description>
        <field>Apttus__Agreement_Number__c</field>
        <formula>Apttus__Contract_Number__c</formula>
        <name>Set Agreement Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetClonetriggertofalse</fullName>
        <description>Set Clone trigger to false</description>
        <field>Apttus__Workflow_Trigger_Created_From_Clone__c</field>
        <literalValue>0</literalValue>
        <name>Set Clone trigger to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>APTS_Default_Workflow_Rule_SelfService</fullName>
        <actions>
            <name>APTS_Change_Status_Auth</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>APTS_Change_Status_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>APTS_Reset_Workflow_trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status_Category__c</field>
            <operation>equals</operation>
            <value>Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Workflow_Trigger_Viewed_Final__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set Status Category / Status for In Authoring / Author Contract</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>APTS_Set Agreement Value</fullName>
        <actions>
            <name>APTS_Set_Agreement_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status__c</field>
            <operation>notEqual</operation>
            <value>Activated</value>
        </criteriaItems>
        <description>Set Agreement Value based on Fee Type</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>APTS_Set Default Status to Author Contract</fullName>
        <actions>
            <name>APTS_Change_Status_Auth</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status_Category__c</field>
            <operation>equals</operation>
            <value>In Authoring</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>APTS_Set Default Status to Request</fullName>
        <actions>
            <name>APTS_Set_Status_to_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status_Category__c</field>
            <operation>equals</operation>
            <value>Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>APTS_Set Termination Date</fullName>
        <actions>
            <name>APTS_Set_Termination_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status__c</field>
            <operation>equals</operation>
            <value>Terminated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Termination_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Reset Clone Trigger</fullName>
        <actions>
            <name>Apttus__SetClonetriggertofalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Workflow_Trigger_Created_From_Clone__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reset Clone Trigger</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Search Field Update</fullName>
        <actions>
            <name>Apttus__SearchFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate an external Id search field with account name, so that side bar support can work with Account name search</description>
        <formula>or(not (isnull(Apttus__Account__r.Name)) ,not (isnull(Apttus__FF_Agreement_Number__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Set Agreement Number</fullName>
        <actions>
            <name>Apttus__SetAgreementNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Agreement_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set agreement number for new agreements. The agreement number is auto generated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
