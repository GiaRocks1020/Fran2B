/**
 * @description Used to display notes
 *
 * @author Zach French
 * @date 2019-09-24
 */
({
    doInit: function(cmp, event, helper) {
        helper.getNotes(cmp, event, helper);
    },

    processRowAction : function(cmp, event, helper) {
		helper.handleClick(cmp, event);
		let rowActionObject = event.getParam('rowActionObject');

		cmp.set('v.rowActionObject', rowActionObject);

		let actions = cmp.get('v.actions');

		actions.forEach( function(action, index) {
			if(rowActionObject.action === action.name) {
			    cmp.set('v.selectedRowAction', action);
				action.invokeFunction(cmp, event, helper);
			}
		});
    },

    recordUpdate : function(cmp, event, helper) {
        helper.getNotes(cmp, event, helper);
    },

    refreshCurrentView : function(cmp, event, helper) {
        helper.getNotes(cmp, event, helper);
    },

    handleGotoRelatedList : function (cmp, event, helper) {
        helper.setViewAllURL(cmp, event, helper);
    },

});