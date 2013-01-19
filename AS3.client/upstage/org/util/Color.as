package org.util 
{
	/**
	 * Added for smooth transition to AS3, as color was used extensively. 	 *
	 * @author Shaun Narayan
	 * @version 0.1	 */

    import flash.display.*;
    import flash.events.*;
    import flash.geom.ColorTransform;
    import org.Client;
 
    public class Color 
	{
 
        // Constants:
        public static var CLASS_NAME : String = "Color";
        public static var LINKAGE_ID : String = "org.util.Color";  
 		public static var DEF_COL	 :Object = {ra:0,ga:0,ba:0,aa:0,rb:0,gb:0,bb:0,ab:0};
 		private var transform :ColorTransform;
 		private var obj:Object;
        /**
        * Constructor
        *
        * @usage
        *           var __Color:Color = new Color ( this );
        * @param    $targetObj      a reference to a movie clip or object
        */
        public function Color(targetObj:DisplayObject=null, colorValue:Object = null):void 
        {
            // trace ( LINKAGE_ID + ' class instantiated');
            if (targetObj == null || colorValue == null) { return; }
            targetObj.transform.colorTransform = toColorTransform(colorValue);
            obj = targetObj;
        }
        public function toColorTransform(obj:Object) :ColorTransform
        {
        	return new ColorTransform(obj.ra, obj.ga, obj.ba, obj.aa, obj.rb, obj.gb, obj.bb, obj.ab);
        }
    } // end class
	 
} // end package