include "./public/interfaces/RequestParserInterface.iol"
include "./public/interfaces/TestSuiteClientGenerationInterface.iol"

include "console.iol"
include "metarender.iol"
include "metajolie.iol"
include "string_utils.iol"
include "file.iol"

outputPort RequestParser {
Interfaces: RequestParserInterface
}

inputPort TestSuiteClientGenerator {
Location: "local"
Interfaces: TestSuiteClientGenerationInterface
}

embedded {
Jolie:
	"request_parser.ol" in RequestParser
}

define __create_clients {
      for( ifx = 0, ifx < #__input.interfaces, ifx++ ) {
	    __cur_interface -> __input.interfaces[ ifx ];
	    println@Console("Extracting operations from interface " + __cur_interface.name.name)();
	    for( op = 0, op < #__cur_interface.operations, op++ ) {
		  __cur_operation -> __cur_interface.operations[ op ];
		  __starting_type = __cur_operation.input.name;
		  println@Console("Extracting operation " + __cur_operation.operation_name )();
		  content = "include \"" + http_test_suite_location + __input.name + "/testport_surface.iol\"\n";
		  content = content + "init{ install( ExecutionFault => nullProcess ) }\n";
		  content = content + "main{\nrun( request )( response ) {\n";
		  content = content + "scope( test ) { install( default => valueToPrettyString@StringUtils( test )( s ); fault.faultname=test.default; fault.message = \"Error during execution of " + __cur_operation.operation_name +",\" + s; throw( ExecutionFault, fault ) );\n"; 
		  content = content + __cur_operation.operation_name + "@" + __input.name +"( request )( response )\n";
		  content = content + "}}\n}\n";
		  with( file ) {
			.filename = dir_name + "/" + __cur_operation.operation_name + ".ol";
			.content -> content
		  };
		  writeFile@File( file )()
	    }
      }
}

define __create_surface {
      // generate surface
      getSurface@MetaRender( __input )( surface );
      with( surface_file ) {
	    .filename = dir_name + "/testport_surface.iol";
	    .content -> surface 
      };
      writeFile@File( surface_file )()
      
}

define __create_local_abstract {
      content = "";
      with( file ) {
	    .filename = request.target_folder + "/localAbstractGoal.iol";
	    .content -> content
      };
      writeFile@File( file )()
}

define __generate {
      
      dir_name = request.target_folder + __input.name;
      mkdir@File( dir_name )();
      __create_surface;
      __create_clients;
      __create_local_abstract
}

main {
      generate( request )( response ) {    
	    scope( readfile ) {
		  http_test_suite_location = request.http_test_suite_location;
		  with( metaInput ) {
			.filename = request.main_file
		  }
		  getInputPortMetaData@MetaJolie( metaInput )( __inputs )
		  
		  for( i = 0, i < #__inputs.input, i++ ) {
			  println@Console( "Generating clients for input port " + __inputs.input[ i ].name.name )();

			  __input -> __inputs.input[ i ];
			  __generate
		  }
	    }	    
      }
}
