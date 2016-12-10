({
	getPageSrc : function(pageName,recordId,urlArguments,auraId){
		var pageSrc='';
		var argDelim='?';
		
		//-- calculate the target page src/address.
		if( pageName ){
			pageSrc='/apex/'+pageName+"?auraId=" + auraId;
			if( recordId ){
				pageSrc+='&Id='+recordId;
			}
			if( urlArguments ){
				pageSrc+='&'+urlArguments;
			}
		}
		
		return( pageSrc );
		component.set('v.src',pageSrc);
	},
	
	/**
	 *	Setup that should only run once.
	 **/
	onetimeSetup: function( component, helper){
		//-- only setup an event listener once for this component.
		var didRun=false;
		if( component.get('v.setupComplete') === false ){
			
			//-- this will only run once
			helper.setupPostMessageListeners(component,helper);
			
			component.set('v.setupComplete',true);
			didRun=true;
		}
		return( didRun );
	},
	
	/**
	 * Sets up the listners for visualforce notifications.
	 **/
	setupPostMessageListeners: function(component,helper){
		
		this.postOffice = new LNE_MessagePostOffice(this);
		
		//-- handle the save complete
		this.postOffice.addTypeHandler( 'saveComplete', function( myPostMessage ){
			//-- now notify visualforce pages.
			var iFrameTarget=component.find( "targetFrame").getElement();
			
			console.log( "YAY, vf event in lightning" );
			
			$A.get('e.force:refreshView').fire();
			
			//-- tell the other pages
			myPostMessage.dispatch( iFrameTarget.contentWindow );
		});
		
		//-- handle any unknown types of events
		this.postOffice.addTypeHandler( null, function( myPostMessage ){
			//-- now notify visualforce pages.
			var iFrameTarget=component.find( "targetFrame").getElement();
			
			console.log( "YAY, vf event in lightning" );
            
			
			if( typeof myPostMessage.data.auraMessageType !== 'undefined' &&
			   myPostMessage.data.auraMessageType
			){
				
                
            	if( myPostMessage.data.auraId &&
            	    myPostMessage.data.auraId != component.getGlobalId()
            	){
            	    console.log( 'auraId sent and does not match. not sending aura message' );
                } else {
                    var auraMessageData = {} || myPostMessage.data.auraMessageData;
                    //console.log( 'Aura message:' + myPostMessage.data.auraMessageType );
                    //console.log( 'Aura data:' ); console.log( myPostMessage.data.auraMessageData );
                    
                    //debugger;
                    var appEvent = $A.get( myPostMessage.data.auraMessageType );
                    appEvent.setParams(myPostMessage.data.auraMessageData);
                    appEvent.fire();
                }
			}
			
			//-- tell the other pages.
			myPostMessage.dispatch( iFrameTarget.contentWindow );
		});
		
		this.postOffice.listenForPostEvents(window);
	}
    
    
			/*
			//-- @TODO: investigate why the following throws an error that cannot be caught.
			try {
				if( typeof myPostMessage.data !== 'undefined' &&
				   typeof myPostMessage.data.auraId !== 'undefined' &&
				   myPostMessage.data.auraId == component.getGlobalId();
				){
					console.log( 'auraId sent and does not match. halting' );
					return;
				}
			} catch( err ){
				console.log( 'error occurred in validating auraid:' + err );
				console.log( err );
				debugger;
			}
			*/
})