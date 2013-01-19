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
    import org.util.Slider;
    import org.util.Construct;
    import org.util.ButtonMc;
    import flash.display.*;
	
    /**
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...)
     * 			 Shaun Narayan (Apr 2010) - Modified radius var to scale huge circle.     */
    public class SizeSlider extends MovieClip 
    {
        private var baseLayer    :Number;
        private var circleLayer  :Number;
    
        private var myWidth        :Number;
        private var offX         :Number;
        private var offY         :Number;
    
        public var value         :Number;
        private var circle       :MovieClip;
        private var slider       :Slider;
        private var listener     :Function;
    
    
        static public function factory(parent :MovieClip, range: Number,
                                       offX:Number, offY: Number,
                                       width:Number, gap:Number) :SizeSlider
        {
            trace('in SizeSlider');
            trace(arguments);
    
            var layer: Number = ButtonMc.nextButtonLayer();
            var name :String = 'slider' + layer;
            var s :SizeSlider = new SizeSlider();
            s.baseLayer = layer;
            s.circleLayer = layer + 1;
            s.useHandCursor = true;
            s.slider = Slider.factory(s, range, offX + gap, offY, width - gap, Client.UI_SLIDER_HEIGHT, true);
            s.slider.listener = function(v:Number) :void{
                s.setFromValue(v);
                if (s.listener != null)
                    s.listener();
            }
    
            s.myWidth = width;
            s.offX = offX;
            s.offY = offY;
            s.value = 0;
            s.drawCircle();
            parent.addChild(s);
            return s;
        }
            
        public function drawCircle() :void
        {
        	this.circle = new MovieClip();
            this.addChild(this.circle);
            this.circle.x = this.offX + 0;
            this.circle.y = this.offY + 0;
            var r:Number = 0.5;
            Construct.approximateCircle(this.circle, r, r, r, 0x000000, 0xffffff, 0.5, 100);        
        }
    
        public function setFromValue(s:Number) :void
        {
            this.slider.setFromValue(s);
            this.circle.scaleX = s + 0.1;
            this.circle.scaleY = s + 0.1;
            this.value = this.slider.value; // let slider check range.
        }
    
        function SizeSlider(){}
    }
}
