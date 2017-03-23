({
	doInit: function(component, event, helper) {
		helper.getLogACallModel(component, event);
	},
	save : function(component, event, helper) {
		helper.save(component, event);
	},
	wireUpCallbacks: function(component, event, helper) {
		ContactPad.onCallStart(function(payload) {
			helper.saveNotesFromPreviousCallAndRefresh(component);
		});
	}
})