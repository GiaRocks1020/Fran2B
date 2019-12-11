/**
 * @description Trigger for Files(Content Document) Object
 *
 * @author Sugandha Chugh
 * @date 2019-08-21
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update,
after delete, after undelete) {
    new ContentDocumentLinkTriggerHandler();
}