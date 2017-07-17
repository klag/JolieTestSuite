
type ExecutionFaultType: void {
  .message: string
  .faultname: string
}

type RunRequest: undefined

type RunResponse: undefined

type GoalInitializeRequest: void {
  .localGUILocation: any
  .localGoalManagerLocation: any}

interface GoalInterface {
 
RequestResponse:
  initialize( GoalInitializeRequest )( void ),
  
  run( RunRequest )( RunResponse )
    throws ExecutionFault( ExecutionFaultType )
}