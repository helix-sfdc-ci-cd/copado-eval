({
    disableControls : function(component) {
        component.find("noteInputTextArea").set("v.disabled", true);
        component.find("noteSaveButton").set("v.disabled", true);
    },
    enableControls : function(component) {
        component.find("noteInputTextArea").set("v.disabled", false);
        component.find("noteSaveButton").set("v.disabled", false);
    },
    getLogACallModel: function(component, event) {
    	var action = component.get("c.getViewModel");
    	action.setCallback(this, function(response) {
    		if(component.isValid() && response.getState() === "SUCCESS") {
    			var returnValue = response.getReturnValue();
    			if (returnValue.UserInfo.NVMContactWorld__MostRecentCall__c !== undefined) {
                    component.set("v.logACallModel", returnValue);
                    this.enableControls(component);
                }
            }
    	});
    	this.disableControls(component);
    	$A.enqueueAction(action);
    },
	save: function(component, event) {
        var action = component.get("c.saveLatestCallInfo");
        var logACallModel = component.get("v.logACallModel");
        console.log(logACallModel);

        action.setParams({ "note" : logACallModel.Note,
                           "whoId": logACallModel.WhoId,
                           "whatId": logACallModel.WhatId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid()) {
                this.saveNoteToast(component, response.getReturnValue());
                this.enableControls(component);
            }
        });
        this.disableControls(component);
        $A.enqueueAction(action);
    },
    saveNotesFromPreviousCallAndRefresh: function(component) {
        var action = component.get("c.saveLatestCallInfo");
        var logACallModel = component.get("v.logACallModel");
        action.setParams({ "note" : logACallModel.Note,
                           "user" : logACallModel.UserInfo,
                           "whoId": logACallModel.WhoId,
                           "whatId": logACallModel.WhatId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid()) {
                this.saveNoteToast(component, response.getReturnValue());
                this.getLogACallModel(component);
            }
        });
        this.disableControls(component);
        $A.enqueueAction(action);
    },
    saveNoteToast: function(component, response) {
        var toastEvent = $A.get("e.force:showToast");
        if (!response.State) {
            toastEvent.setParams({
                "title": "Oh no!",
                "message": response.Message,
                "type": "error"
            });
        } else {
            toastEvent.setParams({
                "title": "Relax!",
                "message": response.Message,
                "type": "success"
            });
        }
        toastEvent.fire();
    }
})