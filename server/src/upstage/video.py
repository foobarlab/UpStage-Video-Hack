#Copyright (C) 2004-2006 Douglas Bagnall (douglas--paradise-net-nz)
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
""" 'Video' in upstage is made from a series of still jpeg images.
    When the client loads one jpeg it waits a short time, before
    trying to reload from the same url.
""" 

#standard lib
import os, time

#upstage
from upstage import config
#from upstage.misc import no_cache

#twisted
from twisted.python import log
from twisted.internet import reactor, defer
from twisted.web import server, error, http
from twisted.web.resource import Resource

class VideoDirectory(Resource):
    """Requests for a child cause the creation of a _VideoFile object,
    if the request filename looks reasonably like an image.
    """
    deferable_types = ('jpg', 'jpeg')

    def __init__(self, path):
        """path -- where to find the files"""
        log.msg("Starting VideoDirectory %s" % id(self))
        Resource.__init__(self)
        self.path = path
        self.children = {} # holds a VideoFile object for each requested subpath
                           # NB:they should expire from disuse

    def deferable(self, path):
        """is the file deferable? depends on the extension"""
        tail = path[path.rfind('.') + 1:] # last bit after a "."
        return tail in self.deferable_types

    def getChild(self, path, request):
        """If requests come in quick succession, check if the file has
        changed.  If not, wait until it has.
        """
        log.msg("in VideoDirectory, asking for '%s'" %path)
        if path not in self.children:
            if path == '':
                return self            
            elif not self.deferable(path):
                log.msg("wrong type (%s): not deferring" % path)
                return error.ForbiddenResource('no no no')
            log.msg('creating new child for %s, self.children is %s' %(path, self.children))
            self.children[path] = _VideoFile(path, self.path)
            reactor.callLater(config.VIDEO_DESTRUCT_TIME, self.drop, path)

        return self.children[path]

    def drop(self, path):
        """Pop a timed-out child, and returns the world to equilibrium."""
        c = self.children.get(path)
        if c is not None and c.unused():
            del self.children[path]
            log.msg("dropping %s" %c)
        else:
            log.msg("not dropping %s, somebody still loves it" %c)
            #try again later
            reactor.callLater(config.VIDEO_DESTRUCT_TIME, self.drop, path)


    def render(self, resource):
        #XXX links to images that won't automatically refresh
        out = ["<html><body><h1>Video</h1><ul>"]
        for p in os.listdir(self.path):
            if self.deferable(p):
                out.append('<li><a href="%s%s">%s</a></li>'
                           %(config.WEBCAM_URL, p, p))
        out.append('</ul></body></html>')
        return '\n'.join(out)
    

class _VideoFile(Resource):
    """For periodically replaced images, that are meant to look like
    videos.  Each client is expected to send a new http request when
    it needs the next image in sequence.

    This resource doesn't know where the client is up to in the
    sequence, but will try to avoid sending an image if it has not
    recently changed on the server.

    If the client sends a IF-MODIFIED-SINCE header (depends on the
    browser) a relevant modification is looked for, and if found, the
    changed image is returned.

    Otherwise the server looks to see if there has been a recent
    change that the client can't reasonably have received.  If so, it
    is sent. If not, the final answer is delayed for a short time, in
    the hope that the image is about to change (this is reasonable if
    the webcams are actually working).  If the image is not changing,
    and there is no if-modified-since header, it returns the image
    eventually anyway."""
    interval = config.VIDEO_FRAME_LENGTH

    def __init__(self, filename, directory):
        log.msg("in _VideoFile, for %s" % filename)  #should only happen once,
        Resource.__init__(self)
        self.filename = filename
        self.fullpath = os.path.join(directory, filename)
        self.lastmod = 0
        self.size = 0
        self.askers = {}
        self.waiting = False
        self.requests = []
        self.content = None


    def _update(self):
        """Look for changes in the file.  If the file's modification time or size
        is different, it is assumed to have changed."""
        try:
            s = os.stat(self.fullpath)            
            if s.st_mtime != self.lastmod or self.size != s.st_size:        
                self.lastmod = s.st_mtime
                self.size = s.st_size
                self.content = None # forcing re-read.
        except OSError, e:
            #it is difficult to know what to do here perhaps the file
            # is being updated, in which case it is a matter of
            # waiting, or of pretending it has changed
            # or perhaps it is really lost.
            # SO, we set it to send a 404 and let the client decide what to do. (perhaps 503 is more appropriate)
            log.msg("%s does not seem to exist! (%s)" % (self.fullpath, e))
            self.size = self.lastmod = 0
            self.content = None

    def render_pending(self, due):
        """render requests that have collected up - but only if things have changed for them."""
        if due:
            r = due.pop(0)
            #log.msg('rendering pending %s. %s requests left' % (r, len(due)))
            self.render(r)
            reactor.callLater(0, self.render_pending, due)

    def render(self, request):
        """see class docstring"""
        if not self.waiting:
            self._update()
            self.waiting = True
            def wake():
                self.waiting = False
                self.render_pending(self.requests)
                self.requests = []
            reactor.callLater(self.interval, wake)
            
        remoteID = request.args.get('s', [None])[0]
        if (remoteID not in self.askers or
            self.askers[remoteID] != (self.lastmod, self.size) or
            time.time() - self.lastmod > config.VIDEO_TIMEOUT):
            self.really_render(request)
            return server.NOT_DONE_YET
        else:
            #log.msg("*** delaying render ***")
            # not modified. wait for the change.
            self.requests.append(request)
            return server.NOT_DONE_YET


    def really_render(self, request):
        """actually write the image data for the request"""
        remoteID = request.args.get('s', [None])[0]
        #if there is no 's' attribute, this is not a streaming request
        if remoteID is not None:
            self.askers[remoteID] = (self.lastmod, self.size)
        #log.msg("rendering %s for %s" %(self.filename, remoteID))
        if self.content is None:
            try:
                f = open(self.fullpath)
                self.content = f.read()
                f.close()
            except IOError, e:
                log.msg("%s File isn't readable!\n" % self.fullpath, e)
                request.setResponseCode(self, 404)
                self.content = error.NoResource('file missing, presumed drowned').render(request)

        
        request.setHeader('Content-type', 'image/jpeg')
        request.setLastModified(self.lastmod)
        #need to set content length when not returning from .render
        request.setHeader('Content-length', len(self.content))
        request.write(self.content)
        request.finish()

    def unused(self):
        """estimate of whether anyone is watching this video anymore"""
        return not self.requests
