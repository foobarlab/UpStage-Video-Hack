/**
 * Simple class to subscribe to a video stream using red5
 */
class upstage.subscriber.Main extends MovieClip {

	// Constants:
	public static var CLASS_REF:Object = upstage.subscriber.Main;
	public static var LINKAGE_ID:String = "upstage.subscriber.Main";
	
	//private static var symbolName:String = "__Packages.upstage.subscriber.Main";
    //private static var symbolLinked:Boolean = Object.registerClass(symbolName, Main);
	
	public static var CONNECTION_STRING:String = "rtmp://localhost/oflaDemo";
	public static var STREAM_NAME:String = "red5StreamDemo";
	public static var BUFFER_TIME:Number = 0.1;

	// Public Properties:
	
	// Private Properties:
	
	// hardware access
	//private var cam:Camera;
	//private var mic:Microphone;
	
	// network
	private var connection:NetConnection;
	private var stream:NetStream;
	
	// UI Elements:
	//private var image:MovieClip;
	private var display:MovieClip;
	private var video:Video;
	
	// Initialization:
	private function Main() {
		
		trace("Constructor called");
	
		// set security for cross-domain scripting (not needed yet)
    	// see: http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00002104.html
		//System.security.allowDomain("*");
		
		// TODO initialize logger
	}
	
	private function onLoad():Void {
		
		trace("onLoad called");
		
		// local testing (not called in UpStage)
		configUI();
		startStream();
		
	}

	// Public Methods:

	// Semi-Private Methods:

	// Private Methods:

	private function configUI():Void 
	{		
		trace("configUI called");
		
		/*
		// setup cam
		cam = Camera.get();
		cam.setMode(320, 240, 15); 
		cam.setQuality(0, 80);
		*/
		
		/*
		// setup microphone
		mic = Microphone.get();
		mic.setUseEchoSuppression(true);
		mic.setSilenceLevel(0);
		*/

		/*
		// for broadcaster:
		var display = _root.attachMovie("VideoDisplay", "display", _root.getNextHighestDepth());
		display.video._width = 320;
		display.video._height = 240;
		display.video.attachVideo(cam);
		*/
		
		// for subscriber:
		this.display = _root.attachMovie("VideoDisplay", "display", _root.getNextHighestDepth(), {_x:0, _y:0, _width:320, _height:240});
	
	}

	public function startStream():Void
	{
		trace("startStream called");
		
		// create connection to red5
		connection = new NetConnection();
		connection.connect(null);
		connection.connect(CONNECTION_STRING);
		
		// connect stream
		stream = new NetStream(connection);
		stream.setBufferTime(BUFFER_TIME);
		stream.play(STREAM_NAME, -1);
		
		this.video = this.display.video;
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
		
		this.display._visible = true;
		//this.image._visible = false;	// FIXME not working in UpStage
	}
	
	public function stopStream() : Void
	{
		trace("stopStream called");
		
		stream.close();
		if(connection.isConnected) connection.close();
		this.video.clear();
		
		this.display._visible = false;
		//this.image._visible = true;		// FIXME not working in UpStage
	}
}