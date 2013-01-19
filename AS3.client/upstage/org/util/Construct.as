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
    
    
    /**
     * Module:  Construct.as
     *
     * static functions for drawing on screen.
     * @mofified Shaun Narayan (Feb 2010) - Converted to AS3. Changes include embedded fonts,
     * 								use of .graphics for drawing, removal of some depricated fields,
     * 								and consolidation of parent/child relationships for some MC's.
     * 								Normal conversion changes also applied - Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event handling etc...
     * @note Havent had time to allow for formatting the way it actually should be
     */
    
  import org.Client;    
	import flash.display.*;
	import flash.text.*;
	import org.util.Web;
    public class Construct 
    {
    	//Shaun Narayan - Added embedded fonts to work with AS3
        [Embed(source='Vera.ttf', fontName="VeraSans", fontWeight="normal", fontFamily="Vera", mimeType="application/x-font-truetype")]
        public var VERA_SANS:Class;
        [Embed(source='VeraBd.ttf', fontName="VeraBold", fontWeight="bold", fontFamily="Vera", mimeType="application/x-font-truetype")]
        public var VERA_BOLD:Class;
        // Default text format used in many places
        public static var defaultFormat :TextFormat = new TextFormat();
    
        // Current stage Url set in Transport.STAGE_NAME()
        public static var stageUrl :String = '';
        
        public var scaleNo :Number = 0;
    
    
        /* 
         * Format to apply to text which doesn't change.
         */
    
        public static function getFixedTextAttrs() :Object
        {
            return {
                    align: 'center',
                    leftMargin: 0, 
                    rightMargin: 0,
                    leading: 0
                    //autoSize: TextFieldAutoSize.CENTER
                    };
        }
    
    
    
        /**
         * @brief Set up a special TextFormat that uses embedded fonts
         * Note: Can't toggle bold later using this function
         * See application.xml
         */
        public static function textFormat(scale :Number, bold: Boolean) :TextFormat
        {
            bold = bold || false;
            scale = scale || 1;
            var f : TextFormat = new TextFormat();
            f.color = 0x000000;
            f.bold = bold;
            //f.font = "Vera";
            f.font = "Verdana";
            f.size = scale * Client.BASE_FONT_SIZE;  // Base font size;
            return f;
        }
    
    
        public static function formattedTextField(mc: MovieClip, name: String, layer: Number,
                                           x: Number, y: Number, w: Number, h:Number, scale:Number,
                                           bold: Boolean, fieldOptions: Object, formatOptions: Object): TextField
        {
            var attr: String;
    
            var txtField:TextField = createTextField(mc, layer, x, y, w, h);
         
            //set up textField options
            //default is to embed fonts.
    
            //txtField.embedFonts = true;
            if (fieldOptions){
                for (attr in fieldOptions){
                   	txtField[attr] = fieldOptions[attr];

                }
            }
            var format :TextFormat = Construct.textFormat(scale, bold);
            if (formatOptions){
                for (attr in formatOptions){
                   	format[attr] = formatOptions[attr];
                }
            }
    
            txtField.defaultTextFormat = format;
            return txtField;
        }
    
    
        public static function fixedTextField(mc: MovieClip, name: String, layer: Number,
                                       x: Number, y: Number, w: Number, h:Number, scale:Number,
                                       bold: Boolean, fieldOptions: Object): TextField
        {
            var fmt:Object = Construct.getFixedTextAttrs();
            return Construct.formattedTextField(mc, name, layer,
                                                x, y, w, h, scale,
                                                bold, fieldOptions, fmt);        
        }
    
        /**
         * @brief Draw a polygon on screen
         * Final point must be equal to first point. ie for a square there are five points.
         */
        public static function polygon(obj: MovieClip, points : Array, scale :Number, offX :Number, offY :Number) :void

        {
            scale = scale || 1;
            offX = offX || 0;
            offY = offY || 0;
            //move to first point, thereafter draw
            obj.graphics.moveTo(points[0] * scale + offX, 
                       points[1] * scale + offY);
    
            for(var z :Number = 2; z < points.length;)
                {
                    var X :Number = points[z++] * scale + offX;
                    var Y :Number = points[z++] * scale + offY;
                    obj.graphics.lineTo(X, Y);
                }
        }
    
    
    
        /**
         * @brief Draw a polygon filled with the background color
         */
        public static function filledPolygon(mc: MovieClip, points : Array, scale :Number,
                                      lineColour :Number, fillColour:Number,
                                      offX :Number, offY :Number) :void

        {
    /*        trace('filledPolygon: points ' + points + ' line ' + lineColour + 
                  ' fill ' + fillColour); */
            mc.graphics.lineStyle(0.5, lineColour);
            if(! isNaN(fillColour))
               mc.graphics.beginFill(fillColour);
            polygon(mc, points, scale, offX, offY);
            mc.graphics.endFill();
        }
    
    
        public static function approximateCircle(mc:MovieClip, x:Number, y:Number, r:Number,
                                          border: Number, fill: Number, borderWidth: Number, alpha:Number) :void

        {
            var i:Number, s:Number, c:Number;
            var points: Array = [];
            for (i = 0; i < Math.PI * 2; i += Math.PI * 0.1){            
                s = Math.sin(i);
                c = Math.cos(i);
                points.push(s * r);
                points.push(c * r);
            }        
            points.push(points[0]);
            points.push(points[1]);
            trace('in approximateCircle');
            trace(points);
            trace(arguments);
            Construct.filledPolygon(mc, points, 1, border, fill, x, y);
        }
    
    
    
        /**
         * @brief Draw a filled rectangle, with a border.
         */
        public static function rectangle(mc: MovieClip, x:Number, y: Number, w:Number, h:Number,
                                  border: Number, fill: Number, borderWidth: Number, alpha:Number) :void

        {
            if (isNaN(alpha))
                alpha = .1;
            if (isNaN(borderWidth)) //backwards compatibility.
                borderWidth = 0.5;
            mc.graphics.lineStyle(borderWidth, border, alpha);
            if (! isNaN(fill) && fill >= 0)
                mc.graphics.beginFill(fill, alpha);
            mc.graphics.moveTo(x, y);
            mc.graphics.lineTo(x + w, y);
            mc.graphics.lineTo(x + w, y + h);
            mc.graphics.lineTo(x, y + h);
            mc.graphics.lineTo(x, y);
            mc.graphics.endFill();
        }
    
    
    
        /*draw a border around a movieclip
          NB -the border actually makes the clip grow.
        */
        public static function border(mc: MovieClip, colour:Number):void
        {
            Construct.rectangle(mc, 0, 0, mc._width, mc._height, colour, undefined, 0.5, 30);
        }
    
    
        /**
         * @brief Draw a filled rectangle, in the style of upstage user interface widgets
         */
        public static function uiRectangle(mc: MovieClip, x:Number, y: Number, w:Number, h:Number, col:Number) :void
        {
            rectangle(mc, x, y, w, h, Client.BORDER_COLOUR, col, Client.BORDER_WIDTH, undefined);
        }
    
    
        //Aaron (02.08.08)
        /** 
         * @brief Draw a filled rectangle - for Backdrop and Prop only
         * in the style of upstage user interface widgets, w background colour
         */
        public static function uiRectangleBackgroundAndProp(mc: MovieClip, x:Number, y: Number, w:Number, h:Number, bgColor:Number) :void
        {
            rectangle(mc, x, y, w, h, Client.BORDER_COLOUR, bgColor, Client.BORDER_WIDTH, undefined);
        }
    
    
    
    
    
        // BH 29-Aug-2006 Added
        /**
         * @brief Draw a rounded polygon - Used for drawing buttons See ButtonMc
         */
        public static function roundedPolygon(obj: MovieClip, points : Array, scale :Number,
                                       offX :Number, offY :Number) :void

        {
            var up :Boolean = true;
            scale = scale || 1;
            offX = offX || 0;
            offY = offY || 0;
            for (var z :Number = 0; z < points.length;)
                {
                    var iX   :Number = points[z++] * scale + offX;
                    var iY   :Number= points[z++] * scale + offY;
                    var bezX :Number = points[z++] * scale + offX;
                    var bezY :Number = points[z++] * scale + offY;
                    var oX   :Number= points[z++] * scale + offX;
                    var oY   :Number= points[z++] * scale + offY;
                    if(up == true)
                        {
                            obj.graphics.moveTo(iX,iY);
                            up = false;
                        }
                    else
                        {
                            obj.graphics.lineTo(iX,iY);
                        }
                    if (!isNaN(bezX))
                        {
                            obj.graphics.curveTo(bezX,bezY, oX,oY);
                        }
                }
        }
    
    
        /**
         * @brief constrainSize, resizes downwards only, and maintain aspect ratio
         */
        public static function constrainSize(mc: MovieClip, maxw: Number, maxh: Number):void

        {
            // Do we need to scale
            var scale :Number = Math.min(maxw / mc.width, 
                                         maxh / mc.height);
            trace("Scale is: " + scale + "Width " + mc.width);
            //this.scaleNo = scale;
            if (scale < 1.0)
                {
                	trace("Scale is: " + scale + "Width " + mc.width);
                    mc.scaleX = scale;
                    mc.scaleY = scale;
                }
        }
        /**
         * Shaun Narayan- Created to replace as2 method.
         */
        public static function createTextField(parent:MovieClip, layer:Number, xx:Number, yy:Number, wwidth:Number, hheight:Number): TextField
        {
        	var txf:TextField = new TextField();
        	//txf.autoSize = TextFieldAutoSize.CENTER;
            txf.x = xx;
            txf.y = yy;
            txf.width = wwidth;
            txf.height = hheight;
            /**txf.visible = true;
            txf.background = true;
            txf.backgroundColor = 0xFFFF00;
            txf.border = true;
            txf.borderColor = 0x00FF00;
            txf.text = "Hello";
            txf.textColor = 0x000000;
            txf.type = TextFieldType.DYNAMIC;*/
            parent.addChild(txf);
            trace("######"+txf.x + "-" + txf.y + "-" + txf.width + "-" + txf.height+"-"+txf.length + "-"+txf.text);
            return txf;
        }
    
    
        /**
         * @brief List the variables inside an to debugger in format "object name: Value"
         * Does first level only
         */
        public static function deepTrace(obj : Object) : void
        {
            trace("deep tracing " + obj + " -------------------");
            for (var x : Object in obj)
                {
                    trace(x + ': ' + obj[x]);
                }
            trace("----------------------------------");
        };
    
        /**
         * @brief Get the stage to reload
         */
        //XXX does this belong here?
        public static function reloadStage() :void
        {
            // Reload the stage
               Web.getURL(Construct.stageUrl);
        }
    };
}
