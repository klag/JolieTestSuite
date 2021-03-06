

include "console.iol"
include "runtime.iol"
include "string_utils.iol"
include "file.iol"

include "./__goal_manager/public/interfaces/GoalManagerInterface.iol"
include "./__gui/public/interfaces/GUIInterface.iol"
include "./__http_file_retriever/public/interfaces/HttpFileRetrieverInterface.iol"

include "./config/config.iol"


outputPort GoalManager {
Interfaces: GoalManagerInterface
}

outputPort GUI {
Interfaces: GUIInterface
}

outputPort HttpFileRetriever {
Interfaces: HttpFileRetrieverInterface
}


embedded {
  Jolie:
    "./__goal_manager/main_goal_manager.ol" in GoalManager,
    "./__http_file_retriever/main_http_file_retriever.ol" in HttpFileRetriever,
    "./__gui/main_gui.ol" in GUI
}

inputPort ClientLocal {
Location: "local" 
Protocol: sodep
Aggregates: GUI
}

inputPort Client {
Location: ClientLocation 
Protocol: sodep
Aggregates: GUI
RequestResponse:
  shutdown
}

constants {
  TEST_SUITE_DIRECTORY = "test_suite/"
}

main {
	if ( #args > 0 ) {
		with( init_gm ) {
			.location = ClientLocation;
			.abstract_goal = "./public/interfaces/abstractGoal.ol";
			.goal_directory = args[0] + TEST_SUITE_DIRECTORY;
			.runtime_dir = "runtime"
		};  
		initialize@GoalManager( init_gm );
		init_http.documentRootDirectory = args[0] + TEST_SUITE_DIRECTORY;
		initialize@HttpFileRetriever( init_http );

		if ( #args == 1 ) {
			first_goal = "init"
		} else {
			first_goal = args[ 1 ]
		};
			

		scope( goal_execution ) {
			install( ExecutionFault => valueToPrettyString@StringUtils( goal_execution.ExecutionFault )( s ); 
										println@Console( s )()
			);
			install( GoalNotFound => println@Console("GoalNotFound: " + goal_execution.GoalNotFound.goal_name )() );
			gr.name = first_goal;
			goal@GoalManager( gr )( grs )
		}
	} else {
		println@Console( "Usage: jolie main_test_suite <test directory> [goal (default=init)]" )(  )
	}
	
}