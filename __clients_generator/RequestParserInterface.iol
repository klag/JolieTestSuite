include "types/role_types.iol"

type GetRequestRequest: void {
      .types*: Type
      .request_type_name: string
}

type RowsResponse: void {
      .rows*: string
}

type GetNativeTypeRequest: void {
      .native_type: NativeType
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

type GetTypeRequest: void {	
      .is_inline: bool {
	    .inline_type?: Type
      }
      .type_name: string
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

type GetSubTypeRequest: void {
      .subtype: SubType
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

interface RequestParserInterface {
RequestResponse:
      getRequest( GetRequestRequest )( RowsResponse ),
      getNativeType( GetNativeTypeRequest )( RowsResponse ),
      getType( GetTypeRequest )( RowsResponse ),
      getSubType( GetSubTypeRequest )( RowsResponse )
}