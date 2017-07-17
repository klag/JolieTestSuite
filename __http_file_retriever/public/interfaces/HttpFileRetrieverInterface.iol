type HttpFileRetrieverInitializeRequest: void {
  .documentRootDirectory: string
}

interface HttpFileRetrieverInterface {
OneWay:
  initialize( HttpFileRetrieverInitializeRequest )
RequestResponse:
  default(undefined)(undefined)
}