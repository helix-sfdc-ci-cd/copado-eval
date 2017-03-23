/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 3/20/2016
    @Purpose: This is the util class for generic methods that can be used by multiple APIs
*/
public with sharing class HMAPI_SFDC_IntegrationUtil {
    
    static Id b2cAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Helix B2C Account').getRecordTypeId();
    static Id b2cContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Helix B2C Contact').getRecordTypeId();
    
    //create new account
     public static Id createNewAccount(HM_Account hmAccount){
        Account acc = new Account(name = hmAccount.contact.firstName+' '+hmAccount.contact.lastName, RecordTypeId = b2cAccountRTId);
        insert acc;
        return acc.Id;
        
    }
    
    //create new contact. this also includes creation of legal agreements for the contacts 
    public static Id createNewContact(HM_Contact hmContact, HM_Address hmAddress, String addressType, Id accId, Id sourcingPartnerId, 
                                            Boolean hasOptedOutOfEmail, Boolean isFirstPartyOrder){
        
        Contact con = new Contact(firstname = hmContact.firstName, lastName = hmContact.lastName, email = hmContact.email, accountId = accId, userid__c = hmContact.userId,
                                    phone = hmContact.phone, HasOptedOutOfEmail = hasOptedOutOfEmail, RecordTypeId = b2cContactRTId);
        
        if(sourcingPartnerId != null)
            con.Sourcing_Partner__c = sourcingPartnerId;
        
        addressType = getAddressFieldName(addressType);
        String companyField = getCompanyFieldName(addressType);
        mapAddressFieldsOnContact(con, addressType, hmAddress, companyField);
        insert con;
        
        createAgreement(hmContact, con.Id);
        return con.Id;
    }
    
    public static String getAddressFieldName(String addressType) {
        if(addressType != null && addressType.equals('Billing')) {
            addressType = 'Other';
        } else if(addressType != null && addressType.equals('Shipping')) {
            addressType = 'Mailing';
        }
        return addressType;
    }
    
    public static String getCompanyFieldName(String addressType) {
        String companyField = '';
        if(addressType != null && addressType.equals('Billing')) {
            companyField = 'Company_BillTo__c';
        } else if(addressType != null && addressType.equals('Shipping')) {
            companyField = 'Company_ShipTo__c';
        }
        return companyField;
    }
    
    public static Contact mapAddressFieldsOnContact(Contact con, String addressType, HM_Address hmAddress, String companyField) {
        if(hmAddress != null) {
        String street2 = (hmAddress.street2 == null || hmAddress.street2 == 'null' )? '' : hmAddress.street2;
            
            con.put(addressType + 'Street', hmAddress.street1 + '\n'+ street2);
            con.put(addressType + 'City', hmAddress.city);
            con.put(addressType + 'State', hmAddress.state);
            con.put(addressType + 'Country', hmAddress.country);
            con.put(addressType + 'PostalCode', hmAddress.zip);
            
            if(companyField != null && companyField != '')
                con.put(companyField, hmAddress.company);
        }
        return con;
    }
    
    //create new contact. this also includes creation of legal agreements for the contacts 
    public static Id createNewContact(HM_Contact hmContact, Id accId){
        
        Contact con = new Contact(firstname = hmContact.firstName, lastName = hmContact.lastName, email = hmContact.email, accountId = accId, userid__c = hmContact.userId,
                                    phone = hmContact.phone, Naturally_Black_Hair__c = hmContact.blackNaturally, Biological_Sex__c = hmContact.biologicalSex);
        
        if(hmContact.dateOfBirth != null)
            con.Birthdate = hmContact.dateOfBirth;
        insert con;
        
        createAgreement(hmContact, con.Id);
        return con.Id;
    }
    
    public static void createAgreement(HM_Contact hmContact, Id conId) {
        List<Legal_Agreement__c> agreeList = new List<Legal_Agreement__c>();
        if(hmContact.agreements != null){
            for(HM_Agreement mnt : hmContact.agreements){
                Legal_Agreement__c agmt = new Legal_Agreement__c();
                agmt.key__c = mnt.key;
                agmt.version__c = mnt.version;
                agmt.Contact__c = conId;
                agmt.agreed__c = mnt.agreed;
                agmt.agreedDateTime__c = mnt.agreedDateTime != null ? mnt.agreedDateTime : System.now();
                agmt.appId__c = mnt.appId;
                agreeList.add(agmt);
            }
        }
        if(agreeList.size() > 0){
            insert agreeList;
        }
    }
    
    //Method called when UserId is not null
    public static Contact getExistingContact(String userId){     
        //Querying Contact with the given userId
        Contact con;
        List<Contact> conList = [ Select Id, phone,Naturally_Black_Hair__c,Biological_Sex__c, AccountId, Account.NON_BUYER_Account__c, Sourcing_Partner__c,
                                  HasOptedOutOfEmail, Marketing_Opt_Out__c, Reminder_Opt_Out__c, Account.Account_Status__c From Contact Where userid__c = :userId ];
        if(conList.size() > 0){
            con = conList[0];
        }
        
        return con;
    }
    
    /*public static Boolean isDuplicateOrder(String partnerChannel, String partnerOrderNumber) {
        List<Order> orderList = [select id from Order where Partner_Channel__r.Partner_Id__c = :partnerChannel
                                        and Partner_Order_Number__c = :partnerOrderNumber limit 1];
        if(orderList != null && orderList.size() > 0)
            return true;
        else 
            return false;
    }*/
    
    public static Map<Integer, Order> createrOrderList(List<HM_Order> orderList, String billToAccId, Id pbId, 
                    String partnerId, Super_Order superOrder, SuperOrder__c sOrderRec, String billToConId,
                    String shipToConId, Contact existingContact) {
        Map<Integer, Order> mapOrderList = new Map<Integer, Order>();
        Integer count = 1;
        if(orderList != null) {
            for(HM_Order hmOrder : orderList) {
                Order o = new Order(accountid = billToAccId, transactionid__c = superOrder.transactionId, Status = 'Draft',
                             EffectiveDate = system.today(), Partner_Channel__c = partnerId, PriceBook2Id = pbId, 
                             Partner_affiliated_Customer_ID__c = superOrder.partnerAffiliatedCustomerId,
                             Partner_Order_Number__c = superOrder.partnerOrderNumber, SuperOrder__c = sOrderRec.id,
                             Tax_Doc_ID__c = superOrder.taxDocId);
                if(hmOrder.ldt != null)  {
                    o.LDT__c = hmOrder.ldt;
                }
                if(hmOrder.ldtApproved != null)  {
                    o.LDT_Approved__c = hmOrder.ldtApproved;
                }
                if(superOrder.shippingAddress != null){   
                    o.shippingcountry = superOrder.shippingAddress.country;
                    o.shippingCity = superOrder.shippingAddress.city; 
                    o.shippingState = superOrder.shippingAddress.state;
                    String street2 = (superOrder.shippingAddress.street2 == null || superOrder.shippingAddress.street2 == 'null' )? '' : superOrder.shippingAddress.street2;
                    o.shippingstreet = superOrder.shippingAddress.street1+'\n'+street2; 
                    o.shippingpostalcode = superOrder.shippingAddress.zip;
                    o.Company_ShipTo__c = superOrder.shippingAddress.company;
                    o.User_specified_Address__c = superOrder.shippingAddress.userSpecifiedAddress;
                }
                if(superOrder.billingAddress != null){ 
                    o.billingcountry = superOrder.billingAddress.country; 
                    o.billingCity = superOrder.billingAddress.city; 
                    o.billingState = superOrder.billingAddress.state;
                    String street2 = superOrder.billingAddress.street2 == null ? '' : superOrder.billingAddress.street2;
                    o.billingstreet = superOrder.billingAddress.street1 + '\n' + street2; 
                    o.billingpostalcode = superOrder.billingAddress.zip;
                    o.Company_BillTo__c = superOrder.billingAddress.company;
                }
                o.BillToContactId = billToConId != null ? billToConId : (existingContact != null ? existingContact.Id : null);
                if(hmOrder.isShipToSameAsBillTo != null && hmOrder.isShipToSameAsBillTo){
                    o.ShipToContactId = o.BillToContactId;
                    
                } else if(shipToConId != null) {
                    o.ShipToContactId = shipToConId;
                }
                mapOrderList.put(count, o);
                count++;
            }
        }
        return mapOrderList;
    }
    
    /* Kit_type_products, partnerShippingOption are passed as parameters
       1. convert list of Kit_type_products to set: to check whether set contains orderLine sku
       2. check in orderLine loop whether Kit_type_products set contains orderLine sku
       3. if yes, then 
           a. populate partnerShippingOption.Carrier__c and partnerShippingOption.Service_Level__c on kit line orderItem
           b. shipping_produt_id = partnerShippingOption.Shipping_Product__c
           c. create an order line for shipping_produt_id, outside orderLine loop and inside order loop
       4. kitLinesCount = size of list of Kit_type_products
       5. populate unitPrice on shpping_product by calling method getUnitPrice(kitLinesCount, partnerShippingOption)
    */
    
    public static List<OrderItem> createOrderLineList(List<HM_Order> orderList, Map<String, PricebookEntry> productIdToPricebkEntry,
                                         Map<Integer, Order> mapOrderList, String billToConId, String shipToConId, 
                                         Boolean srcPartMatchHelixId, Boolean partnerChannelExist, 
                                         Partner_Shipping_Option__c partnerShippingOption, Integer kitLinesCount,
                                         Decimal totalTax) {
        
        List<OrderItem> lineList = new List<OrderItem>();
        Integer orderCount = 1;
        Decimal kitLineUnitPrice = 0;
        if(kitLinesCount > 0) {
            kitLineUnitPrice = getShippingLineUnitPrice(kitLinesCount, partnerShippingOption);
        }
        List<Order> orderToUpdateList = new List<Order>();
        Map<Id, Decimal> mapOrderPrice = new Map<Id, Decimal>();
        Decimal totalPrice = 0;
        
        for(HM_Order hmOrder : orderList) {
            Order orderObj = mapOrderList.get(orderCount);
            Id orderId = orderObj.id;
            
            Decimal appUnitPrice = 0;
            PricebookEntry appPbe;
            Decimal totalAppKitPrice = 0;
            for(HM_OrderLine line : hmOrder.lines){
                
                OrderItem lineItem1 = new OrderItem();
                
                if(productIdToPricebkEntry != null && productIdToPricebkEntry.containsKey(line.sku)) {
                    PricebookEntry pbe = productIdToPricebkEntry.get(line.sku);
                    if(pbe.Product2.Type__c == 'APP') {
                        appPbe = pbe;
                        appUnitPrice = line.unitPrice;
                        orderObj.App_Partner__c = pbe.Product2.Partner_Account__c;
                        orderToUpdateList.add(orderObj);
                        lineItem1 = createOrderLine(orderId, line.quantity, line.sku,
                                            appUnitPrice, productIdToPricebkEntry, billToConId, shipToConId);
                        totalAppKitPrice += appUnitPrice;
                        totalPrice += appUnitPrice;
                    } else if(pbe.Product2.Type__c == 'KIT') {
                        lineItem1 = createOrderLine(orderId, line.quantity, line.sku,
                                            line.unitPrice, productIdToPricebkEntry, billToConId, shipToConId);
                        lineItem1.Carrier__c = partnerShippingOption.Carrier__c;
                        lineItem1.Service_Level__c = partnerShippingOption.Service_Level__c;
                        totalAppKitPrice += line.unitPrice;
                        totalPrice += line.unitPrice;
                    }
                }
                lineList.add(lineItem1);
            }
            mapOrderPrice.put(orderId, totalAppKitPrice);
            orderCount++;
            if(appPbe != null) {
                Decimal minimumFee = appPbe.Product2.Minimum_Fee__c == null ? 0 : appPbe.Product2.Minimum_Fee__c;
                Decimal unitPricePartRev = 0;
                if(partnerChannelExist) {
                    unitPricePartRev = appUnitPrice - minimumFee;
                    if(srcPartMatchHelixId) {
                        Decimal partRevShare_pct = appPbe.Product2.Partner_Revenue_Share_PCT__c == null ? 0 : appPbe.Product2.Partner_Revenue_Share_PCT__c;
                        unitPricePartRev = unitPricePartRev * partRevShare_pct/100;
                        
                        Decimal unitPriceHelixRev = appUnitPrice - minimumFee - unitPricePartRev;
                        OrderItem refFeeLineItem = createOrderLine(orderId, 1, System.Label.Helix_Referral_Fee, unitPriceHelixRev, productIdToPricebkEntry, billToConId, shipToConId);
                        lineList.add(refFeeLineItem);
                    }
                    Decimal helixSeqPrice =  minimumFee;
                    OrderItem seqRevLineItem = createOrderLine(orderId, 1, System.Label.Helix_Sequence_Revenue, helixSeqPrice, productIdToPricebkEntry, billToConId, shipToConId);
                    lineList.add(seqRevLineItem);
                    OrderItem partnerRevLineItem = createOrderLine(orderId, 1, System.Label.Partner_Revenue_Share, unitPricePartRev, productIdToPricebkEntry, billToConId, shipToConId);
                    lineList.add(partnerRevLineItem);
                } else {
                    Decimal helixSeqPrice =  minimumFee - (appPbe.Product2.Kit_Revenue__c == null ? 0 : appPbe.Product2.Kit_Revenue__c);
                    OrderItem seqRevLineItem = createOrderLine(orderId, 1, System.Label.Helix_Sequence_Revenue, helixSeqPrice, productIdToPricebkEntry, billToConId, shipToConId);
                    lineList.add(seqRevLineItem);
                    Decimal kitRevenueUnitPrice = appPbe.Product2.Kit_Revenue__c == null ? 0 : appPbe.Product2.Kit_Revenue__c;
                    OrderItem kitRevenueLineItem = createOrderLine(orderId, 1, System.Label.Kit_Revenue, kitRevenueUnitPrice, productIdToPricebkEntry, billToConId, shipToConId);
                    lineList.add(kitRevenueLineItem);
                }
            }
            if(kitLinesCount > 0) {
                OrderItem shipProdLineItem = createOrderLine(orderId, 1, partnerShippingOption.Shipping_Product__r.ProductCode, kitLineUnitPrice, productIdToPricebkEntry, billToConId, shipToConId);
                lineList.add(shipProdLineItem);
            }
        }
        /* adding sales tax line item
           1. mapOrderPrice has key as id of each order and value as price of total of app and kit product price
           2. totalPrice is the total sum of price of all orders
           3. totalTax is the total tax from super order which is to be divided among the sales tax order lines
           4. salesTaxLineItem is sales tax line item
        */
        for(Id oId :mapOrderPrice.keySet()) {
            Decimal unitPrice = 0;
            if((totalPrice != null && totalPrice > 0 ) && totalTax != null)
                unitPrice = (mapOrderPrice.get(oId) / totalPrice) * totalTax;
            OrderItem salesTaxLineItem = createOrderLine(oId, 1, System.Label.Sales_Tax_Product_Code, unitPrice, productIdToPricebkEntry, billToConId, shipToConId);
            lineList.add(salesTaxLineItem);
        }
        
        if(orderToUpdateList != null && orderToUpdateList.size() > 0)
            update orderToUpdateList;
            
        return lineList;
    }
    
    public static OrderItem createOrderLine(Id ordId, Decimal qty, String prodCode,  
                Decimal unitPrice, Map<String, PricebookEntry> productIdToPricebkEntry, String billToConId, String shipToConId){
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = ordId;
        lineItem.quantity = qty;
        lineItem.UnitPrice = 0;
        System.debug('prodCode===' + prodCode);
        System.debug('productIdToPricebkEntry.containsKey(prodCode)===' + productIdToPricebkEntry.containsKey(prodCode));
        if(prodCode != null && prodCode != '' && productIdToPricebkEntry.containsKey(prodCode)){
            PricebookEntry pbe = productIdToPricebkEntry.get(prodCode);
            lineItem.pricebookentryId = pbe.id;
            lineItem.AppID__c = pbe.Product2.AppID__c;
            
        }
        if(unitPrice != null)
            lineItem.UnitPrice = unitPrice;
        lineItem.BillTo_Contact__c = billToConId;
        lineItem.ShipTo_Contact__c = shipToConId;
        return lineItem;
    }
    
    
    public static Set<String> getProdSet(List<HM_Order> orderList) {
        Set<String> prodSet = new Set<String>{System.Label.Helix_Sequence_Revenue, System.Label.Partner_Revenue_Share, System.Label.Helix_Referral_Fee, System.Label.Kit_Revenue, System.Label.Sales_Tax_Product_Code};
        for(HM_Order hmOrder : orderList) {
            if(hmOrder != null && hmOrder.lines != null) {
                for(HM_OrderLine line : hmOrder.lines){
                    if(line.sku != null)
                        prodSet.add(line.sku);
                }
            }
        }
        return prodSet;
    }
    
    public static Map<String, PricebookEntry> getMapPricebookEntry(Set<String> prodSet, Id pbId) {   
        Map<String, PricebookEntry> productIdToPricebkId = new Map<String, PricebookEntry>();
        for(PricebookEntry  p :[SELECT Product2Id,Product2.name, UnitPrice, Product2.AppID__c, Product2.Minimum_Fee__c, 
                                Product2.Partner_Revenue_Share_PCT__c, Product2.Type__c, Id,ProductCode,
                                Product2.Kit_Revenue__c, Product2.Partner_Account__c FROM PricebookEntry 
                                WHERE ProductCode in :prodSet AND  PriceBook2Id = :pbId]){
            productIdToPricebkId.put(p.Productcode, p);     
        
        }
        return productIdToPricebkId;
    }
    
    public static Integer kitLinesCount(List<HM_Order> orderList, Map<String, PricebookEntry> productIdToPricebk) {
        Integer kitLinesCount = 0;
        for(HM_Order hmOrder : orderList) {
            for(HM_OrderLine line : hmOrder.lines){
                if(productIdToPricebk != null && productIdToPricebk.containsKey(line.sku)) {
                    PricebookEntry pbe = productIdToPricebk.get(line.sku);
                    if(pbe.Product2.Type__c == 'KIT') {
                        kitLinesCount++;
                    }
                }
            }
        }
        return kitLinesCount;
    }
    
    // check if carrier and shipping_method matches for partner in "Partner_Shipping_Option__c" object 
    // return Partner_Shipping_Option__c record
    public static Partner_Shipping_Option__c getPartnerShippingOption(String partnerChannelId, String carrier, String shippingMethod) {
        List<Partner_Shipping_Option__c> partnerShippingOptionList = [select Partner_Account__c, Shipping_Product__c, 
                                Shipping_Product__r.ProductCode, Default_Price__c, Carrier__c, Service_Level__c,
                                Rate_1_kit__c, Rate_2_kits__c, Rate_3_kits__c, Rate_4_kits__c, Rate_5_kits__c,
                                Rate_6_kits__c, Rate_7_kits__c, Rate_8_kits__c, Rate_9_kits__c, Rate_10_kits__c,
                                Rate_11_kits__c, Rate_12_kits__c, Rate_13_kits__c, Rate_14_kits__c, Rate_15_kits__c,
                                Rate_16_kits__c, Rate_17_kits__c, Rate_18_kits__c, Rate_19_kits__c, Rate_20_kits__c  
                                from Partner_Shipping_Option__c 
                                where Carrier__c = :carrier and Service_Level__c = :shippingMethod
                                and Partner_Account__c = :partnerChannelId];
        
        Partner_Shipping_Option__c partnerShippingOption = new Partner_Shipping_Option__c();
        if(partnerShippingOptionList != null && partnerShippingOptionList.size() > 0) {
            partnerShippingOption = partnerShippingOptionList[0];
        }
        return partnerShippingOption;
    }
    
    // this method returns the kit lines shipping cost
    public static Decimal getShippingLineUnitPrice(Integer kitLinesCount, Partner_Shipping_Option__c partnerShippingOption) {
        String shippingMethod = partnerShippingOption.Carrier__c + ' ' + partnerShippingOption.Service_Level__c;
        Decimal unitPrice = partnerShippingOption.Default_Price__c;
        Decimal defaultPrice = 0;
        
             if(kitLinesCount == 1) defaultPrice = partnerShippingOption.Rate_1_kit__c;
        else if(kitLinesCount == 2) defaultPrice = partnerShippingOption.Rate_2_kits__c;
        else if(kitLinesCount == 3) defaultPrice = partnerShippingOption.Rate_3_kits__c;
        else if(kitLinesCount == 4) defaultPrice = partnerShippingOption.Rate_4_kits__c;
        else if(kitLinesCount == 5) defaultPrice = partnerShippingOption.Rate_5_kits__c;
        else if(kitLinesCount == 6) defaultPrice = partnerShippingOption.Rate_6_kits__c;
        else if(kitLinesCount == 7) defaultPrice = partnerShippingOption.Rate_7_kits__c;
        else if(kitLinesCount == 8) defaultPrice = partnerShippingOption.Rate_8_kits__c;
        else if(kitLinesCount == 9) defaultPrice = partnerShippingOption.Rate_9_kits__c;
        else if(kitLinesCount == 10) defaultPrice = partnerShippingOption.Rate_10_kits__c;
        else if(kitLinesCount == 11) defaultPrice = partnerShippingOption.Rate_11_kits__c;
        else if(kitLinesCount == 12) defaultPrice = partnerShippingOption.Rate_12_kits__c;
        else if(kitLinesCount == 13) defaultPrice = partnerShippingOption.Rate_13_kits__c;
        else if(kitLinesCount == 14) defaultPrice = partnerShippingOption.Rate_14_kits__c;
        else if(kitLinesCount == 15) defaultPrice = partnerShippingOption.Rate_15_kits__c;
        else if(kitLinesCount == 16) defaultPrice = partnerShippingOption.Rate_16_kits__c;
        else if(kitLinesCount == 17) defaultPrice = partnerShippingOption.Rate_17_kits__c;
        else if(kitLinesCount == 18) defaultPrice = partnerShippingOption.Rate_18_kits__c;
        else if(kitLinesCount == 19) defaultPrice = partnerShippingOption.Rate_19_kits__c;
        else if(kitLinesCount == 20) defaultPrice = partnerShippingOption.Rate_20_kits__c;
        
        
        if(defaultPrice != null)
            unitPrice = defaultPrice/ kitLinesCount;
        
        return unitPrice;
    }
    
    public static Id getPartnerAccId(String partnerChannel) {
        Id partnerAccountId;
        
        for(Account acc :[Select Partner_ID__c From Account Where Partner_ID__c = :partnerChannel limit 1]) {
            partnerAccountId = acc.id;
        }
        return partnerAccountId;
    }
    
    public static void updateLead(String emailAddr) {
        List<Lead> leadList = [ Select Id, Invitation_Code__c, Invitation_Code_Used__c From Lead Where email = :emailAddr];
        if(leadList.size() > 0){
            Lead l = leadList[0];
            l.Invitation_Code_Used__c = true;
            update l;
        }
    }
    
    public static CreateOrderResponse validateOrder(List<HM_Order> orderList, Set<String> prodSet, Set<String> existingProdSet) { //, HM_Address shippingAddress
        
        CreateOrderResponse res;
        
        for(String p :prodSet) {
            System.debug('p====' + p);
            System.debug('existingProdSet===' + existingProdSet);
            if(!existingProdSet.contains(p)) {
                res = CreateOrderAPI.generateResponse('Product Not Available','Product Not Available',null,'');
                return res;
            }
        }
        for(HM_Order hmOrder : orderList) {
            for(HM_OrderLine line : hmOrder.lines){
                if(line.quantity > 1) {
                    res = CreateOrderAPI.generateResponse('Quantity should not be more than 1','Quantity should not be more than 1',null,'');
                    return res;
                }
            }
        }
        return res;
    }
    
    public static CreateOrderResponse success(List<Order> orderList, SuperOrder__c sOrderRec) {
        List<String> ordNumList = new List<String>();
        for(Order o :[select Helix_Order_Number__c from Order where id in :orderList]) {
            ordNumList.add(o.Helix_Order_Number__c);
        }
        sOrderRec = [select Name from SuperOrder__c where id = :sOrderRec.id limit 1];
        CreateOrderResponse res = CreateOrderAPI.generateResponse(null,null,ordNumList,sOrderRec.Name);
        return res;
    }
    
    public static Id getHelixPartnerAccId() {
        List<Account> accList = [select id from Account where Partner_Id__c = :System.Label.Helix_Partner_Id];
        Id accId;
        if(accList != null && accList.size() > 0) {
            accId = accList[0].id;
        }
        return accId;
    }
    
    public static Error_Log__c logError(String statusCode, String description, String typeOfError, String message, String cause) {
        Error_Log__c errorLog = new Error_Log__c(Error_Code__c = statusCode, 
                    System_Message__c = message, Description__c = description, Type__c = typeOfError,
                    Cause__c = cause);
        return errorLog;
    }
}