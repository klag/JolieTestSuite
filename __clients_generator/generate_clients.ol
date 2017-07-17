include "./public/interfaces/TestSuiteClientGenerationInterface.iol"
include "console.iol"

outputPort ClientGenerator {
Interfaces: TestSuiteClientGenerationInterface
}

embedded {
Jolie :
    "main_clients_generator.ol" in ClientGenerator
}

main {
      if( #args == 3 ) {
	  request.main_file = args[ 0 ];
	  request.target_folder = args[ 1 ];
	  request.http_test_suite_location = "http://localhost:55555/";
	  if ( args[ 2 ] == "yes" ) {	
		request.generate_data = true
	  } else {
		request.generate_data = false
	  };
	  generate@ClientGenerator( request )()
      } else {
	  println@Console("Usage jolie generate_clients.ol sourcefile target_folder generate_data (yes/no)")()
      }
}