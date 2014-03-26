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

cliopatria:menu_item(500=places/provoviz, 'Provoviz').

:- http_handler(root(provoviz), provoviz, []).
:- http_handler(root(provovizresult), provovizresult, []).


provoviz(_):-
		reply_html_page(cliopatria(_),title('Vizualize provenance'),
                        [ h1('Visualize provenance'),
			  \provheader,
                          \provform			                          ]).

provheader -->html(\['<p>Here, you can vizualize the provenance of the DSS datacloud. For the visualization, we use <a href="www.provoviz.org">Rinke Hoekstra\'s PROV-O-Viz tool</a>.PROV-O-Viz visualizes any provenance graph expressed using the <a href="http://www.w3.org/TR/prov-o/" target="_blank">W3C PROV-O vocabulary</a> as an intuitive <a href="http://bost.ocks.org/mike/sankey/" target="_blank">Sankey diagram</a> using the <a href="http://d3js.org/">D3.js</a></p>'])	.

provform-->

        html([

		  form([id(form), action='provovizresult'],
                    ['Provenance graph IRI:',
		     input([size='50',type='text', name='graph_uri', value='http://purl.org/collections/nl/dss/dss_provenance'],[]),
		     br([]),
                     button([ id='searchButton', value='submit',onclick='this.disabled=true;this.value=\'Sending, please wait...\';this.form.submit();'],['Get provenance!'])
		       ])
             ]).


provovizresult(Request):-
	http_parameters(Request, [], [form_data(Data)]),
	member(graph_uri=GUri,Data),
	get_prov_text(GUri, PT),
	http_open(%'http://localhost:3020/test',
		  'http://provoviz.org/service',
		  PStream,
		  [method(post),
		   post(form_data([graph_uri=GUri,
				      data=PT]))
		  ]
		      ),
	read_stream_to_codes(PStream, PCodes),
	close(PStream),
	atom_codes(PAt, PCodes),
	reply_html_page(cliopatria(_),title('Vizualize provenance'),
                        [  h1('Provenance result'),
			   \provheader,
                          \[PAt]			                          ]).




get_prov_text(GUri,PT):-
	with_output_to(string(PT),
		       rdf_save_turtle(stream(current_output),[graph(GUri)])).


