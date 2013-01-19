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
    
    import org.util.Construct;
    import org.util.ButtonMc;
    import org.util.PictureButton;
    import org.util.UiButton;
    import org.util.Slider;
    import org.Client;
    import flash.display.*;
    import flash.events.*;
    /**
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...)
     * 			 Shaun Narayan (Apr 2010) -	Modified button, text and image scaling to fix
     * 								oversized Drawtools bug. Clear button is a AudioFactory button to reuse code,
     * 								should probably rename the function to something more abstract??     */
    public class LayerPickerSet extends MovieClip 
    {
        public var pressed      :Boolean;
        public var greyed       :Boolean;
        public var baseLayer    :Number;
        public var borderLayer  :Number;
        public var takenLayer   :Number;
    
        public  var index        :Number;
        public  var isVisible      :Boolean;
        public  var alphaSlider  :Slider;
    
        public var clearButton  :UiButton;
        public var visButton    :PictureButton;
        public var selectButton :PictureButton;
        public var layerMirror  :PictureButton;
        public var border       :MovieClip;
        public var taken        :MovieClip;
    
        static var eyePoints:Array = [{line:0x0000ff, fill:0x330077, points:Client.DRAWING_EYE_1},
                                      {line:0x000000, fill:0xffffee, points:Client.DRAWING_EYE_2}
                                      ];
        static var eyeScale:Number = 0.36;
    
        static var pencilPoints: Array = [{line:0x000000, fill:0xff0066, points:Client.DRAWING_PENCIL}];
        static var pencilScale:Number = 0.03;
        
    
        /**
         * @brief Messy constructor override required to extend MovieClip
         */
        static public function factory(parent :MovieClip, offX:Number, offY:Number, index:Number) :LayerPickerSet
                                       
        {
            var layer: Number = ButtonMc.nextButtonLayer();
            var name :String = 'button' + layer;
            //var mc:MovieClip = parent.attachMovie(LayerPickerSet.symbolName, name, layer);
            var set :LayerPickerSet = new LayerPickerSet();
            set.index = index;
            set.isVisible = true;
            set.baseLayer = layer;
            set.borderLayer = layer + 1;
            set.takenLayer = layer + 2;
           
            /*border showing that the layer is selected. */
    	    set.makeBorder('border', set.borderLayer, 0x000000, offX, offY);
       		set.makeBorder('taken', set.takenLayer, 0x99cccc, offX, offY);
            Construct.uiRectangle(set, offX, offY, Client.LAYER_PICKER_W, Client.LPICKER_LAYER_H - 1, 0xffffff);
            
            /*visibility button to switch the layer visibility on or off */
            set.visButton = PictureButton.factory(set, LayerPickerSet.eyePoints, 
                                                  LayerPickerSet.eyeScale, offX + 1, offY + 2, undefined);
            set.visButton.addEventListener(MouseEvent.CLICK, function(){
                trace("vis button pressed for " + set.index);
                parent.toggleLayerVis(set, true);
            });
    
    
            /*button to select the layer for drawing */
            set.selectButton = PictureButton.factory(set, LayerPickerSet.pencilPoints, 
                                                     LayerPickerSet.pencilScale, 
                                                     offX + set.visButton.width + 2, offY + 1, undefined);
            set.selectButton.addEventListener(MouseEvent.CLICK, function(){
                trace("select button pressed for " + set.index);
                //parent.setActiveLayer(set.index);
            parent.askForLayer(set.index);
            });
    
            set.clearButton = UiButton.AudioSlotfactory(set,  Client.BTN_LINE_CLEAR,
                                             Client.BTN_FILL_CLEAR, 'clear', 0.6,
                                               offX + set.visButton.width + set.selectButton.width + 3,
                                               offY + 1);
            //set.clearButton._xscale = 75;
            set.clearButton.addEventListener(MouseEvent.CLICK, function(){
                parent.confirmClear(index);
            });
    
            /*slider to change layer alpha*/
            set.alphaSlider = Slider.factory(set, 100, offX + 2, offY + 7.25, 20, 2.75, true);
            set.alphaSlider.setFromValue(100);
            set.alphaSlider.listener = function(n:Number){
                trace("alpha sliding for " + set.index);
                parent.setAlpha(set, n);
            }
            
    		parent.addChild(set);
            return set;
        }
    
        private function makeBorder(name:String, layer:Number, colour:Number, offX:Number, offY:Number) :void
        {
            this[name] = new MovieClip();//this.createEmptyMovieClip(name + layer, layer);
            Construct.rectangle(this[name], offX, offY, Client.LAYER_PICKER_W, Client.LPICKER_LAYER_H - 1,
                                colour, undefined, 1, 100);
            this[name].visible = false;
            var that:MovieClip = this[name];
            this.addChild(that);
            //this.addChildAt
        }    
    
    
    
    
        function LayerPickerSet(){}
    }
}
