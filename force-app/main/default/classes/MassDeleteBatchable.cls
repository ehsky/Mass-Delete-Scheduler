/**
 * @description       : This class mass deletes the incoming objects and therfor should be handled with care.
 *                    : The purpose of this class is to do mass delete operations on any given salesforce object.
 *                    : Please note that the query for the object to be deleted is constructed by the caller.
 * @author            : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @last modified on  : 08-29-2022
 * @last modified by  : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
global with sharing class MassDeleteBatchable implements Database.Batchable<SObject>, Database.Stateful {
  global final String query;
  global final Boolean isHardDelete;
  private String originalTransactionId;
  private Integer numOfSuccessfulDeletions = 0;
  private Integer numOfUnsuccessfulDeletions = 0;

  /**
   * Take the incoming query into the constructor
   **/
  global MassDeleteBatchable(String q, Boolean hardDelete) {
    query = q;
    isHardDelete = hardDelete;
  }

  /**
   * Start the batch job
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
  }

  /**
   * Execute the query in the batch mode
   **/
  global void execute(Database.BatchableContext bc, List<SObject> scope) {
    List<Database.DeleteResult> deleteResultList = Database.delete(
      scope,
      false
    );

    for (Database.DeleteResult dr : deleteResultList) {
      if (dr.isSuccess()) {
        // Delete was successful
        // If you have a logger service you can get the Id of the record that was processed here.
        numOfSuccessfulDeletions++;
      } else {
        // Operation failed, so get all errors
        for (Database.Error err : dr.getErrors()) {
          // If you have a logger service you can get the error status and message of the failing record here.
        }
        numOfUnsuccessfulDeletions++;
      }
    }

    // Removes records from recycle bin
    if (isHardDelete) {
      Database.emptyRecycleBin(scope);
    }
  }

  /**
   * Finish the batch job.
   **/
  global void finish(Database.BatchableContext BC) {
    System.debug('# Job MassDeleteBatchable finished');
    System.debug('# numOfSuccessfulDeletions: ' + numOfUnsuccessfulDeletions);
    System.debug('# numOfUnsuccessfulDeletions: ' + numOfUnsuccessfulDeletions);
  }
}
