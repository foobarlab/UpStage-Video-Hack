package org.util {
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
    
    import org.util.Construct;
    import org.Client;
    import org.util.LoadTracker;
    import flash.display.*;
	
    /**
     * Icon image for things.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - listener callbacks + MC tree refactor.
     */
    
    public class Icon extends MovieClip 
    {
        public var myName         :String;
        public var image        :MovieClip;
        public var icon        :Icon;
        public var thumbUrl        :String;
        public var imageLayer    :Number;
        public var baseLayer    :Number;
    
    
        /**
         * @brief factory
         */
        static public function create(parent :MovieClip, name :String, baseLayer :Number,
                                      url :String) :Icon
        {
            var out :Icon;
    
            out = new Icon();
            out.imageLayer = baseLayer + 1;  
            out.baseLayer = baseLayer;
      //      out.loadThumb();
            out.myName = name;
            out.thumbUrl = parent.thumbnail || parent.url; //added parent and thumbnail
            
            
     //       var parent: MovieClip = this;
            var listener :Object = LoadTracker.getLoadListener();
            listener.onLoadComplete = function(){
                LoadTracker.loadComplete();
                out.visible = true;
                Construct.constrainSize(out, Client.ICON_SIZE - 1, Client.ICON_SIZE - 1);
            };        
    
            out.image = LoadTracker.loadImage(out, url, out.imageLayer, listener);
            out.visible = true;
            parent.addChild(out);
            return out;
            
        }
    
        public function loadThumb() :void                       
        {
    
            
        }    
    
    
        /**
          * @brief Hide the thing
          */    
        public function hide() :void
        {
            this.visible = false;
        }
        
        public function show() :void
        {
            this.visible = true;
        }
    
        function Icon(){}
    }
}
