:- module(rewrite_das,
	  [ rewrite_das/0,
	    rewrite_das/1,
	    rewrite_das/2,
	    list_rules_das/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_das:-
	rdf_rewrite(das).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_das(Rule) :-
	rdf_rewrite(das, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_das(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_das :-
	rdf_rewrite_rules.

:- discontiguous
	rdf_mapping_rule/5.



% All class and property labels are in English, since the in
% put data is also in En.

give_class @@
{S, rdf:type, das:'Row'}
<=>
{S, rdf:type, das:'Voyage'}.


% Give URIs to classes
%
make_uri @@
{S, rdf:type, das:'Voyage'},
{S, das:number, literal(Num)}\
{S}
<=>
literal_to_id(['voyage-',Num],das,URI),
	{URI}.


% consolidate values as concepts

make_placeOfArrival
@@
{S, das:placeOfArrival ,literal(Pl)}
<=>
literal_to_id(['place-',Pl],das,URI),
{S, das:placeOfArrival,URI},
{URI,rdf:type, das:'Place'},
{URI, skos:prefLabel, literal(Pl)}.

make_placeOfDeparture
@@
{S, das:placeOfDeparture ,literal(Pl)}
<=>
literal_to_id(['place-',Pl],das,URI),
{S, das:placeOfDeparture,URI},
{URI,rdf:type, das:'Place'},
{URI, skos:prefLabel, literal(Pl)}.

make_typeOfShip
@@
{S, das:typeOfShip ,literal(Pl)}
<=>
literal_to_id(['shiptype-',Pl],das,URI),
{S, das:typeOfShip,URI},
{URI,rdf:type, das:'ShipType'},
{URI, skos:prefLabel, literal(Pl)}.


make_chamber
@@
{S, das:chamber ,literal(Pl)}
<=>
literal_to_id(['chamber-',Pl],das,URI),
{S, das:chamber,URI},
{URI,rdf:type, das:'Chamber'},
{URI, skos:prefLabel, literal(Pl)}.


% Master is parametrized by Number, since we do not know whether they
% are the same person
make_master@@
{S, das:number, literal(Num)}\
{S, das:master ,literal(Ma)}
<=>
literal_to_id(['person-',Num,'-',Ma],das,URI),
{S, das:master,URI},
{URI,rdf:type, das:'Person'},
{URI, das:name, literal(Ma)}.
