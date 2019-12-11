/**
 * @description Test Class for PIPNotesHelper
 *
 * @author Zach French
 * @date 2019-09-26
 */
@IsTest
private class PIPNotesHelperTest {
	
	/** 
	 * @description Used to validate notes were collated in a list of ContentNoteLink records
	 *
	 * @return void
	 */
	@IsTest
	static void validateRetrievalOfNotes() {

		// Create Property record
		Property__c property = TestDataFactory.createProperty(true);

		Contract__c contract = TestDataFactory.createContract(false);
		contract.Property__c = property.Id;
		insert contract;

		Opportunity deal = TestDataFactory.createDeal(false);
		deal.Property__c = property.Id;
		insert deal;

		// Create PIP record
		TASKRAY__Project__c pip = TestDataFactory.createPIP(false);
		pip.Property__c = property.Id;
		insert pip;

		// Create Content Note

		String body = 'This is the body of a note.';
		List<ContentNote> contentNotes = new List<ContentNote> {
			new ContentNote(
				Title = '1',
				Content = Blob.valueOf(body.escapeHTML4())),
			new ContentNote(
				Title = '2',
				Content = Blob.valueOf(body.escapeHTML4())),
			new ContentNote(
				Title = '3',
				Content = Blob.valueOf(body.escapeHTML4()))
		};

		insert ContentNotes;

		// Create ContentDocumentLink
		List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
		for(ContentNote contentNote : contentNotes) {
			ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
			contentDocumentLink.ContentDocumentId = ContentNote.Id;
			contentDocumentLink.LinkedEntityId = contentNote.Title != '3' ? property.Id : pip.Id;
			contentDocumentLink.ShareType = 'V';

			contentDocumentLinks.add(contentDocumentLink);
		}
		insert contentDocumentLinks;

		List<PIPNotesHelper.ContentNoteLink> contentNoteLinks = new List<PIPNotesHelper.ContentNoteLink>();

		Test.startTest();
		contentNoteLinks = PIPNotesHelper.getContentNotesByRecordId(property.Id);
		Test.stopTest();

		System.assert(!contentNoteLinks.isEmpty() && contentNoteLinks.size() > 0);
	}
}