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
    
    //import org.util.Construct;
    import org.Client;
   	import flash.display.*;
   	import org.util.Color;
   	import flash.events.*;

    /**
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...) - .graphics calls and handCursor registration added.
     * 								
     * 			 Shaun Narayan (Apr 2010) -	Modified draw function to take an explicit scale value
     * 								since function pointers seem to break the reference to the object instance to
     * 								which it belongs.     */
    public class ButtonMc extends MovieClip 
    {
    
        // member variables
        protected var colours   :Color;
        protected var pressed   :Boolean;
        protected var greyed    :Boolean;
    
        protected var upCT      :Object;
        protected var downCT    :Object;
        protected var overCT    :Object;
        protected var greyCT    :Object;
    
        protected var baseLayer :Number;
    
        public static var _nextButtonLayer: Number = Client.L_UI_BUTTONS;
    
        protected var scale     :Number;
    
    
        /**
         * @brief factory.
         */
        static public function create(parent :MovieClip, Class: Object, 
                                      scale : Number) :ButtonMc
        {
            if (!Class || ! Class.symbolName){
                trace("no class in ButtonMc constructor");
                Class = ButtonMc;
            }
            var layer: Number = ButtonMc.nextButtonLayer();        
            var name :String = 'button' + layer;
            
            var button :ButtonMc = new ButtonMc();
            button.baseLayer = layer;
            button.buttonMode = true;
            button.useHandCursor = true;
            
            // Create transitions
            button.colours = new Color(button);
            button.upCT   = Client.BUTTON_UP_CT;
            button.downCT = Client.BUTTON_DOWN_CT;
            button.overCT = Client.BUTTON_OVER_CT;
            button.greyCT = Client.BUTTON_GREY_CT;
    
            button.scale = scale || 1;
            button.greyed = false;
            button.addEventListener(MouseEvent.MOUSE_OVER, button.onRollOver);
            button.addEventListener(MouseEvent.MOUSE_OUT, button.onRollOut);
    		parent.addChild(button);
            trace("button "+ button + " level " +button.baseLayer);
            return button;
        }
    
    
    
        //-------------------------------------------------------------------------
    
    
        /**
         * @brief Draw the button on the movieclip
         */
        protected function draw(drawer: Function, points: Array, 
                              lineColour:Number, fillColour:Number,
                              offX :Number, offY :Number, scale:Number) :void
        {
            this.graphics.lineStyle(Client.BORDER_WIDTH, lineColour);
            this.graphics.beginFill(fillColour);
            drawer(this, points, scale, offX, offY);
            this.graphics.endFill();
        }
    
    
        /**
         * @brief Press the button
         */
        public function depress() :void

        {
            this.pressed = true;
            new Color(this, downCT);
        };
    
    
        /**
         * @brief Raise the button
         */
        public function raise() :void

        {
            this.pressed = false;
            new Color(this, upCT);
        };
    
    
        /**
         * @brief Used during testing (override when using buttons
         */
        public function onPress() :void

        {
            this.pressed = !this.pressed;
            new Color(this, (this.pressed ? this.downCT : this.upCT));
        };
    
    
        /**
         * @brief Pretty color changes for rollover events
         */
        public function onRollOver(evt:Event) :void

        {
            if (this.greyed == false) {
                new Color(this, this.overCT);
            }
        };
    
    
        /**
         * @brief Pretty color changes for rollout events
         */
        public function onRollOut(evt:Event) :void

        {
            if(this.greyed)
                new Color(this, this.greyCT);
            else
                new Color(this, (this.pressed ? this.downCT : this.upCT));
        };
    
    
        /**
         * @brief Toggle the button raised/pressed state
         * @return is the button pressed after toggle
         */
        public function toggle() :Boolean
        {
            if (this.pressed)
                {
                    this.raise();
                    return false;
                }
            else
                {
                    this.depress();
                    return true;
                }
        }
    
    
        /**
         * @brief Is the button pressed now
         */
        public function isPressed() :Boolean
        {
            return this.pressed;
        }
    
        public function grey() :void
        {
            new Color(this, greyCT);
            this.greyed = true;
        }
    
        public function ungrey() :void
        {
            new Color(this, upCT);
            this.greyed = false;
        }
    
        public function hide() :void
        {
            this.visible = false;
        }
    
        public function show() :void
        {
            this.visible = true;
        }
    
        /* an incrementing level counter */
    
        public static function nextButtonLayer():Number
        {
            //increment the class's static level counter.
            ButtonMc._nextButtonLayer += Client.UI_BUTTON_LAYERS;
            return ButtonMc._nextButtonLayer;
        }
    
        /**
         * @brief wannabe constructor
         */
        function ButtonMc(){};
    }
}
