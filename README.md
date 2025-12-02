# vanmanen-lepcha-manuscripts

This repository contains transcripts for Johan Van Manen's collection
of Lepcha manuscripts held by the Leiden University Library.

There are 182 manuscripts in total. Some are being transcribed by hand
to form "ground truth" data; others will be transcribed automatically.

The **manifests.xml** file contains XML versions of the IIIF manifests
that are currently in play. In some cases, edits have been made to these
files. Transkribus did not correctly import all pages, so some pages 
have been removed from the original Leiden University Library manifests.

The **iiif-manifests** directory contains deployable manifests, which 
link to IIIF Content Search API 1.0 and Content Search API 2.0 endpoints.
These manifests can be tested in various IIIF-compliant viewers.

The **transkribus** directory has Transkribus Page XML exports, with the 
XML Schema reference removed.

The **pages** directory contains corrected Page XML files, the result
of applying **pages.xsl** to the **transkribus** directory.
A transcribed page of text must include: (a) a transcription for each
line of text, and (b) boundary boxes around each Lepcha syllable. The
stylesheet takes the syllables from the line annotations and then
affiliates them to the word boxes in the word annotation layer. It also
sorts the words by leftmost x coordinate. If the number of syllables
in the line transcription doesn't match the number of boxed words,
then an error is placed in the output.

The **annotations** directory takes the corrected Page XML files and
produces JSON annotation files for each transcribed manuscript page.
Annotations target the IIIF Content Search Version 2.0 API, with some
additional wrapping data. Every possible syllable ngram for each line
of text is generated, along with corresponding rectangular boundary
boxes computed from the word boundary boxes.