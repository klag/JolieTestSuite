

include "console.iol"
include "runtime.iol"
include "file.iol"
include "string_utils.iol"
include "time.iol"

include "./__data_retriever/public/interfaces/DataRetrieverInterface.iol"
include "./public/interfaces/GoalManagerInterface.iol"
include "../public/interfaces/GoalInterface.iol"
include "../config/config.iol"

execution{ concurrent }

outputPort DataRetriever {
Interfaces: DataRetrieverInterface
}

outputPort Goal {
Interfaces: GoalInterface
}

embedded {
Jolie:
	  "./__data_retriever/main_data_retriever.ol" in DataRetriever
}

inputPort GoalManager {
Location: "local"
Protocol: sodep
Interfaces: GoalManagerInterface
}

constants {
  LOCAL_ABSTRACT_GOAL = "localAbstractGoal.iol",
  DATA_FOLDER = "data/",
  TMP_DIR = "./__test_tmp_dir/"
}

define __delete {
  if ( new_filename != "" ) {
      delete@File( new_filename )()
  }
}

init {
  initialize( request );
  TRACING = request.trace
  global.localGUILocation = request.location;
  global.GOAL_DIRECTORY = request.goal_directory;
  global.ABSTRACT_GOAL = request.abstract_goal;
  getLocalLocation@Runtime()( global.localGoalManagerLocation );
  println@Console("GoalManager is running...")();
  install( ExecutionFault => __delete );
  install( GoalNotFound => __delete );
  install( FileNotFound => __delete )
}

main {
  [ goal( request )( response ) {
	  println@Console("TESTING " + request.name + "...")();
	  filename = "";
	  scope( get_goal ) {

		  install( ExecutionFault => valueToPrettyString@StringUtils( get_goal.ExecutionFault )( s );
					     println@Console( s )();
					     throw( ExecutionFault, request.name + ":" + get_goal.ExecutionFault )
		  );
		  install( FileNotFound =>   fault.goal_name = request.name;
					    throw( GoalNotFound, fault )
		  );

		  request.client_location = global.myLocation;

		  abstract = "include \"console.iol\"
			      include \"string_utils.iol\"

			      include \"./public/interfaces/GoalInterface.iol\"
			      include \"./__goal_manager/public/interfaces/GoalManagerInterface.iol\"
			      include \"./__gui/public/interfaces/GUIInterface.iol\"


			      outputPort GoalManager {
			      Protocol: sodep
			      Interfaces: GoalManagerInterface
			      }

			      outputPort GUI {
			      Protocol: sodep
			      Interfaces: GUIInterface
			      }

			      inputPort Goal {
			      Location: \"local\"
			      Protocol: sodep
			      Interfaces: GoalInterface
			      }

			      init {
				       initialize( request )() {
				          GoalManager.location = request.localGoalManagerLocation;
				          GUI.location = request.localGUILocation
				       }
			      }";
		  rd.filename = global.GOAL_DIRECTORY + request.name + ".ol";
		  readFile@File( rd )( goal );
		  rd.filename = global.GOAL_DIRECTORY + LOCAL_ABSTRACT_GOAL;
		  readFile@File( rd )( local_abstract_goal );
		  goal_activity.content = abstract + local_abstract_goal + goal;

		  filename = new;
		  new_filename = TMP_DIR + filename + ".ol";
		  with( wf ) {
		    // writing goal on file system
		    wf.filename = new_filename
		    wf.content = goal_activity.content;
		    writeFile@File( wf )( )
		  };
		  // embedding goal
		  with( request_embed ) {
			if ( TRACING ) {
				.filepath = "--trace " + new_filename 
			} else {
		    	.filepath = new_filename
			}
		    .type = "Jolie"
		  };
		  loadEmbeddedService@Runtime( request_embed )( Goal.location );
		  with( init_activity ) {
		    .localGUILocation = global.localGUILocation;
		    .localGoalManagerLocation = global.localGoalManagerLocation
		  };
		  initialize@Goal( init_activity )();
		  if ( is_defined( request.request_message ) ) {
			run_request -> request.request_message
		  } else if ( is_defined( request.dataname ) ) {
			println@Console("Retrieving data " + global.GOAL_DIRECTORY + DATA_FOLDER + request.dataname )();
			dataretriever_rq.dataname = global.GOAL_DIRECTORY + DATA_FOLDER + request.dataname;
			getData@DataRetriever( dataretriever_rq )( run_request );
			println@Console("Data retrieved!")()
		  };
		  sleep@Time( 100 )(); // required for giving time to the embedded to prepare the run operation to receive
		  run@Goal( run_request )( response );
		  println@Console("SUCCESS: " + request.name )()
	  }
  }] {
	__delete
     }
}
