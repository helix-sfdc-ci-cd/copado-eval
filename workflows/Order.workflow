<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alpha_Order_Confirmation</fullName>
        <description>Alpha Order Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>BillToContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>alpha@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Alpha_Templates/Order_Confirmation_v2</template>
    </alerts>
    <alerts>
        <fullName>Beta_1st_Party_Order_Confirmation</fullName>
        <description>Beta 1st Party Order Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>BillToContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>beta@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Beta_Templates/Beta_Order_Confirmation_v2</template>
    </alerts>
    <alerts>
        <fullName>Send_Kit_Registration_Reminder</fullName>
        <description>Alpha Send Kit Registration Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>BillToContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>alpha@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Alpha_Templates/KIT_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>NS_Integration_Retry_1</fullName>
        <description>+1 to the previous NS Integration Retries counter.</description>
        <field>NS_Integration_Retries__c</field>
        <formula>PRIORVALUE( NS_Integration_Retries__c ) +1</formula>
        <name>NS Integration Retry + 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DNAG_Integration_Flag_to_FALSE</fullName>
        <field>Integrate_with_DNAG__c</field>
        <literalValue>0</literalValue>
        <name>Set DNAG Integration Flag to FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DNAG_Integration_Flag_to_TRUE</fullName>
        <field>Integrate_with_DNAG__c</field>
        <literalValue>1</literalValue>
        <name>Set DNAG Integration Flag to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_Order_Type</fullName>
        <description>Sets Default Order Type if not specified on creation</description>
        <field>Type</field>
        <literalValue>Narwhal Beta</literalValue>
        <name>Set Default Order Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Netsuite_Integration_Flag_to_FALSE</fullName>
        <field>Integration_Test__c</field>
        <literalValue>0</literalValue>
        <name>Set Netsuite Integration Flag to FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Netsuite_Integration_Flag_to_TRUE</fullName>
        <field>Integration_Test__c</field>
        <literalValue>1</literalValue>
        <name>Set Netsuite Integration Flag to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SO_Integration_Status_to_Ready</fullName>
        <field>Netsuite_Integration_Status__c</field>
        <literalValue>Ready for Sales Order Upload</literalValue>
        <name>Set SO Integration Status to Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Shipping_Confirmation_Send_Date_Time</fullName>
        <field>Shipping_Confirmation_Send_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Shipping Confirmation Send Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>1st Party Order Confirmation</fullName>
        <actions>
            <name>Beta_1st_Party_Order_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.BillToContactId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Partner_ID__c</field>
            <operation>equals</operation>
            <value>PA-6ZOM57IPBT2EXCFMWJPG4ZM3NRMKEW5C</value>
        </criteriaItems>
        <description>Triggers 1st Party Order Confirmation Email to BillTo Contact associated to the inserted Order</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alpha Kit Reminder Email Alert</fullName>
        <active>false</active>
        <description>Sends Kit Reminder Email to BillTo Contact if Registered By is not filled in on Order record at 3 weeks after Order is created</description>
        <formula>Isblank(Registered_By__c)</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Kit_Registration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Order.CreatedDate</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Alpha Order Confirmation</fullName>
        <actions>
            <name>Alpha_Order_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.BillToContactId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Triggers Order Confirmation Email to Alpha BillTo Contact associated to the inserted Order</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LDT Order Integrations OFF</fullName>
        <actions>
            <name>Set_DNAG_Integration_Flag_to_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Netsuite_Integration_Flag_to_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Turns OFF ERP and 3pl kit integrations when LDT true and not yet approved.</description>
        <formula>AND( LDT__c ,NOT(LDT_Approved__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LDT Order Integrations ON</fullName>
        <actions>
            <name>Set_DNAG_Integration_Flag_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Netsuite_Integration_Flag_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Turns on ERP and 3pl kit integrations when LDT is APPROVED</description>
        <formula>AND( LDT__c ,LDT_Approved__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NS Integration Retry Trigger</fullName>
        <actions>
            <name>NS_Integration_Retry_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_SO_Integration_Status_to_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.NS_Integration_Retries__c</field>
            <operation>lessOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Netsuite_Integration_Error_Detail__c</field>
            <operation>contains</operation>
            <value>An unexpected error occurred. Error ID:,Error executing Netsuite operation: com.netledger.common.exceptions.NLException: The Connection Pool is not,Error executing Netsuite operation: (503)Service Unavailable</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Netsuite_Integration_Status__c</field>
            <operation>equals</operation>
            <value>Error</value>
        </criteriaItems>
        <description>Evaluates number of retries and error messages. If conditions are met, the integration is retried</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Order Type on Order Creation</fullName>
        <actions>
            <name>Set_Default_Order_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets Order Type to Default value if not specified.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Shipping Confirmation Send Date</fullName>
        <actions>
            <name>Set_Shipping_Confirmation_Send_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Shipping_Confirmation_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Shipping Confirmation Sent is set to TRUE, this WFR will populate the Shipping Confirmation Send Date Date/Time field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
