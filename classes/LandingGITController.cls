/**
 * Created by guillaume.rebmann on 6/21/17.
 */

public with sharing class LandingGITController {
    public static String CRON_NAME = 'Digital Deer GIT - ';
    public String mode {get;set;}
    public Boolean displayPopup {get;set;}
    public String messageToDisplay {get;set;}
    public String selectedItem {get;set;}


    public GitSchedule GitScheduleItem {get;set;}
    public static Set<String> availableTypes = new Set<String>{'Github'};
    public static Map<String,String> availableFrequencies = new Map<String,String>{
            'Every Hour' => '0 0 * * * ?',
            'Every 5 Hours'=> '0 0 5 * * ?',
            'Every 10 Hours'=> null,
            'Every days' => null,
            'Every week' => null,
            'Every Month' => null
    };

    public LandingGITController(){
        this.mode = 'view';
    }


    public void cancel(){
        this.mode = 'view';
        this.GitScheduleItem = null;
    }

    public void save(){
        GitSettings__c gitSetting = this.GitScheduleItem.getGitSetting();
        GitSettings__c original = GitSettings__c.getValues(this.GitScheduleItem.name);

        if(this.mode == 'new' && [select count() from GitSettings__c where name =:gitSetting.Name] == 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This name is already used'));
        }else{
            upsert gitSetting Name;
            this.mode = 'view';
        }
        String name = CRON_NAME+gitSetting.Name;
        for(CronTrigger cJob : [select id from CronTrigger where CronJobDetail.Name = :name]){
            System.abortJob(cJob.Id);
        }

        if(gitSetting.active__c){
            scheduleGIT.process(gitSetting.Name);
        }


    }

    public void createSchedule(){
        this.mode = 'new';
        this.GitScheduleItem = new GitSchedule();
    }

    public void edit(){
        this.mode = 'edit';
        this.GitScheduleItem = new GitSchedule(GitSettings__c.getValues(selectedItem));
    }

    public void reset(){
        GitSettings__c item = GitSettings__c.getValues(selectedItem);
        String name = CRON_NAME+item.Name;
        for(CronTrigger cJob : [select id from CronTrigger where CronJobDetail.Name = :name]){
            System.abortJob(cJob.Id);
        }
        update item;
        scheduleGIT.process(item.Name);

    }

    public void remove(){

        GitSettings__c item = GitSettings__c.getValues(selectedItem);
        String name = CRON_NAME+item.Name;
        for(CronTrigger cJob : [select id from CronTrigger where CronJobDetail.Name = :name]){
            System.abortJob(cJob.Id);
        }
        delete item;
    }

    public void activate(){
        GitSettings__c item = GitSettings__c.getValues(selectedItem);
        item.active__c = true;
        update item;
        scheduleGIT.process(item.Name);

    }

    public void deactivate(){
        GitSettings__c item = GitSettings__c.getValues(selectedItem);
                                    item.active__c = false;
        String name = CRON_NAME+item.Name;
        for(CronTrigger cJob : [select id from CronTrigger where CronJobDetail.Name = :name]){
            System.abortJob(cJob.Id);
        }
        update item;

    }

    public void closePopup(){
        this.displayPopup = false;
    }


    public List<GitSchedule> getSchedules(){
        List<GitSchedule> returned = new List<GitSchedule>();

        Map<String,GitSettings__c> settings = GitSettings__c.getAll();
        for (String key : settings.keySet()) {
            returned.add(new GitSchedule(settings.get(key)));
        }

        return returned;
    }

    public List<SelectOption> getTypes(){
        List<SelectOption> returned = new List<SelectOption>();

        for(String key : availableTypes){
            returned.add(new SelectOption(key,key));
        }
        return returned;

    }

    public List<SelectOption> getFrequencies(){
        List<SelectOption> returned = new List<SelectOption>();

        for(String key : availableFrequencies.keyset()){
            returned.add(new SelectOption(key,key));
        }
        return returned;
    }








    public class GitSchedule{
        public String name {get;set;}
        public String type {get;set;}
        public String frequency {get;set;}
        public Boolean active {get;set;}
        public Id id {get;set;}

        public Boolean IncludeApexClasses{get;set;}
        public Boolean IncludeTriggers{get;set;}
        public Boolean IncludeVisualForcePages{get;set;}
        public Boolean IncludeComponents{get;set;}

        public String gitUsername {get;set;}
        public String gitEmail {get;set;}
        public String gitRepository {get;set;}
        public String gitPath {get;set;}
        public String gitToken {get;set;}
        public String gitBranch {get;set;}
        public String namespace {get;set;}


        public GitSchedule(){}

        public GitSchedule(GitSettings__c item){
            this.name                       = item.name;
            this.id                         = item.id;
            this.type                       = item.Type__c;
            this.frequency                  = item.Frequency__c;
            this.active                     = item.Active__c;
            this.IncludeApexClasses         = item.IncludeApexClasses__c;
            this.IncludeTriggers            = item.IncludeTriggers__c;
            this.IncludeVisualForcePages    = item.IncludeVisualForcePages__c;
            this.IncludeComponents          = item.IncludeComponents__c;
            this.gitUsername                = item.UsernameGit__c;
            this.gitEmail                   = item.EmailGit__c;
            this.gitRepository              = item.RepositoryGit__c;
            this.gitPath                    = item.PathGit__c;
            this.gitToken                   = item.tokenGit__c;
            this.gitBranch                  = item.branchGit__c;
            this.namespace                  = item.Namespace__c;
        }

        public GitSettings__c getGitSetting(){
            GitSettings__c  item = new GitSettings__c();
                    item.name                                       = name;
                    item.Type__c                        = type;
                    item.Frequency__c                   = frequency;
                    item.Active__c                      = active;
                    item.IncludeApexClasses__c          = IncludeApexClasses;
                    item.IncludeTriggers__c             = IncludeTriggers;
                    item.IncludeVisualForcePages__c     = IncludeVisualForcePages;
                    item.IncludeComponents__c           = IncludeComponents;
                    item.UsernameGit__c                 = gitUsername;
                    item.EmailGit__c                    = gitEmail;
                    item.RepositoryGit__c               = gitRepository;
                    item.PathGit__c                     = gitPath;
                    item.branchGit__c                   = gitBranch;
                    item.tokenGit__c                    = gitToken;
                    item.Namespace__c                   = namespace;
            return item;
        }
    }

}