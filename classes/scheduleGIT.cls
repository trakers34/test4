/**
 * Created by guillaume.rebmann on 6/21/17.
 */

public with sharing class scheduleGIT implements Schedulable{

    public String target {get;set;}
    public Static String SECURITY_KEY = '123JKJIJOJKHIULKOIJUHNKO123OSD';
    public Static String URL = 'https://boiling-shore-35292.herokuapp.com';

    public scheduleGIT(String target){
        this.target = target;
    }

    public void execute(SchedulableContext SC) {
        process(this.target);
        System.abortJob(SC.getTriggerId());
    }


    @Future (callout=true)
    public static void process(String target){
        Datetime currentDatetime = Datetime.now();

        Map<String,Object> returned = new Map<String,Object>{
                'security_key'   => SECURITY_KEY,
                'org_id'        => UserInfo.getOrganizationId()
        };


        GitSettings__c settings = GitSettings__c.getValues(target);


        returned.put('settings',new Map<String,Object>{
                'name'          => target,
                'apex'          => settings.IncludeApexClasses__c,
                'trigger'       => settings.IncludeTriggers__c,
                'page'          => settings.IncludeVisualForcePages__c,
                'component'     => settings.IncludeComponents__c,
                'git' => new Map<String,String>{
                        'username'      => settings.UsernameGIT__c,
                        'email'         => settings.EmailGIT__c,
                        'repository'    => settings.RepositoryGIT__c,
                        'path'          => settings.PathGIT__c,
                        'branch'        => settings.branchGit__c == null ? 'master':settings.branchGit__c,
                        'type'          => settings.Type__c.toLowerCase(),
                        'token'         => settings.TokenGit__c
                },
                'cursor'        => null,//settings.CurrentSelector__c,
                'namespace'     => settings.Namespace__c
        });


        System.debug(JSON.serialize(returned));



        Boolean callWebservice = true; // test

        if(callWebservice && settings.TokenGit__c <> null){
            // Here we send the information to server
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('content-type', 'application/json');
            req.setEndpoint(URL+'/rest/git');
            req.setBody(JSON.serialize(returned));
            System.debug(JSON.serialize(returned));

            Http http = new Http();

            try {

                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
                System.debug('STATUS:'+res.getStatus());
                System.debug('STATUS_CODE:'+res.getStatusCode());

                String chronExpression = scheduleGIT.cronBuilder(settings.Frequency__c);
                System.schedule( 'Digital Deer GIT - '+target, chronExpression,new scheduleGIT(target));
            } catch(System.CalloutException e) {
                System.debug(e.getMessage());
            }
        }




    }


    /*
    public static String filterBuilder(Datetime cursor,String namespace){

        String returned = '';
        if(namespace == null){
            returned +=' NamespacePrefix = null';
        }else{
            returned +=' NamespacePrefix = \''+namespace+'\'';
        }

        if(cursor != null){
            returned +=' AND LastModifiedDate >= '+cursor;
        }

        return returned;

    }
    */


    public static String cronBuilder(String frequency){
        Datetime dt = Datetime.now();
        Datetime newDT;
        String result;
        Integer freq = LandingGITController.availableFrequencies.get(frequency);
        if(freq > 0){
            newDT = dt.addMinutes(freq);
        }else if(freq == -1){
            newDT = dt.addMonths(1);
        }
        result = '0 '+newDT.minute()+' '+newDT.hour()+' '+newDT.day()+' '+newDT.month()+' ?';
        System.debug(result);
        return result;




    }

    public class ScheduleGitMock implements HttpCalloutMock {
        public Integer status = 200;

        public Map<String,Object> result = new Map<String,Object>{
                'result' => 'connected'
        };

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(JSON.serialize(this.result));
            response.setStatusCode(this.status);
            return response;
        }


    }



}