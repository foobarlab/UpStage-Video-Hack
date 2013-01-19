package org.model {
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
    //import org.util.Construct;
    import org.Sender;
    import org.thing.Avatar;
    import org.thing.MoveableDrawing; // Natasha
    import org.thing.Prop;
    import org.view.ActorButtons;
    import org.view.AvScrollBar;
    import org.view.Bubble;
    //import org.util.Construct; - Alan (23.01.08) - Import not used warning.
    import org.view.ItemGroup;
    import org.view.DrawTools;
    //import org.view.AudioTools; // PQ: Added 22.9.07
    import org.view.AuScrollBar;
    import org.model.ModelSounds;
    import org.model.TransportInterface;
    import flash.display.*;
    import flash.text.*;
    /**
     * Author: 
     * Modified by: Phillip Quinlan, Lauren Kilduff, Endre Bernhardt
     * Modified by: Wendy, Candy and Aaron 30/10/2008
	 * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - also
     * 								functionality allowing toolbar bg color to be changed.
     * 			 Shaun Narayan (Apr 2010) - Added  methods to allow avatar names to be changed (and actually reflected on other
     * 							clients.
     * 			 Shaun Narayan (12/05/10) - Added method to allow update of all required slow/fast handlers.
     * Purpose: Handles messages that affect avatars. Stores information about Avatars.
     * Notes: 
     */
    
    /**
    
     *
     */
    
    public class ModelAvatars implements TransportInterface 
    {
        public var sender       :Sender;    // Handle to Sender
        public var stage        :MovieClip; // Handle to main stage
    
        //Prop Pane Backdrop Color //AB: added 02.08.08
        private var NumPropBackGroundColour :Number = 0xFFFFFF;
        // Views
        private var drawTools    :DrawTools;
        //public var audioTools   :AudioTools; // PQ: Added 22.9.07
        public var audioScrollBar   :AuScrollBar; // PQ: Added 22.9.07
        private var actorButtons :ActorButtons;
        private var avScrollBar  :AvScrollBar;
        private var propIcons    :ItemGroup;
        private var modelsounds  :ModelSounds;
    
        // Internal variables
        public var avatar    :Avatar;
        public var avatars    :Array;
        public var userID    :String;
        private var moveFast  :Boolean;
    	
        private var drawing   :Boolean;
        private var moveableOn :Boolean; // Natasha & Thomas - Whether to create a moveable drawing
        private var bAudioing  :Boolean; // PQ: Added
        
        private var toolsBgColor :Number = 0xFFFFFF;//Shaun narayan (would rather have added a parameter to draw but for consistency will do this way).
        /**
         * @brief Constructor
         */
        public function ModelAvatars(sender :Sender, stage :MovieClip, modelSounds:ModelSounds)
        {
            trace('ModelAvatars constructor');
            trace(modelSounds);
            this.sender = sender;
            this.stage = stage;
            this.avatar = null;
            this.avatars = new Array();
            this.moveFast = false;
            this.modelsounds = modelSounds;
        };
    	/**
    	 * Interface to moveFast    	 */
    	public function setMoveFast(fast:Boolean)
    	{
    		this.moveFast = fast;
    		this.actorButtons.updateMoveSpeed(this.moveFast);
    		this.avatar.updateMoveSpeed(this.moveFast);
    	}
    	public function isMoveFast() : Boolean
        {
        	return this.moveFast;
        }
        /**
         * @brief Draw all client MovieClips
         */
        public function drawScreen(stage :MovieClip) :void
        {
            trace('ModelAvatar.drawScreen');
            this.propIcons = ItemGroup.create(stage, "propIcons",
                                              Client.L_PROP_FRAME, 
                                              Client.PROP_BOX_X, Client.PROP_BOX_Y, NumPropBackGroundColour, this);
            for(var i:Number = 0; i < stage.numChildren; i++)
            {
            	trace(stage.getChildAt(i).name);
            }
            this.actorButtons = ActorButtons.create(stage, 'actorButtons',
                                                    Client.L_BUTTONS_FRAME, 
                                                    Client.RIGHT_BOUND, Client.AV_UI_BUTTON_Y, this, toolsBgColor);
    
            this.drawTools = DrawTools.create(stage, 'drawTools',
                                              Client.L_DRAW_TOOLS, 
                                              Client.RIGHT_BOUND, Client.CONTROL_Y, this, toolsBgColor);
    
            this.audioScrollBar = AuScrollBar.create(stage, 'audioScrollBar',
                                                     Client.L_AUDIO_TOOLS, Client.RIGHT_BOUND, 
                                                     Client.CONTROL_Y, this, this.modelsounds, toolsBgColor);
    
            // AC (24/04/08) - Sets up the list of available audio files from the audio tools
            this.modelsounds.setAudioScrollbar(this.audioScrollBar);
            
            this.avScrollBar = AvScrollBar.create(stage, 'avScrollBar',
                                                  Client.L_SCROLL_FRAME, Client.RIGHT_BOUND, 
                                                  Client.CONTROL_Y, this, toolsBgColor);
            //this.setDrawMode(false);
            //this.setAudioMode(false); //PQ: Added 22.9.07
            
            /* 
            AC (24/04/08) - For inital stage loading as the 
            setDrawMode(false) and setAudioMode(false) caused 
            issues with the display of prop and backdrop scroll buttons.
            */
            this.setInitialState();
        };
        public function getPropIcons() :ItemGroup
        {
        	return propIcons;
        }
        /**
         * @brief Hide the view
         */
        public function hide()
        {
            this.actorButtons.visible = false;
            this.avScrollBar.visible = false;
            this.propIcons.visible = false;
            this.propIcons.left.visible = false; // AC added 23/04/08
            this.propIcons.right.visible = false; // AC added 23/04/08
            this.drawTools.visible = false;
            this.audioScrollBar.visible = false; //PQ: Added 23.9.07
        }
        
        /**
         * LK added 15/10/07
         * @brief Hide the Prop Scroll Bars
         */
        public function hidePropScrollButtons(hide:Boolean)
        {
            this.propIcons.hideScrollButtons(hide); 
        }
        
        public function show()
        {
            this.actorButtons.visible = true;
            this.avScrollBar.visible = true;
            this.propIcons.visible = true;
            this.drawTools.visible = true;
            
            // AC (23/04/08) - Added to display scrollbuttons if were already displayed.
            this.propIcons.left.visible = (this.propIcons.canDisplayButtons); // LK added 10/10/07
            this.propIcons.right.visible = (this.propIcons.canDisplayButtons); // LK added 10/10/07
       
            this.audioScrollBar.visible = false; //PQ: Added 23.9.07
        }
    
    /**
     * @brief: Set the drawing mode
     * Modified by: Natasha & Thomas     */
    	public function setMoveableDrawingMode()
    	{
    		if(moveableOn)
    		{
    			moveableOn = false;
    		}
    		else
    		{
    			moveableOn = true;
    		}
    	}
        // AC: Added 17/04/08
        public function setVolunteerMode(volunteer:Boolean){
            // Show only what is needed to use volunteer avatars.    
        }
        
        // AC (24/04/08) - For initial stage loading.
        public function setInitialState(){
            this.drawTools.visible = false;
            this.drawing = false;
            this.drawTools.setListenMode(false);
            this.actorButtons.visible = true;
            this.avScrollBar.visible = true;
            this.propIcons.visible = true;
            this.audioScrollBar.visible = false;
            this.bAudioing = false;
            this.moveableOn = false;
        }
    
        public function setDrawMode(draw:Boolean){
            trace('Toggled draw widget');
            this.moveableOn = false; // Natasha
            this.drawTools.visible = draw;
            this.drawing = draw;
            this.drawTools.setListenMode(draw);
            this.actorButtons.visible = ! draw;
            this.avScrollBar.visible = ! draw;
            this.propIcons.visible = ! draw;
            
            if (this.propIcons.canDisplayButtons) {
                this.propIcons.left.visible = ! draw; // AC added 24/04/08
                this.propIcons.right.visible = ! draw; // AC added 24/04/08
            }
    
        }
        
        // PQ: Added 22.9.07
        public function setAudioMode(bInAudioMode:Boolean){
            trace('Toggled audio widget');
            this.audioScrollBar.visible = bInAudioMode;
            this.bAudioing = bInAudioMode;
            this.actorButtons.visible = ! bInAudioMode;
            this.avScrollBar.visible = ! bInAudioMode;
            this.propIcons.visible = ! bInAudioMode;
            
            if (this.propIcons.canDisplayButtons) {
                this.propIcons.left.visible = ! bInAudioMode; // AC added 24/04/08
                this.propIcons.right.visible = ! bInAudioMode; // AC added 24/04/08
            }
            
            /*if ((bInAudioMode) && (this.propIcons.canDisplayButtons)) {
                this.propIcons.left._visible = false; // LK added 10/10/07
                this.propIcons.right._visible = false; // LK added 10/10/07
            }
            else if ((bInAudioMode == false) && (this.propIcons.canDisplayButtons)) {
                this.propIcons.left._visible = true; // LK added 10/10/07
                this.propIcons.right._visible = true; // LK added 10/10/07
            }*/
        }
    
    
        //-------------------------------------------------------------------------
        // Messages sent from Views to server
    	/**
    	 * Shaun Narayan (27/04/10) - Following two methods Allow avatars to be renamed.    	 */
        public function toggleRename()
        {
        	if(this.avatar.txtField.visible)
        	{
        		this.avatar.txtField.visible = false;
        		this.avatar.inputField.visible = true;
        	}
        	else
        	{
        		SET_AV_RENAME(this.avatar.inputField.text);
        		this.avatar.txtField.visible = true;
        		this.avatar.inputField.visible = false;
        	}
        	
        }
    	public function SET_AV_RENAME(name:String)
    	{
    		this.sender.RENAME(name);
    	}
        //-------------------------------------------------------------------------
        // Messages from ActorButtons
        /**
         * @brief View asked to change current avatar name visibility
         */
        public function SET_SWITCH_AV_NAME() :void

        {
            // Toggle name visibility on current avatar ID
            var av: Avatar = this.avatar;
            if (av)
                {
                    this.sender.AVPROPERTIES(av.ID, ! av.getShowName());
                }
        };

		/**
		 * @brief: Get a moveable drawing id from the server
		 * Natasha & Thomas		 */
		 public function CREATE_DRAWING_ID() :void
		 {
		 	if(this.avatar != null)
		 	{
		 		this.sender.CREATE_DRAWING_ID(this.avatar.ID);
		 	}
		 }
		 
		 
        /**
         * @brief View asked to move the avatar up a layer
         */
        public function MOVE_LAYER_UP() :void

        {
            var av: Avatar = this.avatar;
            if (av)
            {
                    var thisLayer:Number = av.baseLayer;
                    var otherAv:Avatar = null;
                    var nextLayer:Number = undefined;
                    for (var i:String in this.avatars) {
                        var tempAv:Avatar = this.avatars[i];
                        
                        if ((tempAv.baseLayer > thisLayer) && ((tempAv.baseLayer < nextLayer) || (nextLayer == undefined))) {
                            otherAv = tempAv;
                            nextLayer = tempAv.baseLayer;
                        }
                    }
                    
                    if (nextLayer != undefined) {
                        av.move_to_layer(nextLayer);
                        this.sender.NB('move_layer_up layer:'+nextLayer);
                        this.sender.AVLAYER(av.ID, nextLayer);
        
                        if (otherAv != null) {
                            otherAv.move_to_layer(thisLayer);
        
                            var avMC:MovieClip = av.image;
                            var otherMC:MovieClip = otherAv.image;
                            avMC.swapDepths(otherMC);
                        }
                    }
                    //  SHOULD SWAP MC TO NEW DEPTH EVEN IF THERE IS NO OTHERAV ?
            }
        }
        
        /**
         * @brief View asked to move the avatar down a layer
         */
        public function MOVE_LAYER_DOWN() :void

        {
            var av: Avatar = this.avatar;
            if (av)
            {
                
            var thisLayer:Number = av.baseLayer;
                var otherAv:Avatar = null;
                var previousLayer:Number = undefined;
                for (var i:String in this.avatars) {
                    var tempAv:Avatar = this.avatars[i];
                    
                    if ((tempAv.baseLayer < thisLayer) && ((tempAv.baseLayer > previousLayer) || (previousLayer == undefined))) {
                        otherAv = tempAv;
                        previousLayer = tempAv.baseLayer;
                    }
                }
                
                if (previousLayer != undefined) {
                    av.move_to_layer(previousLayer);
                    this.sender.NB('move_layer_down layer:'+previousLayer);
                    this.sender.AVLAYER(av.ID, previousLayer);
    
                    if (otherAv != null) {
                        otherAv.move_to_layer(thisLayer);
    
                        var avMC:MovieClip = av.image;
                        var otherMC:MovieClip = otherAv.image;
                        avMC.swapDepths(otherMC);
                    }
                }
            }
        }
    
        /**
         * @brief View asked all avatars to leave the stage
         */
        public function SET_EXIT_ALL() :void

        {
            //XXXXXXXXX needs looking at -- a lot of traffic for a simple thing..
            // Call exit on every avatar on this stage
            // Note server tracks avatars held by others & doesn't exit them
            // BH 29-Aug-2006 Don't drop avatar of person who pressed clear
            var x: Object;
            var ID: Number = (this.avatar) ? this.avatar.ID : undefined;
            // Don't clear held avatar
            var i:Number;
            for (i = 0; i < this.avatars.length; i++)
                {
                    if (i != ID)//but why? if the server is tracking?
                        {
                            this.sender.EXIT(i);
                        }
                }
            
        };
    
    
    
        /**
         * @brief View wants current avatar to stop moving
         */
        public function SET_STOP() :void

        {
    
            // Stop on this players PC -- cosmetic only, and probably bad
            // you really want to see what others see.
            //this.avatar.stopWalk(); 
    		if(this.avatar ==null) return;
            // send out stop message
            var av   :Avatar = this.avatar;
            // Offset x / y by half image width / height
            var x    :Number = av.x + av.centreX;
            var y    :Number = av.y + av.centreY;
    
            this.sender.MOVE(x, y);
        };
    
    
        /**
         * @brief View asked to drop the current avatar
         */
        public function SET_EXIT() :void

        {
            if (this.avatar)
                this.sender.EXIT(this.avatar.ID);
        };
    
    
        //------------------------------------------------------------------------
        // Messages sent to the server by PropItems
        /**
         * @brief View telling server that the current avatar picked up a prop
         */
        public function SET_PROP(propID: Number) :void

        {
            if (this.avatar && this.avatar.isOnStage())
                {
                    //XXX can give instant feedback
                    //var prop :Prop = Prop(propIcons.getItemByID(propID));
                    //this.avatar.holdProp(prop);
    
                    // Tell other clients about prop bind
                    this.sender.PROP(propID);
                }
        }
        
    
    
        //-------------------------------------------------------------------------
        // Messages sent to the server by AvScrollBar
    
        /**
         * @brief View asked to pick up an avatar
         */
        public function SET_AV(avID :Number) :void

        {
            this.sender.AV(avID);
        }
    
        /**
         * @brief View asked to move an avatar
         */
        public function SET_MOVE(mouseX :Number, mouseY :Number)
        {
            var av: Avatar = this.avatar;
            if (av && mouseX < Client.RIGHT_BOUND  &&
                mouseY < Client.BOTTOM_BOUND)
                {
                    // Tell the server we want to move
                    if (this.moveFast || ! av.isOnStage())
                        {
                            this.sender.MOVE(mouseX, mouseY);
                        }
                    else
                        {
                            this.sender.MOVETOWARD(mouseX, mouseY);
                        }
                }
        }
        /** Drawing functions */
    
        public function SET_DRAW_LINE(x:Number, y:Number)
        {
            this.sender.DRAW_LINE(x, y);
        }
    
        public function SET_DRAW_MOVE(x:Number, y:Number)
        {
            this.sender.DRAW_MOVE(x, y);
        }
    
        public function SET_DRAW_STYLE(thickness:Number, colour:Number, alpha:Number, layer:Number)
        {
            this.sender.DRAW_STYLE(thickness, colour, alpha);
        }
    
        public function SET_DRAW_VIS(layer:Number, alpha:Number, visible:Boolean)
        {
            trace("SET_DRAW_VIS got " + layer + " alpha "+ alpha + " visible " + visible);
                    
            this.sender.DRAW_VIS(layer, alpha, visible);
        }
    
        public function SET_DRAW_CLEAR(layer:Number)
        {
            this.sender.DRAW_CLEAR(layer);
        }
    
        public function SET_DRAW_LAYER(layer:Number)
        {
            this.sender.DRAW_LAYER(layer);
            /* send the draw style. due to bad separation this is a bit
               hacky Another way would be to actually adopt the settings
               of the new layer, and set the tools accordingly */
            //this.drawTools.lastColour = 0;
            //this.drawTools.perhapsSetStyle();
        }
        
        public function GET_DRAW_TOOLS(colour:Number, alpha:Number, size:Number)
        {
            this.drawTools.setDrawStyle(colour, alpha, size);
        } 
    
        public function GET_DRAW_VIS(layer:Number, visible:Boolean, alpha:Number){
            try
            {
            	this.drawTools.GET_DRAW_VIS(layer, visible, alpha);
            }
            catch(error:Error)
            {
            	trace(error);
            }
        }
    
        public function GET_DRAW_LINE(x:Number, y:Number){
            this.drawTools.clearTrace(x, y);
        }
    
        public function GET_DRAW_LAYER_STATE(layers: Array){    
        this.drawTools.layerPicker.setActiveLayers(layers);
            this.drawTools.cueStyleResend();
        }
    
        //-------------------------------------------------------------------------
        // Messages received from the server for AvScrollBar
        /**
         * @brief Server wants model to load an avatar
         */
        public function GET_LOAD_AV(ID :Number, name :String, url :String,
                             thumbnail :String, allowed :Boolean, available :Boolean,
                             medium :String, frame: Number) :void
        {
            var av :Avatar;
            av = Avatar.factory(stage, ID, name, url, thumbnail,
                                medium, this.avScrollBar, available, frame, this);
                                // Natasha - create a bubble here and pass
            var bubble :Bubble = new Bubble(av, stage);
            av.bubble = bubble;
            
            //XXX this.avatars *might* be a sparse array -- ID range is not necessarily contiguous
            trace(ID);
            this.avatars[ID] = av;
            this.avScrollBar.addAvatar(av);
        }
    
    
        /**
         * @brief Server wants model to drop or make an avatar available
         */
        public function GET_AV_DISCONNECT(avID :Number, clientID :String)
        {
            var av :Avatar = this.avatars[avID];
            trace("clientID " + clientID + "this.userID " + this.userID + "avID " + avID);
    
            // or if (av.icon == this.avScrollBar.icon) -- then can skip clientID
            if (clientID == this.userID)
                {
                    // Player asked to disconnect avatar
                    this.avScrollBar.dropAvatar();
                }
            // Another user has dropped it. make it available.
            //av.icon.enable();
        }
    
    
        /**
         * @brief Server wants view to pick up / make avatar unavailable
         */
        public function GET_AV_CONNECT(avID :Number, clientID :String)
        {
            var av :Avatar = this.avatars[avID];
            if (clientID == this.userID)
                {
                    // Player asked to select avatar
                    this.avScrollBar.select(av.myIcon);
                    this.avatar = av;
                    // make name button state match avatar name visibility
                    this.actorButtons.setNameButton(av.isNameOn());
                }
            else
                {
                    // Tell others they can't use avatar
                    //av.icon.disable();
                }
        }
    
    
        /**
         * @brief Server is telling model about a new avatar position
         */
        public function GET_AV_POS(avID :Number, x :Number, y :Number, z:Number)
        {
            var av :Avatar = this.avatars[avID];
    
            // Make sure avaiable is set correctly for people who arrive late...
            av.setPosition(x, y, z);
            av.avatarMenu.x = av.bubble.x;//av.bubble.mc.x;
            av.avatarMenu.y = av.bubble.y;//av.bubble.mc.y;
        }
        
        /**
         * @brief Get the avatar specified and move them to the new layer.
         *        This is called after an incoming broadcast message from the server.
         * @author Endre
         */
        public function GET_AVLAYER(avID: Number, newLayer:Number)
        {
            var av:Avatar = this.avatars[avID];
     
            var thisLayer:Number = av.baseLayer;
            //av.move_to_layer(newLayer);
    
            var otherAv:Avatar;
            for (var i:String in this.avatars) {
                var tempAv:Avatar = this.avatars[i];
                
                if (tempAv.baseLayer == newLayer) {
                    otherAv = tempAv;    
                }
            }
    
            av.move_to_layer(newLayer);
            
            if (otherAv != null) {
                otherAv.move_to_layer(thisLayer);
                
                var avMC:MovieClip = av.image._parent;
                var otherMC:MovieClip = otherAv.image._parent;
                avMC.swapDepths(otherMC);
            }
            
        }
    
    
        /**
         * @brief Server is telling model about new avatar properties
         */
        public function GET_AVPROPERTIES(avID :Number, showName :Boolean)
        {
            var av :Avatar = this.avatars[avID];
            av.setShowName(showName);
        }
    
    
        /**
         * @brief Server is telling model that an avatar is moving toward a position
         */
        public function GET_AV_MOVETOWARD(avID :Number, x :Number, y :Number, duration :Number)
        {
            var av :Avatar = this.avatars[avID];
    
            av.movetoward(x, y, duration);
        }
    
    
        /**
         * @brief Server wants model to put away an avatar
         */
        public function GET_PUT_AWAY(avID :Number)
        {
            var av :Avatar = this.avatars[avID];
    
            // Drop the avatar if the player is holding it
            if (this.avatar == av)
                {
                    this.avScrollBar.dropAvatar();
                }
    
            av.hide();
            av.stopWalk();
        }
    
    
        /**
         * @brief Server wants model to rename an avatar (until next stage reset)
         */
        public function GET_AV_RENAME(avID :Number, name :String)
        {
            var av :Avatar = this.avatars[avID];
            av.rename(name);
    
            // Tell AvScrollBar about renames
            if (av == this.avatar)
                {
                    //this.avScrollBar.rename(av.icon, name);
                }
        }

        /**
         * @brief Server wants avatar to display a given frame
         */
        public function GET_FRAME(avID:Number, frameNumber: Number):void

        {
            trace("ModelAvatars got " + avID + "|" + frameNumber);
            var av:Avatar = this.avatars[avID];
            av.frame(frameNumber);
        }
    
    
        /**
         * @brief Server telling model that an avatar is speaking
         */
        public function GET_TEXT(avID :Number, text :String) :void

        {
            var av :Avatar = this.avatars[avID];
            av.speak(text);
        }

		 /**
		  * @brief: create a moveable drawing
		  * Modified by: Natasha		  */
		 public function CREATE_MOVEABLE_DRAWING(avID :Number, drawID :String) :void
		 {
		 	var av :Avatar = this.avatars[avID]; //drawID :String, url :String, parent :MovieClip
		 	var mdrawing :MoveableDrawing = MoveableDrawing.factory(drawID, stage);
		 	av.addMoveableDrawing(mdrawing);
		 }
		 
		     
        /**
         * @brief an avatar is thinking.
         */
        public function GET_THOUGHT(avID :Number, text :String) :void

        {
            this.avatars[avID].think(text);
        }
        
        /**
         * Shout Feature
         * Wendy, Candy and Aaron 
         * 30/10/08
         */
        public function GET_SHOUT(avID :Number, text :String) :void

        {
            this.avatars[avID].shout(text);
        }
    
    
        /**
         * @brief Server confirmed in response to client LOADED message
         */
        public function GET_CONFIRM_LOADED() :void

        {
            this.avScrollBar.setReady();
        }
    
        //-------------------------------------------------------------------------
        // Messages from the server - props
        /**
         * @brief Server wants model to load a prop
         */
        public function GET_LOADPROP(ID : Number, name :String, url :String, thumbnail :String, medium :String, show :Boolean)
        {
            this.propIcons.addItem(Prop, ID, name, url, thumbnail, medium);
            //XXX ignoring show attribute.
            // it is no use anyway - an unbound prop is hidden
        }
    
    
        /**
         * @brief Server telling model that an avatar picked up a prop
         */
        public function GET_BINDPROP(avID: Number, propID :Number):void

        {
            var av :Avatar = avatars[avID];
            var prop :Prop = Prop(propIcons.getItemByID(propID));
            trace("av is " + av + " prop is " + prop);
    
            // 25-Sep-2006 BH, FP First get any other avatar to drop the prop if held
            for (var x :Object in this.avatars){
                this.avatars[x].dropIfHeld(prop);
            }
    
            av.holdProp(prop);
        }
    
    
        //-------------------------------------------------------------------------
        // Utility functions
        /**
         * @brief Handle mouse clicks on the main stage
         */
        public function clicker(mouseX :Number, mouseY :Number) :void

        {
            if (! this.drawing)
                this.SET_MOVE(mouseX, mouseY);            
        };
    
    
        /**
         * @brief Set the current user ID
         */
        public function setUserID(userID :String) :void

        {
            if (userID)
                this.userID = userID;
        };
        
        /** AB - 02-08-08
         * @brief Set Prop Pane Background Color
         */
       public function SET_PROP_PANE_COLOR(bgColor: Number) :void

       {
               this.NumPropBackGroundColour = bgColor;
       }
        /**
         * 
         */
       public function SET_BG_COLOR(col:Number)
       {
               this.toolsBgColor = col;
       } 
    }
}
