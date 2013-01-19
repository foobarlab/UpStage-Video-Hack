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
    
    import org.Client;
    import org.model.TransportInterface;
    import org.util.UiButton;
    import org.util.Construct;
    import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import org.util.Web;
	import flash.events.*;
	
    /**
     * Module: SplashScreen.as
     *
     * Display a splash screen & loading bar to stop user clicking before
     * images et al have properly loaded.
     * 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...) also - most splash components had to be moved (from relative
     * 								positioning to absolute) to look the same as in previous client.
     * 			 Shaun Narayan (Apr 2010) - Repositioned load blocks and offset (fix for bug where loader blocks
     * 			 					appear in top left of the screen.
     */
    
    
    public class SplashScreen extends MovieClip 
    {
        public var txtField :TextField;
        private var txtFieldStartupMsg :TextField;
        private var txtFieldUserName :TextField;
        private var progressBar :MovieClip;
        // Buttons
        private var reloadBtn : UiButton;
        private var cancelBtn : UiButton;
    
    
        private var finished:Number;
        private var lastRedraw: Number = 0;
    
        private var startupLayer: Number;
        private var nameLayer: Number;
        private var msgLayer: Number;
        private var barLayer: Number;
    
        // Variables for startup msg
    
        private var badImageMsg :String =
        'Images from the server failed to load correctly, please select ' +
        'Reload or Cancel.';
    
        private var doubleLoginMsg :String =
        'You cannot login to the same stage as the same user twice. ' +
        'You can however log the same user into different stages at the same ' +
        'time. Please select Cancel, you can then either return to you other '+
        'browser window, or log in as a different user.';
    
    
    
        /**
         * @brief Call this to make the splash screen.
         */
        static public function create(parent :MovieClip, name :String,
                      layer :Number, x :Number, y: Number,
                      ti: TransportInterface) :SplashScreen
        {
	        var out :SplashScreen;
	       //out = SplashScreen(parent.attachMovie(SplashScreen.symbolName, name, layer));
	        out = new SplashScreen();
	        out.startupLayer = layer + 1;
	        out.nameLayer = layer + 2;
	        out.msgLayer = layer + 3;
	        out.barLayer = layer + 4;
	        out.x = x;
	        out.y = y;
	    
	        Construct.uiRectangle(out, 0, 0, Client.SCREEN_WIDTH, Client.SCREEN_HEIGHT, undefined);
	        out.alpha = 70;
	    
	        // Make textFields
	        var txtFieldX :Number = (Client.SCREEN_WIDTH - Client.SPLASH_TF_W) / 2;
	        var txtFieldY :Number = Client.SCREEN_HEIGHT / 2 - Client.SPLASH_TF_H;
	    
	        out.txtField = Construct.fixedTextField(out, 'txtField', out.msgLayer, txtFieldX, txtFieldY,
	                                     Client.SPLASH_TF_W, Client.SPLASH_TF_H, Client.SPLASH_TF_SCALE, false, undefined);
	        
	        out.txtField.text = 'Loading ...';
	        out.initProgressBar(parent);
	        out.createButtons();
	        out.addChild(out.txtField);
	        parent.addChild(out);
	        return out;
        }
    
        /** @brief set up the movieclip and outline for the progress bar */
          
		private function initProgressBar(parent:MovieClip)
		{
	        var b:Number =  Client.PROGRESS_BAR_BORDER;
	        var w:Number =  Client.PROGRESS_BAR_W;
	        var h:Number =  Client.PROGRESS_BAR_H;
	        progressBar = new MovieClip();
	        this.progressBar.x = (parent.width - w) / 2;
	        this.progressBar.y = (parent.height - h) / 2;
	
	        Construct.rectangle(this.progressBar, Client.SCREEN_WIDTH/2, Client.SCREEN_HEIGHT/2, w + b * 2, h + b * 2, 
	                            Client.PROGRESS_FORE, Client.UI_BACKGROUND, 0.5, undefined);
	        this.addChild(progressBar);
    	}
    
        /** @brief draw the progress bar.  This is called from 
         * LoadTracker.as
         */
    
        public function redrawProgressBar(expected :Number,
                                   started :Number,
                                   finished :Number,
                                   failed :Number) :void
        {
            //restrict to 20 redraws per second
    //        trace('**** expected:' + expected + ' started: ' + started + ' fin ' + 
    //              finished + ' fail ' + failed);
            var now:Number = getTimer();
            if (now - this.lastRedraw < 50)
                return;
            this.lastRedraw = now;    
        
            var mc:MovieClip = this.progressBar;
            var h:Number =  Client.PROGRESS_BAR_H;
            var item:Number = Client.PROGRESS_BAR_W / expected;
            var offset:Number;
            var i:Number;
            // avoid repainting the ones that are already finished.
            for (i = this.finished; i < finished; i++){
                offset = i * item;
                Construct.rectangle(mc, h * 0.2 + offset + Client.SCREEN_WIDTH/2, h*0.2+Client.SCREEN_HEIGHT/2, item - 0.75, 
                                    h, Client.PROGRESS_LOAD_L, Client.PROGRESS_LOAD_F, undefined, undefined);        
            }
            for (; i < started; i++){
                Construct.rectangle(mc, h * 0.2 + offset + Client.SCREEN_WIDTH/2, h*0.2+Client.SCREEN_HEIGHT/2, item - 0.75, 
                                    h, Client.PROGRESS_START_L, Client.PROGRESS_START_F, undefined, undefined);        
                offset += item;
            }
            for (i = 0; i < failed; i++){//will this ever show?
                Construct.rectangle(mc, h * 0.2 + offset+Client.SCREEN_WIDTH/2, h*0.2+Client.SCREEN_HEIGHT/2, item - 0.75, 
                                    h, Client.PROGRESS_FAIL_L, Client.PROGRESS_FAIL_F, undefined, undefined);        
                offset += item;
            }
            this.finished = finished;
        }
    
    
        /**
         * @brief Method to display startup message
         */
        public function displayStartupMsg(msg:String) :void

        {
            if (! this.txtFieldStartupMsg){
                var smX : Number = (this.width - Client.SPLASH_MSG_W) / 2;
                var smY : Number = Client.SPLASH_MSG_Y;
                this.txtFieldStartupMsg = Construct.fixedTextField(this, 'startMsg', this.startupLayer, smX, smY,
                                                             Client.SPLASH_MSG_W, Client.SPLASH_MSG_H, 
                                                             Client.SPLASH_MSG_SCALE, false, {wordWrap:true});
                this.addChild(this.txtFieldStartupMsg);
            }
        this.txtFieldStartupMsg.text = msg;
        }
    
    
        /**
         * @brief Creates splash screen buttons
         */
        public function createButtons() :void

        {
        var reloadX : Number = this.width/2 - 20;
        var Y : Number = this.height/2 + 20;
            
            this.reloadBtn = UiButton.factorySplash(this, Client.BTN_LINE_RELOAD, Client.BTN_FILL_RELOAD, 
                                              'reload', Client.SPLASH_BTN_SCALE, reloadX, Y, 20, Client.UI_BUTTON_HEIGHT);
            this.reloadBtn.addEventListener(MouseEvent.CLICK, function(){
                Construct.reloadStage();
            });
        this.cancelBtn = UiButton.factorySplash(this, Client.BTN_LINE_CNCL, Client.BTN_FILL_CNCL, 
                                              'cancel', Client.SPLASH_BTN_SCALE, reloadX + 24, Y, 20, Client.UI_BUTTON_HEIGHT);
        this.cancelBtn.addEventListener(MouseEvent.CLICK, function(){
                Web.getURL('/stages/');
            });
    
        }
    
        /**
         * @brief Called when double login detected
         */
        public function doubleLogIn(msg :String) :void
        {
        	this.txtField.text = 'Logged in twice ...';
        	this.displayStartupMsg(this.doubleLoginMsg);
        	this.reloadBtn.visible = false;
        	this.cancelBtn.x -= 12;
    
  		    this.visible = true;
        }
    
        /**
         * @brief Called when images failed to load...
         */
        public function badImageLoad() :void
        {
        	this.txtField.text = "Couldn't load all images";
        	this.displayStartupMsg(this.badImageMsg);
        }
    
        /**
         * @brief Called when all images loaded successfully
         */
        public function shutDown() :void
        {
        	this.visible = false;
        }
    
    
        /**
         * @brief Called automatically to set stagename
         */
        public function setStageName(name :String) :void
        {
        	this.txtField.text = 'Loading: ' + name + '...';
        }
    
        /**
         * @brief Method to create the username text field
         * Called when the username arrives, if it does.
         */
        public function setUserName(name :String) :void

        {
        
            if (this.txtFieldUserName == null)
                {
                    var x : Number = (this.width - Client.SPLASH_NAME_W) / 2;
                    var y : Number = Client.SPLASH_NAME_Y;
                    this.txtFieldUserName = Construct.fixedTextField(this, 'txtFieldUserName', this.nameLayer, x, y, 
                                             Client.SPLASH_NAME_W, Client.SPLASH_NAME_H, 
                                             Client.SPLASH_NAME_SCALE, false, {wordWrap:true});
                }
        this.txtFieldUserName.text = 'Welcome ' + name;
        }
    
    
        function SplashScreen(){};
    }
}
