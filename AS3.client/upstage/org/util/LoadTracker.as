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
    
    /**
     * Module: LoadTracker.as
     * Authors: Beau Hardy, Wise Wang, Francis Palma, Lucy Chu, Douglas Bagnall
     * 
     * Track the progress of clips that are loading.  This is the global
     * face of ModelSplashScreen.  Modules loading images use
     * getLoadListener() and loadImage() to tell the splach screen how
     * things are going. 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - also had to re-position components, add padding,
     * 								Use of URLRequests and URLLoader added, MC structure changed.
     * 			 Shaun Narayan (Apr 2010) - Added accessor/mutator methods for tracking values so external objects overriding
     * 								listeners still update the tracker
     */
    import org.Client;
    import org.util.Construct;
    import flash.display.*;
	import flash.net.*;
	import flash.events.*;
    
    
    public class LoadTracker 
    {
        // How many images are currently loading
        private static var failed      :Number;  // Failed to load
        private static var expected    :Number;  // Total requested to load
        private static var started     :Number;  
        private static var finished    :Number;  
        
        // MovieClip constants for on screen display
        private static var view        :MovieClip;
        private static var modelSplash :Object;
    
    
        /**
         * @brief Set up the callback links and
         * initialise counters.
         */
        public static function init(model: Object,  view:MovieClip)
        {
            LoadTracker.modelSplash = model;
            LoadTracker.view = view;
            // Reset loading counts
            LoadTracker.expected = 0;
            LoadTracker.started = 0;
            LoadTracker.finished = 0;
            LoadTracker.failed = 0;
            LoadTracker.redraw();
            trace('LoadTracker initialised');
        };
    
        /**
         * @brief set the expected number of images, from the number of
         * different kinds of things to be loaded.  Each kind of thing
         * might load a different number of images.
         */
        public static function setExpected(avatars:Number, props:Number, backdrops:Number) : void
        {        
            LoadTracker.expected = (avatars * Client.LOADS_PER_AVATAR + 
                                    props * Client.LOADS_PER_PROP + 
                                    backdrops * Client.LOADS_PER_BACKDROP);
            if (LoadTracker.expected == 0){
                //need to finish straight away.  There will be no load
                //events to do it for us
                LoadTracker.modelSplash.complete();
            }
            else{
                LoadTracker.redraw();
                trace('LoadTracker setExpected()');
                Construct.deepTrace(arguments);
                Construct.deepTrace(LoadTracker);        
            }
        };
    
        /**
         * @brief gets the Splashscreen to redraw the progess bar.
         */
        private static function redraw() :void

        {
            LoadTracker.view.redrawProgressBar(LoadTracker.expected,
                                               LoadTracker.started,
                                               LoadTracker.finished,
                                               LoadTracker.failed);   
        };
    
        /**
         * @brief Create an object with appropriate callbacks
         * for a MovieClipLoader listener.
         * An object loaded using this listener will register
         * its status with the LoadTracker.
         */
        public static function getLoadListener(): Object
        {
    //        trace('**getting LoadListener. expected is ' + LoadTracker.expected);
            return {
                onLoadError: function(mc :Object, error :String){
                    LoadTracker.failed++;
                    LoadTracker.redraw();
                    LoadTracker.modelSplash.fail();    
    
    //                trace('**Didnt load: ' + mc._name + ' because: ' + error);
                    Construct.deepTrace(LoadTracker);
                },
                onLoadComplete: function(mc :Object){
                    loadComplete();
                    //trace('Load Complete is done...');

                },
                onLoadStart: function(mc :Object){
                    //trace('Load started...');
    //                trace('**started ' + mc._name );
					loadStart();
                }
            }
        }
    	public static function loadStart()
    	{
            LoadTracker.started++;
            LoadTracker.redraw();
    	}
    	public static function loadComplete()
    	{
            LoadTracker.finished++;                
            LoadTracker.redraw();
            if(LoadTracker.finished == LoadTracker.expected)
                LoadTracker.modelSplash.complete();
    	}
    
        /**@brief Load an image, keeping track of its progress if its
         * listener object is null, or derived from
         * LoadTracker.getLoadListener()
         */
    
    
        public static function loadImage(mc: MovieClip, url : String, 
                                  layer: Number, listener: Object) :MovieClip
        {
        	if(url == null) return new MovieClip;
            if (!listener){
                listener = LoadTracker.getLoadListener();
            }
            trace("Loading " + url);
            var layerName:String = "layer" + layer;
            //var img:MovieClip = mc.createEmptyMovieClip(layerName, layer);
            //var loadWatcher  :MovieClipLoader = new MovieClipLoader();
        	//loadWatcher.addListener(listener);
            //loadWatcher.loadClip(url, img);
            var img:MovieClip = new MovieClip();
			var req:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();  
			loader.load(req);  
			listener = listener || getLoadListener();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, listener.onLoadComplete);
            //loader.contentLoaderInfo.addEventListener(Event.ERROR, getLoadListener().onLoadError);
            loader.contentLoaderInfo.addEventListener(Event.OPEN, listener.onLoadStart);
            trace("Loaded " + url + " " + loader + " " + img);
            img.addChild(loader);
            mc.addChild(loader);
            return img;
        }
    };
}
