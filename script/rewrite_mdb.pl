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

% Special rule for first row

firstrow
@@
{S, mdb:bronid, literal('NULL')}
<=>
{S, mdb:bronid, literal('Null')}.




give_class @@
{S, mdb:scheepsnaam,_}\
{S, rdf:type, mdb:'Record'}
<=>
{S, rdf:type, mdb:'Aanmonstering'}.

give_class @@
{S, mdb:achternaam,_}
\
{S, rdf:type, mdb:'Record'}
<=>
{S, rdf:type, mdb:'PersoonsContract'}.


% Do NULL removal here -> TODO: fix uri giving rules

clean_null@@
{_, _, literal('NULL')}
<=>
true.


% Give URIs to classes
%
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
	{URI},
	literal_to_id(['aanmonstering-',BS,'-',BronId],mdb,URI2),
	{URI, mdb:has_aanmonstering, URI2}.

make_uri @@
{S, rdf:type, mdb:'PersoonsContract'},
{S, mdb:bewaarplaats, literal(BWP)},
{S, mdb:bronid, literal(BronId)}\
{S}
<=>
rdf_is_bnode(S),
bwps(BWP,BS),
literal_to_id(['persoonscontract-',BS,'-',BronId,'-','unknown'],mdb,URI),
	{URI},
	literal_to_id(['aanmonstering-',BS,'-',BronId],mdb,URI2),
	{URI, mdb:has_aanmonstering, URI2}.


% For persons we use ID only (multiple identical achternaam, no voornaam
% possible per ship.
make_persoon
@@
{S, rdf:type, mdb:'PersoonsContract'},
{S, mdb:bewaarplaats, literal(BWP)},
{S, mdb:bronid, literal(BronId)},
	{S, mdb:id, literal(ID)}\
{S, mdb:achternaam, AN}?,
{S, mdb:voornaam, VN}? ,
{S, mdb:woonplaats, WP}?
<=>
bwps(BWP,BS),
literal_to_id(['persoon-',BS,'-',BronId,'-',ID],mdb,URI),
{URI,mdb:achternaam, AN},
{URI,mdb:voornaam, VN},
{URI,mdb:woonplaats, WP},
{URI,rdf:type, mdb:'Persoon'},
{S, mdb:persoon	, URI}.






make_ship @@
{S, rdf:type, mdb:'Aanmonstering'},
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

make_vertrekhaven
@@
{S, mdb:vertrekhaven,literal(BWP)}
<=>
literal_to_id(['plaats-',BWP],mdb,URI),
{S, mdb:vertrekhaven,URI},
{URI,rdf:type, mdb:'Plaats'},
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


parse_locations
@@
{S, rdf:type, mdb:'Plaats'}\
 {S, rdfs:label, literal(Label)}
<=>
 parse_label(Label, NewLabel),
{S, mdb:orig_label, literal(Label)},
 {S, rdfs:label, literal(NewLabel)}.


% 'vocabularies'

make_shiptype
@@
{S, mdb:scheepstype,literal(ST)}
<=>
literal_to_id(['shiptype-',ST],mdb,URI),
{S, mdb:scheepstype,URI},
{URI,rdf:type, mdb:'ScheepsType'},
{URI, skos:prefLabel, literal(ST)}.

make_rank
@@
{S, mdb:rang,literal(R)}
<=>
literal_to_id(['rang-',R],mdb,URI),
{S, mdb:rang,URI},
{URI,rdf:type, mdb:'Rang'},
{URI, skos:prefLabel, literal(R)}.


% -------------- UTIL PREDS ------------------------------
%

% just get everything in front of the first parenthesis
parse_label(Lab,NewLab):-
	sub_atom(Lab, Before, 2, _After, ' ('),
	sub_atom(Lab, 0, Before, _, NewLab),!.

parse_label(Lab,NewLab):-
	sub_atom(Lab, Before, 1, _After, '('),
	sub_atom(Lab, 0, Before, _, NewLab),!.

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

% nw version
bwps('Dokkum, Streekarchief Noordoost-Friesland (Westdongeradeel)', dokkun_w).
bwps('Groningen, RHC Groninger Archieven (Fivelingo)',gron_archfv).
bwps('Groningen, RHC Groninger Archieven (Groningen)',	gron_archgron).

bwps('Aa en Hunze, Gemeentearchief (Gasselte)',gasselte).
bwps('Winschoten, Cultuurhistorisch Centrum Oldambt', winschotern).

bwps('Delfzijl, Gemeentearchief (Termunten)',delfzijl_term).
bwps('Workum, Gemeentearchief Zuidwest Friesland (Stavoren)',work_stav).


/*
nwe bewaarplaatsen (17/1)
Groningen, Noordelijk Scheepvaartmuseum
Delfzijl, Gemeentearchief (Delfzijl)
Dokkum, Streekarchief Noordoost-Friesland (Westdongeradeel)
Groningen, RHC Groninger Archieven (Fivelingo)
Aa en Hunze, Gemeentearchief (Gasselte)
Groningen, RHC Groninger Archieven (Groningen)
Hoogezand-Sappemeer, Gemeentearchief (Hoogezand)
Oude Pekela, Gemeentearchief (Oude Pekela)
Oude Pekela, Gemeentearchief (Nieuwe Pekela)
Hoogezand-Sappemeer, Gemeentearchief (Sappemeer)
Delfzijl, Gemeentearchief (Termunten)
Veendam, Gemeentearchief (Veendam)
Veendam, Gemeentearchief (Wildervank)
Winschoten, Cultuurhistorisch Centrum Oldambt
Workum, Gemeentearchief Zuidwest Friesland (Stavoren)
De Marne, Gemeentearchief (Ulrum)
Nieuwe Pekela, Kapiteinshuis
particulier bezit
Sneek, Fries Scheepvaartmuseum
*/
