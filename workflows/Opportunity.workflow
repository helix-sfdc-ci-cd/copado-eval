<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Coverage_Check_Date</fullName>
        <field>Coverage_Check_Date__c</field>
        <formula>Today ()</formula>
        <name>Coverage Check Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Definitive_Agreement</fullName>
        <description>Used to date stamp when &quot;Definitive Agreement: Obtained &amp; Added&quot; is checked</description>
        <field>Definitive_Agreement_Date__c</field>
        <formula>Today()</formula>
        <name>Definitive Agreement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MOU</fullName>
        <description>Used to date stamp with &quot;MOU: Obtained &amp; Added: is checked</description>
        <field>MOU_Date__c</field>
        <formula>Today ()</formula>
        <name>MOU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NDA</fullName>
        <description>Update date when NDA: Obtained &amp; Added is checked</description>
        <field>NDA_Date__c</field>
        <formula>Today ()</formula>
        <name>NDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Scientific_Eval</fullName>
        <description>Used to update &quot;Scientific Eval: Obtained &amp; Added&quot; is checked</description>
        <field>Scientific_Eval_Date__c</field>
        <formula>Today()</formula>
        <name>Scientific Eval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Coverage Check%3A Date Stamping for Sales Checklist</fullName>
        <actions>
            <name>Coverage_Check_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Coverage_Check_Obtained_Added__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used for updating dates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Definitive Agreement%3A Date Stamping for Sales Checklist</fullName>
        <actions>
            <name>Definitive_Agreement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Definitive_Agreement_Obtained_Added__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used for updating dates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MOU%3A Date Stamping for Sales Checklist</fullName>
        <actions>
            <name>MOU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.MOU_Obtained_Added__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used for updating dates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NDA%3A Date Stamping for Sales Checklist</fullName>
        <actions>
            <name>NDA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.NDA_Obtained_Added__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used for updating dates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Scientific Eval%3A Date Stamping for Sales Checklist</fullName>
        <actions>
            <name>Scientific_Eval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Scientific_Eval_Obtained_Added__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used for updating dates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
