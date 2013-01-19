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
    
    import org.thing.Thing;
    import org.Client;
    import org.util.Construct;
    import org.util.Icon;
    import org.util.LoadTracker;
    import flash.display.*; 
    import flash.events.*;
    /**
     * background images.
     * 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								changed constructor to instantize parent there instead of through 
     * 								factory to abide by normal AS3 standards.
     * 			 Shaun Narayan (Apr 2010) - Fixed numerous bugs (Same as avatar mostly).
	 *			 Vibhu and Heath (15/06/2011) - Backdrop remains at back of avatar
     */
    
    public class BackDrop extends Thing 
    {
        // Aaron (21/04/08) Testing multi-frame backdrop
        // Image and its loader.
        public var myImage            :MovieClip;
        private var images          :Array;
        private var frameNumber        :Number;
        
    
        public static var transportSetFunctionName:String = 'SET_BACKDROP';
    
        static public function factory(imgParent : MovieClip, iconParent : MovieClip, ID :Number,
                                name :String, url :String, thumbnail :String,
                                medium :String, frame :Number): BackDrop
        {
            trace("BackDrop factory");
    
            var baseLayer:Number = Client.L_BG_IMG -(-ID *  Client.THING_IMG_LAYERS);
            var baseName: String = 'backdrop_' + ID;
            //var thing:Thing = Thing.factory(ID, name, url, baseName,
              //                              thumbnail, medium, baseLayer, imgParent, BackDrop);
            var backdrop: BackDrop = new BackDrop(ID, name, url, baseName,
                                            thumbnail, medium, baseLayer, imgParent, BackDrop);
            
            backdrop.frameNumber = frame;
            
            // Aaron (21/04/08) Testing multi-frame backdrop
            var listener :Object = LoadTracker.getLoadListener();
            listener.onLoadComplete = function(e:Event){
                LoadTracker.loadComplete();
                backdrop.finalise();
                //XXX could call finalise here.
            };
            backdrop.images = new Array();
            backdrop.myImage = new MovieClip();
            backdrop.loadImage(backdrop.url, baseLayer + 1, listener, backdrop.myImage);
	        backdrop.images[1] = backdrop.myImage;
            // Create icon & ask for it to load
            var iLayer :Number = Client.L_UI_ICONS_BASE -(-ID);
            var iUrl :String = thumbnail || url;
        
            backdrop.icon = Icon.create(backdrop, name, iLayer, iUrl);
            iconParent.addChild(backdrop.icon);
            backdrop.addChild(backdrop.myImage);
            return backdrop;
        }
          
    	
        function BackDrop(ID :Number, name :String, url :String, baseName: String,
                                       thumbnail :String, medium :String, layer: Number,
                                       parent:MovieClip, Class: Object)
        {
        	trace("In Backdrop cons");
        	super(ID, name, url, baseName, thumbnail, medium, layer, parent, Avatar);  
        };;
    
    
        public override function finalise(){
            //this.setPosition(Client.SCREEN_WIDTH/2, Client.SCREEN_HEIGHT/2, 0);
            // Stop press of onscreen backdrops
            this.icon.useHandCursor = false;
            this.icon.x = this.icon.x + 1;
            this.icon.y = this.icon.y + 1;
            // Break animation of backdrop initially
            this.frame(this.frameNumber);
    
            // Fit to screen onload without changing aspect ratio
            //But no resizing up.
            //Sets the backdrop size to that of stage. 14/06/2011 Vibhu and Mohammed
            this.myImage.width = (Client.SCREEN_WIDTH - 62);
            this.myImage.height = (Client.SCREEN_HEIGHT - 55);
            this.myImage.x = 3;
            this.myImage.y = 3;
			//Sets backdrop at back of screen 15/06/2011 Vibhu and Heath
			this.parent.setChildIndex(this, 0);
            this.visible = false;
        };    
        
        // Aaron (21/04/08) Testing multi-frame backdrop
        /* @brief Change Background Image
         */
        function frame(number: Number)
        {
            this.frameNumber = number;
            
            if (number == 0)
                {
                    this.myImage.play();
                }
            else {
                if (! (number > 0 &&  number <= this.myImage.totalFrames)){
                    trace('FRAMES: (backdrop) Number is wrong:' +  number);
                    number = 1;
                }
                trace ('FRAMES: Setting backdrop frame: ' + number);
                this.myImage.gotoAndStop(number);
            }
        }
        
        
    };
    
}
