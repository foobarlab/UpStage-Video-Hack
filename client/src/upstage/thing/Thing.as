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

import upstage.util.Icon;
import upstage.Client;
import upstage.util.LoadTracker;
import upstage.util.Construct;


/**
 * Prototype for other things
 *
 * Modified by: Heath Behrens & Vibhu Patel 08/08/2011 - Modified function Added line which calls Construct
 *                                                       to scale the prop on stage
 *
 */
class upstage.thing.Thing extends MovieClip
{
    var ID                :Number;
    var url               :String;
    var name              :String;
    var medium            :String;
    var thumbnail         :String;
    var wrap_ID           :String;
    var icon              :Icon;       // Mini icon

    private var videoLayer1   :Number;
    private var videoLayer2   :Number;
    private var videoSwitch   :Boolean;
    private var videoDelay    :Number;
    private var videoInterval :Number = 0;
    private var videoTime     :Number;
    private var videoWait     :Number;
    private var videoSocketID :String;
    private var videoFailures :Number;

    public var  image        :MovieClip; //points to the currently showing image
    private var baseLayer    :Number;
    private var layerOffset  :Number;
    private var baseName     :String;

    private static var symbolName:String = "__Packages.upstage.thing.Thing";
    private static var symbolLinked:Boolean = Object.registerClass(symbolName, Thing);

    static var LAYER: Number = Client.L_PROPS_IMG;

	// streaming properties
	public var videodisplay : MovieClip;	// videodisplay (carries video)
    public var video : Video;				// video itself
	public var streamName : String;			// name of the stream, e.g. 'red5StreamDemo'
	public var streamServer : String;		// url of the stream server, e.g. 'rtmp://localhost/oflaDemo'
	private var connection:NetConnection;	// the network connection to the stream server
	private var stream:NetStream;			// the network stream of a connected stream server


    /**
     * @brief Constructor
     * Initialise the object
     */

    static public function factory(ID :Number, name :String, url :String, baseName: String,
                                   thumbnail :String, medium :String, layer: Number,
                                   parent:MovieClip, Class: Object) : Thing
    {
        if (!Class || ! Class.symbolName){
            trace("no class in Thing constructor");
            Class = Thing;
        }
        var mc:MovieClip = parent.attachMovie(Class.symbolName, baseName, layer);
        var thing:Thing = Thing(mc);
        thing.baseLayer = layer;
        thing.baseName = baseName;
        thing.ID = ID;
        thing.url = url;// + '?r=' + Math.random(); //cache busting.
        thing.name = name;
        thing.medium = medium;
        
        // TODO collect streaming params, hardcoded for now:
        // TODO initialize in constructor
        thing.streamName = 'red5StreamDemo';
        thing.streamServer = 'rtmp://localhost/oflaDemo'
        
        if (medium == 'video') {
            thing.videoInit();
        }
        if (medium == 'stream') {
        	thing.streamInit();
        }
        thing.thumbnail = thumbnail;
        thing._visible = false;
        
        return thing;
    }

    /* 
    *
    * load the initial image
    * Modified by: Heath / Vibhu 08/08/2011 - Added to scale the prop on stage.
    *
    */

    function loadImage(url : String, layer: Number, listener: Object, is_prop: Boolean)
    {
    	
    	trace("load image from url " + url);
    	
        //Heath Behrens / Vibhu Patel 08/08/2011 - Added to check if current thing is a prop and then scale accordingly. 
        if(is_prop && !listener){
            var thing: Thing = this;
            listener = LoadTracker.getLoadListener();
            listener.onLoadInit = function(mc: MovieClip){
                //Modified by: Heath / Vibhu 08/08/2011 - Added to scale the prop on stage.
                mc._width = Client.PROP_MAX_WIDTH;
                mc._height = Client.PROP_MAX_HEIGHT;  
                  
                thing.image = mc;
                thing.finalise();
            };
        }
        else if (!listener){
            var thing: Thing = this;
            listener = LoadTracker.getLoadListener();
            listener.onLoadInit = function(mc: MovieClip){
                
                thing.image = mc;
                thing.finalise();
            };
        }
        LoadTracker.loadImage(this, url, layer, listener);
    }


    /**
     * @brief finalise.
     * Called when the things are all loaded.
     */
    public function finalise(){
        //trace("finalising thing " + this.name);
    }

	function streamInit() {
		trace("in Thing.streamInit");
		
		// TODO prepare stream
		
		// OBSOLETE:
		// FIXME not working because swf has not been loaded yet!
		// ensure presence of display mc:
		// attach mc for video display (configured in application.xml of stream.swf) 
		//this.image.streamSubscriber.display = this.image.streamSubscriber.attachMovie(
		//	"VideoDisplay", "display", this.image.streamSubscriber.getNextHighestDepth(), {_x:0, _y:0, _width:320, _height:240});
		
		// attach videodisplay from library
		// TODO can this be attached before image is loaded?
		//this.videodisplay = _root.attachMovie("VideoDisplay", "videodisplay", _root.getNextHighestDepth(), {_x:0, _y:0, _width:120, _height:90});

		// TODO should connection to the streaming server be already established here? does it work with multiple stream avatars then?
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
        if (mc._width && mc._height){
            //it worked so switch visibility between the two frames
            mc._visible = true;
            thing.image._visible = false;
            thing.image = mc;
            thing.videoSwitch = ! thing.videoSwitch;
            thing.videoFailures = 0;
        }
        else {
            trace("movie clip " + mc + " failed to load with size(" +
                  mc._width + ", " + mc.height + ")");
        }

        //set up the next cycle, if necessary
        if (thing._visible){
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
                                httpCode: Number) : Void
    {
        thing.videoFailures++;
        trace("frame failure for " + thing + " (" + thing.url + "). mc:" + mc);
        trace("error was '" + errorCode + "'; http status was '" + httpCode +
              "'. Number " + thing.videoFailures);
        if (thing.videoFailures < Client.VIDEO_MAX_FAILURES &&
            thing._visible && thing.videoInterval == 0){            
            thing.videoInterval = setInterval(Thing.reloadVideo, 
                                              Client.VIDEO_INTERVAL_TARGET, 
                                              thing);            
        }
    }

    static function reloadVideo(thing: Thing) : Void
    {
        //XXX neeed to check that nothing is loading. if it is don't restart.
        //this is because this function gets called by setting visibility, not only
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
        //XXX could reuse the movieclips too.
        var layer:Number = thing.videoSwitch ? thing.videoLayer1 : thing.videoLayer2;

        var loadWatcher  :MovieClipLoader = new MovieClipLoader();
        var layerName:String = "videolayer" + layer;
        var img:MovieClip = thing.createEmptyMovieClip(layerName, layer);
		loadWatcher.addListener(listener);
        //because http doesn't always work as expected,
        //make a unique suffix for the url, forcing fresh load.
        var uniquify:String = '&u=' + Math.random();
        loadWatcher.loadClip(thing.url + thing.videoSocketID + uniquify, img);
    }


    /**
     * @brief Show the thing
     */
    function show() :Void
    {
        trace("thing.show with" + this);
        
        if (this.medium == 'video') {
            trace("setting video interval " +  Client.VIDEO_INTERVAL_TARGET);
            if (this.videoInterval == 0){
                this.videoInterval = setInterval(Thing.reloadVideo, Client.VIDEO_INTERVAL_TARGET, this);
            }
        }
        
        this._alpha = 100;
        this._visible = true;
        
        if (this.medium == 'stream') {
        	trace("showing video stream");
        	
        	// TODO start video
        	
        	// OBSOLETE:
        	/*
        	//this.image.streamSubscriber.configUI();
        	
        	// FIXME create display on init?
        	this.image.streamSubscriber.display = this.image.streamSubscriber.attachMovie(
        		"VideoDisplay", "display", this.image.streamSubscriber.getNextHighestDepth(), {_x:0, _y:0, _width:320, _height:240});
        	
        	Construct.deepTrace(this.image.streamSubscriber);
        
        	this.image.streamSubscriber.startStream();
        	*/
        	
        	// TODO resize videodisplay (steps 320x240 => 160x120 => 120x90 => 80x60)
        	
        	//this.image = this.videodisplay;
        	//this.videodisplay = _root.attachMovie("VideoDisplay", "videodisplay", _root.getNextHighestDepth(), {_x:0, _y:0, _width:120, _height:90});
        	this.videodisplay = this.attachMovie("VideoDisplay", "videodisplay", _root.getNextHighestDepth(), {_x:0, _y:0, _width:120, _height:90});
        	
        	// hide avatar image (frame)
        	//this.image._visible = false;
        	
        	// create connection to server
			connection = new NetConnection();
			connection.connect(null);
			connection.connect(this.streamServer);
			
			// connect stream
			stream = new NetStream(connection);
			stream.setBufferTime(0.1);
			stream.play(this.streamName, -1);
			
			this.video = this.videodisplay.video;
			//this.video.clear();
			
			// attach video to display
			this.video.attachVideo(stream);
		
			// automatically set proper size
			stream.onStatus = function(infoObj:Object) {
				switch (infoObj.code) {
					case 'NetStream.Play.Start':
					case 'NetStream.Buffer.Full':
						this.video._width = this.video.width;
						this.video._height = this.video.height;
						break;
				}
			}
        	
        }
    };

	/**
 	 * @brief Hide the thing
 	 */
    function hide() :Void
    {
        trace("thing.hide with" + this);
        if (this.medium == 'video' && this.videoInterval){
            //turn off the stream (if it is waiting for load there is no interval)
            clearInterval(this.videoInterval);
            this.videoInterval = 0;
        }
        
        if (this.medium == 'stream') {
        	trace("hiding video stream");
        	
        	// TODO stop video	
        	
        	// OBSOLETE:
        	//this.image.streamSubscriber.stopStream();
        	
        	// TODO show image again
        	//this.image._visible = true;
        	
        	stream.close();
			if(connection.isConnected) connection.close();
			this.video.clear();
        	
        }
        
        this._visible = false;
        //Construct.deepTrace(this);
    };

    /**
     * @brief Set the thing's position on stage
     */
    function setPosition(x :Number, y :Number, z :Number) :Void
    {
        //trace("setting thing position to " + x + "," + y + " now:" + this._x + "," + this._y);
        this._x = x - (this.image._width * 0.5);
        this._y = y - (this.image._height * 0.5);
    };

    function Thing(){};
};