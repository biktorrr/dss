:- module(rewrite_vocopv_sol,
	  [ rewrite_vocopv_sol/0,
	    rewrite_vocopv_sol/1,
	    rewrite_vocopv_sol/2,
	    list_rules_vocopv_sol/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_vocopv_sol:-
	rdf_rewrite(vocop_soldijboeken).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_vocopv_sol(Rule) :-
	rdf_rewrite(vocop_soldijboeken, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_vocopv_sol(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_vocopv_sol :-
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
literal_to_id(['soldijrecord-',ID],vocopv,URI),
	{URI}.



give_class @@
{S, rdf:type, vocopv:'Row'}
<=>
{S, rdf:type, vocopv:'SoldijRecord'}.


link_to_opvarenden @@
{S, vocopv:inventarisNummer, SoldijID}
	==>
rdf(S1, vocopv:soldijboek, SoldijID, vocop_opvarenden),
       {S, vocopv:has_soldijboek, S1}.




/*
% These rules rewrite the unnamed field names, according to the list as
% provided in "Eigenschappen VOC-Opvarenden.xmlx"
%

fieldname @@
{_S, F, _O}\
{F}
<=>
fieldname(F,P,_,_,_),
	{P}.



fieldname(vocopv:field1, vocopv:'ID', 'ID', 'Long INT,', 'ID').
fieldname(vocopv:field2, vocopv:inventarisnummer, 'Inventarisnummer', 'Long INT', 'Inventarisnummer').
fieldname(vocopv:field3, vocopv:das_nummer, 'DAS nummer', 'Long INT', 'DAS nummer').
fieldname(vocopv:field4, vocopv:reisnummer, 'Reisnummer', 'Long INT', 'Reisnummer').
fieldname(vocopv:field5, vocopv:datum_vertrek, 'Datum vertrek', 'Date/Time', 'Datum vertrek').
fieldname(vocopv:field6, vocopv:jaar_vertrek, 'Jaar vertrek', 'Long INT', 'Jaar vertrek').
fieldname(vocopv:field7, vocopv:field7, 'Field7', 'Long INT', '').
fieldname(vocopv:field8, vocopv:field8, 'Field8', 'Long INT', '').
fieldname(vocopv:field9, vocopv:scheepsnamen, 'Field9', 'CHAR', 'Scheepsnamen').
fieldname(vocopv:field10, vocopv:kamers_van_voc,'Field10', 'CHAR', 'Kamers van de VOC').
fieldname(vocopv:field11, vocopv:plaats_vertrek, 'Plaats vertrek', 'Long INT', 'Plaats vertrek').
fieldname(vocopv:field12, vocopv:aankomst_kaap, 'Aankomst Kaap', 'CHAR', 'Aankomst Kaap').
fieldname(vocopv:field13, vocopv:vertrek_kaap, 'Vertrek Kaap', 'CHAR', 'Vertrek Kaap').
fieldname(vocopv:field14, vocopv:uuid, 'UUID', 'CHAR', 'UUID, unique id').


*/
