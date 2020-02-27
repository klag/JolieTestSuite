

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
	TMP_DIR = "__test_tmp_dir"
}



main {
	  
	  if ( #args == 0 ) {
		  println@Console( "Usage jolie main_test_suite.ol goal_directory [ goal_name ] [ --trace ]")()
		  throw( BadFormat )
	  }
	  elseargs << args
	  goal_directory = args[ 0 ]
	  trace = false
	  for ( i = 1, i < #args, i++ ) {
		  if ( args[ i ] == "--trace" ) {
			  trace = true
			  undef( elseargs[ i ] )
		  } 
	  }
	  undef( elseargs[ 0 ] )
	  if ( #elseargs == 0 ) {
		  first_goal = "init"
	  } else {
		  first_goal = elseargs[ 0 ]
	  };

	  with( init_gm ) {
		  .location = ClientLocation;
		  .abstract_goal = "./public/interfaces/abstractGoal.ol";
		  .goal_directory = goal_directory;
		  .trace = trace
	  };  
	  initialize@GoalManager( init_gm );
	  init_http.documentRootDirectory = args[0]
	  initialize@HttpFileRetriever( init_http );
	  
	  mkdir@File( TMP_DIR )()
	  scope( goal_execution ) {
		  install( ExecutionFault => println@Console("TEST FAILED!" )() );
		  install( GoalNotFound => println@Console("GoalNotFound: " + goal_execution.GoalNotFound.goal_name )() );
		  gr.name = first_goal;
		  goal@GoalManager( gr )( grs )
	  }
	  deleteDir@File( TMP_DIR )()
}