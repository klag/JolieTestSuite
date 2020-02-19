include "types/definition_types.iol"


type GetRequestRequest: void {
      .types*: TypeDefinition
      .request_type_name: string
}

type RowsResponse: void {
      .rows*: string
}

type GetNativeTypeRequest: void {
      .native_type: NativeType
      .node_name: string
}


type GetSubTypeRequest: void {
      .subtype: SubType
      .node_name: string
      .type_hashmap: undefined
      .recursion_level: int
}

type GetTypeRequest: void {
      .type: Type
      .node_name: string
      .type_hashmap: undefined
      .recursion_level: int
}

type GetTypeInLineRequest: void {
      .type: TypeInLine
      .node_name: string
      .type_hashmap: undefined
      .recursion_level: int
}

type GetTypeLinkRequest: void {
      .type: TypeLink 
      .node_name: string
      .type_hashmap: undefined
      .recursion_level: int
}


type GetTypeChoiceRequest: void {
      .type: TypeChoice 
      .node_name: string
      .type_hashmap: undefined
      .recursion_level: int
}

type GetTypeUndefinedRequest: void {
      .node_name: string
      .type: TypeUndefined
      .recursion_level: int
      .type_hashmap: undefined
}

interface RequestParserInterface {
RequestResponse:
      getRequest( GetRequestRequest )( RowsResponse ),
      getNativeType( GetNativeTypeRequest )( RowsResponse ),
      getType( GetTypeRequest )( RowsResponse ),
      getTypeInLine( GetTypeInLineRequest )( RowsResponse ),
      getTypeLink( GetTypeLinkRequest )( RowsResponse ),
      getTypeChoice( GetTypeChoiceRequest )( RowsResponse ),
      getTypeUndefined( GetTypeUndefinedRequest )( RowsResponse ),
      getSubType( GetSubTypeRequest )( RowsResponse )
}