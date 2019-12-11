/**
 * @description Helper file
 *
 * @author Zach French
 * @date 2019-09-24
 */
({
	showToast : function(cmp, event, helper, status) {
	    let mode = 'dismissible';
	    let title = '';
	    let message = '';
	    let type = 'other';

	    if(status === 'SUCCESS') {
	        title = 'Success!';
	        type = 'success';
	        message = 'Success!';
	    } else if(status === 'ERROR') {
            title = 'Error!';
            type = 'error';
            message = 'Error!';
	    } else if(status === 'WARNING') {
            title = 'Warning!';
            type = 'warning';
            message = 'Warning!';
	    }

	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "mode": mode,
	        "type": type,
	        "title": title,
	        "message": message
	    });
	    toastEvent.fire();
	},

	handleClick: function (cmp, event) {
        cmp.set('v.disableButton', !cmp.get('v.disableButton'));
    },

    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    getNotes : function(cmp, event, helper) {
        helper.handleClick(cmp, event);

        helper.setActions(cmp, event, helper);
        helper.setColumns(cmp, event, helper);

        var action = cmp.get('c.getContentNotesByRecordId');
        action.setParams({
            recordId: cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var message = response.getReturnValue();

                message.forEach( function(value, index) {
                });

                console.log(message);
                cmp.set('v.notes', message);
                cmp.find("noteTable").reInit();
            }
                helper.handleClick(cmp, event);
        });
        $A.enqueueAction(action);
    },

    setColumns: function(component, event) {
        let actions = component.get('v.actions');

        component.set('v.columns', [
            {label: 'Title', fieldName: 'IdURL', type: 'url', sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'Title'
                    },
                },
                target: '_self'
            },
            {label: 'Text Preview', fieldName: 'TextPreview', type: 'text', sortable: true},
            {label: 'Parent Record', fieldName: 'linkedEntityURL', type: 'url', sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'LinkedEntityName'
                    },
                    target: '_self'
                }
            },
            {label: 'Parent Record Object', fieldName: 'sObjectTypeLabel', type: 'text', sortable: true},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true,
                typeAttributes: {
                    month: "2-digit",
                    day: "2-digit",
                    year: "numeric",
                    hour12: "true",
                    hour: "2-digit",
                    minute: "2-digit"
                } },
			{label: 'Created By', fieldName: 'CreatedByName', type: 'text', sortable: true},
            //{ type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' }, }
        ]);
    },

    setActions : function(cmp, event, helper) {
        cmp.set('v.actions', [
            //{label: 'Edit', name: 'edit', invokeFunction: },

        ]);

    },

	setViewAllURL : function(cmp, event, helper) {
	    let objectRecord = cmp.get('v.objectRecord');
	    let viewAllUrl = `/lightning/r/${objectRecord.Id}/related/view`;

		var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
          'url': viewAllUrl
        });
        urlEvent.fire();
	},

    showToastDate: function (component, event, type, title, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: msg,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },

});