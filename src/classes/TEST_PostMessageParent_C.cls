/**
 *	FOR DEMONSTRATION PURPOSES ONLY
 *	<p>Controller for the TEST_PostMessageParent page</p>
 *	@author Paul Roth <proth@salesforce.com>
 **/
global class TEST_PostMessageParent_C {
	
	//-- constants
	/** Name of the ID parameter used to specify the target account **/
	public static final String PARAM_ID = 'Id';
	
	/** initial custom count **/
	public static final Decimal DEFAULT_AMOUNT = 0.0;
	
	/** error messages for this test example. **/
	public static final String ERROR_ID_MUST_BE_SENT = 'ID Get parameter must be sent. Try: apex/TEST_PostMessageParent?id=';
	public static final String ERROR_ID_ACCOUNT_ID = '[ Id of Account with Contacts ]';
	public static final String ERROR_WHILE_FINDING_VALID_ACCOUNT = 'Exception occurred while finding an Account with Contacts. No Accounts with associated Contacts found';
	public static final String ERROR_FINDING_CHILDREN = 'Exception occurred when finding the records';
	public static final String ERROR_NO_ACCOUNTS_WITH_CHILDREN = 'This current demo uses Accounts with child Contacts. No Accounts with associated Contacts found';
	
	/** List of any errors found. **/
	private String[] errorStrings { get; set; }
	/** JavaScript exposed set of initial page errors **/
	public String errorStringsJSON {
		get {
			return( JSON.serialize( this.errorStrings ) );
		}
	}
	
	/** Initial set of children. **/
	private Contact[] contacts;
	/**
	 *	JavaScript exposed set of contacts available to pass.
	 *	
	 *	<p>The Child iFrame wants these and manipulates these
	 *	but cannot do so directly within its domain.</p>
	 **/
	public String contactsJSON {
		get {
			return( JSON.serialize( this.contacts ));
		}
	}

	/** Id of the current record **/
	public ID accountId {get;private set;}
	
	/** PageRedirection if the current URL isn't a good one to demo from. **/
	private ApexPages.PageReference userRedirectionToBetterTest;

	
	/**
	 *	Constructor.
	 *	<p>For the purpose of this demo, we strictly 'pre-load' the responses
	 *	for the child page, and redirect to a better URL
	 *	if the current Account has no contacts.</p>
	 **/
	public TEST_PostMessageParent_C(){
		this.errorStrings = new String[]{};
		this.userRedirectionToBetterTest = null;
		this.accountId = null;
		
		//-- determine if the current page references an Account with contacts.
		
		Map<String,String> params = ApexPages.currentPage().getParameters();
		if( !params.containsKey( PARAM_ID )){
			//-- No Account Id was sent.
			
			String pageMessageStr=ERROR_ID_MUST_BE_SENT + ERROR_ID_ACCOUNT_ID;
			try {
				//-- find an account that does have contacts.
				AggregateResult[] ar = [ select AccountId, count(Name) from contact group by AccountId having count(Name) > 1 limit 1 ];
				if( ar.size() < 1 ){
					pageMessageStr = ERROR_NO_ACCOUNTS_WITH_CHILDREN;
				} else {
					this.accountId = (String)ar[0].get('AccountId');
				}
			} catch( Exception err ){
				pageMessageStr = ERROR_WHILE_FINDING_VALID_ACCOUNT;
			}
			
			if( !String.isEmpty( this.accountId )){
				addPageMessage( pageMessageStr );
				return;
			}
		} else {
			this.accountId=params.get(PARAM_ID);
		}
		
		//-- pre-load with the initial set of contacts for the child iFrame to use.
		this.contacts = new Contact[]{};
		try {
			this.contacts = [ Select id, name, DEMO_CustomCount__c from Contact where AccountId = :this.accountId ];
			for( Contact c : this.contacts ){
				if( c.DEMO_CustomCount__c == null ){
					c.DEMO_CustomCount__c = DEFAULT_AMOUNT;
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
				c.DEMO_CustomCount__c = DEFAULT_AMOUNT;
			}
		}
		return( results );
	}
	
	/**
	 * Saves a set of contacts
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