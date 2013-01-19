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
    //import org.util.UiButton;
    import org.util.ButtonMc;
    import org.util.LayerPickerSet;
    import org.Client;
    import flash.display.*;
    import flash.text.*;
	
    /**
     * LayerPicker.as
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...) also rescaled text fields.
     * 			 Shaun Narayan (Apr 2010) - Changed alpha values from 0-100 to 0-1
     * Pick a layer upon which to draw.
     */
    
    
    public class LayerPicker extends MovieClip 
    {

        private var myWidth        :Number;
        private var myHeight       :Number;
        private var offX         :Number;
        private var offY         :Number;
        private var layers        :Array;
        public var ti           :Object;
        public  var activeLayer  :Number;
    
        static public function factory(parent :MovieClip, layer:Number,
                                       offX:Number, offY: Number) :LayerPicker
        {
            var name :String = 'LayerPicker_' + layer;
            //var mc:MovieClip = parent.attachMovie(LayerPicker.symbolName, name, layer);
            var lp :LayerPicker = new LayerPicker();
            lp.offX = offX;
            lp.offY = offY;
            lp.myWidth = Client.LAYER_PICKER_W;
            lp.myHeight = Client.LAYER_PICKER_H;
            lp.ti = parent.ti;
            parent.addChild(lp);
            lp.drawLayers();
            lp.activeLayer = -1;
            return lp;
        }
    
    
        public function drawLayers():void
        {
            //draw from bottom up.(layer 0 is bottommost)
            var top: Number = this.offY + this.myHeight - Client.LPICKER_LAYER_H;
            var i:Number;
            this.layers = [];
            for (i = 0; i < Client.DRAWING_LAYERS.length; i++)
                {
                    var x:Object = Client.DRAWING_LAYERS[i];
                    if (x.type == 'layer'){
                        //add another set of buttons.
                        this.layers.push(LayerPickerSet.factory(this, this.offX, top, this.layers.length));
                        top -= Client.LPICKER_LAYER_H;
                    }
                    else if (x.type == 'label'){
                        var txtField: TextField;
                        txtField = Construct.fixedTextField(this, 'label_' + i, ButtonMc.nextButtonLayer(),
                                                      this.offX, top + 3, this.myWidth - 1, 
                                                      Client.LPICKER_LABEL_H, 0.6, undefined, undefined); 
                        txtField.text = x.description;
                        top -= Client.LPICKER_LABEL_H;
                    }
                }                
        }
        
        public function setAlpha(set:LayerPickerSet, alpha:Number):void
        {
            trace("setAlpha got " + set + " alpha " + alpha);
            this.ti.SET_DRAW_VIS(set.index, alpha, set.visible);
        }
    
        public function getAlpha():Number
        {
            var set:LayerPickerSet = this.layers[this.activeLayer];
            return set.alphaSlider.value;
        }
    
        /* the user wants to draw on a layer. Ask the server for it. The
         * server should send somthing back that triggers setActiveLayer*/
    
        public function askForLayer(layer:Number):void
        {
            this.ti.SET_DRAW_LAYER(layer);       
        }
    
    
        public function setActiveLayers(layers:Array):void
        {
            trace("setActiveLayer got " + layers);
            var i:Number;
            trace(this.layers);
            this.activeLayer = -1; //turn off active layer
            for (i = 0; i < this.layers.length; i++){
                //trace("doing " + i + " layers[i] " + layers[i] + " 1: " + (layers[i] == 1) + " 2: " + (layers[i] == 2));
            this.layers[i].taken.visible = (layers[i] == 1);
            if (layers[i] == 2){        
                    this.layers[i].border.visible = true;
            this.activeLayer = i;
            }            
                else
                    this.layers[i].border.visible = false;
            }        
        }
    
        /**@brief turn layer visibility on or off.
         * set broadcast to false to make it a local change only.
         */
    
        public function toggleLayerVis(set:LayerPickerSet, broadcast:Boolean) :void
        {
            trace("toggleLayerVis got " + set + " visible " + set.isVisible);
            
            set.isVisible = ! set.isVisible;
            if (broadcast)
                this.ti.SET_DRAW_VIS(set.index, set.alphaSlider.value, set.isVisible);
            //grey out the hidden layer's buttons.
            if (set.isVisible){
                set.alpha = 1;            
            }
            else{
                set.alpha = 0.5;
            }
        }
    
    
        public function GET_DRAW_VIS(layer:Number, visible:Boolean, alpha:Number) :void
        {
            var set: LayerPickerSet = this.layers[layer];
            if (!isNaN(alpha))
                set.alphaSlider.setFromValue(alpha);        
            if (set.visible != visible)
                this.toggleLayerVis(set, false);
        }
    
    
    
    
        public function confirmClear(layer:Number) :void
        {
            //XXX should be asking to confirm
            this.ti.SET_DRAW_CLEAR(layer);
        }
    
        function LayerPicker(){}
    }
}
