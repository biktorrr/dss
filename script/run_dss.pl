:- module(dss,
	  [ run_dss/0,
	    run_gzmvoc/0,
	    run_mdb/0,
	    load_mdb/0,
	    clean_all/0,
	    save_gzmvoc/0
	  ]).


% gzmvoc csv file created by
% http://www.luxonsoftware.com/Converter/CsvToXml

user:file_search_path(data, 'C:/Users/victor/DSS/dss_semlayer/data/DSS/').

:- use_module(library(semweb/rdf_db)).

:- rdf_register_ns(dss, 'http://purl.org/collections/nl/dss/').
:- rdf_register_ns(gzmvoc, 'http://purl.org/collections/nl/dss/gzmvoc/').
:- rdf_register_ns(mdb, 'http://purl.org/collections/nl/dss/mdb/').

:- rdf_register_ns(dcterms, 'http://purl.org/dc/terms/').

:- use_module([ library(xmlrdf/xmlrdf),
		library(semweb/rdf_cache),
		library(semweb/rdf_library),
		library(semweb/rdf_turtle_write)
	      ]).
:- use_module(rewrite_gzmvoc).
:- use_module(rewrite_mdb).

load_ontologies :-
	rdf_load_library(dc),
	rdf_load_library(skos),
	rdf_load_library(rdfs),
	rdf_load_library(owl).

:- initialization			% run *after* loading this file
	rdf_set_cache_options([ global_directory('cache/rdf'),
				create_global_directory(true)
			      ]).
	%load_ontologies.

load_gzmvoc:-
        absolute_file_name(data('xml/gzmvoc.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('dataTable', gzmvoc, File).

load_mdb:-
        absolute_file_name(data('xml/monsterrollen_sm.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('Row', mdb, File).


load(Unit, Graph, File) :-
	rdf_current_ns(Graph, Prefix),
	load_xml_as_rdf(File,
			[ dialect(xml),
			  unit(Unit),
			  prefix(Prefix),
			  graph(Graph)
			]).


run_dss:-
	run_gzmvoc,
	run_mdb.

run_gzmvoc:-
	load_gzmvoc,
	rewrite_gzmvoc,
	save_gzmvoc.

run_mdb:-
	load_mdb,
	rewrite_mdb,
	save_mdb.



save_gzmvoc:-
	absolute_file_name(data('rdf/gzmvoc_data.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(gzmvoc)]).


save_mdb:-
	absolute_file_name(data('rdf/mdb_data.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(mdb)]).


clean_all:-
	rdf_retractall(_,_,_,mdb),
	rdf_retractall(_,_,_,gzmvoc),
	rdf_retractall(_,_,_,user).








