:- module(rewrite_vocopv_beg,
	  [ rewrite_vocopv_beg/0,
	    rewrite_vocopv_beg/1,
	    rewrite_vocopv_beg/2,
	    list_rules_vocopv_beg/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_vocopv_beg:-
	rdf_rewrite(vocop_begunstigden).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_vocopv_beg(Rule) :-
	rdf_rewrite(vocop_begunstigden, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_vocopv_beg(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_vocopv_beg :-
	rdf_rewrite_rules.

:- discontiguous
	rdf_mapping_rule/5.


clean_empty
@@
{_,_,literal('')}
<=>
true.

make_uri @@
{S, rdf:type, vocopv:'Row'},
{S, vocopv:'ID',literal(ID)}\
{S}
<=>
literal_to_id(['begunstigdenrecord-',ID],vocopv,URI),
	{URI}.


give_class @@
{S, rdf:type, vocopv:'Row'}
<=>
{S, rdf:type, vocopv:'BegunstigdenRecord'}.



link_to_opvarende @@
{S, vocopv:fkPersoon, PersID}
	==>
rdf(S1, vocopv:'ID', PersID, vocop_opvarenden),
       {S, vocopv:has_persoon, S1}.


make_chamber
@@
{S, vocopv:kamersVanDeVOC,literal(Pl)}
<=>
literal_to_id(['chamber-',Pl],vocopv,URI),
{S, vocopv:has_kamersVanDeVOC,URI},
{URI,rdf:type, vocopv:'Kamer'}  >> vocopv_gen_thes,
{URI, skos:prefLabel, literal(Pl)}  >> vocopv_gen_thes,
{URI, skos:inScheme, vocopv:'VOCOPV KamerScheme'} >> vocopv_gen_thes.

% Keep original ship as literal -> add resource
make_ship
@@
{S, vocopv:scheepsnamen,literal(Sch)}
==>
literal_to_id(['ship-',Sch],vocopv,URI),
	{S,has_schip, URI},
	{URI,rdf:type, vocopv:'Schip'} ,
	{URI, rdfs:label, literal(Sch)}.
