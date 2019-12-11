({
    doInit: function (component, event, helper) {
        console.log('ACTIONS::: ' +component.get('v.actions'));
        component.set('v.filteredArrayToPaginate', component.get('v.arrayToPaginate'));
        component.set('v.currentPage', 1);
        helper.processPagination(component,helper);
    },

    updateColumnSorting : function(component,event,helper){
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        component.set('v.bypassSelection', true);
        helper.sortData(component, helper, fieldName, sortDirection);
    },

    previousPage: function (component,event,helper) {
       component.set('v.bypassSelection', true);
       helper.goToPrevious(component,helper,component.get('v.currentPage') - 1);
    },

    nextPage: function (component,event,helper) {
        component.set('v.bypassSelection', true);
        helper.goToNext(component,helper,component.get('v.currentPage') + 1);
    },

    processPagination: function(component, event, helper){
        helper.setEmptyCase(component, helper);
        helper.processPagination(component, helper, false);
    },

    setEmptyCase: function(component, event, helper){
        helper.setEmptyCase(component, helper);
    },

    handleButtonClickEvent: function(component, event, helper){
       //every time the button is clicked, fire an event to let parent know the button was clicked
       var compEvent = component.getEvent("oSelectedSearchBtnEvent");
       compEvent.fire();
    },

    handleSelectedRowChange: function (component, event, helper){
        //every time the selected rows list is changed, fire an event to make the parent component aware of the new
        //selected row values
        console.log('select:' , component.get('v.selection'));
        var getSelectRecord = component.get("v.selectedRowData");
        var compEvent = component.getEvent("oSelectedRowsEvent");
        compEvent.setParams({"selectedRows":getSelectRecord});
        compEvent.fire();
    },

    handleRowAction : function(component, event, helper) {

    },

    onRowSelection : function(component, event, helper) {
        //prevent entering when the page changes are a result of moving forward, next or filtering.
        if(component.get('v.bypassSelection')){
            component.set('v.bypassSelection', false);
            return;
        }

        //Get the select rows on current page
        var selectedRows = event.getParam('selectedRows');
        //Get all selected rows from datatable, this will give all the selected data from all the pages
        var allSelectedRowIds = component.get("v.selection");
        var allSelectedRows = component.get("v.selectedRowData");
        //Get current page number
        var currentPageNumber = component.get("v.currentPage");
        //get Id map
        var recordIdtoPageMap = component.get('v.recordIdtoPageMap');
        //get the maxSelection of checkboxes for the datatable
        var maxSelection = parseInt(component.get('v.maxSelection'));

        //Process the rows
        //Add or remove selected and deselected rows from the allSelectedRows attribute
        //Because we don't have a way of knowing if a row was selected or deselected when we enter this
        //function, remove current page rows from allSelectedRows attribute and then add only the selected rows

        //Removing all rows coming from current page from allSelectedRows, when the maxSelection is 1 then remove
        //everything regardless of page number as only one record can be selected at a time
        var i = allSelectedRowIds.length;
        while (i--) {
            var pageNumber = recordIdtoPageMap.get(allSelectedRowIds[i]);
            if(maxSelection > 1 || !maxSelection){
                if (pageNumber && pageNumber == currentPageNumber) {
                    allSelectedRowIds.splice(i, 1);
                    allSelectedRows.splice(i, 1);
                }
            }else{
                allSelectedRowIds.splice(i, 1);
                allSelectedRows.splice(i, 1);
            }
        }

        //Adding the new selected rows in allSelectedRows, if the max selection is 1 then do not add any previous
        //selections as only one item can be selected at the time.
        var selectRowLength = selectedRows.length;
        if(maxSelection > 1 || !maxSelection){
            for(var i=0; i<selectRowLength; i++){
                if(!allSelectedRowIds.includes(selectedRows[i].Id)){
                        allSelectedRowIds.push(selectedRows[i].Id);
                        allSelectedRows.push(selectedRows[i]);
                }
            }
        } else {
            if( selectedRows[selectRowLength-1]){
                allSelectedRowIds.push(selectedRows[selectRowLength-1].Id);
                allSelectedRows.push(selectedRows[selectRowLength-1]);
            }
        }

        //Setting new value in selection attribute
        component.set("v.selection", allSelectedRowIds );
        component.set("v.selectedRowData", allSelectedRows );
    },

    search: function (component, event, helper) {
        var val = component.get("v.searchValue").toLowerCase();
        var rows = JSON.parse(JSON.stringify(component.get("v.arrayToPaginate")));
        var columns = JSON.parse(JSON.stringify(component.get("v.columns")));
        var selectedRows = component.get("v.selection");
        var filteredRows = [];
        //if the search value was cleared out then expand to display all original records and re-paginate.
        if (val === undefined || val === '') {
            component.set("v.filteredArrayToPaginate", component.get('v.arrayToPaginate'));
            helper.processPagination(component,helper);
            return;
        }
        //loop through every column in every row to see if it matches the value entered in the searching by
        //if it matches the value or if the row had been previously selected, then add it to the list of rows
        //to display and re-paginate
        for (var i in rows) {
            for (var y in columns){
                var col = String(columns[y]['fieldName']);
                if(rows[i][col]){
                    if ((rows[i][col].toLowerCase().includes(val)) || selectedRows.indexOf(rows[i].Id) > -1) {
                        filteredRows.push(rows[i]);
                        break;
                    }
                }
            }
        }
        //if the search does not find any matches then clear the view, otherwise go paginate
        if(filteredRows.length<=0){
            component.set('v.arrayPaginated', []);
        }else{
            component.set('v.currentPage', 1);
            component.set("v.filteredArrayToPaginate", filteredRows);
            component.set('v.bypassSelection', true);
            helper.processPagination(component,helper);
        }
    },

    handleRowAction : function(component, event, helper) {
		var action = event.getParam('action');
        var row = event.getParam('row');

        let actions = component.get('v.actions');

        actions.forEach( function(actionObject, index) {
			if(actionObject.name === action.name) {
		        var rowActionEvent = component.getEvent("onSelectedRowActionEvent");
                rowActionEvent.setParams({
                    "rowActionObject": {
                        "selectedRows":row,
                        "action": action.name
                    }
                });
                rowActionEvent.fire();
			}
        });
    },
})