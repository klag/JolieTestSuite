# JolieTestSuite
a test suite for performing unit tests with jolie.

## Prerequistes:
- Jolie > 10.0 must be installed

## Preparing the suite:
- prepare the scripts `generate-clients` and `jolie-test-suite` in script folder, to be used from any directory
  - edit them and change the forst line `STS_HOME=/jolie-test-suite` replacing `jolie-test-suite` with the absolute path where the test suite is installed
  - copy them into `/usr/bin/` folder and give them permissions to be executed

## Usage
- enter the folder where there is the jolie service to be tested
- create directory `test_suite`
- run the following command for generating all the clients for all the available input ports
`generate-clients your-service-name.ol ./test_suite/`
  - within folder `test_suite` a subfolder for each input port of the service under test will be created. Each of them contains the clients for invoking the exposed operations
  - a file named `localAbstractGoal.iol` should have been created

- write your tests editing file `init.ol` within folder `test_suite`. The structure of the file must be:

```jolie
main {
      run( request )( response ) {	  
	      // your tests
      }
} 
```
Thus, it is necessary to implement operation `run`. It will be executed by the suite.

In the body it is possible to refer to other module where there are tests like in the following example:
```jolie
main {
      run( request )( response ) {	  
	      grq.name = "archivingLogs";
	      goal@GoalManager( grq )( grs )    
	      ;
	      grq.name = "writing";
	      goal@GoalManager( grq )( grs )    
      }
}
```
where `archivingLogs` (file `archivingLogs.ol`) and `writing` (file `writing.ol`) represents two other modules in folder `init` which follows the same structire of init.  In the above example the init will run the two modules.
In order to call an operation of the service, use the generated ones as it follows:

```jolie
main {
      run( request )( response ) {

		  grq.name = prefix + "/PortName/getInfoTest";
		  grq.request_message.field = "test field"
	      goal@GoalManager( grq )( grs )
		  if ( grs.test_field_reply != "test field" ) {
              throw( TestFailed, "Expected 'test field', found " + grs.test_field_reply )
          }
      }
}
```
where:
  - `/PortName/getInfoTest` it is the name of the client to be used for the test. `/PortName/` is the name of the folder in folder test_suite that has the same name of the inputPort from which the client has been generated. `getInfoTest` it is the name of the operation to be invoked
  - `grq.request_message` must contain the nodes of the request message
  - `goal@GoalManager( grq )( grs )` it performs the test call
  - last lines just test it the reply is like it is expected

- run the service under test
- run the suite `jolie-test-suite ./`

