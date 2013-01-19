package org{
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
    
    import org.Auth;
    import org.Client;
    import org.Sender;
    import org.util.Construct;
    import org.model.ModelChat;
    import org.model.ModelInfo;
    import org.model.ModelBackDropItems;
    import org.model.ModelAvatars;
    import org.model.ModelSplashScreen;
    import org.model.ModelSounds;
    import org.model.ModelDrawing;
    import flash.net.XMLSocket;
    import flash.display.*;
    import flash.net.*;
    import flash.system.*;
    import flash.external.*;
    import flash.events.*;
    /**
     * Author: 
     * Modified by: Phillip Quinlan, Lauren Kilduff, Endre Bernhardt, Alan Crow
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * Modified by: Vishaal Solanki 15/10/09
     * @modified Shaun Narayan (01/29/10) - Modified LOAD_AUDIO so it can allow music playing 
     *                                            on the server to be played on the clients computer.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...) - also allowed for setting color of multiple stage item
     * 								backgrounds, changed oldschool decoder to new URLVars, modified connect
     * 								handler to avoid infinate loops.
     * 			 Shaun Narayan (Apr 2010) - Modified connection system to send one connection request and only
     * 			 							attempt a reconnect after knowing it failed for sure, also dont assume
     * 			 							connection failure until the event is triggered (Event.CLOSE) (This caused
     * 			 							upstage to display connection failed until the connect event came through).
     * Notes: 
     */
    
    
    public class Transport extends XMLSocket {

    {
        // Internal variables
        private var connectionTried :Number;
    
        // Instances of classes
        private var auth     :Auth;      // Auth object
        private var sender   :Sender;    // Sender object
    
        // Handlers for various onscreen objects
        private var modelChat          :ModelChat;
        private var modelAvatars       :ModelAvatars;
        private var modelBackDropItems :ModelBackDropItems;
        private var modelInfo          :ModelInfo;
        private var modelSplashScreen  :ModelSplashScreen;
        private var modelSounds        :ModelSounds;
        private var modelDrawing       :ModelDrawing;
    
        private var stage      :MovieClip;  // Handle to main stage movie clip
    
        public var mode        :String;
        public var swfport     :Number;
        public var policyport  :Number;
        public var stageID     :String;
        //public var player      :String;
        
        static var volunteer  :Boolean;
    
        /**
         * @brief Constructor
         * Creates new Auth object which gets app talking to server
         */
        function Transport(stage :MovieClip)
        {
            
            trace('Transport constructor...');
    
            this.stage = stage;
            super();  // Call XMLSocket constructor
    
            this.connectionTried = 0;
    
            this.parseUrlVars();
    
            this.sender = new Sender(this);
            // Create new handlers for events
            //---------------------------------------------------------------------
    
            // Do splash screen first for loaded progress bar
            this.modelSplashScreen = new ModelSplashScreen(sender);
    
            // Order of other handlers doesn't really matter
            /** EB 22/10/07: EXCEPT!! Make modelSounds before modelAvatars
             * 
             * modelAvatars (for some reason known only to Douglas or the previous team)
             * is responsible for the interface controls. When it is created, the
             * audioScrollBar is created. To create linkage between the audioscrollbar 
             * and ModelSounds (so the AudioSlot objects have the MS object to update to),
             * the ModelSounds object needs to be provided to the constructor for modelAvatars.
             * Then the audioScrollBar needs to be passed back to ModelSounds after modelAvatars
             * has been created. This kind of restriction may be indicative of an architectural
             * problem but it's a bit late in the day for us to look at it indepth now.
             * Sorry, it's what we have to work with for now..
             * 
             */
            //this.modelSounds = new ModelSounds(sender); //PQ: Added sender
            //this.modelAvatars = new ModelAvatars(sender, stage, this.modelSounds);
            //this.modelSounds.setAudioScrollbar(this.modelAvatars.audioScrollBar);
    
            this.modelChat = new ModelChat(sender);
            this.modelBackDropItems = new ModelBackDropItems(sender);
            this.modelSounds = new ModelSounds(sender);//, this.modelChat); //PQ: Added sender
            this.modelAvatars = new ModelAvatars(sender, stage, this.modelSounds);
            this.modelInfo = new ModelInfo(sender);
            this.modelDrawing = new ModelDrawing(sender);//, stage);
            volunteer = false;
            
            // True application execution begins when auth finishes load
            this.auth = new Auth();
            //this.auth.load(this.drawScreen);
            this.auth.load(this);
        }
    
        function parseUrlVars(){
            trace("parsing url vars");
            //var url:String = stage.root.loaderInfo.loaderURL;
            var url:String = ExternalInterface.call('function(){return document.getElementById("app").data;}');
            var args:String = url.split('?')[1];
			var decoder:URLVariables = new URLVariables();
            trace("loading args of "+ args);
			decoder.decode(args);
            this.mode = decoder.mode;
            this.swfport = Number(decoder.swfport);
            this.policyport = Number(decoder.policyport);
            this.stageID = decoder.stageID;
        }
    
    
        /**
         * @brief EventHandler 
         * This onConnect function is used to check and return if the connection
         * successful or not, if not try a maximum of Client.MAX_CONNECTION_ATTEMPTS
         * (probably 4) times.
         */
        function onConnect(e :Event) : void
        {
            trace('Transport.onConnect()...');
            trace('ok, connected');
            this.sender.IDENT(this.auth.getKey());
            this.sender.JOIN(this.stageID);
    
            trace('Transport.onConnect() done...');
        }
    
    
    
        /**
         * EventHandler 
         * This onClose function is used for XMLSocket callback
         */
        function onClose(e:Event) : void
        {
            trace('Connection to XMLTransport lost');
            this.displayConnectionLost("Connection failed");
            this.connectionTried++;
            if(connectionTried < Client.MAX_CONNECTION_ATTEMPTS) attemptConnect;
        }
    
    
    
        /**
         * @brief Tries to connect to application (twistd) port
         * Retries a fixed number of times
         */
        private function attemptConnect() : void
        {
            // tries to connect to server as specified in server object
            // fails very plainly - there's not much that can be done.
            this.addEventListener(Event.CONNECT, onConnect);
            this.addEventListener(Event.CLOSE, onClose);
            this.addEventListener(DataEvent.DATA, onDataWrap);
            var lc: LocalConnection = new LocalConnection();
            var domain: String = lc.domain;
    		connectionTried = 0;
            // AC - Get required policy file
            Security.loadPolicyFile('xmlsocket://' + domain + ':' + Client.POLICY_PORT.toString());
            //Security.allowDomain('http://' + domain + ':' + this.swfport);
            trace('attemptConnect() - trying to connect to ' + this.swfport);
            this.connect(null, this.swfport);
            trace(this.connected);
        }
    
    
        /**
         * @brief Bugfix some flash players
         * EventHandler for XMLSocket
         */
        function onDataWrap(msg :DataEvent) :void

        {
            //workaround apparent bug in players
            this.onData(msg);
        }
    
        /**
         * @brief EventHandler 
         * Called when data received from server
         * Data dispatched to Receiver class
         * Event Handler for XMLSocket
         */
        function onData(msg :DataEvent)  :void

        {
            trace('GOT "' + msg +'"');
            var vars:URLVariables = new URLVariables();
    
            //convert the a variable string to a property of specified LoadVars object
            vars.decode(msg.data);
    
            var mode :String = vars.mode.toUpperCase();
            trace(mode);
            if (mode && this[mode])
            {
                // Get the reciever functions below to handle the message
                this[mode](vars);
            }
            else if (msg)
            {
                trace('\nreceived mystery message:\n' + msg );
            }
        }
    
    
        /**
         * @brief Gets application underway after inital Auth / Server
         * handshaling is complete
         */
        function startPlay() :void

        {
            this.attemptConnect();
            trace('********************* started! *********************');
        }
    
    
        /**
         * @brief Draw all child movie clips
         */
        public function drawScreen() :void

        {
            trace('transport.drawScreen()');
            // Display the splashscreen
            trace(this.stage);
            this.modelSplashScreen.drawScreen(this.stage);
    
            // Set the username for the welcome message
            this.modelSplashScreen.GET_USER_NAME(this.auth.getUserName());
    
            // Will draw appropriate screen for
            // Players and audience.
            this.modelDrawing.drawScreen(this.stage);
            
            if (this.auth.getCanAct()){
                trace("can act...");
                this.modelChat.drawScreen(this.stage);
                this.modelInfo.drawScreen(this.stage);
            }
            else {
                //Display Audience View player/audience count - Vishaal 15/10/09
                 this.modelInfo.drawScreenAudience(this.stage);
                
                if (volunteer) {
                    // LK added 24/9/07`
                    this.modelChat.drawScreen(this.stage);
                    this.modelAvatars.setDrawMode(false);
                    this.modelAvatars.setAudioMode(false);
                    trace('transport has redrawscreen');
                }
                
                else {
                    this.modelChat.drawScreenAudience(this.stage);
                }
                
            }
            this.modelChat.focus();
            this.startPlay();
            trace('transport.drawScreen() done.');
        }
        
        /**
         * LK added 31/10/07
         * @brief Shows volunteer view
         */
        function VolunteerBtnClicked() : void
        {
            trace('Volunteer button clicked');
            volunteer = true;
            this.drawScreen();
        }
    
    
        //-------------------------------------------------------------------------
        /**
         *  @brief Handle when server/auth dies...
         */
        function displayConnectionLost(str:String)
        {
            this.modelChat.displayConnectionLost(str);
        }
    
    
        /**
         * LK added 24/9/07
         * @brief Testing volunteer av
         */
        function VOLUNTEER() :void

        {
            this.modelChat.DISP_VOLUNTEER_BTN();
        }
        
        function VOL_LET_GO()
        {
            volunteer = false;
            this.drawScreen();
        }
        
        /**
         * LK added 30/10/07
         * @brief Hide volunteer button
         */
        function NO_VOLUNTEER() :void

        {
            this.modelChat.HIDE_VOLUNTEER_BTN();
        }
    
        static function isVolunteer():Boolean
        {
            return volunteer;
        }
        
        /**
         * LK added 17/10/07
         * @brief Display applause button
         */
        function APPLAUSE(x :Object) :void

        {
            this.modelChat.DISP_APPLA();
        }
        
        /**
         * LK added 29/10/07
         * @brief Hide applause button
         */
        function NO_APPLAUSE(x :Object) :void

        {
            this.modelChat.HIDE_APPLA();
        }
    
        /**
         * @brief An avatars speech - writes to ChatField and makes a speech bubble
         */
        private function TEXT(x :Object) :void

        {
            var avID :Number = x.ID;
    
            // Modified by Endre to account for htmlText, and to delimit the 
            // actor name from the message when parsing text (primarily for
            // when the url is the only/first string in the text
            var logtext: String = '&lt;' + x.name + '&gt; ' + x.text;
    
            // Send text to chat field
            this.modelChat.GET_TEXT(x.name, x.text);
    
            // Send text to avatar speech bubble
            this.modelAvatars.GET_TEXT(avID, x.text);
        }
    
    
        /**
         * @brief A non avatars speech (usually audience) - writes to ChatField
         */
        private function ANONTEXT(x :Object) :void

        {
            this.modelChat.GET_ANONSPEAK(x.text);
        }
    
        private function THINK(x :Object):void

        {
            var avID:Number = x.ID;
            var thought:String = x.thought;
            var name:String = this.modelAvatars.avatars[avID].name;
            
            this.modelChat.GET_THOUGHT(name, thought);
            this.modelAvatars.GET_THOUGHT(avID, thought);
        }
        
        /**
         *  Shout Feature
         * Wendy, Candy and Aaron 
         * 30/10/08
         */
        private function SHOUT(x :Object):void

        {
            var avID:Number = x.ID;
            var shout:String = x.shout;
            var name:String = this.modelAvatars.avatars[avID].name;
            
            this.modelChat.GET_SHOUT(name, shout);
            this.modelAvatars.GET_SHOUT(avID, shout);
        }
    
    
    
        /**
         * @brief Call back to server for mp3, over http
         * arguably should attach the sound to correct avatar.
         */
        private function WAVE(x :Object) :void

        {
            this.modelSounds.playSound(x.url);
        }
    
    
        /**
         * @brief Call back to server for mp3 music, over http
         */
        private function MUSIC(x :Object) :void

        {
            // Music NOT IMPLEMENTED on server side
            trace("!MUSIC! url = " + x.url);
            this.modelSounds.loadMusic(x.url);
        }
    
        private function EFFECT(x :Object) :void

        {
            // Effects NOT IMPLEMENTED on server side
            this.modelSounds.loadEffect(x.url);    
        }
        
        private function PLAY_CLIP(x :Object): void
        {
            this.modelSounds.remotePlayClip(x.array, x.url, 0);
        }
        
        private function PAUSE_CLIP(x :Object): void
        {
            this.modelSounds.remotePauseClip(x.array, x.url);
        }
        
        private function LOOP_CLIP(x :Object): void
        {
            this.modelSounds.remoteLoopClip(x.array, x.url);
        }
        
        // PQ & LK: Added 31.10.07 - Play the applause sound
        private function APPLAUSE_PLAY(x :Object): void
        {
            this.modelSounds.playApplause(x.url);    
        }
    
        //EB 22/10/07 - to handle broadcast volume messages
        private function VOLUME(x :Object): void
        {
            var type:String = x.type;
            var url:String = x.url;
            var volume:Number = Number(x.volume);
            
            this.modelSounds.remoteVolumeControl(type, url, volume);
        }
        
        // PQ: 29.10.07 - To handle broadcast stop audio messages
        private function STOPAUDIO(x :Object): void
        {
            var type:String = x.type;
            var url:String = x.url;
            
            trace("STOPAUDIO MESSAGE RECIEVED!!!");
            
            this.modelSounds.remoteStopAudio(type, url);
        }
        
        
        // AC: 29.05.08 - Clear Audio Slot
        private function CLEAR_AUDIOSLOT(x: Object): void
        {
            var type: String = x.type;
            var url: String = x.url;
            this.modelSounds.clearSlot(type, url);    
        }    
            
        /**
         * @brief Called by server when client tries to login to same stage twice
         */
        private function ERR_DOUBLE_LOGIN(x :Object) :void

        {
            // Can't close the transport (will kill both client windows)
    
            // Tell the client all about it
            this.modelSplashScreen.GET_ERR_DOUBLE_LOGIN(x.msg);
        }
    
    
        /**
         * @brief Writes to ChatField in different color with 'Quoth server' message
         */
        private function ERR(x :Object) :void

        {
            // Show error in chat field
            this.modelChat.GET_ERR(x.error);
        }
    
    
        /**
         * @brief Same as per ERR writes to ChatField in a different color
         */
        private function MSG(x :Object) :void

        {
            this.modelChat.GET_MSG(x.message);
        }
    
        /**
         * @brief Tell the client to load messages alread typed in the ChatField
         * before they joined
         */
        private function LOAD_CHAT (x :Object) :void

        {
            this.modelChat.GET_LOAD_CHAT(x.chat);
        }
    
    
        /**
         * @brief Tell the client to load a new Avatar
         */
        private function LOAD_AV (x :Object) :void
        {
        	trace(x.medium);
            var ID :Number = Number(x.ID);
            var allowed :Boolean = (x.allowed == 'True');
            var available :Boolean = (x.available == 'True');
            this.modelAvatars.GET_LOAD_AV(ID, x.name, x.url, x.thumbnail, allowed,
                                          available, x.medium, x.frame);
        }
    
    
        /**
         * @brief Tell the client to load a new Backdrop
         */
        private function LOAD_BACKDROP (x :Object) :void
        {
            var ID : Number = x.ID;
            var show:Boolean = (x.show == 'True');
            this.modelBackDropItems.GET_LOAD_BACKDROP(ID, x.name, x.url, x.thumbnail,
                                                      x.medium, show, x.frame);
        }
    
    
        /**
         * @brief Tell the client to select a backdrop
         */
        private function SHOW_BACKDROP (x :Object) :void

        {
            var ID : Number = x.ID;
            this.modelBackDropItems.GET_SHOW_BACKDROP(ID);
        }
    
    
        /**
         * @brief Tell the client to load a new Prop
         */
        private function LOAD_PROP (x :Object) :void

        {
            var ID : Number = x.ID;
            var show :Boolean = (x.show == 'True');
            this.modelAvatars.GET_LOADPROP(ID, x.name, x.url, x.thumbnail, x.medium, show);
        }
        
        /**
         * Shaun Narayan (01/28/10)- Updated method to allow 
         * running music to play for new players.
         * 
         */
        private function LOAD_AUDIO (x :Object) :void
        {
            trace("Loading audio");
            if(x != null) {
                var ID : Number = x.ID;
                var name : String = x.name;
                var url :String = x.url;
                var type : String = x.type;
                var position : Number = x.position;
                
                trace("loaded audio - ID: " +ID +" Name: "+name+" URL: "+url+" Type: "+type+" Position: "+position);  
                
                if(position > 0)
                { 
                    var newURL :String = "/media/audio/"+url;
                    this.modelSounds.GET_LOAD_AUDIO(ID, name, url, type);
                    this.modelSounds.addWait(newURL,position);
                }
                else
                {
                    this.modelSounds.GET_LOAD_AUDIO(ID, name, url, type);
                }    
            }
            else{
                trace("LOAD_AUDIO transport.as line 639 is null")
            }         
        }
    
    
        /**
         * @brief Server is saying how much of each kind of thing needs loading
         */
        private function SPLASH_DETAILS(x :Object) :void

        {
            this.modelSplashScreen.GET_SPLASH_DETAILS(x.avatars, x.props, x.backdrops, x.msg);
        }
    
    
        /**
         * @brief A client put down the avatar they were holding
         */
        private function AV_DISCONNECT (x :Object) :void

        {
            var avID :Number = x.ID;
            this.modelAvatars.GET_AV_DISCONNECT(avID, x.client);
        }
    
    
        /**
         * @brief A client picked up an avatar
         */
        private function AV_CONNECT (x :Object) :void

        {
            var avID : Number = x.ID;
            this.modelAvatars.GET_AV_CONNECT(avID, x.client);
        }
    
    
        /**
         * @brief A client moved an avatar to a new position (fast button)
         * Or a client joined late and the avatar is already on screen
         */
        private function AV_POS (x :Object) :void

        {
            var avID :Number = x.ID;
            var avX  :Number = x.X;
            var avY  :Number = x.Y;
            var avZ  :Number = x.Z;
            this.modelAvatars.GET_AV_POS(avID, avX, avY, avZ);
        }
    
    
        /**
         *  @brief A client walked an avatar toward a point (slow button)
         */
        private function AV_MOVETOWARD (x :Object) :void

        {
            var avID       :Number = x.ID;
            var avX        :Number = x.X;
            var avY        :Number = x.Y;
            var avDuration :Number = x.duration;
            this.modelAvatars.GET_AV_MOVETOWARD(avID, avX, avY, avDuration);
        }
    
    
        /**
         * @brief Server requested that all avatars return to the scrollbar
         */
        private function PUT_AWAY(x :Object) :void

        {
            var avID :Number = x.ID;
            this.modelAvatars.GET_PUT_AWAY(avID);
        }
    
    
        /**
         * @brief An avatar picked up a prop
         */
        private function BINDPROP (x :Object) :void

        {
            var avID   :Number = x.ID;
            var propID :Number = x.prop;
            this.modelAvatars.GET_BINDPROP(avID, propID);
        }
        
        /**
         * @brief An avatar moved layer, get the model to update their display
         * @author Endre
         */
         private function AVLAYER(x : Object) :void

         {
             var avID:Number = x.ID;
             var layer:Number = x.newLayer;
             this.modelAvatars.GET_AVLAYER(avID, layer);
         }
    
    
        /**
         * @brief A client renamed an avatar (for duration of performance)
         * Changes are lost after stage reset
         */
        private function RENAME (x :Object) :void

        {
            var avID : Number = x.ID;
            var name :String = x.name;
            this.modelAvatars.GET_AV_RENAME(avID, name);
        }
    
    
        /**
         * @brief An avatars properties were changed (currenly only name visibility)
         * Maybe more later
         */
        private function AVPROPERTIES (x :Object) :void

        {
            var avID :Number = x.ID;
            var showName :Boolean = (x.showName=='show' ? true : false);
            this.modelAvatars.GET_AVPROPERTIES(avID, showName);
        }
    
    
        /**
         * @brief A player pressed the reset button
         * Server has cleaned out it variables and wants this client to reload
         */
        private function RELOAD (x :Object) :void

        {
            // Terminate the connection to the server
            this.close();
            // BH 29-Aug-2006 Safe reload now in Construct
            // Reload the stage
            Construct.reloadStage();
        }
    
    
        /**
         * @brief Server is confirming players identity
         */
        private function SET(x :Object) :void

        {
            // Pass user information to various models
            // Should have really called these functions GET_XXX
            trace("setting player " + auth.getUserName());
            this.modelChat.setPlayer(auth.getUserName());
            trace("setting avatar user id " + x.ID);
            this.modelAvatars.setUserID(x.ID);
        }
    
    
        /**
         * @brief A player or an auidence member joined the current stage
         */
        private function JOINED(x :Object) :void

        {
            var pCount :Number = x.pCount;
            var aCount :Number = x.aCount;
            this.modelInfo.GET_JOINED(aCount, pCount);
        }
    
    
        /**
         * @brief The server is telling the client what the long (human readable name)
         * for the current stage is
         */
        // XXX should ber STAGE_INIT, also telling client how many avatars, etc to expect.
        private function STAGE_NAME(x: Object) :void

        {
            Construct.stageUrl = ('/stages/' + x.stageID);
            this.modelSplashScreen.GET_STAGE_NAME(x.stageName);
        }
        
        private function CHAT_COLOUR(x: Object) :void

        {
            this.modelChat.SET_CHAT_PANE_COLOUR(x.bgcolour);
            if (this.auth.getCanAct())
            {
                this.modelChat.drawScreen(this.stage);
            }
            else 
            {
                this.modelChat.drawScreenAudience(this.stage);
            }
        }
        private function TOOLS_COLOUR(x: Object) :void

        {
            if (this.auth.getCanAct())
            {
                this.modelAvatars.SET_BG_COLOR(x.bgcolour);
                this.modelAvatars.drawScreen(this.stage);
            }
        }
        private function PAGE_COLOUR(x: Object) :void

        {
            stage.graphics.beginFill (x.bgcolour, 100);
            stage.graphics.drawRect(0, 0, stage.width, stage.height);
            stage.graphics.endFill(); 
        }
        
        /**
         * @brief The server is telling the client what the background Colour of the 
         * Props and Background toolbar will be
         */
         // AB: 2.08.08 - Set Props and Background toolbar Color
        private function BACKDROPANDPROP_COLOUR(x: Object) :void

        {
            //Set the Avatar and Backdrop BG Color
            this.modelAvatars.SET_PROP_PANE_COLOR(x.bgcolour)
            this.modelBackDropItems.SET_BACKDROP_PANE_COLOR(x.bgcolour)
            
            //Draw the Rectangles on stage If user is Actor
            this.modelAvatars.drawScreen(this.stage);
            this.modelBackDropItems.drawScreen(this.stage);
            trace("CAN ACT = " + this.auth.getCanAct() + "-" + this.auth.getUserName());
            if (this.auth.getCanAct()){
                //If they Are actors - Do not hide Prop or backdrop Panes
            }
            else {
                this.modelBackDropItems.hide();
                this.modelAvatars.hidePropScrollButtons(true);
                this.modelBackDropItems.hideBackDropScrollButtons(true);
                
                if (volunteer) {
                    this.modelChat.drawScreen(this.stage);
                    this.modelAvatars.setDrawMode(false);
                    this.modelAvatars.setAudioMode(false);
                    trace('transport has redrawscreen');
                }
                else {
                    this.modelAvatars.hide();
                    this.modelBackDropItems.hide();
                    }
                }
           }
    
    
        /**
         * @brief A player send a whisper message to this player
         */
        private function WHISPER(x :Object) :void

        {
            this.modelChat.GET_WHISPER(x.senderID, x.text);
        }
    
        /**
         * @brief A player selects a freame for avatar
         */
        private function FRAME(x :Object): void
        {
            var avID :Number = x.avID;
            var frameNumber :Number = x.frameNumber;
    
            trace('I got it on transport' + avID + "/" + frameNumber);
            this.modelAvatars.GET_FRAME(avID, frameNumber);
        }
        
        // Aaron
        /*
         * @brief Change the backdrop frame
         */
        private function BACKDROP_FRAME(x :Object): void
        {
            var frameNumber :Number = x.frameNumber;
            this.modelBackDropItems.SET_BACKDROP_FRAME(frameNumber);
            
        }
    
        /**
         * @brief Called by the server when it recevies a LOADED from the client
         */
        private function CONFIRM_LOADED(x:Object)
        {
            this.modelAvatars.GET_CONFIRM_LOADED();
            this.modelSplashScreen.GET_CONFIRM_LOADED();
            this.modelChat.GET_CONFIRM_LOADED();
            this.modelSounds.confirmReady();
            trace('Server Confirmed ready');
        }
    
    
        /**-------------drawing tools ----------------**/
    
        function DRAW_LINE(msg:Object){
            this.modelDrawing.GET_DRAW_LINE(Number(msg.layer),
                                            Number(msg.x),
                                            Number(msg.y));
        }
    
        function DRAW_MOVE(msg:Object){
            this.modelDrawing.GET_DRAW_MOVE(Number(msg.layer),
                                            Number(msg.x),
                                            Number(msg.y));
            
        }
    
        
        function DRAW_STYLE(msg:Object){
            this.modelDrawing.GET_DRAW_STYLE(Number(msg.layer),
                                             Number(msg.thickness),
                                             Number(msg.colour),
                                             Number(msg.alpha)
                                             );
        }
    
        /* set the style of the users tools unused*/
        function DRAW_TOOLS(msg:Object){
            this.modelAvatars.GET_DRAW_TOOLS(Number(msg.colour),
                                             Number(msg.alpha),
                                             Number(msg.thickness)
                                             );
        } 
    
    
        function DRAW_VIS(msg:Object){
            this.modelDrawing.GET_DRAW_VIS(Number(msg.layer),
                                           msg.visible == 'True',
                                           Number(msg.alpha));
    
            //so DrawTools can show proper visibility in controls
            this.modelAvatars.GET_DRAW_VIS(Number(msg.layer),
                                           msg.visible == 'True',
                                           Number(msg.alpha));
        }
    
        function DRAW_CLEAR(msg:Object){
            this.modelDrawing.GET_DRAW_CLEAR(Number(msg.layer));
        }
    
        function DRAW_LAYER_STATE(msg:Object){
            var i:Number;    
            var layers: Array = [];
                for (i = 0; i < Client.DRAWING_LAYERS_N; i++){
                    var ID:String = msg['L' + i];
                    if (ID){
                    if (ID == this.auth.getUserName())           
                        layers.push(2);
                    else
                        layers.push(1);
                    }
                    else
                    layers.push(0);
                }    
            this.modelAvatars.GET_DRAW_LAYER_STATE(layers);
        }
    
 		/*------------- Moveable Drawing Functions --------------*/
 		
 		/**
 		 * @brief: Send the id from the server to the drawing
 		 * Modified by: Natasha
 		 */
 		function SET_DRAW_ID(msg:Object)
 		{
 			this.modelAvatars.CREATE_MOVEABLE_DRAWING(msg.ID, msg.drawid);
 		}
 		       
        /**
         * @brief Clicks on the main stage (eventually) get passed here
         * Dispatch to as many Models as need it
         */
        function clicker(mouseX :Number, mouseY :Number) :void

        {
            this.modelAvatars.clicker(mouseX, mouseY);
            this.modelChat.focus();
        }
    
        function sendDebug(x:Object){
            this.sender.DEBUG(x);
        }
    
    }
}
}