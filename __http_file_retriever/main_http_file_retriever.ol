include "./public/interfaces/HttpFileRetrieverInterface.iol"

include "console.iol"
include "string_utils.iol"
include "file.iol"

include "../config/config.iol"


execution{ concurrent }

inputPort HttpFileRetrieverLocal {
  Location: "local"
  Interfaces: HttpFileRetrieverInterface
}

inputPort HttpFileRetriever {
  Location: HttpFileRetrieverLocation
  Protocol: http {
		    .keepAlive = 0; // Do not keep connections open
		    .debug = 0; 
		    .debug.showContent = 0;
		    .format -> format;
		    .contentType -> mime;
		    .default = "default"
		  }
  Interfaces: HttpFileRetrieverInterface
}


define setMime {
	getMimeType@File( file.filename )( mime );
	//println@Console( file.filename +":" + mime )();
	mime.regex = "/";
	split@StringUtils( mime )( s );
	if ( s.result[0] == "text" ) {
		file.format = "text";
		format = "html"
	} else {
		file.format = format = "binary"
	}
}


init{
  initialize( request );
  documentRootDirectory = request.documentRootDirectory
}

main {

  default( request )( response ) {
    scope( s ) {
	//valueToPrettyString@StringUtils( request )( str );
	//println@Console( str )();
	install( FileNotFound => println@Console("File not found: " + request.operation )()
	);
	s = request.operation;
	s.regex = "\\?";
	split@StringUtils( s )( s );
	filename = s.result[0];	// used for retrieving css files within fault handler
	file.filename = documentRootDirectory + s.result[0];
	setMime;
	readFile@File( file )( response )
	//valueToPrettyString@StringUtils( response )( str );
	//println@Console( str )()
    }
  }
    
}