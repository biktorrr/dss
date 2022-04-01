Dutch Ships and Sailors (DSS) Linked Data Cloud
'Victor de Boer
===

* Description
Repository for code (and possibly data) produced in the context of the CLARIN 'Dutch Ships and Sailors' project. More information on this project can be found at http://dutchshipsandsailors.nl or in the paper [1]. 

The Dutch Ships and Sailors (DSS) Linked Data Cloud brings together four curated datasets on Dutch Maritime history as five-star linked data. The individual datasets use separate datamodels, designed in close collaboration with maritime historical researchers. The individual models are mapped to a common interoperability layer, allowing for analysis of the data on the general level. We present the datasets, modeling decisions, internal links and links to external data sources. We show ways of accessing the data and present a number of examples of how the dataset can be used for historical research. The Dutch Ships and Sailors Linked Data Cloud is a potential hub dataset for digital history research and a prime example of the benefits of Linked Data for this field.



* Content
The repository contains the following
- cmdi_isocat/ CMDOI files for the four core datasets plus DSS metadata
- csv/ Original CSV version of GZMVOC data
- rdf/ contains the RDF data, in separate RDF/Turtle files
-- void.ttl descrives the various datasets and files. Cliopatria can use this VOID file to load the various datasets.
-- metadata.ttl provides further metadata in schema.org format
-- dss_provenance contains provenance information for each of the named graphs in PROV
-- The remaining files are RDF/turtle files (including gzipped files) making up the actual dataset:
--- vocopv_X: VOC opvarenden 
--- das_X: Dutch Asiatic Shipping
--- gzmvoc_X: Generale zeemonsterrollen VOC
--- mdb_X: Noordelijke monsterrollen (18/19C)
- rdfxml/ contains the RDFXML conversion scripts (see https://semanticweb.cs.vu.nl/xmlrdf/)
- script/ contains additional (RDFXML and python) scripts
- sources/ contains source material (MS Excel and Word documents)
- xml/ contains XML source files
- web/ contains web files for the Cliopatria landing page


* Cite as
[1] Boer, V. D., Rossum, M. V., Leinenga, J., & Hoekstra, R. (2014, October). Dutch ships and sailors linked data. In International Semantic Web Conference (pp. 229-244). Springer, Cham.
