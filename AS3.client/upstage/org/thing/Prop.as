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
    
    
    /**
     * class for prop images.
     * 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								changed constructor to instantize parent there instead of through 
     * 								factory to abide by normal AS3 standards.
     * 			 Shaun Narayan (Apr 2010) - adjusted Icon placement, other bug fixes (same as avatar & backdrop).
     */
    
    
    import org.thing.Thing;
	import org.util.Construct;
    import org.util.Icon;
    import org.util.LoadTracker;
    import org.Client;
    import flash.display.*;
    import flash.events.*;
    //import org.util.Construct;
    
    
    public class Prop extends Thing 
    {
    
        public static var transportSetFunctionName:String = 'SET_PROP';
    
        public static function factory(imgParent : MovieClip, iconParent : MovieClip, ID :Number,
                                name :String, url :String, thumbnail :String,
                                medium :String, frame:Number): Prop
        {
    
            var baseLayer:Number = Client.L_PROPS_IMG -(-ID *  Client.THING_IMG_LAYERS);
            var baseName: String = 'prop_' + ID;
            var prop: Prop = new Prop(ID, name, url, baseName,
                                            thumbnail, medium, baseLayer, imgParent, Prop);
    		var listener :Object = LoadTracker.getLoadListener();
    		listener.onLoadStart = function(e: Event){
                    LoadTracker.loadStart();
            };
    		listener.onLoadComplete = function(e:Event){
				LoadTracker.loadComplete();
				Construct.constrainSize(prop.image, Client.PROP_MAX_WIDTH, Client.PROP_MAX_HEIGHT);
    		}
    		prop.image = new MovieClip();
            prop.loadImage(prop.url, baseLayer + 1, listener, prop.image);
    
            // Create icon & ask for it to load
            var iLayer :Number = Client.L_UI_ICONS_BASE + ID * Client.ICON_IMG_LAYERS;
            var iUrl :String = thumbnail || url;
    		trace("Icon Name = " + name);
            prop.icon = Icon.create(prop, name, iLayer, iUrl);
            prop.icon.x = prop.icon.x + 1;
            prop.icon.y = prop.icon.y + 1;
            iconParent.addChild(prop.icon);
            prop.addChild(prop.image);
            return prop;
        }
    
    
        function Prop(ID :Number, name :String, url :String, baseName: String,
                                       thumbnail :String, medium :String, layer: Number,
                                       parent:MovieClip, Class: Object)
        {
        	super(ID, name, url, baseName, thumbnail, medium, layer, parent, Avatar);  
        };
    
    };
}
