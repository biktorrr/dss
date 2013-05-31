:- module(rewrite_mdb,
	  [ rewrite_mdb/0,
	    rewrite_mdb/1,
	    rewrite_mdb/2,
	    list_rules_mdb/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_mdb:-
	rdf_rewrite(mdb).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_mdb(Rule) :-
	rdf_rewrite(mdb, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_mdb(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_mdb :-
	rdf_rewrite_rules.

:- discontiguous
	rdf_mapping_rule/5.

/**/

fix_quote
@@
{S,mdb:bewaarplaats,literal(BP)}
<=>
atom_concat(BP1,'\'',BP),
	{S,mdb:bewaarplaats,literal(BP1)}.

give_class @@
{S, mdb:scheepsnaam,_}\
{S, rdf:type, mdb:'Row'}
<=>
{S, rdf:type, mdb:'Aanmonstering'}.

give_class @@
{S, mdb:achternaam,_}\
{S, rdf:type, mdb:'Row'}
<=>
{S, rdf:type, mdb:'PersoonsContract'}.




% todo: fix NULL bronid
make_uri @@
{S, rdf:type, mdb:'Aanmonstering'},
{S, mdb:bewaarplaats, literal(BWP)},
{S, mdb:bronid, literal(BronId)}\
{S}
<=>
bwps(BWP,BS),
literal_to_id(['aanmonstering-',BS,'-',BronId],mdb,URI),
	{URI}.

make_uri @@
{S, rdf:type, mdb:'PersoonsContract'},
{S, mdb:bewaarplaats, literal(BWP)},
{S, mdb:bronid, literal(BronId)},
{S, mdb:voornaam, literal(VN)},
{S, mdb:achternaam, literal(AN)}\
{S}
<=>
bwps(BWP,BS),
literal_to_id(['persoonscontract-',BS,'-',BronId,'-',VN,'_',AN],mdb,URI),
	{URI}.


make_persoon
@@
{S, rdf:type, mdb:'PersoonsContract'},
{S, mdb:bewaarplaats,literal(BWP)},
{S, mdb:bronid, literal(BronId)}\
{S,mdb:achternaam, literal(AN)},
{S,mdb:voornaam, literal(VN)},
{S,mdb:woonplaats, WP}
<=>
bwps(BWP,BS),
literal_to_id(['persoon-',BS,'-',BronId,'-',VN,'_',AN],mdb,URI),
{URI,mdb:achternaam, literal(AN)},
{URI,mdb:voornaam, literal(VN)},
{URI,mdb:woonplaats, WP},
{URI,rdf:type, mdb:'Persoon'},
{S, mdb:persoon	, URI}.




link_pc_am @@
{A, rdf:type, mdb:'Aanmonstering'},
{A, mdb:bewaarplaats,BWP},
{A, mdb:bronid, literal(BronId)},
{P, rdf:type, mdb:'PersoonsContract'},
{P, mdb:bewaarplaats, BWP},
{P, mdb:bronid, literal(BronId)}
==>
{A, mdb:persoonsContract, P}.



make_ship @@
{S, mdb:bewaarplaats, literal(BWP)},
{S, mdb:bronid, literal(BronId)}\
{S, mdb:scheepsnaam, SN}
<=>
bwps(BWP,BS),
literal_to_id(['schip-',BS,'-',BronId,'-',SN],mdb,URI),
{URI,rdf:type, mdb:'Schip'},
{S, mdb:schip,URI},
{URI, mdb:scheepsnaam, SN}.

make_ship @@
{S, mdb:schip, URI}\
{S, mdb:scheepstype, ST}
<=>
{URI, mdb:scheepstype, ST}.

make_ship @@
{S, mdb:schip, URI}\
{S, mdb:thuishaven, ST}
<=>
{URI, mdb:thuishaven, ST}.


make_bewaarplaats
@@
{S, mdb:bewaarplaats,literal(BWP)}
<=>
bwps(BWP,BS),
literal_to_id(['bewaarplaats-',BS],mdb,URI),
{S, mdb:bewaarplaats,URI},
{URI,rdf:type, mdb:'Bewaarplaats'},
{URI, rdfs:label, literal(BWP)}.

make_thuishaven
@@
{S, mdb:thuishaven,literal(BWP)}
<=>
literal_to_id(['plaats-',BWP],mdb,URI),
{S, mdb:thuishaven,URI},
{URI,rdf:type, mdb:'Plaats'},
{URI, rdfs:label, literal(BWP)}.

make_ligplaats
@@
{S, mdb:ligplaats,literal(BWP)}
<=>
literal_to_id(['plaats-',BWP],mdb,URI),
{S, mdb:ligplaats,URI},
{URI,rdf:type, mdb:'Plaats'},
{URI, rdfs:label, literal(BWP)}.

make_woonplaats
@@
{S, mdb:woonplaats,literal(BWP)}
<=>
literal_to_id(['plaats-',BWP],mdb,URI),
{S, mdb:woonplaats,URI},
{URI,rdf:type, mdb:'Plaats'},
{URI, rdfs:label, literal(BWP)}.

make_bestemming
@@
{S, mdb:bestemming,literal(BWP)}
<=>
literal_to_id(['plaats-',BWP],mdb,URI),
{S, mdb:bestemming,URI},
{URI,rdf:type, mdb:'Plaats'},
{URI, rdfs:label, literal(BWP)}.


clean_empty
@@
{_,_,literal('')}
<=>
true.

clean_empty
@@
{_,_,literal('NULL')}
<=>
true.



% shorthands for bewaarplaatsen

bwps('Groningen, Noordelijk Scheepvaartmuseum', gron_nsm).
bwps('Delfzijl, Gemeentearchief (Delfzijl)',	del_gem).
bwps('Groningen, Groninger Archieven (Fivelingo)',gron_archfv).
bwps('Gieten, Gemeentearchief (Gasselternijveen)', gieten).
bwps('Hoogezand-Sappemeer, Gemeentearchief (Hoogezand)',	hoog_hoog).
bwps('Hoogezand-Sappemeer, Gemeentearchief (Sappemeer)',	hoog_sapp).
bwps('Veendam, Gemeentearchief (Wildervank)',	veen_wild).
bwps('De Marne, Gemeentearchief (Ulrum)',	marn_ulrum).
bwps('particulier bezit',	particulier).
bwps('Workum, Nijefurd, Gemeentearchief (Stavoren)',	work_stav).
bwps('Dokkum, Gemeentearchief (Dongeradeel)',	dokkum).
bwps('Groningen, Groninger Archieven (Groningen)',	gron_archgron).
bwps('Oude Pekela, Gemeentearchief (Oude Pekela)',     oude_pekela ).
bwps('Oude Pekela, Gemeentearchief (Nieuwe Pekela)',	nw_pek_gemarch).
bwps('Sneek, Fries Scheepvaartmuseum',	sneek_mus).
bwps('Nieuwe Pekela, Kapiteinshuis',	nw_pek_kap).
bwps('Veendam, Gemeentearchief (Veendam)',veen_veen).
