
include "console.iol"
include "string_utils.iol"

include "./public/interfaces/GoalInterface.iol"
include "./__goal_manager/public/interfaces/GoalManagerInterface.iol"
include "./__gui/public/interfaces/GUIInterface.iol"


outputPort GoalManager {
Protocol: sodep
Interfaces: GoalManagerInterface
}

outputPort GUI {
Protocol: sodep
Interfaces: GUIInterface
}

inputPort Goal {
Location: "local"
Protocol: sodep
Interfaces: GoalInterface
}

init {
  initialize( request )() { 
      GoalManager.location = request.localGoalManagerLocation;
      GUI.location = request.localGUILocation
  }
}
