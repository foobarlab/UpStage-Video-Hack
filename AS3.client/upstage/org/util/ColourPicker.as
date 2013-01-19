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
    
    import org.util.Slider;
    import org.util.Construct;
	import org.Client;
   	import flash.display.*;

    /**
     * ColourPicker.as
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...).
     * A set of sliders to pick an RGB colour.
     */
    
    
    public class ColourPicker extends MovieClip 
    {

        public var colour        :Number;
        public var sliderX       :Number;
        public var sliderH       :Number;
        public var listener      :Function;
    
        private var sliderR      :Slider;
        private var sliderG      :Slider;
        private var sliderB      :Slider;
    
        private var myWidth        :Number;
        private var myHeight       :Number;
        private var offX         :Number;
        private var offY         :Number;
        private var borderColour :Number = Client.SLIDER_BORDER;
    
    
        static public function factory(parent :MovieClip, layer:Number,
                                       offX:Number, offY: Number,
                                       width:Number, height:Number) :ColourPicker
        {
            trace('in ColourPicker');
            trace(arguments);
    
            var name :String = 'ColourPicker_' + layer;
            var cp :ColourPicker = new ColourPicker();
    
            cp.offX = offX;
            cp.offY = offY;
            cp.myWidth = width;
            cp.myHeight = height;
    
            cp.sliderX = offX + width / 3;
            cp.sliderH = (height - 2) / 3;
            
            cp.sliderR = Slider.factory(cp, 255, cp.sliderX, offY, width - cp.sliderX, cp.sliderH, true);
            cp.sliderG = Slider.factory(cp, 255, cp.sliderX, offY + (height - cp.sliderH) / 2, width - cp.sliderX, cp.sliderH, true);
            cp.sliderB = Slider.factory(cp, 255, cp.sliderX, offY + height - cp.sliderH, width - cp.sliderX, cp.sliderH, true);
            var f: Function = function():void{
                cp.doColourBox();
            }
            cp.sliderR.listener = f;
            cp.sliderG.listener = f;
            cp.sliderB.listener = f;
            cp.doColourBox();
            parent.addChild(cp);     
            return cp;
        }
    
    
        function doColourBox() :void
        {
            var R:Number = this.sliderR.value * 65536;
            var G:Number = this.sliderG.value * 256;
            var B:Number = this.sliderB.value;
    
            this.colour = R + G + B;
    
            Construct.rectangle(this, this.offX, this.offY,
                                this.sliderX - 2, this.height, this.borderColour, this.colour, undefined, undefined);
    
            this.sliderR.drawGradient(G + B, 255 * 65536 + G + B);
            this.sliderG.drawGradient(R + B, R + 255 * 256 + B);
            this.sliderB.drawGradient(R + G, R + G + 255);
    
        }
    
        public function setFromValue(s:Number) :void
        {
            this.sliderB.setFromValue(s & 255);
            this.sliderG.setFromValue(s >> 8 & 255);
            this.sliderR.setFromValue(s >> 16& 255);
            this.doColourBox();
            this.colour = s;
        }
    
    
    
        function ColourPicker(){};
    }
}
