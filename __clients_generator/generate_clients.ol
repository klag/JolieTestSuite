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
    if( #args == 2 ) {
		request.main_file = args[ 0 ];
		request.target_folder = args[ 1 ];
		request.http_test_suite_location = "http://localhost:55555/";
		generate@ClientGenerator( request )()
	} else {
		println@Console("Usage jolie generate_clients.ol sourcefile target_folder")()
    }
}