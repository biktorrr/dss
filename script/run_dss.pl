:- module(dss,
	  [ run_dss/0,
	    run_gzmvoc/0,
	    run_mdb/0,
	    load_mdb/0,
	    run_vocop/0,
	    clean_all/0,
	    save_gzmvoc/0
	  ]).


% gzmvoc csv file created by
% http://www.luxonsoftware.com/Converter/CsvToXml

user:file_search_path(data, 'C:/Users/victor/DSS/dss_semlayer/data/DSS/').

:- use_module(library(semweb/rdf_db)).

% Namespaces for the datasets
:- rdf_register_ns(dss, 'http://purl.org/collections/nl/dss/').
:- rdf_register_ns(gzmvoc, 'http://purl.org/collections/nl/dss/gzmvoc/').
:- rdf_register_ns(mdb, 'http://purl.org/collections/nl/dss/mdb/').
:- rdf_register_ns(vocopv, 'http://purl.org/collections/nl/dss/vocopv/').
:- rdf_register_ns(das, 'http://purl.org/collections/nl/dss/das/').


:- rdf_register_ns(dcterms, 'http://purl.org/dc/terms/').

:- use_module([ library(xmlrdf/xmlrdf),
		library(semweb/rdf_cache),
		library(semweb/rdf_library),
		library(semweb/rdf_turtle_write)
	      ]).
:- use_module(rewrite_gzmvoc).
:- use_module(rewrite_mdb).

:- use_module(rewrite_vocopv_opv).
:- use_module(rewrite_vocopv_beg).
:- use_module(rewrite_vocopv_sol).

:- use_module(rewrite_das).



load_ontologies :-
	rdf_load_library(dc),
	rdf_load_library(skos),
	rdf_load_library(rdfs),
	rdf_load_library(owl).

:- initialization			% run *after* loading this file
	rdf_set_cache_options([ global_directory('cache/rdf'),
				create_global_directory(true)
			      ]).


% Algemeen
%

load(Unit, Graph, Files, Prefix) :-
	%rdf_current_ns(Graph, Prefix),
	writef('loading files %w\n',Files),
	load_xml_as_rdf(Files,
			[ dialect(xml),
			  unit(Unit),
			  prefix(Prefix),
			  graph(Graph)
			]).
run_dss:-
	run_gzmvoc,
	run_mdb.

clean_all:-
	rdf_retractall(_,_,_,mdb),
	rdf_retractall(_,_,_,gzmvoc),


	clean_vocop,
	rdf_retractall(_,_,_,user).




% --------------------------------------------------------
% ---------------  Generale Zeemonsterrollen  ------------
% --------------------------------------------------------

load_gzmvoc:-
        absolute_file_name(data('xml/gzmvoc.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	rdf_current_ns(gzmvoc, Prefix),
	load('dataTable', gzmvoc, File, Prefix).

run_gzmvoc:-
	load_gzmvoc,
	rewrite_gzmvoc,
	save_gzmvoc,
	save_gzmvoc_thes.




save_gzmvoc:-
	absolute_file_name(data('rdf/gzmvoc_data.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(gzmvoc)]).

save_gzmvoc_thes:-
	absolute_file_name(data('rdf/gzmvoc_thes_gen.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(gzmvoc_gen_thes)]).



% --------------------------------------------------------
% -------------   Monsterrollen database    --------------
% --------------------------------------------------------

run_mdb:-
	rdf_retractall(_,_,_,mdb),
	load_mdb,
	rewrite_mdb,
	save_mdb.


load_mdb:-
	absolute_file_name(data('xml/monsterrollen/monsterrollen_*'), FilePat),
	expand_file_name(FilePat, Files),
	rdf_current_ns(mdb, Prefix),
	load('record', mdb, Files, Prefix).


save_mdb:-
	absolute_file_name(data('rdf/mdb_data.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(mdb)]).


% --------------------------------------------------------
% ------------------   VOC Opvarenden --------------------
% --------------------------------------------------------

run_vocop:-
	load_vocop,
	rewrite_vocop,
	save_vocop.

load_vocop:-
	load_soldijboeken,
	load_begunstigden_all,
	load_opvarenden_sm.

rewrite_vocop:-
	rewrite_vocopv_sol,
	rewrite_vocopv_beg,
	rewrite_vocopv_opv.

save_vocop:-
	save_soldijboeken,
	save_begunstigden,
	save_opvarenden,
	save_other_vocopv.


load_soldijboeken:-
	rdf_current_ns(vocopv, Prefix),
	absolute_file_name(data('xml/voc_opv/soldijboeken.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('Row', vocop_soldijboeken, File, Prefix).

load_begunstigden_sm:-
        rdf_current_ns(vocopv, Prefix),
        absolute_file_name(data('xml/voc_opv/begunstigden_0.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('Row', vocop_begunstigden, File, Prefix).

load_begunstigden_all:-
        rdf_current_ns(vocopv, Prefix),

        absolute_file_name(data('xml/voc_opv/begunstigden_*'), FilePat),
	expand_file_name(FilePat, Files),
	write(Files),
	load('Row', vocop_begunstigden, Files, Prefix).

load_opvarenden_sm:-
	rdf_current_ns(vocopv, Prefix),
	absolute_file_name(data('xml/voc_opv/opvarenden_0.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('record', vocop_opvarenden, File, Prefix).

load_opvarenden_all:-
	rdf_current_ns(vocopv, Prefix),
	absolute_file_name(data('xml/voc_opv/opvarenden_*.xml'), FilePat),
	expand_file_name(FilePat, Files),
	write(Files),
	load('record', vocop_opvarenden, Files, Prefix).


clean_vocop:-
	rdf_retractall(_,_,_,vocop_begunstigden),
	rdf_retractall(_,_,_,vocop_soldijboeken),
	rdf_retractall(_,_,_,vocop_opvarenden).


run_begunstigden:-
	load_begunstigden_sm,
	rewrite_vocopv_beg,
	save_begunstigden.


run_opvarenden:-
	load_opvarenden_sm,
	rdf_retractall(_A, _B, literal('')), % do this here, for speed's sake
	rewrite_vocopv_opv,
	save_opvarenden.

run_soldijboeken:-
	load_soldijboeken,
	rewrite_vocopv_sol,
	save_soldijboeken.

save_opvarenden:-

	absolute_file_name(data('rdf/vocopv_opv.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(vocop_opvarenden)]).


save_begunstigden:-

	absolute_file_name(data('rdf/vocopv_beg.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(vocop_begunstigden)]).


save_soldijboeken:-

	absolute_file_name(data('rdf/vocopv_sol.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(vocop_soldijboeken)]).

save_other_vocopv:-
	absolute_file_name(data('rdf/vocopv_2_das.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(vocop_2_das)]),

	absolute_file_name(data('rdf/vocopv_gen_thes.ttl'), File1,
			   [ access(write)
			   ]),
	rdf_save_turtle(File1,[graph(vocopv_gen_thes)]).


% --------------------------------------------------------
% ------------------   DAS Voyages    --------------------
% --------------------------------------------------------

run_das:-
	load_das,
	rewrite_das,
	save_das.


load_das:-
	rdf_current_ns(das, Prefix),
	absolute_file_name(data('xml/das/DAS_voyages_with_details_victor.xml'), File,
			   [ access(read)
			   ]),
	write(File),
	load('Row', das, File, Prefix).


save_das:-

	absolute_file_name(data('rdf/das_data.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(das)]).
