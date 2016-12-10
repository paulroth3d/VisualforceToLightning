//-- @TODO: separate out to a separate file
/**
 *  Helper function for calling remoting methods
 *  ex: remotingHelper( 'TEST_POstMessageParent_C.calculateSomething', 1,1,2, successFunction, failureFunction );
 *  @param remoting function name - Class.Remoting Method - i.e. TEST_PostMessageParent_C.getMessage
 *  @param [any additional arguments to remoting call]
 *  @param function successHandler - always the first arguent
 *  @param function failureHandler - always the last argument
 **/
this.remotingHelper = function(){
	var remotingArguments = _.union(arguments);
	try {
		var remotingFunctionName = remotingArguments.shift();
	
		var failureHandler = remotingArguments.pop();
		var successHandler = remotingArguments.pop();
		var scope = this;
		
		var remotingHandler = function(result,event){
			//console.log('remoting returned');
			if(event.status){
				successHandler.call( scope, result );
			} else if( event.type == 'exception' ){
				console.log( 'remoting failure' ); debugger;
				failureHandler.call( scope, event.message, result, event);
			} else {
				console.log( 'unknown remoting failure' ); debugger;
				failureHandler.call( scope, event.message, result, event);
			}
		}
		
		var errorString='';
		if( !remotingFunctionName || typeof remotingFunctionName !== 'string' ){
			errorString = 'remoting call error: remoting function name was not sent or was not understood:' + remotingFunctionName + '. Please check the remoting call directory as the first arguement';
		} else if( remotingFunctionName.indexOf('.') < 0 ){
			errorString = 'remoting call error: remember that the remoting call must include the ApexClassName. Ex: TEST_PostMessgeParent_C.getMessage';
		} else if( !failureHandler || typeof failureHandler !== 'function' ){
			errorString = 'remoting call error: the last two arguments must be: a success handler and an error handler. The error handler was not found.';
		} else if( !successHandler || typeof successHandler !== 'function' ){
			errorString = 'remoting call error: the last two arguments must be: a success handler and an error handler. the success handler was not found.';
		}
		
		var remotingFunctionNameTranslation = '';
		if( errorString ){
			console.error( errorString );
			console.error(arguments);
			failureHandler(errorString);
			return;
		}
		
		var newArguments = _.union( [remotingFunctionName], remotingArguments, [remotingHandler] );
		Visualforce.remoting.Manager.invokeAction.apply(Visualforce.remoting.Manager,newArguments);
	} catch( err ){
		console.error( err ); debugger;
	}
}