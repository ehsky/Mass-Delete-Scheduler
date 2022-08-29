/**
 * @description       :
 * @author            : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @group             :
 * @last modified on  : 08-29-2022
 * @last modified by  : erlend.hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
@isTest
public without sharing class MassDeleteSchedulableTest {
  @IsTest
  static void testMassDeleteSchedulable() {
    // Create a test lead
    insert new Lead(
      FirstName = 'John',
      LastName = 'Doe',
      Company = 'Salesforce'
    );

    Test.startTest();
    // Schedule the test job using a cron expression for midnight every day
    String cronExpString = '0 0 0 * * ?';

    // We initiate the class where testing and override the getAllMetadata() method
    // This is so we can set mock values and assert on mock data
    MassDeleteSchedulable scheduleJob = new MassDeleteSchedulable();
    scheduleJob.allQueries = new List<Query__mdt>{
      new Query__mdt(
        Label = 'Test Delete Lead Records MDT',
        Object__c = 'Lead',
        IsActive__c = true,
        Operation_Type__c = 'Delete',
        Condition__c = 'Company = \'Salesforce\''
      )
    };
    String jobId = System.schedule(
      'testDeleteRecordsSchedulable',
      cronExpString,
      scheduleJob
    );

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE Id = :jobId
    ];

    // Verify the cron expressions are the same
    System.assertEquals(
      cronExpString,
      ct.CronExpression,
      'The cron expression in test class did not match the cron expression for the job'
    );

    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered, 'The job has not run');

    // Verify the next time the job will run (midnight tomorrow)
    System.assertEquals(
      String.valueOf(Date.today().addDays(1)) + ' 00:00:00',
      String.valueOf(ct.NextFireTime),
      'The cron expression for the next time a batch will run is invalid'
    );

    // Verify that lead has not been deleted
    System.assertNotEquals(0, [SELECT Id FROM Lead].size());

    Test.stopTest();
  }
}
