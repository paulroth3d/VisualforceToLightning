({
	/**
	 *  Initialization event
	 **/
    doInit : function(component, event, helper) {
        //console.log( 'LNE_VisualforceContainer inited');
        
        var pageName=component.get('v.pageName');
        var recordId=component.get('v.recordId');
        var urlArguments=component.get('v.urlArguments');
        var guid = component.getGlobalId();
        
        var pageSrc=helper.getPageSrc(pageName,recordId,urlArguments,guid);
        component.set('v.src',pageSrc);
	},
    
    /**
     *  Handler for when all associated scripts have finished loading
     **/
    handleScriptsLoaded: function( component, event, helper ){
		//-- console.log( 'LNE_VisualforceContainer component finished loading all script/resources' );
		helper.onetimeSetup(component,helper);
    }
})