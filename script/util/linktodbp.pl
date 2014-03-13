

% get DBPedia
%
% rdf_db:rdf_file_type(ntriples,turtle).library(rdf_ntriples) http open,
% file dumpen in een .nt file en dan triples laden.
:-use_module(library(rdf_ntriples)).



first_char_uppercase(WordLC, WordUC) :-
    atom_chars(WordLC, [FirstChLow|LWordLC]),
    atom_chars(FirstLow, [FirstChLow]),
    lwrupr(FirstLow, FirstUpp),
    atom_chars(FirstUpp, [FirstChUpp]),
    atom_chars(WordUC, [FirstChUpp|LWordLC]).

lwrupr(Low, Upp) :- upcase_atom(Low, Upp).


make_dbp_preds:-
	(   rdf(T,rdfs:subClassOf, dss:'Rank');rdf(T,rdfs:subClassOf, dss:'ShipType')),
	rdf(A,rdf:type,T),
	rdf(A,skos:prefLabel,literal(Lit)),
	first_char_uppercase(Lit,UpLit),
	atomic_list_concat(['http://nl.dbpedia.org/data/',UpLit],URI),
	assert(dbp1(A,URI)),
	false;true.

clear_dbp:- retractall(dbp(_,_)).

get_all_nw:-

	forall(dbp1(_Source,URI),
	     catch((
		 rdf_load(URI)
		     ),A,print_message(warning,A))
	      ).

get_all:-
%	A = 'http://purl.org/collections/nl/niod/entity-Aal',
	open('dbpedia_dump1.ttl','write',S, [type(binary)]),
	forall(dbp1(_Source,URI),
	     catch((
		 http_open:http_open(URI,T,[]),
		 copy_stream_data(T,S),
		 write('.'),flush,
		 close(T),
		 sleep(1)
	     ),A,print_message(warning,A))
	      ),
	close(S).

convert_dbpedia_uri(DURI, DURI2):-
	atom_concat('http://nl.dbpedia.org/resource/',C,DURI),
	atom_concat('http://nl.dbpedia.org/data/',C,DURI12),
	atom_concat(DURI12,'.ntriples',DURI2).
























