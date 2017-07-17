type GetDataRequest: void {
      .dataname: string
}

interface DataRetrieverInterface {
RequestResponse:
      getData( GetDataRequest )( undefined )
	  throws FileNotFound
}