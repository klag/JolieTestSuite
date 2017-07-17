include "./public/interfaces/DataRetrieverInterface.iol"
include "./public/interfaces/DataFileInterface.iol"

include "file.iol"
include "runtime.iol"
include "time.iol"
include "console.iol"

execution{ concurrent }

outputPort DataFile {
Interfaces: DataFileInterface
}

inputPort DataRetriever {
Location: "local"
Interfaces: DataRetrieverInterface
}

main {
      getData( request )( response ) {
	    rd.filename = request.dataname;
	    readFile@File( rd )( datafile );
	    
	    // create datafile
	    content = "include \"./__goal_manager/__data_retriever/public/interfaces/DataFileInterface.iol\"\ninputPort DataRetriever { Location:\"local\"\nInterfaces: DataFileInterface }\n";
	    content = content + "init {" + datafile + "}\nmain { getData()( request ) { nullProcess } }";
	
	    filename = new;
	    with( wf ) {
		  .filename = filename + ".ol";
		  .content -> content
	    };
	    writeFile@File( wf )();

	    // embed it
	    with( request_embed ) {
	      .filepath = filename + ".ol";
	      .type = "Jolie"
	    };
	    loadEmbeddedService@Runtime( request_embed )( DataFile.location );

	    // retrieve data
	    sleep@Time( 200 )(); // in order to give time to the embedded file to be ready to receive
	    getData@DataFile()( response );

	    // delete tmp file
	    delete@File( wf.filename )()
      }
}