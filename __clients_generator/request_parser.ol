include "./public/interfaces/RequestParserInterface.iol"

include "runtime.iol"
include "string_utils.iol"
include "console.iol"
include "metajolie.iol"

execution{ concurrent }

outputPort MySelf {
Interfaces: RequestParserInterface
}

inputPort RequestParserInterface {
Location: "local"
Interfaces: RequestParserInterface
}

constants {		
    SAMPLE_INT = "42",
    SAMPLE_DOUBLE = "42.42",
    SAMPLE_LONG = "123456789",
    SAMPLE_MAX = 5,
    SAMPLE_BOOL = "true",
    SAMPLE_STRING = "\"string\"",
	SAMPLE_RAW = "<insert a test raw file here>",
    NESTED_DEPTH = 2 // avoiding infinte tree due to recursive types
}

init {
    getLocalLocation@Runtime()( MySelf.location )
}

main {
    [ getRequest( request )( response ) {
	  // preparing hash table
	  NODE_NAME = "request"
	  checkNativeType@MetaJolie( { .type_name = request.request_type_name } )( is_native )
	  if ( is_native.result ) {
		  getNativeTypeFromString@MetaJolie( { .type_name = request.request_type_name } )( ntype.native_type )
		  ntype.node_name = NODE_NAME
		  getNativeType@MySelf( ntype )( response )
	  } else {
		for( t = 0, t < #request.types, t++ ) {
				type_hashmap.( request.types[ t ].name ) << request.types[ t ]
		};
		with( req ) {
			.node_name = NODE_NAME;
			.type_hashmap -> type_hashmap;
			.type -> type_hashmap.( request.request_type_name ).type;
			.recursion_level = 0
		}
		getType@MySelf( req )( response )
	  }
	}] 

	[ getType( request )( response ) {
		rtype -> request.type
		with( req ) {
			.node_name = request.node_name;
			.type_hashmap -> request.type_hashmap;
			.type -> rtype;
			.recursion_level = request.recursion_level
		}
		if ( rtype instanceof TypeInLine ) { 
			getTypeInLine@MySelf( req )( res )
		} else if ( rtype instanceof TypeLink ) {
			getTypeLink@MySelf( req )( res )
		} else if ( rtype instanceof TypeChoice ) {
			getTypeChoice@MySelf( req )( res )
		} else if ( rtype instanceof TypeUndefined ) {
			getTypeUndefined@MySelf( req )( res )
		}
	
		for( r = 0, r < #res.rows, r++ ) {
			response.rows[ #response.rows ] = res.rows[ r ]
		}
		
	}]

	[ getTypeInLine( request )( response ) {
		
		with( req ) {
			.native_type << request.type.root_type;
			.node_name = request.node_name
		};
		getNativeType@MySelf( req )( response )
		
		;
		// subtypes
		for( st in request.type.sub_type ) {
		    undef( req );
		    with( req ) {
				.subtype -> st;
				.node_name = request.node_name;
				.type_hashmap -> request.type_hashmap;
				.recursion_level = request.recursion_level
		    };
		    getSubType@MySelf( req )( res );
		    for( r = 0, r < #res.rows, r++ ) {
			  	response.rows[ #response.rows ] = res.rows[ r ]
		    }
		}			
	}]

	[ getTypeChoice( request )( response ){
		with( req ) {
			.node_name = request.node_name;
			.type_hashmap -> request.type_hashmap;
			.type -> request.type.choice.left_type;
			.recursion_level = request.recursion_level
		}
		getType@MySelf( req )( response )

		with( req ) {
			.node_name = request.node_name;
			.type_hashmap -> request.type_hashmap;
			.type -> request.type.choice.right_type;
			.recursion_level = request.recursion_level
		}
		getType@MySelf( req )( res_right )
		response.rows[ #response.rows ] = "// commented lines below represent the right choice of the type"
		for( r in res_right.rows ) {
			response.rows[ #response.rows ] = "// " + r
		}
		
	}]

	[ getTypeUndefined( request )( response ) {
		response.rows[ 0 ] = request.node_name + "= \"undefined\""
	}]

	[ getTypeLink( request )( response ) {
		if ( request.recursion_level < NESTED_DEPTH ) {
			with( req ) {
				.node_name = request.node_name;
				.type_hashmap -> request.type_hashmap;
				.type -> request.type_hashmap.( request.type.link_name ).type;
				.recursion_level = request.recursion_level + 1
			}
			getType@MySelf( req )( response )
		}
	}]

    [ getNativeType( request )( response ) {
	  resp = request.node_name + "=";
	  if ( is_defined( request.native_type.string_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_STRING
	  } else if ( is_defined( request.native_type.int_type ) ) {
		response.rows[ 0 ] =  resp + SAMPLE_INT
	  } else if ( is_defined( request.native_type.void_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_STRING
	  } else if ( is_defined( request.native_type.double_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_DOUBLE
	  } else if ( is_defined( request.native_type.any_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_ANY
	  }  else if ( is_defined( request.native_type.bool_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_BOOL
	  } else if ( is_defined( request.native_type.long_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_LONG
	  } else if ( is_defined( request.native_type.raw_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_RAW
	  }

    }] { nullProcess }

    [ getSubType( request )( response ) {
		cur_node_name = request.node_name + "." + request.subtype.name;
		min = request.subtype.cardinality.min;
		if ( is_defined( request.subtype.cardinality.infinite ) ) {
		      max = SAMPLE_MAX
		} else if ( request.subtype.cardinality.min >= SAMPLE_MAX ) {
		      max = min
		} else if ( request.subtype.cardinality.max >= SAMPLE_MAX ) {
		      max = SAMPLE_MAX
		} else {
		      max = request.subtype.cardinality.max
		};
		
		for( index = 0, index < max, index++ ) {
			  with( req ) {
				.node_name = cur_node_name;
		    	.type_hashmap -> request.type_hashmap;
				.type -> request.subtype.type;
				.recursion_level = request.recursion_level
			  }
		      getType@MySelf( req )( res )
		      for( r = 0, r < #res.rows, r++ ) {
			  		response.rows[ #response.rows ] = res.rows[ r ]
		      }
		}
    }] 
}