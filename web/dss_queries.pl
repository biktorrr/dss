:- use_module(cliopatria(hooks)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_header)).
:- use_module(library(semweb/rdf_turtle_write)).
:- use_module(library(http/http_client)).

cliopatria:menu_item(500=query/dss_queries, 'DSS Queries').

:- http_handler(root(dss_queries), dss_queries, []).
:- http_handler(root(dss_queries1), dss_queries1, []).

dss_queries1(R):-
		reply_html_page(cliopatria(default),title('DSS Queries'),
                        [
			   \queryform(R)

			]).


dss_queries(R):-
		reply_html_page(cliopatria(default),title('DSS Queries'),
                        [ h1('DSS Queries'),
			  \myheader,
                          \form1,
			  hr([]),
			  \queryform(R)

			]).

myheader -->
	html(\['<p>Use the textarea below to fire a SPARQL query at the DSS triple store.You can choose an example query from the list below and copy it to the query field. You can adapt that query if needed before launching it. </p>']).

form1-->
        html( [p('Select your query',
		 form([name='selectform',action='dss_queries',method='POST'],
		      [select([name='query'],[
			  \options
		       ]),
		       input([type='submit',value='Copy to query field'])
		      ]
		     )
		 )]).
options -->
	{findall(X,query(X,_Y,_Z),OptionIDs),
	 maplist(as_option,OptionIDs,OptionSnippets)
	},
	html(OptionSnippets).



queryform(R) -->
	{(memberchk(method(post), R),
	 http_parameters(R, [], [form_data(Data)]),
	 member(query=Q,Data)->
	 MyQuery=Q
	 ;
	MyQuery='0'),
	 query(MyQuery, _Title, Query)
	},
	html(['Your Query:',
	      br([]),
	      form([class='query',name='query', action='/dss/servlets/evaluateQuery',method='GET'],[
		       input([type='hidden', name='repository', value='default']),
		       input([type='hidden', name='serialization', value='rdfxml']),
		       textarea([name='query',cols='70',rows='20'],Query),
		       br([]),
		       select([name='resultFormat'],[
				  option('xml'),
				  option('html'),
				  option('json'),
				  option('csv')]),
		       input([type='submit', value='SPARQL it!'])

		   ])]).


as_option(ID, option([value=ID],X)):-
	query(ID,X,_).


query('0','Select Query','').

query('1', 'Find all mdb aanmonsteringen that have a ship  and a captain with the last name "Boer"',
      'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n \n\n SELECT * WHERE {\n  ?a mdb:schip ?s.\n  ?s mdb:scheepsnaam ?o.\n  ?pc mdb:has_aanmonstering ?a.\n  ?pc mdb:rang mdb:rang-schipper.\n  ?pc mdb:persoon ?pers.\n  ?pers mdb:achternaam "Boer".\n }\n LIMIT 10').

query('1a','Give me all ships (across datasets) with the name "Johanna"','\nSELECT * WHERE \n{\n?s rdf:type dss:Ship.\n?s rdfs:label ?lab.\nFILTER (str(?lab) = "Johanna")\n}\nLIMIT 10').

query('2', 'Find all mdb aanmonsteringen, and list the last name of the captain of the ship','PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\nPREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n SELECT * WHERE {\n  ?a mdb:schip ?s.\n   ?s mdb:scheepsnaam ?o.\n   ?pc mdb:has_aanmonstering ?a.\n   ?pc mdb:rang mdb:rang-schipper.\n  ?pc mdb:persoon ?pers.\n   ?pers mdb:achternaam ?an.\n  }\n LIMIT 10').

query('3a','Find things in DAS and GZMVOC that match the same place in Geonames','SELECT * WHERE \n{\n?gzmplace skos:exactMatch ?pg.\n?dasplace skos:exactMatch ?pg.\nGRAPH <http://purl.org/collections/nl/dss/das/das_data.ttl> {?dass ?dasp ?dasplace}\nGRAPH <http://purl.org/collections/nl/dss/gzmvoc/gzmvoc_data.ttl> {?gzms ?gzmp ?gzmplace}\n}\nLIMIT 10').

query('3b','Find things in 3 datasets that match the same place in Geonames and also give me the lat/long','SELECT * WHERE \n{\n?p1 skos:exactMatch ?pg.\n?p2 skos:exactMatch ?pg.\n?p3 skos:exactMatch ?pg.\nGRAPH <http://purl.org/collections/nl/dss/das/das_data.ttl> {?r1 ?p11 ?p1}\nGRAPH <http://purl.org/collections/nl/dss/gzmvoc/gzmvoc_data.ttl> {?r2 ?p21 ?p2}\nGRAPH <http://purl.org/collections/nl/dss/mdb/mdb_data.ttl> {?r3 ?p31 ?p3}\n}\nLIMIT 20').

query('4','Places where DAS ships have been', 'SELECT * WHERE \n{\n?p1 skos:exactMatch ?pg.\nGRAPH <http://purl.org/collections/nl/dss/das/das_data.ttl> {?p1 rdf:type das:Place. ?rec ?pr1 ?p1. ?rec das:has_ship ?ship. ?ship rdfs:label ?lab}\n?pg <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat.\n?pg <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long.} LIMIT 10').


query('5','Linked newspaper articles for MDB brikken heading to RIGA','SELECT * WHERE \n{\n?s mdb:bestemming mdb:plaats-Riga_LV.\n?s dss:has_kb_link ?link.\n?s mdb:schip ?sh.\n?sh mdb:scheepstype mdb:shiptype-brik.\n}\nLIMIT 2').

query('5a','Linked newspaper articles for MDB schoeners with captains name "Veldman"','SELECT * WHERE \n{\n?s dss:has_kb_link ?link.\n?s mdb:schip ?sh.\n?sh mdb:scheepstype mdb:shiptype-schoener.\n?a mdb:has_aanmonstering ?s.\n?a mdb:rang mdb:rang-kapitein.\n?a mdb:persoon ?persoon.\n?persoon foaf:familyName "Veldman".\n}\nLIMIT 2').



















