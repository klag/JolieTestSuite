type GoalNotFoundType: void {
      .goal_name: string
}

type GoalRequest: void {
      .name: string
      .request_message?: undefined
      .dataname?: string
}

type InitializeRequest: void {
      .location: any
      .goal_directory: string
      .abstract_goal: string
      .trace: bool
}

interface GoalManagerInterface {
OneWay:
      initialize( InitializeRequest )
RequestResponse:
      /*
      *	Refinement
      */
      goal( GoalRequest )( undefined )
	throws ExecutionFault
	       GoalNotFound( GoalNotFoundType )
}