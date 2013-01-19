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
    import org.model.TransportInterface;
   	import flash.display.*;

    /**
       shows pictures drawn by players, on all screens.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								modified drawing calls to refrence .graphics.
     */
    
    public class ModelDrawing implements TransportInterface 
    {
        private var sender        :Sender;
        private var layers        :Array;
        private var layer         :MovieClip;
        private var lineStyles    :Array;
    
        public function ModelDrawing(sender :Sender)
        {
            this.sender = sender;        
            this.layers = [];
            this.lineStyles = [];
        };
    
    
        /**
         * @brief Called automatically by transport after connect
         */
        public function drawScreen(parent :MovieClip) :void

        {
            var i:Number;
            var mc: MovieClip;        
            for (i = 0; i < Client.DRAWING_LAYERS.length; i++)
                {
                    var x:Object = Client.DRAWING_LAYERS[i];
                    if (x.type == 'layer'){                    
                        mc = new MovieClip();//parent.createEmptyMovieClip('layer' + x.layer, x.layer);
                        parent.addChild(mc);
                        this.layers.push(mc);
                    }
                }
        }
    
    
        public function GET_DRAW_LINE(layer:Number, x:Number, y:Number){
            trace('in ModelDrawing.GET_DRAW_LINE with layer ' + layer + ' x ' + x + ' y ' + y);
            this.layers[layer].graphics.lineTo(x, y);        
        }
    
        public function GET_DRAW_MOVE(layer:Number, x:Number, y:Number){
            this.layers[layer].graphics.moveTo(x, y);
        }
        
        public function GET_DRAW_STYLE(layer:Number, thickness:Number, colour:Number, alpha:Number){
            var i:Number;
            trace('in ModelDrawing.GET_DRAW_STYLE with thickness ' + 
                  thickness + ' colour ' + colour + ' alpha ' + alpha + ' layer ' + layer);
            alpha = alpha*0.01;
            this.layers[layer].graphics.lineStyle(thickness, colour, alpha);
            //save the numbers for after a layer is cleared.
            this.lineStyles[layer] = [thickness, colour, alpha];
        }
    
                    
        public function GET_DRAW_VIS(layer:Number, visible:Boolean, alpha:Number){
            if (!isNaN(alpha))
                this.layers[layer].alpha = alpha*0.01;
            this.layers[layer].visible = visible;
        }
    
        public function GET_DRAW_CLEAR(layer:Number){
            this.layers[layer].graphics.clear();
            //restore line style
            var ls: Array = this.lineStyles[layer];
            if (ls){           
                this.layers[layer].graphics.lineStyle(ls[0], ls[1], ls[2]);
            }
        }    
    }
}
