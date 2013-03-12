UpStage
=======

<a href="http://upstage.org.nz/">UpStage</a> is a client-server application platform for <a href="http://en.wikipedia.org/wiki/Cyberformance">Cyberformance</a> (<a href="http://en.flossmanuals.net/upstage-v242-user-manual/">user manual</a>).

This repository holds a modified version of the <a href="http://sourceforge.net/apps/trac/upstage/browser/branches/2.4.2?rev=491">official UpStage 2.4.2 branch (revision 491)</a>.

The intention is to extend UpStage with streaming (audio, video) functionality incooperating the <a href="http://www.red5.org/">Red5</a> streaming server. Read more on the <a href="http://upstage.org.nz/blog/?p=5256">UpStage Blog Announcement</a>.

## Licence

See LICENSE.txt for the GNU GENERAL PUBLIC LICENSE

## Requirements

UpStage requires Python version 2.6 or 2.7 with <a href="http://twistedmatrix.com">Twisted</a> (&gt;= 8.1, &lt; 9.0, 8.2 recommended) and <a href="http://pypi.python.org/pypi/zope.interface">zope.interface</a>. The following Text-to-Speech software is supported (if installed): <a href="http://sourceforge.net/projects/rsynth/">rsynth</a>, <a href="http://espeak.sourceforge.net/">eSpeak</a>, <a href="http://tcts.fpms.ac.be/synthesis/mbrola.html">MBROLA</a> and <a href="http://www.cstr.ed.ac.uk/projects/festival/">Festival</a>.  

For media upload some additional tools have to be installed (TBD).

The Video Hack makes use of <a href="http://www.red5.org">Red5</a>, which needs to be installed either on the same server or an accessible network resource.

## Installation

Please follow the instructions in <a href="http://www.foobarlab.net/blog/2012/11/installing-upstage-from-scratch">Installing UpStage from scratch</a> (although this refers to version 2.1 which is outdated now, but should give some hints).

## Development

ActionScript code is compiled using <a href="http://www.mtasc.org/">MTASC</a> and <a href="http://swfmill.org/">swfmill</a>, all documentation is generated using <a href="http://www.doxygen.org/">Doxygen</a>.

### Recommended IDE configuration

You may use <a href="http://www.eclipse.org/">Eclipse IDE</a> with <a href="http://sourceforge.net/projects/aseclipseplugin/">ASDT</a> and <a href="http://pydev.org/">PyDev</a> plugins installed.

Alternatively you may use the <a href="http://www.flashdevelop.org/">FlashDevelop IDE</a>.

