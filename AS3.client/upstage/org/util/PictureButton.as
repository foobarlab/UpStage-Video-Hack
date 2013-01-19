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
    /*
      a button consisting of a drawing.
    */
    
    
    import org.util.Construct;
    //import org.Client;
    import org.util.ButtonMc;
    import flash.display.*;
    
    /**
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * 			 Shaun Narayan (Apr 2010) - Pass scale variable to draw explicitly (draw tools bug fix).     */
    public class PictureButton extends ButtonMc 
    {
        public var value     :Number;
    
        /* factory returns the button */
        static public function factory(parent :MovieClip, pointSets:Array,
                                       scale: Number, offX : Number, offY : Number,
                                       drawer: Function):PictureButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, PictureButton, scale);
            var pic: PictureButton = new PictureButton();
            if (drawer == null)
                drawer = Construct.polygon;
    
            var i:Number;
    //        trace('making picture button. points is '+ pointSets);
    //        trace('length is '+ pointSets.length);
            for (i = 0; i < pointSets.length; i++){    
                var o:Object = pointSets[i];
                //trace(i, o);
                //Construct.deepTrace(o);
                pic.draw(drawer, o.points,
                         o.line, o.fill, offX, offY, scale);
            }
            btn.addChild(pic);
            parent.addChild(btn);
            return pic;
        }
    
        function PictureButton(){}
    }
}
