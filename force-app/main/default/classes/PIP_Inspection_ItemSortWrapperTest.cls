/**
 *  @description Test class for PIP_Inspection_ItemSortWrapper class
 *  @author Pradnya Desai
 *  @date 2019-09-16
 */

@IsTest
private class PIP_Inspection_ItemSortWrapperTest {


    @IsTest
    static void testSortInspectionItems() {

        TaskRay__Project_Task__c pipItem = new TaskRay__Project_Task__c();
        pipItem.TASKRAY__Description__c = 'Test';
        insert pipItem;
        List<PIP_Inspection_Item__c> inspectionItemsList = new List<PIP_Inspection_Item__c>();

        String inspectionJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/PIP_Inspection_Item__c/a1M0v000001ImtrEAC"},"Id":"a1M0v000001ImtrEAC","LRA_Inspection_Results__c":"'+
                    'Incomplete0","LastModifiedDate":"2019-10-04T17:54:26.000+0000"}';

        PIP_Inspection_Item__c inspectionItems = (PIP_Inspection_Item__c)JSON.deserialize(inspectionJSON, PIP_Inspection_Item__c.class);

                    inspectionItemsList.add(inspectionItems);

        inspectionJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/PIP_Inspection_Item__c/a1M0v000001ImtqEAC"},"Id":"a1M0v000001ImtqEAC","LRA_Inspection_Results__c":"'+
                'Incomplete1","LastModifiedDate":"2019-10-02T17:54:26.000+0000"}';

        inspectionItems = (PIP_Inspection_Item__c)JSON.deserialize(inspectionJSON, PIP_Inspection_Item__c.class);

        inspectionItemsList.add(inspectionItems);

        inspectionJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/PIP_Inspection_Item__c/a1M0v000001ImtsEAC"},"Id":"a1M0v000001ImtsEAC","LRA_Inspection_Results__c":"'+
                'Incomplete2","LastModifiedDate":"2019-10-04T19:54:26.000+0000"}';

        inspectionItems = (PIP_Inspection_Item__c)JSON.deserialize(inspectionJSON, PIP_Inspection_Item__c.class);

        inspectionItemsList.add(inspectionItems);

        List<PIP_Inspection_ItemSortWrapper> inspectionItemWrapper = new List<PIP_Inspection_ItemSortWrapper>();
        for(PIP_Inspection_Item__c inspectionItem : inspectionItemsList){
            PIP_Inspection_ItemSortWrapper item = new PIP_Inspection_ItemSortWrapper(inspectionItem);
            inspectionItemWrapper.add(item);
        }

        inspectionItemWrapper.sort();

        System.assertEquals('Incomplete2',inspectionItemWrapper[0].inspectionItem.LRA_Inspection_Results__c);
        System.assertEquals('Incomplete0',inspectionItemWrapper[1].inspectionItem.LRA_Inspection_Results__c);
        System.assertEquals('Incomplete1',inspectionItemWrapper[2].inspectionItem.LRA_Inspection_Results__c);

    }


}