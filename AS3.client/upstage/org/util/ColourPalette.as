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
    
    import org.util.Construct;
    import org.util.PictureButton;
    import org.Client;
    import flash.display.*;
    import flash.events.*;
	
    /**
     * ColourPalette.as
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...) - also had to specify fill color for "empties" so they
     * 								appear white as in old client.
     * A set of sliders to pick an RGB colour.
     */
    
    
    public class ColourPalette extends MovieClip 
    {
        public var slots         :Number;
        public var fixedSlots    :Number = Client.PALETTE_FIXED.length;
        private var spacing      :Number = Client.COLOUR_PALETTE_W + 1;
        
        private var positions    :Array;
        private var fixedButtons :Array;
        private var varButtons   :Array;
    
        public var listener      :Function;
    
        private var myWidth        :Number;
        private var myHeight       :Number;
    
        static public function factory(parent :MovieClip, layer:Number,
                                       offX:Number, offY: Number,
                                       width:Number, height:Number) :ColourPalette
        {
            var name :String = 'ColourPalette_' + layer;
            //var mc:MovieClip = parent.attachMovie(ColourPalette.symbolName, name, layer);
            var cp :ColourPalette = new ColourPalette();
    
            cp.x = offX;
            cp.y = offY;
            cp.myWidth = width;
            cp.myHeight = height;
            cp.positions = [];
            cp.varButtons = [];
            cp.fixedButtons = [];
    
            cp.slots = Math.floor(width / (Client.COLOUR_PALETTE_W + 1)) - cp.fixedSlots;
    
            cp.drawEmpties();
            cp.drawFixed();
            parent.addChild(cp);
            return cp;
        }
    
        /** @brief draw empty squares that will be filled by 
            palette items.
        */
    
        public function drawEmpties(){
            var i:Number;
            var x:Number = 0;
            for (i = 0; i < this.slots + this.fixedSlots; i++){
                this.positions.push(x);
                Construct.rectangle(this, x, 0, Client.COLOUR_PALETTE_W, 
                                    Client.COLOUR_PALETTE_H, 0xcccccc, 0xffffff, undefined, undefined);
                x += this.spacing;                                             
            }
        }
    
        /** @brief make a single button, as yet unpositioned*/
    
        public function makeButton(colour:Number):PictureButton
        {
            var a:Array = [{line:0x000000, 
                            fill:colour, 
                            points:Client.PALETTE_POINTS}];
            var that:ColourPalette = this;
            var p:PictureButton = PictureButton.factory(this, a, 1, 0, 0, undefined);
            p.value = colour;
            p.addEventListener(MouseEvent.CLICK, function(){
                trace('button pressed. value is ' + p.value);
                trace(that.listener);
                if (p.value != undefined)
                    that.listener(p.value);            
            });
            return p;
        }
    
        /*Add buttons that don't shift or change colour */
    
        public function drawFixed()
        {
            var p:PictureButton;
            var i:Number;
            for (i = 0; i < this.fixedSlots; i++){
                p = this.makeButton(Client.PALETTE_FIXED[i]);
                p.x = this.positions[this.slots + i];
                this.fixedButtons.push(p);
            }            
        }
    
        /** @brief add the new colour onto the left hand 
            side of the palette, shifting along the others.
        */
    
        public function addToPalette(colour:Number)
        {
            var b:PictureButton;
            var i: Number;
            trace('adding colour '+ colour);
            if (this.varButtons.length == this.slots){
                trace('popping button. slots is '+ this.slots);
                this.varButtons.pop(); //XXX could recycle this one.
            }
            b = this.makeButton(colour);
            this.varButtons.unshift(b);
            for (i = 0; i < this.varButtons.length; i++){
                trace('setting button ' +  this.varButtons[i] + ' to ' + this.positions[i]);
                this.varButtons[i].x = this.positions[i];
            }
            trace(this.varButtons);
            trace(this.positions);
        }
    
        public function tryColour(colour:Number){
            var i:Number = 0;        
            trace('trying colour '+ colour);
            for (i = 0; i < this.fixedSlots; i++){
                if (Client.PALETTE_FIXED[i] == colour)
                    return;
            }
            for (i = 0; i < this.varButtons.length; i++){
                trace('comparing to ' + this.varButtons[i].value);
                if (this.varButtons[i].value == colour)
                    return;
            }
            this.addToPalette(colour);
        }
    
        function ColourPalette(){};
    }
}
