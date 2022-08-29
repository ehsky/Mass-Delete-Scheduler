/**
 * @description       : Test class for MassDeleteBatchable
 * @author            : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @last modified on  : 08-29-2022
 * @last modified by  : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
@isTest
public with sharing class MassDeleteBatchableTest {
  @IsTest
  public static void testMassDeleteBatchable() {
    // Insert Accounts to be deleted
    Integer numToInsert = 200;
    List<Account> accountList = new List<Account>();
    for (Integer i = 0; i < numToInsert; i++) {
      Account a = new Account();
      a.Name = 'testAccount' + i;
      a.Type = 'Deletion Candidate';
      accountList.add(a);
    }
    insert accountList;

    // Run the batch delete job
    Test.startTest();
    String deleteQuery = 'SELECT Id FROM Account WHERE Type = \'Deletion Candidate\' LIMIT 200';
    Boolean hardDelete = true;

    MassDeleteBatchable drb = new MassDeleteBatchable(deleteQuery, hardDelete);
    Id batchProcessId = Database.executeBatch(drb);
    Test.stopTest();

    System.assertEquals(
      0,
      [SELECT Id FROM Account].size(),
      'Failed to delete all Account records'
    );
  }

  @IsTest
  public static void testMassDeleteBatchableNegative() {
    // Insert Accounts to be deleted
    Integer numToInsert = 200;
    List<Account> accountList = new List<Account>();
    for (Integer i = 0; i < numToInsert; i++) {
      Account a = new Account();
      a.Name = 'testAccount' + i;
      a.Type = 'Customer';
      accountList.add(a);
    }
    insert accountList;

    // Run the batch delete job
    Test.startTest();
    String deleteQuery = 'SELECT Id FROM Account WHERE Type = \'Deletion Candidate\' LIMIT 200';
    Boolean hardDelete = true;

    MassDeleteBatchable drb = new MassDeleteBatchable(deleteQuery, hardDelete);
    Id batchProcessId = Database.executeBatch(drb);
    Test.stopTest();

    System.assertEquals(
      numToInsert,
      [SELECT Id FROM Account].size(),
      'Failed in assert that no Account records have been deleted'
    );
  }
}
