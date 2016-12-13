/**
 *  FOR DEMONSTRATION PURPOSES ONLY
 *  <p>Controller for the TEST_PostMessageParent page</p>
 *  @author Paul Roth <proth@salesforce.com>
 **/
global class TEST_PostMessageParent_C {
    
    //-- constants
    public static final String PARAM_ID = 'Id';
    public static final String ERROR_ID_MUST_BE_SENT = 'ID Get parameter must be sent. Try: apex/TEST_PostMessageParent?id=';
    public static final String ERROR_ID_ACCOUNT_ID = '[ Id of Account with Contacts ]';
    public static final String ERROR_FINDING_CHILDREN = 'Exception occurred when finding the records';
    
    public String[] errorStrings { get; set; }
    public String errorStringsJSON {
        get {
            return( JSON.serialize( this.errorStrings ) );
        }
    }
    
    public String contactsJSON {
        get {
            return( JSON.serialize( this.contacts ));
        }
    }
    
    public ID accountId {get;private set;}

    //-- private
    private Contact[] contacts;
    
    /**
     *  Constructor
     **/
    public TEST_PostMessageParent_C(){
        this.errorStrings = new String[]{};
        
        //addPageMessage('example error');
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( !params.containsKey( PARAM_ID )){
            //-- page must have the param sent.
            
            String pageMessageStr=ERROR_ID_MUST_BE_SENT + ERROR_ID_ACCOUNT_ID;
            try {
            	AggregateResult[] ar = [ select AccountId, count(Name) from contact group by AccountId having count(Name) > 1 ];
            	String possibleAccountId = (String)ar[0].get('AccountId');
            	pageMessageStr = ERROR_ID_MUST_BE_SENT + possibleAccountId;
            } catch( Exception err ){
            }
            addPageMessage( pageMessageStr );
            return;
        } else {
            this.accountId=params.get(PARAM_ID);
        }
        
        this.contacts = new Contact[]{};
        try {
            this.contacts = [ Select id, name, DEMO_CustomCount__c from Contact where AccountId = :this.accountId ];
            for( Contact c : this.contacts ){
            	if( c.DEMO_CustomCount__c == null ){
            		c.DEMO_CustomCount__c = 0.0;
            	}
            }
        } catch( Exception err ){
            addPageMessage( ERROR_FINDING_CHILDREN );
        }
        
        if( ApexPages.hasMessages() ){
            this.accountId = null;
        }
    }
    
    //-- remote actions
    
    /**
     * Gets a single literal value
     * @return String - some message
     **/
    @RemoteAction
    global static String getMessage(){
        return( 'this is my message' );
    }
    
    /**
     * Determines contacts for a given adplan.
     * @param accountId
     * @return Contact[] - list of contacts for that adplan.
     * @throws SOQLException
     **/
    @RemoteAction
    public static Contact[] listContacts( Id accountId ){
        Contact[] results = [ Select id, name, DEMO_CustomCount__c from Contact where AccountId = :accountId ];
        for( Contact c : results ){
			if( c.DEMO_CustomCount__c == null ){
				c.DEMO_CustomCount__c = 0.0;
			}
		}
        return( results );
    }
    
    /**
     * Saves a st of contacts
     * @param contacts (Contact[]) - contacts to save
     * @throws DMLException
     **/
    @RemoteAction
    public static Contact[] updateContacts( Contact[] contacts ){
        upsert contacts;
        return( contacts );
    }
    
    //-- utility functions
    
    /**
     * Method to show that there was an error.
     * @param message (String)
     **/
    private void addPageMessage( String message ){
        System.debug( message );
        this.errorStrings.add( message );
    }
}