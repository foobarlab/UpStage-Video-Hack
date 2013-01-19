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
Modified by: Phillip Quinlan, Endre Bernhardt, Alan Crow.
Modified by: Shaun Narayan (01/27/10, AUT Upstage team 09/10) - 
                Fix render crash on manage avatar page if no stages exist. (Error msg)
Modified by: Shaun Narayan (02/16/10) - Added media list method, and removed old methods
                which are no longer required. Changed update_from_form to work with new forms.
Modified by: 18/05/11 Mohammed Al-Timimi and Heath Behrens - created the method get_formatted_list which was being used
                by things.py but didn't exist
Modified by: Heath Behrens (17/06/2011) - added fix so that a voice change does not require a server restart, to show. 
             update_from_form lines 302 - 307
Modified by: Heath Behrens 16/08/2011 - added code in update_from_form to extract assigned/unassigned stages
                                      and process accordingly.
             Heath, Corey, Karena 24/08/2011 - Added tags to media collection, as part of server side tagging of things                         
             Heath Behrens / Vibhu Patel 24/08/2011 - Added code to retrieve the tags from form and update the collection.
                                                    - Note the tags are retrieved from the collection first then 
                                                      re added to keep the current tags            
             Heath Behrens / Corey / Karena 26/08/2011 - Added code to update media name, along with a fix for tags which kept adding
                                                        a blank tag when saving name.                                                                    

Notes: 
"""

"""classes for global media handling.  The importable aspect is
{mediatypes}"""


import os, inspect

#siblings
from upstage.misc import Xml2Dict, UpstageError
from upstage.util import get_template
from upstage import config
from upstage.things import Avatar, Prop, Backdrop, ThingCollection, Audio

#twisted
from twisted.python import log

DELETE_PREFIX='delete_'

def _check_thumb_sanity(tn):
    # not _really_ sane at all
    p = config.HTDOCS + tn
    cmd = 'file -ib %s' %p
    stdout = os.popen(cmd)
    result = stdout.read()
    stdout.close()
    log.msg('%.35s ->  %.35s' % (cmd, result))
    return 'image' in result
    


class _MediaFile(object):
    """Not much but a collection of attributes.  This will be given
    life when swallowed by a things.Thing subclass belonging to a stage."""

    def __init__(self, **kwargs):
        """@param kwargs argument list 
           (name, voice, type, height, width, medium, description, uploader, dateTime)"""
        self.file = kwargs.pop('file', None)
        
        if (self.file[-4:] == '.mp3'):
            self.url = config.AUDIO_URL + self.file
        else:
            self.url = config.MEDIA_URL + self.file
        self.thumbnail = ''
        self.web_thumbnail = config.MISSING_THUMB_URL
        tn = kwargs.pop('thumbnail', None)  #or self.file.replace('.swf','.jpg')
        if tn:
            if not config.CHECK_THUMB_SANITY or _check_thumb_sanity(tn):
                self.web_thumbnail = tn
                self.thumbnail = tn
        self.name = kwargs.pop('name', 'nameless')
        self.voice = kwargs.pop('voice', None)
        self._type = kwargs.pop('type', None)
        self.height = kwargs.pop('height', None)
        self.width = kwargs.pop('width', None)
        self.medium = kwargs.pop('medium', None) #medium - video for video/ None for stills.
        self.description = kwargs.pop('description', '') # no form entry for it.
        
        # AC (29.09.07) - 
        self.uploader = kwargs.pop('uploader', '') # user name of uploader.
        self.dateTime = kwargs.pop('dateTime', '') # Date and time of upload.
        self.tags = kwargs.pop('tags', '')#Karena, Corey, Heath
        if kwargs:
            log.msg('left over arguments in _MediaFile', kwargs)


class MediaDict(Xml2Dict):
    """Creates dictionary of avatars or other media from stored
    Doesn't contain actual thing objects, because there can be more
    than one of those per one of these (ie, a MediaFile can be on two
    stages at once)."""
    stages = None

    def set_stages(self, stages):
        """StageDict lets us know it wants to use this"""
        if self.stages is not None:
            # could maintain list, if there is ever a need.
            raise UpstageError("stageDict is already set")
        self.stages = stages
        # add method to iterate through each stage and assign media to it
    
    # Natasha - created set media stage to enable assignment of media to stage from
    # upload media
    def set_media_stage(self, stagename, medianame):
        log.msg('In set media stage/global media. Stages are: %s' % self.stages)
        if self.stages is not None:
            for x in self.stages:
                if x == stagename:
                    stage = self.stages.get(x) # was only a string not object
                    #stage.add_avatar(medianame)
                    stage.add_mediato_stage(medianame)
                    # add method in stage to accept a new media then save to xml
            
    
    def parse_element(self, node):
        """Add XML values to the dictionary
        @param node node to parse"""
        f = node.getAttribute('file')
        av = _MediaFile(file=f,
                        name=node.getAttribute('name') or 'untitled',
                        voice=node.getAttribute('voice') or '',
                        medium=node.getAttribute('medium') or '',
                        thumbnail=node.getAttribute('thumbnail') or '',
                        uploader=node.getAttribute('uploader') or '', # AC - Adds uploader field to dictionary.
                        dateTime=node.getAttribute('dateTime') or '', # AC - Adds dateTime field to dictionary.
                        tags=node.getAttribute('tags') or '', #Heath, Corey, Karena 24/08/2011 - added tags to mediafile 
                        )           
        dict.__setitem__(self, f, av)

    def write_element(self, root, av, mf):
        """Add a new element to the XML dictionary
        @param root root XML element
        @param av ignored
        @param mf list describing a node"""
        #log.msg('should be writing element! %s: %s : %s :%s'%(root,av,dir(mf), self.element))
        #attr['file']=av
        
        # AC (29.09.07) - Added uploader and datetime fields in XML media item files.
        node = root.add(self.element, file=mf.file, url=mf.url, name=mf.name,
                        thumbnail=mf.thumbnail, uploader=mf.uploader, dateTime=mf.dateTime, tags=mf.tags)
        
        for attr in ('voice', 'medium'):
            v = getattr(mf, attr, None)
            if v is not None:
                node[attr] = v

    def path(self, f):
        """Convert a relative path to absolute."""
        # PQ & EB: Added 13.10.07
        # If it's an audio file (ends with .mp3) add in the folder 'audio' in front so it's /media/audio/
        if (f[-4:] == '.mp3') :
            return os.path.join(config.AUDIO_DIR, f)
        else:
            return os.path.join(config.MEDIA_DIR, f)

    def add(self, **kwargs):
        """Put a new item in, and save it (implicitly, through __setitem__)
        """
        f = kwargs.get('file', None)
        if f is not None:
            self[f] = _MediaFile(**kwargs)
            return self[f]

    # Natasha - attempt to add an item via the form
    def addItem(self, form): 
        self.form = form
        f = form.get('file', None)
        if f is not None:
            self[f] = _MediaFile(form)
            return self[f]
        log.msg('tried to add file with no file attribute! %s' % form)

        
    def __delitem__(self, f):
        """Deletes an item from XML dictionary and from the file system
        Won't work if f is a directory name not a file
        @param f file name"""
        try:
            if config.SAVE_DELETED_MEDIA:
                if not os.path.exists(config.OLD_MEDIA_DIR):
                    os.makedirs(config.OLD_MEDIA_DIR, 0755)
                os.rename(self.path(f), os.path.join(config.OLD_MEDIA_DIR, f))
            else:
                os.remove(self.path(f))
        except OSError, e:
            if not f.startswith(config.WEBCAM_SUBURL):
                raise KeyError("%s: %s" %(self.path(f), e))

        return Xml2Dict.__delitem__(self, f)


    def _get_stage_collections(self):
        """make a list of (ThingDict, _Stage) pairs, with the
        ThingDict being the relevant collection for this type of
        media, for the corresponding stage.
        """
         #more direct ways possible -- using a ThingDict 'element'
        collections = []
      
        # Alan (28.01.08) - Enables the sorting of stage collection alphabetically.
        stages = self.stages.items() 
        stages.sort()
    
        for k, s in stages: # Alan (28.01.08) - Added k for key as a set is return from items().
            for c in s.avatars, s.props, s.backdrops, s.audios: # PQ: Added s.audios 13.10.07
                if c.globalmedia is self:
                    collections.append((c, s))
        
        return collections

    def _delete_things(self, form):
        """delete things based on a form (used by update_from_form,
        below). Returns an html string saying what has happened"""
        messages = []
        candidates = [x for x in self.keys() if x in form.get('mediaName',[None])[0] ] #Shaun Narayan (02/14/10) - arg names changed in URL so have been refelcted here.
        log.msg("Candidates are: %s" %candidates)
        collections = self._get_stage_collections()
        if 'force' in form:
            #do the deletion, clean up after
            for x in candidates:
                messages.append('Deleted %s' % self[x].name)
                del self[x]

            for c, s in collections:
                if c.reap_zombies():
                    s.soft_reset()
                    #EB 14/10/07: Save the stages after clearing out the missing media/force-deleted items
                    # to update the XML files correctly
                    s.save() 
        else:
            #abandon deletion of a thing if it is on stages.
            for x in candidates:
                hits = [s.ID for c, s in collections if x in c.media]
                if not hits:
                    #log.msg('attempting to delete media %s at path %s (force=false, hits=null)' %(self[x].name, self[x].url, s.name))
                    messages.append('Deleted %s' % self[x].name)
                    del self[x]

                else:
                    log.msg('skipped deletion of %s at path %s on stage %s (force=false, hits=true)' %(self[x].name, self[x].url, s.name))
                    links = ', '.join(['<a href="/admin/edit/stage/%s">%s</a>' % (ID, ID) for ID in hits])
                    messages.append('<b>Not deleting %s</b> (used in %s)' %(self[x].name, links))
        return '<br />\n'.join(messages)


    """

    Modified by: Heath Behrens 16/08/2011 - Added code lines 309 onwards to extract the assigned/unassigned
                                            stages from the form and process accordingly.
                 Heath Behrens / Vibhu Patel 24/08/2011 - Added code to retrieve the tags from form and update the collection.
                                                        - Note the tags are retrieved from the collection first then 
                                                          readded to keep the current tags
                 Heath Behrens / Corey / Karena 26/08/2011 
                                                        - Modified to include updating media name from a form                                                                      

    """    
    def update_from_form(self, form, player):
        """Process an http form. depending on the form,
        either delete or modify an item
        @param form the form on the web page
        @param player the user that requested update

        There are two modes.  If the form has the key 'delete', then
        any keys in the form delete_??? will attempt to delete the
        thing called ???.  If there is a key 'force', the deleted
        thing will be removed from all stages it is on.  Otherwise it
        will *not* be deleted if the thing is on a stage.

        If 'delete' is not a key, then the form is assumed to be
        editing a particular thing's details.
        """
        if not player.can_admin():
            return
        if 'delete' in form.get('action',[None])[0]: #Shaun Narayan (02/14/10) - arg names changed in URL so have been refelcted here.
            log.msg("Deleting, form is: %s" %form)
            # AC (05.02.08) - Added correct exception handling.
            try:
                msg = self._delete_things(form)
                if msg:
                    log.msg('saving post-deletion')
                    self.save()
                    log.msg('\n%s\n' %msg)
            except:
                raise UpstageError("Could not delete selected items") 
                
        else: #editing a thing
            log.msg("Attempting update")
            ID = form.get('mediaName', [None])[0] #Shaun Narayan (02/14/10) - arg names changed in URL so have been refelcted here.
            try:
                thing = self[ID]
            except KeyError:
                log.msg("Can't edit %s (not in %s)" % (ID, self))
                raise UpstageError("<b>There is no such thing as %s</b>" % ID)
            def _update(x):
                _attr = form.get(x)
                if _attr is not None:
                    if(x == 'tags'):
                        #Added by Heath / Vibhu 24/08/2011 - new tags to the current tags.
                        setattr(thing, x, _attr[0])
                    else:
                        setattr(thing, x, _attr[0])
                    #Added by Heath Behrens 17/06/2011 - Fix so that avatar voice is updated without server restart...
                    collections = self._get_stage_collections() # retrieve the collections for each stage
                    for col in collections: #loop over the collections
                        things = col[0] # extract the things collection
                        if(things.contains_thing(thing)): # check if it contains this thing
                            things.add_media(thing) #if it does add it to media.
            #Heath Behrens 16/08/2011 - Added to extract assigned and unassigned stages from form                
            assigned = form.get('assigned')
            unassigned = form.get('unassigned')
            name = form.get('mediaName')
            # loop over the assigned stages which are comma separated
            for s in assigned[0].split(','):
                st = self.stages.get(s) #get reference to the stage object
                if st is not None:
                    st.add_mediato_stage(name[0])
            for us in unassigned[0].split(','):
                st = self.stages.get(us)
                if st is not None:
                    st.remove_media_from_stage(name[0])
            _update('tags') #call to update the collection with the new tags
            _update('name')
            _update('voice')
            
            if 'audio_type' in form:
                audiotype = form.get('audio_type')[0];

                setattr(thing, 'medium', form.get('audio_type')[0])
                if audiotype == 'sfx':
                    setattr(thing, 'thumbnail', config.SFX_ICON_IMAGE_URL);
                    setattr(thing, 'web_thumbnail', config.SFX_ICON_IMAGE_URL);
                else:
                    setattr(thing, 'thumbnail', config.MUSIC_ICON_IMAGE_URL);
                    setattr(thing, 'web_thumbnail', config.MUSIC_ICON_IMAGE_URL);
                log.msg('thing\'s thumbnail has been changed to %s' %(thing.thumbnail))
        self.save()
        
    """Shaun Narayan (02/14/10) - List media, and assign stage names before returning"""
    def get_media_list(self ,prefix=DELETE_PREFIX):
        things = [(v.name.lower(), {'name': v.name,
                            'type':v.medium,
                            'media': k,
                            'checked': '',
                            'thumb': v.web_thumbnail,
                            'typename': self.element,
                            'voice': getattr(v, 'voice', ''),
                            'uploader': v.uploader or 'unassigned', # AC (22.12.07) - Added field for uploader's username.
                            'dateTime': v.dateTime, # AC (22.12.07) - Added field for dateTime of upload.
                            'prefix': prefix,
                            'row_class':v.medium,
                            'stages':'',
                            'tags':v.tags # Vibhu and Heath (01/09/2011) - Added tags attribute to return associated tags for a media.
                            })
          for k, v in self.iteritems()]
        if things:
            things.sort()
            
        collections = self._get_stage_collections() 
        for n, d in things:
            hits = [s.ID for c, s in collections if d['media'] in c.media]
            if hits:
                links = ', '.join(['%s' % (ID) for ID in hits])
                d['stages'] = links
                
        return things
    
    """ 18/05/11 Mohammed + Heath - Returns a list of avatar media uploaders 
        Could extend this to filter by anything by passing a parameter to this method and replace 'uploader'"""
    def get_formatted_list(self):
        mediaList = self.get_media_list()
        uploaderList  = []
        for entry in mediaList:
            #mediaList is a list with a value at index 1 which maps to a Dictionary object
            uploader = entry[1]['uploader']
            if uploader not in uploaderList: 
                uploaderList.append(uploader)
        return uploaderList

    def html_list_grouped(self, include='thing_item_set.inc', header='thing_group_heading.inc', selected=(), prefix=DELETE_PREFIX):
        """ Alan - 08/01/08 - Used for lists that require grouping on assets by stage. 
        (e.g. avatars, props and backdrops edit selection lists) """

        table = []
        inc = get_template(include)
        things = self.get_formatted_list(inc, selected, prefix)
        end_stage_group = "</table>"
        thing_column_headers = ['', '', 'Name:', 'Stages:', 'Uploader:', 'DateTime:']
        avatar_column_headers = ['', '', 'Name:', 'Voice:', 'Stages:', 'Uploader:', 'DateTime:']
        audio_column_headers = ['', '', 'Name:', 'Type:', 'Stages:', 'Uploader', 'DateTime']
            
        # Check to see if the current media type contains any uploaded assets.
        if things:
            #sort alphabetically (note: things is schwartzian). Only sort if things contains items.
            things.sort()
            collections = self._get_stage_collections()
            group_heading = get_template(header)
            
            # Adds the appropiate column headings for the group
            column_headers = thing_column_headers
            #Shaun Narayan (01/27/10 - Added try except block) - If no stages exist, this throws an exception
            try:
                if collections[0][0].typename == 'avatar': column_headers = avatar_column_headers
                elif collections[0][0].typename == 'audio': column_headers = audio_column_headers 
            except:
                table.extend('<th>No Stages Found</th>')
            
            for c, s in collections:
                if c.things.values(): 
                    table.extend(group_heading % {'stage_name': s.ID })
                    
                    for h in column_headers: table.extend('<th>%s</th>' %h)
                    
                    for n, d in things:                        
                        for i in c.things.values():
                            if d['name'] == i.name and d['media'] in c.media: table.extend(inc % d)
                                    
                    table.extend(end_stage_group)
            
            """ Unassigned media asset group """
            unassigned_assets = [ n for n in things if not len(n[1]['stages']) ]
            
            if unassigned_assets: 
                table.extend(group_heading % { 'stage_name': 'unassigned' })
                for h in column_headers: table.extend('<th>%s</th>' %h)
                for x in unassigned_assets: table.extend(inc % x[1])
                table.extend(end_stage_group)
                
        return ''.join(table)
