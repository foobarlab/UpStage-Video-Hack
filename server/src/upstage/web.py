#Copyright (C) 2003-2006 Douglas Bagnall (douglas * paradise-net-nz)
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


"""
Author: 
Modified by: Phillip Quinlan, Endre Bernhardt, Alan Crow
Modified by: Shaun Narayan (02/16/10) - Changed web tree structure
             to work according to new site layout (changed AdminRealm and website).
Modified by: Nicholas Robinson (04/04/10) - Changed home page to take data.stages collection.
Notes: Guards should be changed to nevow at some point. Woven is depricated and
        poorly documented, nevow seems to be the standard with twisted.
Modified by: Corey, Heath, Karena 24/08/2011 - Added media tagging to function success namely self.media_dict.add(tags = '')
                                             - Added media tagging set the tags to self.tags in AudioThing and VideoThing 
             Heath, Karena, Corey 26/08/2011 - Added retrieving tags from form when avatar uploaded so tags can now be added when media
                                                is uploaded.                                      
Modified by: Daniel Han 26/06/2012		- Modified NonAdmin part inside AdminRealm
Modified by: Daniel Han 29/06/2012		- ADDed SU rights for Admin/Edit access. (inside AdminRealm)
Modified by: Daniel Han 29/08/2012      - Added /Admin/Home and /Admin/Stages. so when user logged in, home and stages are linked to /Admin/Stages
                                        - Also, when user is not logged in, it will show it just as if user is in normal home or stages page.
Modified by: Daniel Han 11/09/2012      - Added Edit/NonAdmin and Edit/Stages

Modified by: Daniel, Scott 11/09/2012   - Added Audio Upload Postback and File size error post back.
Modified by: Gavin          5/10/2012   - Imported AdminError class from pages.py to change the errorMsg variable title for different errors
                                        - Implemented changes to errorMsg in def failure() and def render()
"""


"""Defines the web tree."""

#standard lib
import os, random, datetime, tempfile, string
from urllib import urlencode

# TODO for compressing
#from gzip import GzipFile

# for http headers
from time import time, strftime, mktime

#upstage
from upstage import config, util
from upstage.util import save_tempfile, validSizes, getFileSizes
from upstage.misc import new_filename, no_cache, UpstageError
from upstage.video import VideoDirectory
from upstage.pages import  AdminLoginPage, AdminBase, errorpage, Workshop, HomePage, SignUpPage, Workshop, StageEditPage,\
                           MediaUploadPage, MediaEditPage, MediaEditPage2, CreateDir, \
                           NewPlayer, EditPlayer, NewAvatar, NewProp, NewBackdrop, NewAudio,     \
                           ThingsList, StagePage, UserPage, NonAdminPage, PageEditPage, HomeEditPage, WorkshopEditPage, SessionCheckPage, successpage,\
                           NonAdminEditPage, StagesEditPage, AdminError #VideoThing, AudioThing, 

#twisted
from twisted.python import log
from twisted.internet.utils import getProcessValue
from twisted.internet import reactor

from twisted.web import static, server
from twisted.web.woven import guard
from twisted.web.util import Redirect
from twisted.web.resource import IResource, Resource


from twisted.cred.portal import IRealm, Portal
from twisted.cred.credentials import IAnonymous, IUsernamePassword
from twisted.cred.checkers import AllowAnonymousAccess

# TODO needed for gzip compression
# parseAcceptEncoding() method taken from: http://bazaar.launchpad.net/~divmod-dev/divmod.org/trunk/view/head:/Nevow/nevow/compression.py 
#def parseAcceptEncoding(value):
#    """
#    Parse the value of an Accept-Encoding: request header.
#
#    A value of 0 indicates that the content coding is unacceptable; any
#    non-zero value indicates the coding is acceptable, but the acceptable
#    coding with the highest value is preferred.
#    """
#    encodings = {}
#    if value.strip():
#        for pair in value.split(','):
#            pair = pair.strip()
#            if ';' in pair:
#                params = pair.split(';')
#                encoding = params[0]
#                params = dict(param.split('=') for param in params[1:])
#                priority = float(params.get('q', 1.0))
#            else:
#                encoding = pair
#                priority = 1.0
#            encodings[encoding] = priority
#
#    if 'identity' not in encodings and '*' not in encodings:
#        encodings['identity'] = 0.0001
#
#    return encodings



class NoCacheFile(static.File):
    """A file that tries not to be cached."""
    def render(self, request):
        """Set anti-cache headers before returning contents."""
        no_cache(request)
        return static.File.render(self, request)

# handle cached static.File: http://twistedmatrix.com/documents/8.1.0/api/twisted.web.static.File.html 
class CachedFile(static.File):
    """Handling of static files: add caching headers, process additional url parameters."""
    
    def openForReading(self, *args, **kwargs):
        return static.File.openForReading(self, *args, **kwargs)
    
    def render(self,request):
        log.msg("CachedFile: Handling static file request %s" % request)
        
        if not self.isdir():
            download = request.args.get('download', [None])[0]
            if(download):
                
                # check if a name was explicitly given
                filename = request.args.get('name', [None])[0]
                if filename is None:
                    filename = os.path.basename(self.path)
                
                # ensure the filename does not contain illegal characters
                safechars = '_-.()' + string.digits + string.ascii_letters
                allchars = string.maketrans('', '')
                deletions = ''.join(set(allchars) - set(safechars))
                safe_filename = string.translate(filename, allchars, deletions)
                if safe_filename.startswith('.'):
                    safe_filename = 'download%s' % safe_filename
                
                # set headers
                request.setHeader('Content-Disposition', ('attachment; filename=%s' % safe_filename))
                request.setHeader('Content-Transfer-Encoding','binary')
                request.setHeader('Content-Type','application/octet-stream')
                
                # disable caching
                request.setHeader('Expires','0')
                request.setHeader('Cache-Control','no-cache, no-store, no-cache, must-revalidate, max-age=0')
                request.setHeader('Cache-Control','post-check=0, pre-check=0')
                request.setHeader('Cache-Control','private');
                request.setHeader('Pragma','private')
                request.setLastModified(time())   # set Last-Modified to current time
                
                log.msg("CachedFile: sending file from path '%s' named '%s' as download attachment" % (self.path, safe_filename))
            else:
                cache_duration = 60 * 60 * 24 * 7    # cache for at least one week
                expire_time = datetime.timedelta(seconds=cache_duration)
                request.setHeader('Pragma','cache')
                request.setHeader('Cache-Control','public, max-age=%s' % cache_duration)
                request.setHeader('Expires',(datetime.datetime.now() + expire_time).strftime("%a, %d %b %Y %H:%M:%S GMT"))  # TODO instead of now() it should be the time when the request was made
                last_modified = self.getModificationTime()
                log.msg("CachedFile: file was last modified @ %s" % last_modified)
                request.setLastModified(last_modified)
                
                # TODO add Etag for cache validation? Is the modification date sufficient for reverse-proxying?
            
            # TODO not working yet
#            # send gzip compressed if client sends gzip Accept-Encoding header
#            value = request.getHeader('accept-encoding')
#            if value is not None:
#                encodings = parseAcceptEncoding(value)
#                if(encodings.get('gzip', 0.0) > 0.0):
#                    log.msg("CachedFile: client does accept GZIP compression")
#                    if request.method == 'HEAD':
#                        return ''
#                    #if self.path.exists():
#                    if self.path:
#                        log.msg("CachedFile: path to file exists: %s" % self.path)
#                        compressedFile = tempfile.NamedTemporaryFile(mode='wb', bufsize=-1, suffix='.gz', prefix='cachefile_', dir=None, delete=False)
#                        log.msg("CachedFile: created temporary file %s" % compressedFile.name)
#                        uncompressedFile = self.open(mode='rb')
#                        gzipFile = GzipFile(fileobj=compressedFile, mode='wb', compresslevel=6)
#                        gzipFile.writelines(uncompressedFile)
#                        gzipFile.close()
#                        uncompressedFile.close()
#                        compressedFile.close()
#                        log.msg("CachedFile: uncompressed file = %s" % uncompressedFile.name)
#                        log.msg("CachedFile: compressed file = %s" % compressedFile.name)
#                        ##request.setHeader('content-length', os.path.getsize(compressedFile.name))
#                        request.setHeader('content-encoding', 'gzip')
#                        log.msg("CachedFile: uncompressed file size is %s bytes" % os.path.getsize(uncompressedFile.name))
#                        log.msg("CachedFile: compressed file size is %s bytes" % os.path.getsize(compressedFile.name))
#                        self.path = compressedFile.name
#                    
#                else:
#                    log.msg("CachedFile: client does NOT accept GZIP compression")
#            else:
#                log.msg("CachedFile: client does NOT accept compression")
        
        return static.File.render(self,request)

def _getWebsiteTree(data):
    """Set up and return the web tree"""
    
    #media = static.File(config.MEDIA_DIR)
    media = CachedFile(config.MEDIA_DIR)           # cached
    
    stills = static.File(config.WEBCAM_DIR)        # not cached
    video = VideoDirectory(config.WEBCAM_DIR)      # not cached
    media.putChild(config.WEBCAM_SUBURL, video)
    media.putChild(config.WEBCAM_STILL_SUBURL, stills)
    
    #docroot = static.File(config.HTDOCS)
    docroot = CachedFile(config.HTDOCS)             # cached
    #docroot.putChild(config.MEDIA_SUBURL, media)
    docroot.putChild(config.MEDIA_SUBURL, media)
    #docroot.putChild(config.SWF_SUBURL, NoCacheFile(config.SWF_DIR))
    docroot.putChild(config.SWF_SUBURL, CachedFile(config.SWF_DIR))     # cached  
    docroot.putChild('stages', ThingsList(data.players.audience, childClass=StagePage, collection=data.stages))
    docroot.putChild('admin', adminWrapper(data))
    # Shaun Narayan (02/01/10) - Added home and signup pages to docroot.
    docroot.putChild('home', HomePage(data.stages))
    docroot.putChild('signup', SignUpPage())
    # Daniel Han (03/07/2012) - Added this session page.
    docroot.putChild('session', SessionCheckPage(data.players))
    # pluck speech directory out of stages
    docroot.putChild(config.SPEECH_SUBURL, data.stages.speech_server)
    # PQ & EB: 17.9.07
    docroot.putChild(config.AUDIO_SUBURL, data.stages.audio_server)

    return docroot



# XXX update to new guard? (or bespoke?)
class AdminRealm:
    """The authentication part
	All comes together here.
	See twisted docs to try to understand.
	Newer guard is different: http://twistedmatrix.com/documents/howto/guardindepth
	"""

    __implements__ = IRealm

    def __init__(self, data):
        self.data = data

    # FIXME the method name seems misleading and seems not to represent what it actually does! why is it not called 'buildWebTree' or similiar?
    def requestAvatar(self, username, mind, *interfaces):
        """Put together a web tree based on player admin permissions
		@param username: username of player
		@param mind: ignored
		@param interfaces: interfaces
		"""

        if IResource not in interfaces:
            raise NotImplementedError("WTF, tried non-web login")
        player = self.data.players.getPlayer(username)

        self.data.players.update_last_login(player)		

        if player.can_admin(): 
            tree = Workshop(player, self.data)
            # Shaun Narayan (02/16/10) - Removed all previous new/edit pages and inserted workshop pages.
            workshop_pages = {'stage' : (StageEditPage, self.data),
							  'mediaupload' : (MediaUploadPage, self.data),
							  'mediaedit' : (MediaEditPage, self.data),
                              'mediaedit2' : (MediaEditPage2, self.data),
							  'user' : (UserPage, self.data.players),
							  'newplayer' : (NewPlayer, self.data.players),
							  'editplayers' : (EditPlayer, self.data.players)
							  }

            """ Admin Only  - Password Page """      
            
            # AC 01.06.08 - Allows admin only to change only their own password.
            # Super Admin can change any players details.
            # NR 03.04.10 - Deprecated due to all users being given access to the User Page and its
            # password changer.       
            # Assign the new and edit pages to the website tree         
            tree.putChild('workshop', CreateDir(player, workshop_pages))
            tree.putChild('save_thing', AvatarThing(self.data.mediatypes, player))
            tree.putChild('save_video', VideoThing(self.data.mediatypes, player))
            # PQ & EB Added 12.10.07
            tree.putChild('save_audio', AudioThing(self.data.mediatypes, player))
            tree.putChild('id', SessionID(player, self.data.clients))
            # This is the test sound file for testing avatar voices in workshop - NOT for the audio widget
            tree.putChild('test.mp3', SpeechTest(self.data.stages.speech_server))

            if player.can_su():
                edit_pages = {'home' : (HomeEditPage, self.data),
							  'workshop' : (WorkshopEditPage, self.data),
                              'nonadmin' : (NonAdminEditPage, self.data),
                              'stages' : (StagesEditPage, self.data)}
                tree.putChild('edit', PageEditPage(player, edit_pages))
                

        # player, but not admin.
        elif player.can_act():
            # Daniel modified 27/06/2012
            tree = NonAdminPage(player, self.data.stages)	    
            tree.putChild('id', SessionID(player, self.data.clients))
        # anon - the audience.
        else:
            tree = AdminLoginPage(player)
            tree.putChild('id', SessionID(player, self.data.clients))
        
        tree.putChild('home', HomePage(self.data.stages, player))
        tree.putChild('stages', ThingsList(player, childClass=StagePage, collection=self.data.stages)) 
        return (IResource, tree, lambda : None)


# XXX remove references to woven.guard. sometime.
def adminWrapper(data):
    """Ties it together"""
    p = Portal(AdminRealm(data))    # found in twisted.cred.Portal
    p.registerChecker(AllowAnonymousAccess(), IAnonymous)
    p.registerChecker(data.players, IUsernamePassword)
    upw = guard.UsernamePasswordWrapper(p, callback=dumbRedirect)
    r = guard.SessionWrapper(upw)
    r.sessionLifetime = 12 * 3600
    return r

class SessionID(Resource):
    """Render an urlencoded string giving session id and player tag.
    Session id is created from md5 and handed out to client via http.
    Client will return the ID via flash socket, confirming identity of
    socket.""" 

    def __init__(self, player, clients):
        Resource.__init__(self)
        self.player=player
        self.clients = clients
        log.msg('setting up SessionID for %s' % player.name)

    def render(self, request):
        """Authentication data is rendered in an url-encoded form.
        Sets username and the ip address in the html header
        @param request: request to render"""
        player = self.player
        no_cache(request)
        ip = request.getClientIP() # XXX why bother?
        k = self.clients.add(ip, player)
        log.msg("added player %s, key is %s" %(player, k))

        ID = ''

        if 'name' in request.args:
            if request.args['name'][0] == '1':
                ID = player.name
        else:
            ID = urlencode({
                   'player':   player.name,
                   'key':      k,
                   'canAct':   player.can_act(),
                   'canAdmin': player.can_admin(),
                   'canSu':    player.can_su(),
                   })

        request.setHeader('Content-length', len(ID))
        return ID

def dumbRedirect(x):
    """Redirect to the current directory"""
    return Redirect(".")

#  ---------------------------------------------
class AudioThing(Resource):
    
    isLeaf = True
    def __init__(self, mediatypes, player):
        self.mediatypes = mediatypes
        self.player = player

    def render(self, request):
        # XXX not checking rights.
        args = request.args
        
        # FIXME see AvatarThing: prepare form data
        
        # FIXME: trim spaces from form values? (#104)
        
        # Natasha - get assigned stages
        self.assignedstages = request.args.get('assigned')
        name = args.pop('name',[''])[0]
        audio = args.pop('aucontents0', [''])[0] # was 'audio' before, aucontents0 is the name of the mp3 file field
        type = args.pop('audio_type', [''])[0]
        mediatype = args.pop('type',['audio'])[0]
        self.message = 'Audio file uploaded & registered as %s, called %s. ' % (type, name)
        # Corey, Heath, Karena 24/08/2011 - Added to store tags for this audiothing
        self.tags = args.pop('tags',[''])[0]
        # PQ & EB Added 13.10.07
        # Chooses a thumbnail image depending on type (adds to audios.xml file)
        
        if type == 'sfx':
            thumbnail = config.SFX_ICON_IMAGE_URL
        else:
            thumbnail = config.MUSIC_ICON_IMAGE_URL

        self.media_dict = self.mediatypes[mediatype]
        
        mp3name = new_filename(suffix=".mp3")
        the_url = config.AUDIO_DIR +"/"+ mp3name
        
        file = open(the_url, 'wb')
        file.write(audio)
        file.close()
        
        filenames = [the_url]
        
        # Alan (09/05/08) ==> Gets the size of audio files using the previously created temp filenames.
        fileSizes = getFileSizes(filenames)
        
        if not (fileSizes is None):
            if (validSizes(fileSizes, self.player.can_su()) or self.player.can_unlimited()):
                now = datetime.datetime.now() # AC () - Unformated datetime value
                self.media_dict.add(url='%s/%s' % (config.AUDIO_SUBURL, mp3name), # XXX dodgy? (windows safe?)
                               file=mp3name,
                               name=name,
                               voice="",
                               thumbnail=thumbnail, # PQ: 13.10.07 was ""
                               medium="%s" %(type),
                               # AC (14.08.08) - Passed values to be added to media XML files.
                               uploader=self.player.name,
                               dateTime=(now.strftime("%d/%m/%y @ %I:%M %p")),
                               tags=self.tags) # Corey, Heath, Karena 24/08/2011 - Added for media tagging set the tags to self.tags
                
                if self.assignedstages is not None:
                    for x in self.assignedstages:
                        self.media_dict.set_media_stage(x, mp3name)
                        
                request.write(successpage(request, 'Your Media "' + name + '" has uploaded successfully'))
                request.finish()
            else:
                try:
                    ''' Send new audio page back containing error message '''
                    """
                    self.player.set_setError(True)
                    os.remove(the_url)
                    request.redirect('/admin/new/%s' %(mediatype))
                    request.finish()
                    """
                    AdminError.errorMsg = 'File over 1MB' # Change error message to file exceed - Gavin
                    request.write(errorpage(request, 'Media uploads are limited to files of 1MB or less, to help ensure that unnecessarily large files do not cause long loading times for your stage. Please make your file smaller or, if you really need to upload a larger file, contact the administrator of this server to ask for permission.'))
                    request.finish()
                except OSError, e:
                    log.err("Error removing temp file %s (already gone?):\n %s" % (tfn, e))

        # always finish request
        request.finish()
        return server.NOT_DONE_YET

    def refresh(self, request):
        
        ''' Refreshes the media upload page after uploading media '''
        url = '/admin/workshop/mediaupload'
        request.redirect(url)
        request.finish()
    
    
class VideoThing(Resource):
    
    isLeaf = True
    
    def __init__(self, mediatypes, player):
        self.mediatypes = mediatypes
        self.player = player

    def render(self, request):
        # XXX not checking rights.
        args = request.args
        
        # FIXME see AvatarThing: prepare form data
        
        # FIXME: trim spaces from form values? (#104)
        
        # Natasha - Obtain assigned stages list
        self.assignedstages = request.args.get('assigned')
        name = args.pop('name',[''])[0]
        video = args.pop('video',[''])[0]
        voice = args.pop('voice',[''])[0]
        mediatype = args.pop('type',['avatar'])[0]
        self.message ='video %s registered as a %s, called %s. ' % (video, mediatype, name)
        # Corey, Heath, Karena 24/08/2011 - Added to store tags for this video thing
        self.tags = args.pop('tags',[''])[0]
        # Daniel 04/10/2012 - using 'video' instead of mediatype.
        media_dict = self.mediatypes['avatar']
        now = datetime.datetime.now() # AC () - Unformated datetime value
        media_dict.add(file='%s/%s' % (config.WEBCAM_SUBURL, video), # XXX dodgy? (windows safe?)
                       name=name,
                       voice=voice,
                       thumbnail= config.WEBCAM_STILL_URL + video,
                       medium="video",
                       uploader=self.player.name,
                       dateTime=(now.strftime("%d/%m/%y @ %I:%M %p")),
                       tags=self.tags) # Corey, Heath, Karena 24/08/2011 - Added for media tagging set the tags to self.tags
       
        # Natasha - Assign video to stages
        # FIXME throws exception when trying to add a video avatar
        if self.assignedstages is not None:
            for x in self.assignedstages:
                self.media_dict.set_media_stage(x, name)
        
        self.refresh(request)        
    
    def refresh(self, request):
        
        ''' Refreshes the media upload page after uploading media '''
        url = '/admin/workshop/mediaupload'
        request.redirect(url)
        request.finish()

class AvatarThing(Resource):
    """Start a subprocess to convert an image into swf.
    Upon completion of the process, redirect to NewAvatar page.
    Form should contain these elements:
       - name      - name of the uploaded thing
       - contents  - file contents of uploaded thing
       - type      - media type
     May have:
       - voice     - avatar voice
       - editmode  - ' merely editing' signals non conversion, just
                     metadata changes.
    """
    isLeaf = True
    
    def __init__(self, mediatypes, player):
        Resource.__init__(self)
        self.mediatypes = mediatypes
        # Alan (14/09/07) - Gets the player trying to upload
        self.player = player
        self.assignedstages = '' # natasha
        self.mediatype = '' # Natasha trying to make it a global variable
                 
    def render(self, request):
        """Don't actually render, but calls a process which returns a
        deferred.

        Callbacks on the deferred do the rendering, which is actually
        achieved through redirection.

        """
        # natasha convert
        # turn form into simple dictionary, dropping multiple values.  
        reqargs = request.args
        
        self.assignedstages = reqargs.get('assigned')
        form = dict([(k, v[0]) for k,v in request.args.iteritems()])
        
        # DEBUG: print form sent by request
        for key in form.iterkeys():
            if 'contents' in key:
                value = "[ binary data: %s Bytes ]" % len(form[key])
            else:
                value = form[key]
                if(len(value)>256):
                    value = value[:256] + " ... " # limit length to 256 chars
                value = "'" + value + "'"
            log.msg("AvatarThing: render(): form: '%s' = %s" % (key, value))
        
        # FIXME: trim spaces from form values? (#104)
        
        # handle kind of images: upload or library:
        imagetype = form.get('imagetype','unknown')
        
        # handle upload imagetype
        if imagetype == 'upload':
            
            log.msg('AvatarThing: render(): imagetype UPLOAD')
            
            # natasha: added prefix value
            prefix = ''
            try:
                self.mediatype = form.pop('type', None)
                if not self.mediatype in self.mediatypes:
                    raise UpstageError('Not a real kind of thing: %s' % self.mediatype)
                self.media_dict = self.mediatypes[self.mediatype] #self.media_dict = self.collections
                # change to starswith 'avcontents'
                if self.mediatype == 'avatar':
                    prefix = 'av'
                    # self.media_dict = self.collection.avatars
                elif self.mediatype == 'prop':
                    prefix = 'pr'
                elif self.mediatype == 'backdrop':
                    prefix = 'bk'
                elif self.mediatype == 'audio': # remem audio not included as things
                    prefix = 'au'
                
                # imgs = [ (k, v) for k, v in form.iteritems() if k.startswith('contents') and v ]
                contentname = prefix + 'contents'
                imgs = [ (k, v) for k, v in form.iteritems() if k.startswith(contentname) and v ]
                imgs.sort()
                
                # DEBUG:
                #log.msg("AvatarThing: imgs = %s" % imgs);
     
                # save input files in /tmp, also save file names
                tfns = [ save_tempfile(x[1]) for x in imgs ]
    
                # Alan (12/09/07) ==> Gets the size of image files using the previously created temp filenames.
                # natasha getfilesize
                fileSizes = getFileSizes(tfns)
                
                # imported from misc.py
                swf = new_filename(suffix='.swf')
                thumbnail = swf.replace('.swf', '.jpg')         # FIXME: see #20 (Uploaded media is not converted to JPEG)
                swf_full = os.path.join(config.MEDIA_DIR, swf)
                thumbnail_full = os.path.join(config.THUMBNAILS_DIR, thumbnail)
    
            except UpstageError, e:            
                return errorpage(request, e, 500)
    
            """ Alan (13/09/07) ==> Check the file sizes of avatar frame """
            # natasha continue conversion
            if not (fileSizes is None):
                if (validSizes(fileSizes, self.player.can_su()) or self.player.can_unlimited()):
                    # call the process with swf filename and temp image filenames 
                    d = getProcessValue(config.IMG2SWF_SCRIPT, args=[swf_full, thumbnail_full] + tfns)
                    args = (swf, thumbnail, form, request)
                    d.addCallbacks(self.success_upload, self.failure_upload, args, {}, args, {})
                    d.addBoth(self.cleanup_upload, tfns)
                    d.setTimeout(config.MEDIA_TIMEOUT, timeoutFunc=d.errback)
                    d.addErrback(log.err)   # Make sure errors get logged - TODO is this working?
                else:
                    ''' Send new avatar page back containing error message '''
                    self.player.set_setError(True)
                    self.cleanup_upload(None, tfns)
                    request.redirect('/admin/new/%s' %(self.mediatype))
                    request.finish()
            #return server.NOT_DONE_YET
        
        # handle library imagetype
        elif imagetype == 'library':
            
            log.msg('AvatarThing: render(): imagetype LIBRARY')
            
            name = form.get('name', '')
            while self.name_is_used(name):
                name += random.choice('1234567890')
            
            tags = form.get('tags','')
            
            has_streaming = form.get('hasstreaming','false')
            streamtype = form.get('streamtype','auto')
            streamserver = form.get('streamserver','')
            streamname = form.get('streamname','')
            
            medium = ''
            if (has_streaming.lower() == 'true'):
                medium = 'stream'
            
            now = datetime.datetime.now()
            voice = form.get('voice','')
            
            # create random strings for library items
            random_swf_id = util.random_string(config.LIBRARY_ID_LENGTH)
            random_thumbnail_id = util.random_string(config.LIBRARY_ID_LENGTH)
            
            # FIXME test if generated strings already exist, so choose another
            
            # set thumbnail according to streamtype
            thumbnail_image = 'IconLiveStream'   # default
            if streamtype == 'audio':
                thumbnail_image = 'IconAudioStream'
            elif streamtype == 'video':
                thumbnail_image = 'IconVideoStream'
            
            thumbnail = config.LIBRARY_PREFIX + random_thumbnail_id + ":" + thumbnail_image
            
            swf_image = 'VideoOverlay' 
            swf = config.LIBRARY_PREFIX + random_swf_id + ":" + swf_image
            
            log.msg("render(): has streaming? %s" % has_streaming)
            log.msg("render(): streamtype: %s" % streamtype)
            log.msg("render(): streamserver: %s" % streamserver)
            log.msg("render(): streamname: %s" % streamname)    
            log.msg("render(): swf (file): %s" % swf)
            log.msg("render(): name: %s" % name)
            log.msg("render(): voice: %s" % voice)
            log.msg("render(): now: %s" % now)
            log.msg("render(): tags: %s" % tags)
            log.msg("render(): medium: %s" % medium)
            log.msg("render(): thumbnail: %s" % thumbnail)
            log.msg("render(): swf: %s" % swf)
            
            try:
                self.mediatype = form.pop('type', None)
                if not self.mediatype in self.mediatypes:
                    raise UpstageError('Not a real kind of thing: %s' % self.mediatype)
                self.media_dict = self.mediatypes[self.mediatype]
                
                # add avatar
                self.media_dict.add(file=swf,
                                    name=name,
                                    voice=voice,
                                    uploader=self.player.name,
                                    dateTime=(now.strftime("%d/%m/%y @ %I:%M %p")),
                                    tags=tags,
                                    streamserver=streamserver,
                                    streamname=streamname,
                                    medium=medium,
                                    thumbnail=thumbnail
                                    )
                
                # assign to stage?
                if self.assignedstages is not None:
                    log.msg("render(): assigning to stages: %s" % self.assignedstages)
                    self.assign_media_to_stages(self.assignedstages, swf, self.mediatype)
                    
            except UpstageError, e:            
                return errorpage(request, e, 500)
            
            log.msg("render(): got past media_dict.add, YES")
            
            request.write(successpage(request, 'Your Avatar "' + name + '" has been added successfully'))
            request.finish()
        
        # handle unknown imagetypes
        else:
            # output error, because we do not have a valid imagetype
            log.err('AvatarThing: render(): Unsupported imagetype: %s' % imagetype)
            request.write(errorpage(request, "Unsupported image type '%s'." % imagetype))
            request.finish() 
        
        return server.NOT_DONE_YET
    
    """
     Modified by: Corey, Heath, Karena 24/08/2011 - Added media tagging to self.media_dict.add
    """

    def success_upload(self, result, swf, thumbnail, form, request):
        """Catch results of the process.  If it seems to have worked,
        register the new thing."""
        if result:
            #request.write(result)
            return self.failure_upload(result, swf, thumbnail, form, request)

        # if the name is in use, mangle it until it is not.
        # XXX this is not perfect, but
        #  a) it is kinder than making the person resubmit, without actually
        #     telling them what a valid name would be.
        #  b) it doens't actually matter what the name is.
        # natasha check name
        name = form.get('name', '')
        while self.name_is_used(name):
            name += random.choice('1234567890')
        # Added by Heath, Karena, Corey 26/08/2011 - added to store tags from the form    
        tags = form.get('tags','')
        # if the thumbnail is not working (usually due to an swf file
        # being uploaded, which the img2swf script doesn't know how to
        # thumbnail), detect it now and delete it.
    
        has_streaming = form.get('hasstreaming','false')
        streamtype = form.get('streamtype','auto')
        streamserver = form.get('streamserver','')
        streamname = form.get('streamname','')
        
        log.msg("success_upload(): has streaming? %s" % has_streaming)
        log.msg("success_upload(): streamtype: %s" % streamtype)
        log.msg("success_upload(): streamserver: %s" % streamserver)
        log.msg("success_upload(): streamname: %s" % streamname)
        
        medium = ''
        if (has_streaming.lower() == 'true'):
            medium = 'stream'
            
        log.msg("success_upload(): medium: %s" % medium)
        
        # FIXME why determine mimetype of thumbnail only?
    
        # natasha add to dictionary
        thumbnail_full = os.path.join(config.THUMBNAILS_DIR, thumbnail)
        #_pin, pipe = os.popen4(('file', '-ib', thumbnail_full))
        _pin, pipe = os.popen4(('file', '--brief', '--mime-type', thumbnail_full))
        mimetype = str(pipe.read()).strip()
        pipe.close()
        now = datetime.datetime.now() # AC () - Unformated datetime value
        
        # FIXME insecure mimetype detection!
        log.msg("success_upload(): mimetype (thumbnail) = %s" % mimetype)
        
        swf_mimetypes = ["application/x-shockwave-flash"]
        image_mimetypes = ["image/jpeg","image/gif","image/png"]
        
        log.msg("success_upload(): image mimetypes: %s" % image_mimetypes)
        log.msg("success_upload(): swf mimetypes: %s" % swf_mimetypes)
        
        is_image = mimetype in image_mimetypes
        is_swf = mimetype in swf_mimetypes
        
        log.msg("success_upload(): mimetype: is_image = %s" % is_image)
        log.msg("success_upload(): mimetype: is_swf = %s" % is_swf)
        
        voice = form.get('voice','')
        
        log.msg("success_upload(): swf = %s" % swf)
        log.msg("success_upload(): form: name = %s" % name)
        log.msg("success_upload(): form: tags = %s" % tags)
        log.msg("success_upload(): thumbnail_full = %s" % thumbnail_full)
        log.msg("success_upload(): now = %s" % now)
        log.msg("success_upload(): voice = %s" % voice)
        
        #if not mimetype.startswith('image/'):
        if not is_image:
            self.media_dict.add(file=swf,
                                name=name,
                                voice=voice,
                                # AC (10.04.08) - This section needs uploader and dateTime also.
                                uploader=self.player.name,
                                dateTime=(now.strftime("%d/%m/%y @ %I:%M %p")),
                                tags=tags, # Corey, Heath, Karena 24/08/2011 - Added for tagging media
                                streamserver=streamserver,
                                streamname=streamname,
                                medium=medium,
                                )

        else:
            # Corey, Heath, Karena 24/08/2011
            self.media_dict.add(file=swf,
                                name=name,
                                voice=voice,
                                thumbnail=config.THUMBNAILS_URL + thumbnail,
                                # AC (29.09.07) - Passed values to be added to media XML files.
                                uploader=self.player.name,
                                dateTime=(now.strftime("%d/%m/%y @ %I:%M %p")),
                                tags=tags, # Corey, Heath, Karena 24/08/2011 - Added for tagging media
                                streamserver=streamserver,
                                streamname=streamname,
                                medium=medium,
                                )
        
        log.msg("success_upload(): got past media_dict.add, YES")
        
        #form['media'] = swf
        
        # NB: doing external redirect, but really there's no need!
        # could just call the other pages render method
        # assign_media_to_stages()
        
        #def _value(x):
        #    return form.get(x, [None])
        
        # assign to stage?
        self.media_dict = self.mediatypes[self.mediatype]
        if self.assignedstages is not None:
            log.msg("success_upload(): assigning to stages: %s" % self.assignedstages)
            self.assign_media_to_stages(self.assignedstages, swf, self.mediatype)
        
        #self.refresh(request, swf)

        request.write(successpage(request, 'Your Avatar "' + name + '" has been added successfully'))
        request.finish()
        

    def assign_media_to_stages(self, assignedstages, medianame, mediatype):
        for x in assignedstages:
            self.media_dict.set_media_stage(x, medianame) # collection not defined here. MAYBE IMPORT ADD METHOD IN STAGE DICT??
            # make request
            
    def name_is_used(self, name):
        """checking whether a name exists in any media collection"""
        # XXX should perhaps reindex by name.
        log.msg('name_is_used(): checking whether "%s" is a used avatar name' % name)
        for _k, d in self.mediatypes.items():
            for x in d.values():
                if name == x.name:
                    return True
        return False

    def refresh(self, request, swf):
        url = '/admin/workshop/mediaupload'
        request.redirect(url)
        request.finish()
    
    def redirect(self, request, swf):
        """Redirect a request to the edit thing page.
        # @param swf swf filename"""
        # XXX url path should be consolidated somewhere.
        url = '/admin/edit/%s/%s' % (self.mediatype, swf)
        request.redirect(url)
        request.finish()

    def failure_upload(self, result, swf, thumbnail, form, request):
        """Nothing much to do but spread the word"""
        
        # TODO untested yet:
        if result:
            log.err('failure_upload(): result: %s' % result)
            log.err('failure_upload(): swf: %s, thumbnail: %s' % (swf, thumbnail));
 
        AdminError.errorMsg = 'Something went wrong' # Change error message back to default - Gavin
        request.write(errorpage(request, 'Avatar upload failed - maybe the image was bad. See img2swf.log for details'))
        request.finish() 
        
    def cleanup_upload(self, nothing, tfns):
        """Be rid of temp files"""
        try:
            nothing.printTraceback()
        except AttributeError:
            pass
        for tfn in tfns:
            try:
                os.remove(tfn)
            except OSError, e:
                log.err("cleanup_upload(): Error removing temp file %s (already gone?): %s" % (tfn, e))

#------------------------------------------------------------------------

class SpeechTest(Resource):
    """Wraps the mp3 creation process.
    """
    def __init__(self, speech_server):
        Resource.__init__(self)
        self.speech_server = speech_server

    def render(self, request):
        # dropping multiple values
        form = dict([(k, v[0]) for k,v in request.args.iteritems()])
        voice = form.get('voice')
        text = form.get('text')
        if not text or not voice:
            return errorpage(request, "you need a voice and something for it to say")
        speech_url = self.speech_server.utter(text, voice=voice)
        request.setHeader('Content-type', 'audio/mpeg')
        request.redirect(speech_url)
        request.finish()

