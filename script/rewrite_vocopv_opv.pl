:- module(rewrite_vocopv_opv,
	  [ rewrite_vocopv_opv/0,
	    rewrite_vocopv_opv/1,
	    rewrite_vocopv_opv/2,
	    list_rules_vocopv_opv/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_vocopv_opv:-
	rdf_rewrite(vocop_opvarenden).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_vocopv_opv(Rule) :-
	rdf_rewrite(vocop_opvarenden, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_vocopv_opv(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_vocopv_opv :-
	rdf_rewrite_rules.

:- discontiguous
	rdf_mapping_rule/5.


clean_empty
@@
{_,_,literal('')}
<=>
true.

make_uri @@
{S, rdf:type, vocopv:'Record'},
{S, vocopv:'ID',literal(ID)}\
{S}
<=>
literal_to_id(['opvarenden-',ID],vocopv,URI),
	{URI}.

give_class @@
{S, rdf:type, vocopv:'Record'}
<=>
{S, rdf:type, vocopv:'OpvarendenRecord'}.


link_to_soldijboeken @@
{S, vocopv:soldijboek, SoldijID}
	==>
rdf(S1, vocopv:inventarisNummer, SoldijID, vocop_soldijboeken),
       {S, vocopv:has_soldijboek, S1}.



% herkomst is promoted to SKOS concept, stored in separate
% named graph, the SKOS theasaurus TopConcept as well as its
% topconcept is specific to VOCOPV
% The new 'has_herkomst' link is added to this graph, the
% old 'herkomst' link is retained
herkomst_to_concept @@
{S,vocopv:herkomst, literal(H)}
==>
literal_to_id(['place-',H],vocopv,URI),
	rdf_assert(URI, rdf:type, skos:'Concept', vocopvplace),
	rdf_assert(URI, skos:inScheme, vocopv:'VOCOpvPlaceScheme', vocopvplace),
	rdf_assert(URI, skos:prefLabel, literal(H), vocopvplace),
	{S, vocopv:has_herkomst, URI}.



skos_assertions:-
	rdf_assert(vocopv:'VOCOpvPlaceScheme', rdf:type, skos:'ConceptScheme', vocopvplace),
	rdf_assert(vocopv:'VOCOpvPlaceScheme', rdfs:label, literal('VOC Opvarenden Place ConceptScheme'), vocopvplace),

	rdf_assert(vocopv:'VOCOpvThesaurus', rdf:type, skos:'ConceptScheme', vocopvthes),
	rdf_assert(vocopv:'VOCOpvThesaurus', rdfs:label, literal('VOC Opvarenden Place Thesaurus'), vocopvthes),
	rdf_assert(vocopv:rangConcept, rdf:type, skos:'Concept', vocopvthes),
	rdf_assert(vocopv:rangConcept, skos:prefLabel, literal('Rang'), vocopvthes).


rang_to_concept @@
{S,vocopv:rang, literal(H)}
==>
literal_to_id(['rank-',H],vocopv,URI),
	rdf_assert(URI, rdf:type, skos:'Concept', vocopvthes),
	rdf_assert(URI, skos:inScheme, vocopv:'VOCOpvThesaurus',vocopvthes),
	rdf_assert(URI, skos:prefLabel, literal(H), vocopvthes),
	rdf_assert(URI, skos:broader, vocopv:rangConcept, vocopvthes),
	{S, vocopv:has_rang, URI}.
