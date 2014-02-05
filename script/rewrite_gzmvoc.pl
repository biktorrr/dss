:- module(rewrite_gzmvoc,
	  [ rewrite_gzmvoc/0,
	    rewrite_gzmvoc/1,
	    rewrite_gzmvoc/2,
	    list_rules_gzmvoc/0
	  ]).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(xmlrdf/rdf_convert_util)).
:- use_module(library(xmlrdf/cvt_vocabulary)).
:- use_module(library(xmlrdf/rdf_rewrite)).

:- debug(rdf_rewrite).

%%	rewrite
%
%	Apply all rules on the graph =data=

rewrite_gzmvoc:-
	rdf_rewrite(gzmvoc).

%%	rewrite(+Rule)
%
%	Apply the given rule on the graph =data=

rewrite_gzmvoc(Rule) :-
	rdf_rewrite(gzmvoc, Rule).

%%	rewrite(+Graph, +Rule)
%
%	Apply the given rule on the given graph.

rewrite_gzmvoc(Graph, Rule) :-
	rdf_rewrite(Graph, Rule).

%%	list_rules

%	List the available rules to the console.

list_rules_gzmvoc :-
	rdf_rewrite_rules.

:- discontiguous
	rdf_mapping_rule/5.


clean_empty
@@
{_,_,literal('')}
<=>
true.

make_uri @@
{S, rdf:type, gzmvoc:'DataTable'},
{S, gzmvoc:telling,literal(T)},
{S,gzmvoc:scheepsnaam, literal(Naam)}\
{S}
<=>
literal_to_id(['telling-',T,'-',Naam],gzmvoc,URI),
	{URI}.

give_class @@
{S, rdf:type, gzmvoc:'DataTable'}
<=>
{S, rdf:type, gzmvoc:'Telling'}.


make_ship @@
{S, gzmvoc:telling,literal(T)}\
{S, gzmvoc:scheepsnaam, SN}
<=>
literal_to_id(['schip-',T,'-',SN],gzmvoc,URI),
{S,gzmvoc:schip,URI},
{URI, rdf:type, gzmvoc:'Schip'},
{URI, gzmvoc:scheepsnaam, SN}.

make_ship @@
{S, gzmvoc:schip, URI}\
{S, gzmvoc:scheepstype, ST}
<=>
{URI, gzmvoc:scheepstype, ST}.


make_captain @@
{S, gzmvoc:telling,literal(T)}\
{S, gzmvoc:achternaam, literal(AN)},
{S, gzmvoc:voornaam, VN}?,
{S, gzmvoc:tussenvoegsel, TV}?,
{S, gzmvoc:geboorteplaats, GP}?,
{S, gzmvoc:aankomstAzie, AA}?
<=>
literal_to_id(['schipper-',T,'-',AN],gzmvoc,URI),
{S, gzmvoc:schipper,URI},
{URI,rdf:type, gzmvoc:'Schipper'},
{URI, gzmvoc:voornaam, VN},
{URI, gzmvoc:achternaam, literal(AN)},
{URI, gzmvoc:tussenvoegsel, TV},
{URI, gzmvoc:geboorteplaats, GP},
{URI, gzmvoc:aankomstAzie, AA}.


make_az @@
{S, gzmvoc:azAanduidingMatrozen, A}?,
{S, gzmvoc:azAanduidingVoorman, B}?,
{S, gzmvoc:azAangenomenJaar, C}?,
{S, gzmvoc:azAangenomenParthesius, D}?,
{S, gzmvoc:azAangenomenPlaats, E}?,
{S, gzmvoc:azAantalKok, F}?,
{S, gzmvoc:azAantalMatrozen, G}?,
{S, gzmvoc:azAantalVoorman, H}?,
{S, gzmvoc:azAantalVoormansmaat, I}?,
{S, gzmvoc:azLoonKok, J}?,
{S, gzmvoc:azLoonMatrozen, K}?,
{S, gzmvoc:azLoonVoorman, L}?,
{S, gzmvoc:azLoonVoormansmaat, M}?,
{S, gzmvoc:azRegistratieKop, N}?,
{S, gzmvoc:azRegistratieOpmerking, O}?,
{S, gzmvoc:azRegistratieWijze, P}?
<=>
at_least_one_given([A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P]),
{S, gzmvoc:aziatischeBemanning,
	 bnode([
	     gzmvoc:azAanduidingMatrozen = A,
	     gzmvoc:azAanduidingVoorman = B,
	     gzmvoc:azAangenomenJaar = C,
	     gzmvoc:azAangenomenParthesius = D,
	     gzmvoc:azAangenomenPlaats = E,
	     gzmvoc:azAantalKok = F,
	     gzmvoc:azAantalMatrozen = G,
	     gzmvoc:azAantalVoorman = H,
	     gzmvoc:azAantalVoormansmaat = I,
	     gzmvoc:azLoonKok = J,
	     gzmvoc:azLoonMatrozen = K,
	     gzmvoc:azLoonVoorman = L,
	     gzmvoc:azLoonVoormansmaat = M,
	     gzmvoc:azRegistratieKop = N,
	     gzmvoc:azRegistratieOpmerking = O,
	     gzmvoc:azRegistratieWijze = P
	       ])
}.


make_as @@
{S, gzmvoc:asAanduidingSoldaten, A}?,
{S, gzmvoc:asAanduidingVoorman, B}?,
{S, gzmvoc:asAangenomenJaar, C}?,
{S, gzmvoc:asAangenomenPlaats, E}?,
{S, gzmvoc:asLoonCorporaal, J}?,
{S, gzmvoc:asLoonSoldaat, K}?,
{S, gzmvoc:asLoonHoofd, L}?,
{S, gzmvoc:asRegistratieKop, N}?,
{S, gzmvoc:asRegistratieOpmerking, O}?,
{S, gzmvoc:asRegistratieWijze, P}?
<=>
at_least_one_given([A,B,C,E,J,K,L,N,O,P]),
{S, gzmvoc:aziatischeSoldaten,
	 bnode([
	     gzmvoc:asAanduidingSoldaten = A,
	     gzmvoc:asAanduidingVoorman = B,
	     gzmvoc:asAangenomenJaar = C,
	     gzmvoc:asAangenomenPlaats = E,
	     gzmvoc:asLoonCorporaal = J,
	     gzmvoc:asLoonSoldaat = K,
	     gzmvoc:asLoonHoofd = L,
	     gzmvoc:asRegistratieKop = N,
	     gzmvoc:asRegistratieOpmerking = O,
	     gzmvoc:asRegistratieWijze
	       ])
}.


at_least_one_given(Values) :-
member(V, Values),
ground(V), !.



% geboorteplaats is promoted to SKOS concept, stored in separate
% named graph, the SKOS theasaurus ConceptScheme as well as its
% topconcept is specific to GZMVOC
% The new 'has_geboorteplaatas' link is added to this graph, the
% old 'geboorteplaats' link is retained
%
geboorteplaats_to_concept @@
{S,gzmvoc:geboorteplaats, literal(H)}
==>
literal_to_id(['place-',H],gzmvoc,URI),
	rdf_assert(URI, rdf:type, skos:'Concept', gzmvocplace),
	rdf_assert(URI, skos:inScheme, gzmvoc:'GZMVOCPlaceScheme', gzmvocplace),
	rdf_assert(URI, skos:prefLabel, literal(H), gzmvocplace),
	{S, gzmvoc:has_geboorteplaats, URI}.



% Same for lokatie,these might overlap with previous one, check with
% Matthias
lokatie_to_concept @@
{S,gzmvoc:lokatie, literal(H)}
==>
snip_ter_rede(H,H1),
literal_to_id(['place-',H1],gzmvoc,URI),
	rdf_assert(URI, rdf:type, skos:'Concept', gzmvocplace),
	rdf_assert(URI, skos:inScheme, gzmvoc:'GZMVOCPlaceScheme', gzmvocplace),
	rdf_assert(URI, skos:prefLabel, literal(H), gzmvocplace),
	{S, gzmvoc:has_lokatie, URI}.


% cut of "ter rede" when making concept out of lokatie. This is a bit
% hacky
snip_ter_rede(L1,L2):-
	sub_atom(L1,B,_L,_,', ter re'),
	sub_atom(L1,0,B,_,L2),!.

snip_ter_rede(L,L).

skos_assertions_gzmvoc:-
	rdf_assert(gzmvoc:'GZMVOCPlaceScheme', rdf:type, skos:'ConceptScheme', gzmvocplace),
	rdf_assert(gzmvoc:'GZMVOCPlaceScheme', rdfs:label, literal('Generale ZeemonsterRollen Place ConceptScheme'), gzmvocplace).


% Added a bit later. We now keep the original string, and promote the
% label to a concept as well.

make_shiptype
@@
{S, gzmvoc:scheepstype,literal(ST)}
==>
literal_to_id(['scheepstype-',ST],gzmvoc,URI),
{S, gzmvoc:has_scheepstype,URI} >> gzmvoc_gen_thes ,
{URI,rdf:type, gzmvoc:'ScheepsType'} >> gzmvoc_gen_thes ,
{URI,skos:inScheme, gzmvoc:'ScheepsTypeConceptScheme'} >> gzmvoc_gen_thes ,
{URI, skos:prefLabel, literal(ST)} >> gzmvoc_gen_thes .

