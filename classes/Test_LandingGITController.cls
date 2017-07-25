/**
 * Created by guillaume.rebmann on 7/14/17.
 */

@isTest
private with sharing class Test_LandingGITController {

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

    @isTest static void test_create(){

        LandingGITController controller = new LandingGITController();
                             controller.createSchedule();

                            controller.GitScheduleItem = new LandingGITController.GitSchedule();
                            controller.GitScheduleItem.name                    = 'test2';
                            controller.GitScheduleItem.type                    = 'Github';
                            controller.GitScheduleItem.frequency               = 'Every 5 Hours';
                            controller.GitScheduleItem.active                  = true;
                            controller.GitScheduleItem.IncludeApexClasses      = true;
                            controller.GitScheduleItem.IncludeTriggers         = true;
                            controller.GitScheduleItem.IncludeVisualForcePages = true;
                            controller.GitScheduleItem.IncludeComponents       = true;
                            controller.GitScheduleItem.gitUsername             = 'TestName';
                            controller.GitScheduleItem.gitEmail                = 'test@test.com';
                            controller.GitScheduleItem.gitRepository           = 'test';
                            controller.GitScheduleItem.gitPath                 = null;
                            controller.GitScheduleItem.gitToken                = 'master';
                            controller.GitScheduleItem.gitBranch               = 'blablablabla';
                            controller.GitScheduleItem.namespace               = null;


        controller.save();

        System.assertEquals(2,[select count() from GitSettings__c],'There should be 2 gitSettings');
    }

    @isTest static void test_edit(){
        String name = 'test1';
        LandingGITController controller = new LandingGITController();
                             controller.selectedItem = name;
                             controller.edit();

        controller.GitScheduleItem.gitUsername = 'TestName2';

        controller.save();

        System.assertEquals(1,[select count() from GitSettings__c],'There should be 2 gitSettings');
        System.assertEquals('TestName2',[select UsernameGit__c from GitSettings__c where name = :name limit 1].UsernameGit__c,'The Git Username should be TestName2');


        controller.deactivate();
        System.assertEquals(false,[select Active__c from GitSettings__c where name = :name limit 1].Active__c,'This schedule shouldn\'t be active');
        controller.activate();
        System.assertEquals(true,[select Active__c from GitSettings__c where name = :name limit 1].Active__c,'This schedule should be active');

    }

    @isTest static void test_getMethods(){
        LandingGITController controller = new LandingGITController();
        List<LandingGITController.GitSchedule> test1 =  controller.getSchedules();
        System.assertEquals(1,test1.size());

        List<SelectOption> test2 =  controller.getTypes();
        System.assertEquals(true,test2.size() > 0);

        List<SelectOption> test3 =  controller.getFrequencies();
        System.assertEquals(true,test3.size() > 0);

    }

}