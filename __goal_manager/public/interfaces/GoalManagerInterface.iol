type GoalNotFoundType: void {
      goal_name: string
}

type GoalRequest: void {
      name: string
      request_message?: undefined
      dataname?: string
}

type InitializeRequest: void {
      location: any
      goal_directory: string
      abstract_goal: string
      runtime_dir: string
}
type AssertScalarEqualRequest: void {
      expected: any 
      found: any
}
type AssertTreeEqualRequest: void {
      expected: undefined 
      found: undefined
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
	       GoalNotFound( GoalNotFoundType ),

      assertScalarEqual( AssertScalarEqualRequest )( void ) throws TestFailed( string ),
      assertTreeEqual( AssertTreeEqualRequest )( void ) throws TestFailed( string ),

      annotate( string )( void )
}