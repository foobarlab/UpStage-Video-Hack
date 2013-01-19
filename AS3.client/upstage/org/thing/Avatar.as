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
    
    import org.Client;
    import org.thing.Thing;
    import org.thing.Prop;
    import org.view.Bubble;
    import org.view.AvScrollBarItem;
    import org.view.AvScrollBar;
    import org.view.AvMenu;
    import org.util.Construct;
    import org.util.LoadTracker;
    import org.model.ModelAvatars;
    import flash.display.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.events.*;
    import flash.external.*;
    /**
     * Author: 
     * Modified by: Endre Bernhardt, Alan Crow (AC)
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								changed constructor to instantize parent there instead of through 
     * 								factory to abide by normal AS3 standards (&fix avatar loading issues
     * 								where parent URL's could not be found).
     * 			 Shaun Narayan (Apr 2010) - Fixed numerous bugs (Icon not displaying, mirror not displaying, null pointers in
     * 			 						parent class, listner callback etc..) also added name edit text field to allow the av's name to be changed.
     * 			 Shaun Narayan (12/05/10) - Added interface to speed function (AvMenu).
     * Purpose: Class for Avatars
     * Notes: 
     *          Modified by: Heath Behrens, Vibhu Patel and Henry Goh (09-05-2011)
     *                       Made changes to setPosition and moveToward Functions.
     *          Heath Behrens (20-05-2011) Added setVisible to false for the avatar when it is dropped. So that the bubble is removed too.
     *             
     */
     
    
    public class Avatar extends Thing 
    {
        public var myIcon      :AvScrollBarItem;
        public var prop      :Prop = null;
        public var bubble   :Bubble;
        //public var parent   :MovieClip;
        
        //name text field.
        public var txtField           :TextField;
        public var inputField           :TextField;
        private var txtFieldBG         :MovieClip;
        private var txtFieldText       :String;
        private var txtFieldLayer      :Number;
        private var txtFieldName       :String;
    
    	private var moveableDrawings	:Array //Natasha & Thomas
        // Image and its loader.
        public var myImage        :MovieClip;
        private var images       :Array;
        public var baseLayer    :Number;
        public  var iconLayer    :Number;
        private var layerOffset  :Number;
        private var baseName     :String;
    
        // Variables used by moveToward() function
        private var steps     :Number = 0;
        private var dx        :Number;
        private var dy        :Number;
        private var stepping  :Number = 0;
    
        public var centreX          :Number;
        public var centreY        :Number;
        private var nameX         :Number;
        private var nameY         :Number;
        private var frameNumber      :Number;
    	public var avatarMenu			:AvMenu;
   
        /**
         * @brief factory.  This function gives you the object.
         */
      
        public static function factory(parent: MovieClip, ID :Number, name :String, url :String,
                                       thumbnail :String, medium :String,
                                       scrollBar: AvScrollBar, available:Boolean, frame: Number, ti:ModelAvatars):Avatar
        {
            trace("Avatar factory, URL is: " + url + "Name is: " + name);
            var baseLayer:Number = Client.L_AV_IMG -(-ID * Client.AV_IMG_LAYERS); 
            var baseName: String = 'avwrap_' + ID;
    
            //var thing: Thing = Thing.factory(ID, name, url, baseName, 
              //                               thumbnail, medium, baseLayer, parent, Avatar);    
            var av:Avatar = new Avatar(ID, name, url, baseName, 
                                           thumbnail, medium, baseLayer, parent, Avatar);    
            //name text field
            av.txtFieldLayer = Client.L_AV_NAME + ID;
            av.txtFieldName = 'name' + ID;
            av.layerOffset = 1;
            av.frameNumber = frame;
            //trace(['av', baseLayer, 'name', av.txtFieldLayer]);
            av.images = new Array();
            av.moveableDrawings = new Array(); //Natasha
            av.myImage = new MovieClip();
            if (scrollBar){            
                // set up myIcon
                av.iconLayer = Client.L_AV_ICON -(-ID * Client.AV_ICON_LAYERS); 
                av.myIcon = AvScrollBarItem.create(av, scrollBar, available);
            }
    
            var listener :Object = LoadTracker.getLoadListener();
            listener.onLoadComplete = function(e:Event){
				LoadTracker.loadComplete();
                av.calcSize();
                av.finalise();
                av.avatarMenu = AvMenu.create(av.myImage, 100, 100, ti);
                if(Client.AV_UI_MENU_CUSTOM)
                {
                    //Shaun Narayan (04/25/10) - One over to inverse the image scaling and maintain menu size
                	av.avatarMenu.scaleX = 1/av.myImage.scaleX; 
            		av.avatarMenu.scaleY = 1/av.myImage.scaleY;
                    /**AIR ONLY MouseEvent.RIGHT_CLICK*/
            		av.myImage.addEventListener(MouseEvent.MOUSE_DOWN, function() {av.avatarMenu.visible = !av.avatarMenu.visible});
                	av.avatarMenu.visible = false;
                }
                else
                {
                	av.avatarMenu.scaleX = 1/av.myImage.scaleX; //Shaun Narayan (04/25/10) - One over to inverse the image scaling and maintain menu size
            		av.avatarMenu.scaleY = 1/av.myImage.scaleY;
                }
            };
            av.loadImage(av.url, av.baseLayer + av.layerOffset, listener, av.myImage);
            av.images[av.layerOffset] = av.myImage;
            
            //this.avatarMenu.visible = false;
            //av.myImage = mc;
            av.addChild(av.myImage);
            return av;
        }

    	/**
         * Allows menu context to be updated from external actions.
         */
        public function updateMoveSpeed(fast:Boolean):void
        {
        	avatarMenu.updateMoveSpeed(fast);
        }

        /**
         * @brief finalise.
         * Called when the avatars are all loaded.
         */
        public override function finalise(){
            trace("finalising avatar ID " + ID + " obj " + this);
            
            //ENDRE - txtFieldBG is a white rectangle behind the textxtFieldield displaying the avatar's name
            //this.myIcon.addEventListener(MouseEvent.CLICK, function() {myIcon.selectItem(); myIcon.onPress();});
            this.myIcon.buttonMode = true;
            this.myIcon.useHandCursor = true;
            this.txtFieldBG = new MovieClip();//this.createEmptyMovieClip(this.txtFieldName+"bg", this.getNextHighestDepth());
            this.addChild(txtFieldBG);
            this.txtFieldBG.x = this.nameX;
            this.txtFieldBG.y = this.nameY+2;
            
            Construct.rectangle(this.txtFieldBG, 0, 0, Client.TF_WIDTH, 8,
                         0xFFFFFF, 0xFFFFFF, 0, 0.1);
    
            this.setUpTextField();
            //this.bubble = new Bubble(this);
            this.rename(this.myName);
            //XXX goto first frame; breaks animated avatars.
            this.frame(this.frameNumber);
            //this.txtFieldBG.visibility = false;
            super.finalise();
        }
    
        /**
         * @brief Set up the text field for an avatar
         */
        public function setUpTextField() :void

        {   
                // Create text field for movie
            var txtFieldAttrs :Object = {
                selectable: false,
                wordWrap: false,
                mouseWheelEnabled: false,  //not sure about all these.            
                type: 'dynamic'            //XXX?
            };
            var formatAttrs:Object = {};
            this.txtField = Construct.formattedTextField(this, 'nameField', 0, this.nameX, this.nameY, 
                            				Client.TF_WIDTH, Client.TF_HEIGHT,
                                         0.9, true, txtFieldAttrs, formatAttrs);
    		
            this.txtField.text = this.myName;
            inputField = new TextField();

			inputField.type = TextFieldType.INPUT;
			inputField.border = true;
			inputField.height = Client.TF_HEIGHT;
			inputField.width = Client.TF_WIDTH;
			inputField.x = this.nameX;
			inputField.y = this.nameY;
			inputField.text = this.myName;
			inputField.visible = false;
			addChild(inputField);
        }
    
    /**
     * @brief: add new moveable drawing to the array
     * Modified by: Natasha & Thomas
     */
    	public function addMoveableDrawing(mdrawing :MoveableDrawing) :void
    	{
    		moveableDrawings.push(mdrawing);
    	};
    
        /**
         * @brief calcSizes -- works out the positions of things from the size 
         * of the current myImage.
         */
    
        public function calcSize()
        {
            trace('calculating size for ' + this);
            Construct.constrainSize(this.myImage, Client.AVATAR_MAX_WIDTH, Client.AVATAR_MAX_HEIGHT);
            var im :MovieClip = this.myImage;
            this.centreX = im.width / 2;
            this.centreY = im.height / 2;
            trace("image width= "+im.width+" image height= "+im.height)
            //name is centred, on the bottom.
            this.nameX = this.centreX - (Client.TF_WIDTH * 0.5);
            this.nameY = im.height + 4;
    
            if (this.txtField != null){
                this.txtField.x = this.nameX;
                this.txtField.y = this.nameY;
            }
            //XXX need to think about bubble?
        }
    
    
        /**
         * @brief Make a speech bubble and show it
         */
        public function speak(text :String) :void

        {
            // AC - DATE - Updates the neccesary bubble values
            /* Need to assign avatars y position in bubble class. */
            this.bubble.setText(text);
            this.bubble.av_pos_x = this.x;
            this.bubble.av_pos_y = this.y - 6; //this.centreY / 0.5;
            
            this.bubble.speak(text, undefined);
            //this.addChild(this.bubble);
            ExternalInterface.call("console.log", {centrenum:this.y});
        };
    
        public function think(text :String) :void

        {
            // AC - DATE - Updates the neccesary bubble values
            this.bubble.setText(text);
            this.bubble.av_pos_y = this.y - 6;//this.centreY / 0.5;//this.y;
            
            this.bubble.think();
            ExternalInterface.call('function(){alert("Avatar: in think");}');
        };
        
         /**
         * Shout Feature
         * Wendy, Candy and Aaron 
         * 30/10/08
         */
        public function shout(text :String) :void

        {
            this.bubble.setText(text);
            this.bubble.av_pos_y = this.y - 6;//this.y;
            this.bubble.shout();
        };
        /**
         * Shaun Narayan (04/25/10) - show av menu
         */
    	public function toggleMenu()
    	{
    		this.avatarMenu.visible = !this.avatarMenu.visible;
    	}
    
        /**
         * @brief Set the position of an avatar on screen
         */
        public override function setPosition(x :Number, y :Number, z :Number) :void

        {
            this.stopWalk();  // If already moving, stop
            if (isNaN(x) || isNaN(y)){
                trace("Trying to set position to "+ x +", " + y);
            }
            //trace lies a little
           // trace("setting position to "+ x +", " + y + " from " + this.x + ", " + this.y);
            trace("centreX is"+ this.centreX +", centreY " + this.centreY);

            this.x = x;
            this.y = y;
            //Added by Vibhu/Heath
            // check to make sure that the avatar is positioned correctly when restarting
            if(this.x - this.centreX > this.centreX){
                this.x = x - this.centreX * 2;
            }
            //same check as above but for y
            if(this.y - this.centreY > this.centreY){
                this.y = y - this.centreY * 2;
            }

            this.show();
    
            // Move prop as well
            if (this.prop) {
                this.prop.setPosition(this.x, this.y, undefined);
            }
            
            // AC - Update bubbles record of avatar y position
            this.bubble.av_pos_y = this.y;
            this.bubble.y = this.y;
            ExternalInterface.call("console.log", {Y_pos_override:this.y});
                        
            // AC - DATE - Determine if the avatars bubble has gone off the top of the screen.
            if (this.bubble.isBubbleOffScreen(this.y)) 
                { this.bubble.moveBubbleBelow(); }
            else
                { this.bubble.moveBubbleAbove(); }
        }
    
        /**
         * @brief Go on a walk to the specfied position
         */
        public function movetoward(x :Number, y :Number, duration :Number) :void
        {
            //trace("x is " + x + " y is " + y + "  duration is " + duration);
            //trace('this.x= '+this.x+' this.y= '+this.y);
            var yv :Number = 0;
            var xv :Number = 0;
            this.stopWalk();

            //Conditionals to make sure the avatar stays within the stage bounds.
            if(x > this.x)
            {
                    x = x - this.centreX;
            }

            if(y > this.y){
                    y = y - this.centreY;
            }

            if(x - this.centreX < 0){
                x = this.centreX;
            }

            if(y - this.centreY < 0){
                y = this.centreY;
            }
           
            
            xv = x - this.x - this.centreX;
            yv = y - this.y - this.centreY;
            
            if (! duration) //milliseconds
                {
                    //speed of travel depends on the distance of the click,
                    //but the relationship isn't linear
                    var distance :Number = Math.sqrt((xv * xv) + (yv * yv));
                    duration = Client.AV_STEP_TIME * (distance * 0.2 + Math.sqrt(distance) * 2);
                }
    
            this.steps = (duration / Client.AV_STEP_TIME);
            this.dx = xv / this.steps;
            this.dy = yv / this.steps;
            this.stepping = setInterval(Avatar.avatarStep, Client.AV_STEP_TIME, this);
            //trace("duration: " + duration + "  steps " + steps +" dx " + dx +" dy " + dy);
        };
    
    
        /**
         * @brief Stop an avatar that may be on any previous walk
         */
        public function stopWalk() :void

        {
            trace("Stop Walking");
            clearInterval(this.stepping);
            this.steps = 0;
        };
    
    	/**
    	 * 
    	 * 
    	 */
    	 public function create_moveable_drawing(drawID :Number) :void
    	 {
    	 	
    	 }
    	 
        /**
         * @brief Rename the avatar
         */
        public function rename(name :String)
        {
            this.name = name;
            if (this.txtField != null)
                this.txtField.text = name;
                this.txtField.autoSize = TextFieldAutoSize.CENTER;
                
            if (this.myIcon != null){
                this.myIcon.nameof = name; //XXX why such duplication?
                this.myIcon.nameField.text = name;
            }
        };
    
        /**
         * @brief Move the avatar up a layer
         */
        public function move_up():Number
        {
            var offset:Number = Number(10);
            this.baseLayer = Number(this.baseLayer) + Number(offset);
            return Number(this.baseLayer);
        }
        
        /**
         * @brief Move the avatar down a layer
         */
        
        public function move_down():Number
        {
            var offset:Number = Number(10);
            this.baseLayer = Number(this.baseLayer) - Number(offset);
            return Number(this.baseLayer);
        }
    
        /**
         * @brief called when server broadcasts movement of an avatar to a new layer
         * @author Endre
         */
        public function move_to_layer(newLayer:Number)
        {
            this.baseLayer = Number(newLayer);
        }
    
        /**
         * @brief Change the frame of the avatar
         */
        public function frame(number: Number)
        {
            this.frameNumber = number;
            
            if (number == 0)
                {
                    this.myImage.play();
                }
            else {
                if (! (number > 0 &&  number <= this.myImage.totalFrames)){
                    trace('FRAMES: Number is wrong:' +  number);
                    number = 1;
                }
               // trace ('FRAMES: Setting frame: ' + number);
                this.myImage.gotoAndStop(number);
            }
        }
    
        /**
         * @brief Display/hide avatar name (could do more later)
         */
        public function setShowName(showName :Boolean)
        {
            if (this.txtField != null){
                this.txtField.visible = showName;
                this.txtFieldBG.visible = showName;    
            }    
        }
    
        /**
         * @brief get the name visibility.
         */
        public function getShowName():Boolean
        {
            if (this.txtField != null){
                return this.txtField.visible;
            }
            return false;
        }
    
    
        /**
         * @brief Hold a prop
         * (Bind a props position to the avatar position)
         */
        public function holdProp(prop :Prop) :void

        {
            // Drop existing prop
            trace("av  " + this + " .holdProp with " + prop); 
    
            this.dropProp();
            this.prop = prop;
            prop.show();
            prop.setPosition(this.x, this.y, undefined);
        };
    
        /**
         * @brief Drop prop held by this avatar
         */
        public function dropProp() :void

        {
            if (this.prop != null){
                this.prop.hide();
                this.prop = null;
            }
        };
    
    
        /**
         * @brief Drop the held prop if it is the one given in the argument
         */
        public function dropIfHeld(check :Prop) :void

        {
            if (this.prop == check){
                trace("av " + this + "is dropping the prop" + check); 
                this.dropProp();
            }
        };
    
        /**
         * @brief Hide an avatar Image and drop current prop
         */
        public override function hide() :void
        {
            trace("hiding avatar");
            super.hide();
            this.dropProp();
            //Hide the bubble as well - Heath Behrens 20-05-2011
            this.bubble.visible = false;
        };
    
    
        /**
         * @brief 
         * Makes a step, set up by moveToward. note the staticness.
         */
        public static function avatarStep(av: Avatar) :void

        {
            //trace("stepping...");
            if (av.steps > 0){
                av.x += av.dx;
                av.y += av.dy;
                av.bubble.av_pos_x = av.x;
                av.bubble.av_pos_y = av.y - 12;
                
            	av.bubble.y = av.bubble.av_pos_y; //av.y - 12;
            	av.bubble.x = av.x + 6;
                //av._rotation += 5;
                av.steps--;
                if (av.prop){
                    // Prop clings to avatar
                    av.prop.setPosition(av.x, av.y, undefined);
                }
                    
                // Check if bubble adjust is needed only if bubble is showing.
                   if (av.bubble.isVisible())
                {
                    // update bubbles record of avatar y position
                    av.bubble.av_pos_y = av.y;
                
                    /* Check if bubble adjust is necessary upon each avatar step and 
                     * adjust only once when needed so as to not continue to 'repaint' 
                     * the bubble on each step. */
                    if ((av.bubble.isBubbleOffScreen(av.y)) && (av.bubble.location == 'Above'))
                        { av.bubble.moveBubbleBelow(); }
                        
                    // Is moving bubble above when it is below
                    else if ((av.bubble.location == 'Below') && (!(av.bubble.isBubbleOffScreen(av.y))))
                        { av.bubble.moveBubbleAbove(); }
                }
                
            }
            else{
                //trace('got there');
                av.stopWalk();
            }
        }
    
    
        /**
         * @brief Is the avatar on stage
         */
        public function isOnStage() :Boolean
        {
            return this.visible;
        }
    
        /**
         * @brief Is the avatar name currently visible
         */
        public function isNameOn() :Boolean
        {
            return this.txtField.visible;
        }
    
        /**
         * @brief Constuctor
         */
        public function Avatar(ID :Number, name :String, url :String, baseName: String,
                                       thumbnail :String, medium :String, layer: Number,
                                       parent:MovieClip, Class: Object)
        {
        	trace("In avatar cons");
        	super(ID, name, url, baseName, thumbnail, medium, baseLayer, parent, Avatar);
        };
    }
}
