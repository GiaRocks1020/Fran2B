({
    processPagination: function(component,helper){
        let arrayToPaginate = component.get('v.filteredArrayToPaginate');
        if(!arrayToPaginate || !arrayToPaginate.length){
            helper.setEmptyCase(component);
            return;
        }
        let maxRecordsPerPage = component.get('v.maxRecordsPerPage');
        let totalPages = Math.ceil(arrayToPaginate.length / maxRecordsPerPage);

        component.set('v.totalPages',totalPages);
        let currentPage = component.get('v.currentPage');
        if(currentPage > totalPages){
            currentPage = totalPages;
            component.set('v.currentPage', totalPages);
        }
        helper.updateArrayPaginatedVar(component, helper, arrayToPaginate,currentPage,maxRecordsPerPage);
    },

    setEmptyCase: function (component) {
        component.set('v.filteredArrayToPaginate',[]);
        component.set('v.arrayPaginated',[]);
        component.set('v.currentPage',1);
    },

    updateArrayPaginatedVar: function (component,helper,arrayToPaginate,currentPage,maxRecordsPerPage) {
         //debugger;
        let beginIndex = ((currentPage - 1) * maxRecordsPerPage);
        var paginatedArray = arrayToPaginate.slice(beginIndex, beginIndex + maxRecordsPerPage);
        var tempId = paginatedArray[0].Id;
        var recordIdtoPageMap = new Map();

        //generate a map of the id to the page number it is displayed on.
        //this will later help us to determine which rows are selected on each page.
        for(var i=0; i<paginatedArray.length; i++){
            recordIdtoPageMap.set(paginatedArray[i].Id, currentPage);
        }
        component.set('v.arrayPaginated', paginatedArray);
        component.set('v.recordIdtoPageMap', recordIdtoPageMap);
        //Set the selected rows on the datatable
        component.find("dataTable").set("v.selectedRows", component.get('v.selection'));
        component.set('v.bypassSelection', false);
    },

    goToPrevious: function (component,helper,previousPage) {
        if(previousPage >= 1){
            component.set('v.currentPage', previousPage);
            helper.processPagination(component,helper);
        }
    },

    goToNext: function (component,helper,nextPage) {
        let maxRecordsPerPage = component.get('v.maxRecordsPerPage');
        let arrayToPaginate = component.get('v.arrayToPaginate');
        let totalPages = Math.ceil(arrayToPaginate.length / maxRecordsPerPage);
        if(nextPage <= totalPages){
            component.set('v.currentPage', nextPage);
            helper.processPagination(component,helper);
        }
    },

    sortData: function (component, helper, fieldName, sortDirection) {
        var data = component.get("v.filteredArrayToPaginate");
        var reverse = sortDirection !== 'asc';
        console.log('reverse: ' , reverse);
        data.sort(this.sortBy(fieldName, reverse));
        component.set('v.currentPage', 1);
        component.set('v.filteredArrayToPaginate', data);
        this.processPagination(component, helper);
    },

    sortBy: function (field, reverse, primer) {
       var key = primer
           ? function(x) { return primer(x[field]) }
           : function(x) { return x[field] };
       reverse = !reverse ? 1 : -1;
       return function (a, b) {
           var A = key(a);
           var B = key(b);
           return reverse * ((A > B) - (B > A));
       };
    },
})