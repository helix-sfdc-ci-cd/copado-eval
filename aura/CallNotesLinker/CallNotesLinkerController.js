({
    changeObjectType: function(component, event, helper) {
        helper.changeObjectType(component, event);
    },
    doInit: function(component, event, helper) {
        component.set("v.searchResults", null);
        helper.getObjectTypes(component);
    },
    doSearch: function(component, event, helper) {
        component.set("v.linkObjectName", document.getElementById('text-input-' + component.get("v.linkTarget")).value);
        helper.searchFor(component, component.get("v.linkObjectName"), component.get("v.linkObjectType"));
    },
    onCategoryDropdown: function(component, event, helper) {
        var objectTypesDropdownExpanded = component.get ("v.objectTypesDropdownExpanded");
        component.set("v.objectTypesDropdownExpanded", !objectTypesDropdownExpanded);
    },
    doLink: function(component, event, helper) {
        helper.doLink(component, event);
        helper.lockIn(component);
    },
    releaseAndClear: function(component, event, helper) {
        helper.unlink(component);
        helper.releaseLock(component);
    },
    onLinkedObjectIdChanged: function(component, event, helper) {
        if (!component.get("v.linkObjectId")) {
            component.set("v.lockedIn", false);
        }
        else {
            component.set("v.lockedIn", true);
        }
    }
})