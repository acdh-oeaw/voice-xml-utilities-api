VOICE XML UTILITIES API
=======================

An API that generates data in JSON format from the VOICE CLARIAH data repository.
This is used in the [VOICE 3.0 Online frontend]()
to supply static data about the corpus.
This is mostly used to recalculate XML tag counts and to generate th data stored in corpustree.json
of the VOICE Frontend repository.
Fetch corpustree.json from a running instance at http://localhost:8984//VOICE_CLARIAH/corpus/tree

Set up a local instance
-----------------------

### Prerequisites


* Java LTS ([Oracle](https://www.oracle.com/java/technologies/javase-downloads.html),
  [Azul](https://www.azul.com/downloads/zulu-community/?version=java-11-lts&package=jdk),
  or others) (11 at the moment)
* git ([for Windows](https://gitforwindows.org/), shipped with other OSes)
* curl for downloading [Saxon HE](https://www.saxonica.com/download/java.xml)
  (10.3 at the moment, curl is included with git for windows)
* This git repository needs to be cloned inside a [BaseX ZIP-file distribution](https://basex.org/download/)
  (9.5 at the moment)


### Setup

* unzip BaseX*.zip (for example in your home folder)
  `<basexhome>` is the directory containing `BaseX.jar` and the `bin`, `lib` and
  `webapp` directory (`basex` after unpacking the BaseX*.zip file, but you should
  probably rename it)
* in `<basexhome>/webapp` git clone this repository,
  please do not change the name `voice-clariah-api`
* start a bash in `<basexhome>/webapp/voice-clariah-api`
* run `./deployment/initial.sh`

### Dependencies

The following dependencies are installed for you using `./deployment/initial.sh`

* [Saxon XSLT 2/3 HE processor](https://www.saxonica.com/download/java.xml)
* [openapi4restxq for BaseX](https://github.com/acdh-oeaw/openapi4restxq/tree/master_basex)
* [voice data](https://gitlab.com/acdh-oeaw/voice/voice_data) (privat! fix that!)