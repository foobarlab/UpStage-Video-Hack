package org.view {
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
    
    import org.util.LoadTracker;
    import org.thing.Avatar;
    import org.util.Construct;
    import org.Client;
    import flash.display.*;
	import flash.text.*;
	import flash.events.*;
    
    /**
     * avatar icons.
     */
     
     /**
     * Author: Phill & Endre
     * Created: 7.10.07
     * Modified by: 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * 			 Shaun Narayan (Apr 2010) - modified loading of mirror and thumb images, added new
     * 			 							callbacks, initialization of some null fields, assigned name to
     * 			 							textfield (dont know why this wasnt there).
     * Purpose: The audio item scrollbar (list box) in the audio widget
     * Notes: BH, WW (AUT 2006) created AvScrollBar.as, we took that and created this class)
     */
    
    
    public class AvScrollBarItem extends AvScrollBar 
    {
        //Var here ...
        public var nameField    :TextField;  // Name in scrollbar
        public var avText       :TextField;  // mirror text field (created by AvScrollBar.as)
        public var mir          :MovieClip;  // Mirror full size image
        public var btn          :MovieClip;  // Avatar thumbnail for button
        public var thumbLayer   :Number;
        public var mirrorLayer  :Number;
        public var baseLayer    :Number;
        public var itemNameLayer    :Number;
    
        public var thumbUrl     :String;
        private var myParent	:AvScrollBar;
    
        // Attributes
        public var nameof       :String;   // Of avatar (string)
        public var ID           :Number;   // Of avatar
        public var available    :Boolean;  // Is the avatar currently available
    
        static public function create(av: Avatar, scrollbar :AvScrollBar, 
                                      available: Boolean) :AvScrollBarItem
        {
            //trace("in AvScrollBarItem.create()");
            var out :AvScrollBarItem;
            var name :String = "icon_" + av.ID;
            out = new AvScrollBarItem();
            out.myParent = scrollbar;
            out.nameof = av.myName;   // name of avatar not image...
            out.ID = av.ID;
            
            out.baseLayer = av.iconLayer;
            out.thumbLayer = av.iconLayer + 1;
            out.mirrorLayer = av.iconLayer + 2;
            out.itemNameLayer = av.iconLayer + 3;
            out.thumbUrl = av.thumbnail || av.url;
    		out.btn = new MovieClip();
    		out.mir = new MovieClip();
    		out.addChild(out.btn);
    		out.addChild(out.mir);
            //link to scrollbar's mirror textField.
            out.avText = scrollbar.avName;
            out.addEventListener(MouseEvent.CLICK, function() {out.onPress();});
            out.loadThumb();
            out.loadMirror(scrollbar);
            out.useHandCursor = true;
            out.createName(); 
            //XXXX load once and use duplicateMovieClip? 
            //Construct.deepTrace(out);
            if(available)
            {    out.enable();}
            else
            {    out.disable();}
            scrollbar.addChild(out);
            return out;
        }
    
        /**
         * @brief  load the button image, and size it.
         */
        public function loadThumb() :void                       

        {
            var parent: MovieClip = this;
            var listener: Object = LoadTracker.getLoadListener();
            listener.onLoadComplete = function()
                {
                    //trace("scrollbar button apparently loaded");
                    // Resize icon to fit on scrollbar
                    LoadTracker.loadComplete();
                    Construct.constrainSize(parent.btn, Client.ICON_SIZE, Client.ICON_SIZE);
                    parent.btn.x = parent.btn.x + 1;
            		parent.btn.y = parent.btn.y + 1;
                };
    
            LoadTracker.loadImage(this.btn, this.thumbUrl, this.thumbLayer, listener);
            trace('');
            trace('Thumburl: ' + this.thumbUrl + 'thumblayer: ' + this.thumbLayer);
            trace('');
        }
    
        /**
         * @brief load the mirror image, and size it.
         */
        public function loadMirror(scrollBar:MovieClip)                       
        {
            var parent: MovieClip = this;
            var listener: Object = LoadTracker.getLoadListener();
            listener.onLoadComplete = function()
                {
                	LoadTracker.loadComplete();
                    // Shrink to mirror size, move into position, and turn invisible.
                    //trace("mirror image apparently loaded");
                    parent.mir.visible = false;
                    Construct.constrainSize(parent.mir, Client.MIRROR_ICON_W, Client.MIRROR_ICON_H);
                    parent.mir.x = (Client.AV_MIRROR_WIDTH - parent.mir.width) / 2;
                    parent.mir.y = (Client.AV_MIRROR_HEIGHT - parent.mir.height) / 2;
                };
            listener.onLoadStart = function() 
            {                     
            	LoadTracker.loadStart();
                parent.myParent.loaded(); 
            };
            LoadTracker.loadImage(this.mir, this.thumbUrl, this.mirrorLayer, listener);
            scrollBar.addChild(this.mir);
        }
    
        public function createName()
        {
            // Create text field for movie
            var txtFieldAttrs :Object = {
                selectable: false,
                wordWrap: false,
                mouseWheelEnabled: false,  //not sure about all these.            
                type: 'dynamic'            //XXX?
            };
            var formatAttrs:Object = {};
            this.nameField = Construct.formattedTextField(this, 'nameField', this.itemNameLayer, Client.ICON_SIZE, 0, 
                                         Client.AV_SCROLL_NAME_W, Client.AV_SCROLL_NAME_H,
                                         0.9, true, txtFieldAttrs, formatAttrs);
    		
            this.nameField.text = this.nameof;
        }
    
        /* hide and show: these determine whether an icon is available at
         * all to the user.  A hidden icon is probably either scrolled off
         * the screen, or its avatar is being used by the user.  
         */
    
        /**
         * @brief Make it go away and be gone.
         */
        public function hide() :void
        {
            this.visible = false;
        }
    
        /**
         * @brief Welcome back to the world of light.
         */
        public function show() :void
        {
            this.visible = true;
        }
        
        /* enable, disable. An enabled icon is opaque while a disabled one
         * is translucent */
    
        /**
         * @brief Enable this item
         */
        public function enable() : void
        {
            // Make icon full color & available
            this.btn.alpha = Client.AVAIL_ICON_ALPHA;
            this.available = true;
        };
    
        /**
         * @brief Disable this item
         */
        public function disable() :void

        {
            // Grey icon out & set unavailable
            this.btn.alpha = Client.INUSE_ICON_ALPHA;
            this.available = false;
        };
    
    
        /* select, unselect.  A selected icon is hidden in the scrollbar
         * but shows in the mirror.  This encompasses enabling/disabling
         * (above), but does not hide the selected avatar. XXX and why not?
         */ 
    
        /**
         * @brief Move to the mirror & hide text field[??]
         */
        public function selectItem(): void
        {
            this.mir.visible = true;
            this.disable();
        };
    
        /**
         * @brief Remove from the mirror
         */
        public function unselect() : void
        {
            this.mir.visible = false;        
            this.enable();
        };
    
    
        /**
         * @brief Choose this item when pressed
         */
        public function onPress() : void
        {
            // Tell AvScrollBar that we want to select this avatar
            this.myParent.choose(this);
        };
    
    
        function AvScrollBarItem(){}
    };
}
