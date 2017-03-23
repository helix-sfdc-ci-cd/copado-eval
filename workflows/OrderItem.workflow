<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alpha_Thank_You_and_Survey_Email_Send</fullName>
        <description>Alpha Thank You and Survey Email Send</description>
        <protected>false</protected>
        <recipients>
            <field>registeredBy__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>alpha@helix.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Alpha_Templates/Thank_You_and_Survey</template>
    </alerts>
    <alerts>
        <fullName>Narwhal_Alpha_Kit_Accession_Alert</fullName>
        <description>Narwhal Alpha Kit Accession Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>jackie.yen@helix.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jwoodbury@thirdwaveanalytics.com.helix.prd</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.blanchard@helix.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Alpha_Templates/Narwhal_Alpha_Accessioned</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Hold_Reason</fullName>
        <description>Sets Hold Reason to NULL when hold no longer applies</description>
        <field>Hold_Reason__c</field>
        <name>Clear Hold Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Include_In_Actual_Order_Total_TRUE</fullName>
        <description>True for Apps, Tax, S&amp;H. Set by WFR on Order Product Creation.</description>
        <field>Include_In_Actual_Order_Total__c</field>
        <literalValue>1</literalValue>
        <name>Include In Actual Order Total TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NS_Integration_Retry_1</fullName>
        <description>+1 to the previous NS Integration Retries counter.</description>
        <field>NS_Integration_Retries__c</field>
        <formula>PRIORVALUE( NS_Integration_Retries__c ) +1</formula>
        <name>NS Integration Retry+1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Accessioning_Status_to_RETURN_TO_ACC</fullName>
        <description>Sets Accessioning Status to RETURN TO ACCESSIONING when Order Product that was HOLD/Contact Missing receives a Registered By Contact</description>
        <field>Accessioning_Status__c</field>
        <literalValue>RETURN TO ACCESSIONING</literalValue>
        <name>Set Accessioning Status to RETURN TO ACC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Analysis_Workflow</fullName>
        <description>persists current analysis workflow at time of accession pass</description>
        <field>Analysis_Workflow__c</field>
        <formula>text(PricebookEntry.Product2.Analysis_Workflow__c)</formula>
        <name>Set Analysis Workflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DNAG_Integration_Flag_to_FALSE</fullName>
        <description>Order Product level Integrate with DNAG flag set to FALSE.</description>
        <field>Integrate_with_DNAG__c</field>
        <literalValue>0</literalValue>
        <name>Set DNAG Integration Flag to FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Delivery_Date</fullName>
        <description>Sets Data Delivery Date to NOW()</description>
        <field>Data_Delivery_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Data Delivery Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_First_Accession_Scan_Date_Time</fullName>
        <field>First_Accessioning_Scan__c</field>
        <formula>now()</formula>
        <name>Set First Accession Scan Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Kit_Order_Status_to_Submit</fullName>
        <description>Sets Kit Order Status on Order Product to SUBMIT which will trigger order submission to Kit Vendor via the regular boomi integration job.</description>
        <field>Kit_Order_Status__c</field>
        <literalValue>Submit</literalValue>
        <name>Set Kit Order Status to Submit</name>
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
        <fullName>Set_Previous_Accessioning_Status</fullName>
        <field>Previous_Accessioning_Status__c</field>
        <formula>Text(PRIORVALUE( Accessioning_Status__c ))</formula>
        <name>Set Previous Accessioning Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Project_Name</fullName>
        <field>Project_Name__c</field>
        <formula>text(today()  - MOD(   today()  - DATE(1900, 1, 7), 7)+1)</formula>
        <name>Set Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Required_Yield</fullName>
        <description>populates required yield on kit order product. value will persist even if changed on product record.</description>
        <field>Required_Yield__c</field>
        <formula>value(text(PricebookEntry.Product2.Required_Yield__c ))</formula>
        <name>Set Required Yield</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sample_Status_to_Ready_for_Submissio</fullName>
        <description>sets sample status field to &apos;ready for submission&apos; which is used to trigger the BaseSpace integration to proceed</description>
        <field>Sample_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Set Sample Status to Ready for Submissio</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Shift_Time_9hrs</fullName>
        <description>Applies a +9hr time shift to adjust from supplied UTC time and avoid the appearance that shipments are occuring in the past</description>
        <field>Kit_Order_Shipped__c</field>
        <formula>Kit_Order_Shipped__c + (9/24)</formula>
        <name>Shift Time +9hrs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Kit_Order_Shipped</fullName>
        <description>Field update to capture when Kit Order Status changes to &quot;Shipped&quot; DEACTIVATED NOW THAT THIS VALUE IS SUPPLIED BY DNAG INTEGRATION</description>
        <field>Kit_Order_Shipped__c</field>
        <formula>NOW()</formula>
        <name>Update Kit Order Shipped Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Kit_Shipped_Status_Date</fullName>
        <field>Kit_Shipped_Status_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Kit Shipped Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Accession Pass Actions</fullName>
        <actions>
            <name>Set_Analysis_Workflow</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Project_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Required_Yield</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Sample_Status_to_Ready_for_Submissio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.Accessioning_Status__c</field>
            <operation>equals</operation>
            <value>PASS</value>
        </criteriaItems>
        <description>Sets and persists OP attributes on date that kit passes accessioning.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Accession Start Actions</fullName>
        <actions>
            <name>Set_First_Accession_Scan_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.Accessioning_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.Accessioning_Status__c</field>
            <operation>notEqual</operation>
            <value>CANCELLED</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Accessioning Status Change Actions</fullName>
        <actions>
            <name>Set_Previous_Accessioning_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Accessioning_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Adjust DNAG-Supplied Ship Date</fullName>
        <actions>
            <name>Shift_Time_9hrs</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.Kit_Order_Shipped__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Data Delivery Actions</fullName>
        <actions>
            <name>Set_Data_Delivery_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OrderItem.Sample_Status__c</field>
            <operation>equals</operation>
            <value>Data Delivery Complete</value>
        </criteriaItems>
        <description>Workflow that triggers when Sample Status switches to &quot;Data Delivery Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Kit Order Shipped Actions</fullName>
        <actions>
            <name>Update_Kit_Order_Shipped</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OrderItem.Kit_Order_Status__c</field>
            <operation>equals</operation>
            <value>Shipped</value>
        </criteriaItems>
        <description>Actions taken when Kit Order Status is set to &quot;Shipped&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NS Integration Retry Trigger</fullName>
        <actions>
            <name>NS_Integration_Retry_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Netsuite_Integration_Flag_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.NS_Integration_Retries__c</field>
            <operation>lessOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.Netsuite_Integration_Error_Details__c</field>
            <operation>contains</operation>
            <value>An unexpected error occurred. Error ID:,Error executing Netsuite operation: com.netledger.common.exceptions.NLException: The Connection Pool is not,Error executing Netsuite operation: (503)Service Unavailable.</value>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.Integration_Test__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Evaluates number of retries and error messages. If conditions are met, the integration is retried</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Narwhal Alpha Kit Receipt Alert</fullName>
        <actions>
            <name>Narwhal_Alpha_Kit_Accession_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>Narwhal Alpha</value>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.Accessioning_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Alerts key individuals when a Narwhal Alpha Kit is accessioned.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>On DNAG Error Set Integrate to FALSE</fullName>
        <actions>
            <name>Set_DNAG_Integration_Flag_to_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.Kit_Order_Status__c</field>
            <operation>equals</operation>
            <value>Error</value>
        </criteriaItems>
        <description>If the Kit Order Status on a kit record is set to ERROR, set the Integrate with DNAG checkbox to FALSE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Accessioning Status to RETURN TO ACC</fullName>
        <actions>
            <name>Clear_Hold_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Accessioning_Status_to_RETURN_TO_ACC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Accessioning Status to RETURN TO ACCESSIONING when Order Product that was HOLD/Contact Missing receives a Registered By Contact</description>
        <formula>AND( NOT(ISBLANK(registeredBy__c )),  ISPICKVAL(Accessioning_Status__c, &quot;HOLD&quot;), ISPICKVAL( Hold_Reason__c , &quot;Contact Missing&quot;),  Type__c =&quot;KIT&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Include In Actual Order Total to TRUE</fullName>
        <actions>
            <name>Include_In_Actual_Order_Total_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>OrderItem.Type__c</field>
            <operation>equals</operation>
            <value>APP</value>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.ProductCode</field>
            <operation>equals</operation>
            <value>Shipping &amp; Handling</value>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.ProductCode</field>
            <operation>equals</operation>
            <value>Sales Tax</value>
        </criteriaItems>
        <description>Include In Actual Order Total set by this rule for Apps, S&amp;H, Tax</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Kit Order Status to Submit</fullName>
        <actions>
            <name>Set_Kit_Order_Status_to_Submit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.Kit_Order_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OrderItem.Type__c</field>
            <operation>equals</operation>
            <value>KIT</value>
        </criteriaItems>
        <description>For Order Products with Type = KIT, sets Kit Order Status to Submit which will trigger submission of kit order to Kit Supplier at the next scheduled Boomi job. If Kit Order Status is populated on insert, Kit Order Status will not be changed by this rule</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set for CANCELLED Kit</fullName>
        <actions>
            <name>Set_Netsuite_Integration_Flag_to_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OrderItem.Accessioning_Status__c</field>
            <operation>equals</operation>
            <value>CANCELLED</value>
        </criteriaItems>
        <description>When Accession Status set to CANCELLED, this WFR sets related fields appropriately to prevent downstream errors.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Kit Shipped Status Date</fullName>
        <actions>
            <name>Update_Kit_Shipped_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ispickval( Kit_Order_Status__c, &quot;Shipped&quot;), ISNULL( Kit_Shipped_Status_Date__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
