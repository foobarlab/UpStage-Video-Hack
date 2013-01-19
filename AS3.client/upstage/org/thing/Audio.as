package org.thing {
    /*
      Copyright (C) 2003-2006 Douglas Bagnall (douglas * paradise-net-nz)
    
      This program is free software; you can redistribute it and/or
      modify it under the terms of the GNU General Public License
      as published by the Free Software Foundation; either version 2
      of the License, or (at your option) any later version.
    
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
    
      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    */
    
    import org.Client;
    import org.view.AuScrollBarItem;
    import org.view.AuScrollBar;
    
    /**
     * Module: Audio.as
     * Created: 17/09/07
     * Author: Endre Bernhart & Phillip Quinlan
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...).
     * Purpose: One Audio item for the Audio Widget
     * Notes: Originally the class for prop images transformed into class for audio.
     */
     
    
    public class Audio 
    {
    
        public var ID:Number;
        public var name : String;
        public var url : String;
        public var type : String;
        
        public var icon : AuScrollBarItem;
        public var iconLayer : Number;
    
        public static var transportSetFunctionName:String = 'SET_AUDIO';
    
        public static function factory(ID:Number, name:String, url:String, type:String, scrollBar: AuScrollBar) : Audio
        {
            trace("Audio factory: name is "+name+ " and url is " + url);
    
            var baseLayer:Number = Client.L_PROPS_IMG -(-ID *  Client.THING_IMG_LAYERS);
            var baseName: String = 'audio_' + ID;
            
            var thing:Audio = new Audio();
    
            thing.ID = ID;
            thing.name = name;
            thing.url = url;
            thing.type = type;
            thing.iconLayer = Client.L_AUDIO_ICON -(-ID * Client.AV_ICON_LAYERS); 
            //Heath Behrens - commented out for now, covers buttons.
            //thing.icon = AuScrollBarItem.create(thing, scrollBar);
            
            trace("made Audio object with iconLayer of " + thing.iconLayer);
    
            // Create icon & ask for it to load
            var iLayer :Number = Client.L_UI_ICONS_BASE + ID * Client.ICON_IMG_LAYERS;
            
            //var iUrl :String = thumbnail || url;
    
            //thing.icon = Icon.create(iconParent, name, iLayer, '');
    
            return thing;
        }
    
    
        public function Audio(){};
    
    };
}
