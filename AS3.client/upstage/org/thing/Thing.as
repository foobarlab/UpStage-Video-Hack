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
    
    import org.util.Icon;
    import org.Client;
    import org.util.LoadTracker;
    import org.view.Bubble;
    //import org.util.Construct;
    import flash.display.*;
	import flash.utils.*;
    import flash.net.*;
    import flash.events.*;
    /**
     * Prototype for other things
     * 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								moved factory functionality into constructor to allow inhertiance to
     * 								work with child objects. Listener callbacks changed to new model.
     */
    
    public class Thing extends MovieClip 
    {
        public var ID                :Number;
        public var url               :String;
        public var myName              :String;
        public var medium            :String;
        public var thumbnail         :String;
        public var wrap_ID           :String;
        public var icon              :Icon;       // Mini icon
    
        private var videoLayer1   :Number;
        private var videoLayer2   :Number;
        private var videoSwitch   :Boolean;
        private var videoDelay    :Number;
        private var videoInterval :Number = 0;
        private var videoTime     :Number;
        private var videoWait     :Number;
        private var videoSocketID :String;
        private var videoFailures :Number;
    
        public var image        :MovieClip; //points to the currently showing image
        private var baseLayer    :Number;
        private var layerOffset  :Number;
        private var baseName     :String;
    
        static var LAYER: Number = Client.L_PROPS_IMG;
        /**
         * @brief Constructor
         * Initialise the object
         */
    
        static public function factory(ID :Number, name :String, url :String, baseName: String,
                                       thumbnail :String, medium :String, layer: Number,
                                       parent:MovieClip, Class: Object) : Thing
        {
            //var mc:MovieClip = parent.attachMovie(Class.symbolName, baseName, layer);
            var thing:Thing = new Thing(ID, name, url, baseName, thumbnail, medium, layer, parent, Avatar); 
            parent.addChild(thing);
            return thing;
        }
    
        /* load the initial image */
    
        public function loadImage(url : String, layer: Number, listener: Object, mc:MovieClip) : MovieClip
        {
            trace("in Thing.loadImage for " + this + " with url " + url + " layer " + layer );
    
            if (! listener){
                var thing: Thing = this;
                listener = LoadTracker.getLoadListener();
                listener.onLoadStart = function(e: Event){
                    LoadTracker.loadStart();
                    thing.image = mc;
                    thing.finalise();
                };
            }
            return LoadTracker.loadImage(mc, url, layer, listener);
        }
    
    
        /**
         * @brief finalise.
         * Called when the things are all loaded.
         */
        public function finalise()
        {
            //trace("finalising thing " + this.name);
        }
    	
        function videoInit(){
            trace("in Thing.videoInit");
            this.videoLayer1 = this.baseLayer + 1;
            this.videoLayer2 = this.baseLayer + 2;
            this.videoSwitch = false;
            this.videoTime = 0;
            this.videoFailures = 0;
            //XXX it would be nicer to use the server's id for this socket
            //(as set by Transport.SET)
            this.videoSocketID = '?s=' + Math.random();
        }
    
        static function videoLoaded(thing:Thing, mc: MovieClip){
            // Test for failure by checking mc properties.
            // if it lacks width or height, it probably is not a valid jpeg.
            if (mc.width && mc.height){
                //it worked so switch visibility between the two frames
                mc.visible = true;
                thing.image.visible = false;
                thing.image = mc;
                thing.videoSwitch = ! thing.videoSwitch;
                thing.videoFailures = 0;
            }
            else {
                trace("movie clip " + mc + " failed to load with size(" +
                      mc.width + ", " + mc.height + ")");
            }
    
            //set up the next cycle, if necessary
            if (thing.visible){
                var d:Date = new Date();
                var now:Number = d.getTime();
                var elapsed:Number = now - thing.videoTime;
                thing.videoTime = now;
                var delay: Number = Math.max(Client.VIDEO_INTERVAL_TARGET - elapsed,
                                             Client.VIDEO_INTERVAL_MIN);
                trace("doing video for "+ thing + "elapsed:" + elapsed + " delay:" + delay);
                if (thing.videoInterval == 0)
                    thing.videoInterval = setInterval(Thing.reloadVideo, delay, thing);
            }
        }
    
    
        static function videoFailed(thing: Thing,
                                    mc: MovieClip,
                                    errorCode: String,
                                    httpCode: Number) : void
        {
            thing.videoFailures++;
            trace("frame failure for " + thing + " (" + thing.url + "). mc:" + mc);
            trace("error was '" + errorCode + "'; http status was '" + httpCode +
                  "'. Number " + thing.videoFailures);
            if (thing.videoFailures < Client.VIDEO_MAX_FAILURES &&
                thing.visible && thing.videoInterval == 0){            
                thing.videoInterval = setInterval(Thing.reloadVideo, 
                                                  Client.VIDEO_INTERVAL_TARGET, 
                                                  thing);            
            }
        }
    
        static function reloadVideo(thing: Thing) : void
        {
            //XXX neeed to check that nothing is loading. if it is don't restart.
            //this is becuase this function gets called by setting visibility, not only
            //from videoLoaded
            trace("in reload video with thing " + thing);
            clearInterval(thing.videoInterval);
            thing.videoInterval = 0;
            var listener:Object = { //XXX this object could sit round forever, not be recreated each time
                onLoadInit: function(mc: MovieClip){
                    Thing.videoLoaded(thing, mc);
                },
                onLoadError: function(mc: MovieClip, errorCode:String, httpStatus:Number){
                    Thing.videoFailed(thing, mc, errorCode, httpStatus);
                }
            };
            
            var layer:Number = thing.videoSwitch ? thing.videoLayer1 : thing.videoLayer2;
            var uniquify:String = '&u=' + Math.random();
            var img:MovieClip = new MovieClip();
			var req:URLRequest = new URLRequest(thing.url + thing.videoSocketID + uniquify);
			
			var loader:Loader = new Loader();  
			img.addChildAt(loader, layer);
			loader.load(req);  
			
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, listener.onLoadComplete);
            //loader.contentLoaderInfo.addEventListener(Event.ERROR, listener.onLoadError);
            loader.contentLoaderInfo.addEventListener(Event.OPEN, listener.onLoadInit);
            
            
            /**XXX could reuse the movieclips too.
            var loadWatcher  :MovieClipLoader = new MovieClipLoader();
            var layerName:String = "videolayer" + layer;
            var img:MovieClip = thing.createEmptyMovieClip(layerName, layer);
          loadWatcher.addListener(listener);
            //because http doesn't always work as expected,
            //make a unique suffix for the url, forcing fresh load.
            var uniquify:String = '&u=' + Math.random();
            loadWatcher.loadClip(thing.url + thing.videoSocketID + uniquify, img);*/
        }
    
    
        /**
         * @brief Show the thing
         */
        public function show() :void

        {
            trace("thing.show with" + this);
            if (this.medium == 'video'){
                trace("setting video interval " +  Client.VIDEO_INTERVAL_TARGET);
                if (this.videoInterval == 0){
                    this.videoInterval = setInterval(Thing.reloadVideo, Client.VIDEO_INTERVAL_TARGET, this);
                }
            }
    
            this.alpha = 100;
            this.visible = true;
        };
    
        /**
          * @brief Hide the thing
          */
        public function hide() :void

        {
            trace("thing.hide with" + this);
            if (this.medium == 'video' && this.videoInterval){
                //turn off the stream (if it is waiting for load there is no interval)
                clearInterval(this.videoInterval);
                this.videoInterval = 0;
            }
            this.visible = false;
            //Construct.deepTrace(this);
        };
    
        /**
         * @brief Set the thing's position on stage
         */
        public function setPosition(x :Number, y :Number, z :Number) :void

        {
            //trace("setting thing position to " + x + "," + y + " now:" + this._x + "," + this._y);
            this.x = x - (this.image.width * 0.5);
            this.y = y - (this.image.height * 0.5);
        };
    
        function Thing(ID :Number, name :String, url :String, baseName: String,
                                       thumbnail :String, medium :String, layer: Number,
                                       parent:MovieClip, Class: Object)
        {
            //trace("Thing preconstructor...");
            if (!Class || ! Class.symbolName){
                trace("no class in Thing constructor");
                Class = Thing;
            }
            //var mc:MovieClip = parent.attachMovie(Class.symbolName, baseName, layer);
            this.baseLayer = layer;
            this.baseName = baseName;
            this.ID = ID;
            this.url = url;// + '?r=' + Math.random(); //cache busting.
            this.myName = name;
            this.medium = medium;
            if (medium == 'video')
                this.videoInit();
            this.thumbnail = thumbnail;
            this.visible = false;
            parent.addChild(this);
        }
    };
}
