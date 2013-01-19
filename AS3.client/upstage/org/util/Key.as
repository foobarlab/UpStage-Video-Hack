package org.util
{
	/**
	 * Another AS2/AS3 Transition class. Mimics Key.isDown() featurism.
	 * 
	 * @author Shaun Narayan
	 * @version 0.1
	 * @modified
	 * @see
	 * @note	 */
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.Stage;
	
	public class Key
	{
		public static var _keys:Array = new Array();
		//Add key constants here
		public static var SHIFT:Number = 16;
		
		
		public static function key(stage:Stage) :void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}
		public static function handleKeyDown(evt:KeyboardEvent):void
		{
		    if (_keys.indexOf(evt.keyCode) == -1)
		    {
		        _keys.push(evt.keyCode);
		    }
		}
		
		public static function handleKeyUp(evt:KeyboardEvent):void
		{
		    var i:int = _keys.indexOf(evt.keyCode);
		
		    if (i > -1)
		    {
		        _keys.splice(i, 1);
		    }
		}
		
		public static function isDown(key:int):Boolean
		{
		    return _keys.indexOf(key) > -1;
		}
	}
}