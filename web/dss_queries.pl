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
	html([
	      form([class='query',name='query', action='/data/servlets/evaluateQuery',method='GET'],[
		       input([type='hidden', name='repository', value='default']),
		       input([type='hidden', name='serialization', value='rdfxml']),
		       'Your Query:',
		       br([]),
		       textarea([name='query',cols='90',rows='20'],Query),
		       br([]),
		       'Result format:',
		       select([name='resultFormat'],[
				  option('xml'),
				  option([selected(selected)],'html'),
				  option('json'),
				  option('csv')]),
		       br([]),
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

query('6','Links to CEDAR Hiscorical Occupations','SELECT * WHERE \n{\n?obs <http://cedar.example.org/ns#occupation> ?occ.\n?obs <http://cedar.example.org/ns#city> ?city.\n?city rdfs:label ?label.\n?rank skos:exactMatch ?occ.\n?pc mdb:rang ?rank.\n?pc mdb:persoon ?pers.\n?pers mdb:woonplaats ?wp.\n?wp rdfs:label ?wpl.\n}\nLIMIT 200').



query('Q7','Alle KB gelinkte aanmonsteringen met een kapitein met boer in de naam','SELECT * WHERE \n{\n?s dss:has_kb_link ?link.\n?s mdb:schip ?sh.\n?sh mdb:scheepstype mdb:shiptype-schoener.\n?a mdb:has_aanmonstering ?s.\n?a mdb:rang mdb:rang-kapitein.\n?a mdb:persoon ?persoon.\n?persoon foaf:familyName ?cname.\nFILTER regex(?cname, "Boer")\n}\nLIMIT 20').

query('Q8','Personen met "jans" in de naam, aangemonsterd op schip met "kof" in het type','SELECT * WHERE \n{\n?s mdb:schip ?sh.\n?sh mdb:scheepstype ?sht.\n?sht skos:prefLabel ?shtl.\n?a mdb:has_aanmonstering ?s.\n?a mdb:persoon ?persoon.\n?persoon foaf:familyName ?cname.\nFILTER regex(?cname, "Jans")\nFILTER regex(?shtl, "kof")\n}\nLIMIT 20').

query('Q9','MDB Aanmonsteringen op subtypen van kustvaarders (AAT)','SELECT * WHERE \n{\n?s mdb:schip ?sh.\n?sh mdb:scheepstype ?sht.\n?sht skos:exactMatch ?aattype.\n?aattype skos:broader <http://e-culture.multimedian.nl/ns/rkd/aatned/kustvaarders>.\n?sht skos:prefLabel ?shtl.\n?a mdb:has_aanmonstering ?s.\n?a mdb:persoon ?persoon.\n?persoon foaf:familyName ?cname.\n\n}\nLIMIT 20').

query('Q10','MDB Aanmonsteringen op subtypen van kustvaarders (AAT) in 1815','SELECT * WHERE \n{\n?aanmonstering mdb:schip ?sh.\n?sh mdb:scheepstype ?sht.\n?sht skos:exactMatch ?aattype.\n?aattype skos:broader <http://e-culture.multimedian.nl/ns/rkd/aatned/kustvaarders>.\n?sht skos:prefLabel ?shtl.\n?a mdb:has_aanmonstering ?aanmonstering.\n?a mdb:persoon ?persoon.\n?persoon foaf:familyName ?cname.\n?aanmonstering mdb:datum ?datum.\nFILTER regex(?datum, "1815").\n\n}\nLIMIT 100').

query('Q11','Alle Vocopv opvarendenrecords, met een gematchte plaats en bijbehorende provincie','SELECT * WHERE {\n?opvrec vocopv:has_herkomst ?herkomst.\n?opvrec vocopv:achternaam ?an.\n?herkomst skos:exactMatch ?geoherkomst.\n?opvrec vocopv:jaarUitreis ?jaar.\n?geoherkomst <http://www.geonames.org/ontology%23parentADM1> ?prov.\n\n}\nLIMIT 10').


query('Q11a', 'VOC opvarenden geteld naar provincies', 'SELECT  ?year ?prov (COUNT(?prov) AS ?provcount )WHERE {\n?opvrec vocopv:has_herkomst ?herkomst.\n?herkomst skos:exactMatch ?geoherkomst.\n?opvrec vocopv:jaarUitreis ?year.\n?geoherkomst <http://www.geonames.org/ontology%23parentADM1> ?provuri.\n?provuri <http://www.geonames.org/ontology%23name> ?prov.        \n} \nGroup by ?prov ?year').

query('Q12','GZM voor links naar DAS: VOC kamers met aziatische bemanning','SELECT * WHERE {\n?gzmrol gzmvoc:has_das_link_heen ?das.\n?gzmrol gzmvoc:aziatischeBemanning ?az.\n?das das:chamber ?ch.\n?ch skos:prefLabel ?chname.  } \nLIMIT 10' ).

query('Q13', 'Das reizen per ton vs gzmvoc per loon', 'SELECT * WHERE {\n?gzmrol gzmvoc:has_das_link_heen ?das.\n?gzmrol gzmvoc:aziatischeBemanning ?az.\n?das  das:tonnage ?ton.\n}\n\nQ14: einde op schip -> vgl das schipnaam of gzmvoc\n\nSELECT * WHERE {\n?v vocopv:eindePlaats "Schip".\n}\nLIMIT 10').

query('Q14','MDB herkomsten naar Lat/Long', 'SELECT ?geoherkomst ?lat ?long (COUNT(?x) AS ?countopvrec) WHERE {\n   ?x mdb:vertrekhaven ?herkomst.\n?herkomst skos:exactMatch ?geoherkomst. \n ?geoherkomst geo:featureCode geo:P.PPL. \n ?geoherkomst wgs84:lat ?lat. \n ?geoherkomst wgs84:long ?long.}
GROUP BY ?geoherkomst ?lat ?long').




