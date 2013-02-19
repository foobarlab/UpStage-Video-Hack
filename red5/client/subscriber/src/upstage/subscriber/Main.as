/**
 * Simple class to subscribe to a video stream unsing red5
 */
class upstage.subscriber.Main extends MovieClip {

	// Constants:
	public static var CLASS_REF = upstage.subscriber.Main;
	public static var LINKAGE_ID:String = "upstage.subscriber.Main";

	// Public Properties:
	
	// Private Properties:
	private var cam:Camera;
	private var mic:Microphone;
	private var nc:NetConnection;
	
	// UI Elements:

	private var video:Video;
	private var stream:NetStream;
	
	// Initialization:
	private function Main() {
		//XrayLoader.loadConnector("xray.swf");
		//XrayLoader.addEventListener(XrayLoader.LOADCOMPLETE, this, "xrayLoadComplete");
		//XrayLoader.addEventListener(XrayLoader.LOADERROR, this, "xrayLoadError");
		//XrayLoader.loadConnector("xrayConnector_1.6.3.swf");
	}
	
	private function onLoad():Void {
		configUI();
	}

	// Public Methods:

	// Semi-Private Methods:

	// Private Methods:

	private function configUI():Void 
	{		
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
		
		//_root.attachMovie("Video", "stopVideo", _root.getNextHighestDepth());
				
		//var display = _root.attachMovie("VideoDisplay", "display", _root.getNextHighestDepth());
		var display = _root.attachMovie("VideoDisplay", "display", 101);
		display.video._width = 320;
		display.video._height = 240;
		//display.video.attachVideo(cam);
		
		// create connection to red5
		nc = new NetConnection();
		nc.connect("rtmp://localhost/oflaDemo");
		stream = new NetStream(nc);
		stream.setBufferTime(0.1);
		
		stream.play("red5StreamDemo", -1);
		display.video.attachVideo(stream);
	}

}