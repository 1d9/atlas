all: artefacts/cartographer.v1.zip artefacts/cartographer.v2.zip

artefacts:
	mkdir -p artefacts

artefacts/cartographer.v1.zip: artefacts $(wildcard cartographer/v1/*.json)
	(cd cartographer/v1/; zip ../../artefacts/cartographer.v1.zip ./*)

artefacts/cartographer.v2.zip: artefacts $(wildcard cartographer/v2/*.json)
	(cd cartographer/v2/; zip ../../artefacts/cartographer.v2.zip ./*)

.PHONY: all