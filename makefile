all: artefacts/cartographer.zip

artefacts:
	mkdir -p artefacts

artefacts/cartographer.zip: artefacts $(wildcard cartographer/*.json)
	(cd cartographer; zip ../artefacts/cartographer.zip ./*)

.PHONY: all