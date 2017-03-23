<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_productkey</fullName>
        <description>Copies Product Code to productkey on record creation and will prevent creation of a duplicate product code in a new product record.</description>
        <field>productuniquekey__c</field>
        <formula>ProductCode</formula>
        <name>Update productkey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_APP_Record_Type</fullName>
        <description>Updates Product to an App record type for App products</description>
        <field>RecordTypeId</field>
        <lookupValue>APP_RT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to APP Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_KIT_Record_Type</fullName>
        <description>Updates Product to a Kit Record Type</description>
        <field>RecordTypeId</field>
        <lookupValue>KIT_RT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to KIT Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_OTHER_Record_Type</fullName>
        <description>Updates Product to Other record type if non-kit or non-app product type</description>
        <field>RecordTypeId</field>
        <lookupValue>Other_RT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to OTHER Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>App Product WFR</fullName>
        <actions>
            <name>Update_to_APP_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Type__c</field>
            <operation>equals</operation>
            <value>APP</value>
        </criteriaItems>
        <description>Sets App Product attributes when a product is created or edited to Type = APP</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Kit Product WFR</fullName>
        <actions>
            <name>Update_to_KIT_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Type__c</field>
            <operation>equals</operation>
            <value>KIT</value>
        </criteriaItems>
        <description>Sets Kit Product attributes when a product is created or edited to Type = KIT</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OTHER Product WFR</fullName>
        <actions>
            <name>Update_to_OTHER_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Type__c</field>
            <operation>equals</operation>
            <value>OTHER</value>
        </criteriaItems>
        <description>Sets Other Product attributes when a product is created or edited to Type = OTHER</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update productkey</fullName>
        <actions>
            <name>Update_productkey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates productkey from Product Code on record creation to ensure uniqueness of product code. Prevents entry of a product record with a duplicate product code. THIS RULE MUST BE ACTIVE and run on every edit TO ENSURE PRODUCT CODE UNIQUENESS.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
