package org.util {
    /*
      Copyright (C) 2003-2006 Douglas Bagnall
    
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
    import org.util.ButtonMc;
    import org.util.Construct;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
	
    /**
     * Author: 
     * Modified by: Phillip Quinlan, Endre Bernhardt
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method etc...)
     * 								also - handcursor registration, .graphics calls.
     * 			 Shaun Narayan (Apr 2010) - Modified drawGradient to use drawRect as a fill method to actually do the gradient.
     */
    
    
    public class Slider extends MovieClip 
    {
    
        public var myParent       :MovieClip;
        private var baseLayer    :Number;
        private var pointerLayer :Number;
    
        private var myWidth        :Number;
        private var myHeight       :Number;
        private var offX         :Number;
        private var offY         :Number;
        private var borderColour :Number = Client.SLIDER_BORDER;
        private var fillColour   :Number = Client.UI_BACKGROUND;
        
        private var bHorizontal  :Boolean;  // PQ: Added 23.9.07
    
        private var pointer      :MovieClip;
    
        private var sliding      :Boolean;
        private var scaler       :Number;
        private var range        :Number;
    
        public var value         :Number;
        public var listener      :Function;
    
    
        /**
         * @brief Messy constructor override required to extend MovieClip
         */
        static public function factory(parent :MovieClip, range: Number,
                                       offX:Number, offY: Number,
                                       myWidth:Number, myHeight:Number, bHorizontal: Boolean) :Slider  // PQ: Added 23.9.07 - bHorizontal
        {
            var layer: Number = ButtonMc.nextButtonLayer();
            var name :String = 'slider' + layer;
            var slider :Slider = new Slider();
            slider.myParent = parent;
            slider.baseLayer = layer;
            slider.pointerLayer = layer + 1;
            slider.useHandCursor = true;
    
            slider.myWidth = myWidth;
            slider.myHeight = myHeight;
            slider.offX = offX;
            slider.offY = offY;
            slider.bHorizontal = bHorizontal;  // PQ: Added 23.9.07
    
            slider.value = 0;
            slider.range = range;
            // PQ: Added 23.9.07 - Can now do vertical sliders
            if (bHorizontal)
            {
                slider.scaler = range/myWidth;
            }
            else
            {
                slider.scaler = range/myHeight;
            }
    
            slider.draw();
    
            //slider.onMouseDown = function()
            slider.addEventListener(MouseEvent.MOUSE_DOWN, function()
                {
                    //trace("slider mouse down");
                    slider.sliding = true;
                    //slider.onMouseMove = slider._onMouseMove;
                    // PQ: Added 23.9.07 - Can now do vertical sliders
                    if (bHorizontal)
                    {
                        slider.setFromMouse(slider.mouseX);
                    }
                    else
                    {
                        slider.setFromMouse(slider.mouseY);
                    }
                });
            slider.addEventListener(MouseEvent.MOUSE_MOVE, function()
                {
                    //trace("slider mouse move");
                    if (slider.sliding)
                    {
                        // PQ: Added 23.9.07 - Can now do vertical sliders
                        if (bHorizontal)
                        {
                            slider.setFromMouse(slider.mouseX);
                        }
                        else
                        {
                            slider.setFromMouse(slider.mouseY);
                        }
                    }
                });
            slider.addEventListener(MouseEvent.MOUSE_UP, function()
                {
                    
                    //trace("slider mouse up");
                    slider.sliding = false;
                    // PQ: Added 23.9.07 - Can now do vertical sliders
                    if (bHorizontal)
                    {
                        slider.setFromMouse(slider.mouseX);
                    }
                    else
                    {
                        slider.setFromMouse(slider.mouseY);    
                    }
                    //slider.onMouseMove = null;
    
                    //if (slider._onMouseRelease != null) {
                        //slider._onMouseRelease();
                    //}
                });
            //slider.onReleaseOutside = slider.onRelease;
    		parent.addChild(slider);
            return slider;
        }
    
        /**
         * EB 22/10/07 - For setting the event handler of mouserelease.
         * This will hopefully provide a clean was for the application to know
         * when the user has released the volume slider on the audio pane
         * so the server can be notified.
         * 
         */
        function setReleaseHandler(handler:Function) {
            this.addEventListener(MouseEvent.MOUSE_UP, handler);
        }
    
        //-------------------------------------------------------------------------
    
        function setFromMouse(xy:Number) :void
        {
            // PQ: Added 23.9.07 - Can now do vertical sliders
            if (bHorizontal)
            {
                   xy -= this.offX;
            }
            else
            {
                   xy -= this.offY;
            }
            var s:Number = Math.floor(xy * this.scaler);
            s = Math.max(s, 0);
            s = Math.min(s, this.range);
            this.setFromValue(s);
            // PQ: Added 23.9.07 - Can now do vertical sliders
            if (bHorizontal)
            {
                trace('got answer of ' + s + " x was " + xy + " offset is " + this.offX);
            }
            else
            {
                trace('got answer of ' + s + " y was " + xy + " offset is " + this.offY);
            }
            
            if (this.listener != null) {
                trace("supposedly calling slider's listener");
                this.listener(s);
            }
        }
    
        public function setFromValue(s:Number) :void
        {
            // PQ: Added 23.9.07 - Can now do vertical sliders
            if (bHorizontal)
            {
                this.pointer.x = s / this.scaler;
            }
            else
            {
                this.pointer.y = s / this.scaler;
            }
            //this.pointer._x = this.offX + (s / this.scaler);
            this.value = s;
        }
    
    
    
        /**
         * @brief Draw the slider on the movieclip
         */
        private function draw() :void
        {
            Construct.rectangle(this, this.offX, this.offY,
                                this.myWidth, this.myHeight, this.borderColour, this.fillColour, undefined, undefined);
    
            pointer = new MovieClip();
    		this.addChild(pointer);
            // PQ: Added 23.9.07 - Can now do vertical sliders
            if (bHorizontal)
            {
                Construct.filledPolygon(pointer, Client.SLIDER_DIAMOND, this.myHeight, 
                                    this.borderColour, undefined, this.offX, this.offY);
            }
            else // PQ: Also make the diamond in the middle of the slider rectangle
            {
                Construct.filledPolygon(pointer, Client.SLIDER_DIAMOND, this.myWidth, 
                                    this.borderColour, undefined, this.offX + (this.myWidth/2), this.offY);
            }
    
        }
    
        function drawGradient(left:Number, right:Number) :void
        {
            trace("doing gradient fill: " + left + "," + right + "," +myHeight + "," + myWidth);
            
            var matrix:Matrix = new Matrix;
            matrix.createGradientBox(this.myWidth, this.myHeight, 0, this.offX, this.offY);
            this.graphics.beginGradientFill(GradientType.LINEAR, [left, right], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
            this.graphics.drawRect(this.offX, this.offY, this.myWidth, this.myHeight);
            //Construct.rectangle(this, this.offX, this.offY,
                              //  this.myWidth, this.myHeight, this.borderColour, 0, undefined, undefined);
            this.graphics.endFill();
        }
    
    
    
        public function hide() :void
        {
            this.visible = false;
        }
    
        public function show() :void
        {
            this.visible = true;
        }
    
    
    
        /**
         * @brief wannabe constructor
         */
    
        function Slider(){};
    }
}