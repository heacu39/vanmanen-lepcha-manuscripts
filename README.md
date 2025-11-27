# vanmanen-lepcha-manuscripts

This repository contains transcripts for Johan Van Manen's collection
of Lepcha manuscripts held by the Leiden University Library.

There are 182 manuscripts in total. Some are being transcribed by hand
to form "ground truth" data; others will be transcribed automatically.

The base directory has two XML files:

- collection.xml: Internal IDs and manifests for all 182 manuscripts.
- manifests.xml: All the manifests as XML together in one big file.

In addition, there are three XSL files:

- manifests.xsl: Produces manifests.xml from collection.xml.
- pages.xsl: This stylesheet corrects Page XML exports from Transkribus.
A transcribed page of text must include: (a) a transcription for each
line of text, and (b) boundary boxes around each Lepcha syllable. The
stylesheet takes the syllables from the line annotations and then
affiliates them to the word boxes in the word annotation layer. It also
sorts the words by leftmost x coordinate. If the number of syllables
in the line transcription doesn't match the number of boxed words,
then an error is placed in the output.
- annotations.xsl: This stylesheet takes the corrected Page XML files
and produces JSON annotation files for each transcribed manuscript page.
Annotations target the IIIF Content Search Version 2.0 API, with some
additional wrapping data. Every possible syllable ngram for each line
of text is generated, along with corresponding rectangular boundary
boxes computed from the word boundary boxes.

Explanation of directories:
- transkribus: Transkribus Page XML exports, with the XML Schema
reference removed.
- pages: Corrected Page XML files.
- annotations: JSON annotation files, one per transcribed page.

