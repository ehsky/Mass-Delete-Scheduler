/**
 * @description       : This schedulable class deletes all records defined by queries in the custom metadata
 *                    : type Query. It calls the batchable class DeleteRecordsBatchable to perform the record deletion.
 * @author            : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @last modified on  : 08-29-2022
 * @last modified by  : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
public virtual without sharing class MassDeleteSchedulable implements Schedulable {
  // We are unable to insert custom metadata in test class therefor we make it visible for the test class to set on init.
  @testVisible
  List<Query__mdt> allQueries {
    get {
      if (allQueries == null) {
        allQueries = Query__mdt.getAll().values();
      }
      return allQueries;
    }
    set;
  }

  public void execute(SchedulableContext sc) {
    // Get all active Delete-Queries

    List<Query__mdt> deleteQueries = new List<Query__mdt>();
    for (Query__mdt q : allQueries) {
      if (q.IsActive__c && q.Operation_Type__c == 'Delete') {
        deleteQueries.add(q);
      }
    }

    // Trigger the batchable delete-class for each query.
    for (Query__mdt q : deleteQueries) {
      String queryString =
        'SELECT Id FROM ' +
        q.Object__c +
        ' WHERE ' +
        q.Condition__c;
      Boolean hardDelete = q.Is_Hard_Delete__c;

      MassDeleteBatchable b = new MassDeleteBatchable(queryString, hardDelete);
      Database.executeBatch(b);
    }
  }
}
