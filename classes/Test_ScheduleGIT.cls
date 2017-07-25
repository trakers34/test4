/**
 * Created by guillaume.rebmann on 7/25/17.
 */

@IsTest
private class Test_ScheduleGIT {

    @TestSetup
    public static void setup(){
        GitSettings__c  gitSettings = new GitSettings__c();
        gitSettings.name                        = 'test1';
        gitSettings.Type__c                     = 'Github';
        gitSettings.Frequency__c                = 'Every 5 Hours';
        gitSettings.Active__c                   = true;
        gitSettings.IncludeApexClasses__c       = true;
        gitSettings.IncludeTriggers__c          = true;
        gitSettings.IncludeVisualForcePages__c  = true;
        gitSettings.IncludeComponents__c        = true;
        gitSettings.UsernameGit__c              = 'TestName';
        gitSettings.EmailGit__c                 = 'test@test.com';
        gitSettings.RepositoryGit__c            = 'test';
        gitSettings.PathGit__c                  = null;
        gitSettings.branchGit__c                = 'master';
        gitSettings.tokenGit__c                 = 'blablablabla';
        gitSettings.Namespace__c                = null;
        insert gitSettings;
    }

    static testMethod void test_process() {



        Test.startTest();
            scheduleGIT.ScheduleGitMock  mock = new scheduleGIT.ScheduleGitMock();
            Test.setMock(HttpCalloutMock.class, mock);

            scheduleGIT.process('test1');

        Test.stopTest();

        System.assertEquals(1,[select count() from AsyncApexJob where JobType = 'ScheduledApex'],'There should be 1 ScheduledApex job');
    }

    static testMethod void test_batch(){
        scheduleGIT batchToTest = new scheduleGIT('test1');

        Test.startTest();
                scheduleGIT.ScheduleGitMock  mock = new scheduleGIT.ScheduleGitMock();
                Test.setMock(HttpCalloutMock.class, mock);

                String sch = '0 0 23 * * ?';
                system.schedule('Test check', sch, batchToTest);

        Test.stopTest();

        System.assertEquals(1,[select count() from AsyncApexJob where JobType = 'ScheduledApex'],'There should be 1 ScheduledApex job');
    }




}