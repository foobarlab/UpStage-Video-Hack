package org
{
	/**
	 * Copyright (C) 2003-2006 Douglas Bagnall (douglas * paradise-net-nz)
	 *
	 * This program is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU General Public License
	 * as published by the Free Software Foundation; either version 2
	 * of the License, or (at your option) any later version.
	 *
	 * This program is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * GNU General Public License for more details.
	 *
	 * You should have received a copy of the GNU General Public License
	 * along with this program; if not, write to the Free Software
	 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
	 */

	/**
	 * Information following @mainpage gets put on documentation index.html
	 * Change version in Doxyfile PROJECT_NUMBER also
	 *
	 * @mainpage UpStage Documentation
	 * UpStage release 1.9 -
	 * A student team has contributed to the UpStage project as part of their
	 * final year project
	 *
	 * On a user level the following new features have changed from the
	 * Upstage-2004-09-28.tar.gz release:
	 * +Upstage now renders to 320x200 not 320x240.
	 *	This gets around layout problems when users have many toolbars installed
	 *	in their browsers.
	 *
	 * +A new /command has been added /wh or /whisper which allows players to
	 *	send protected messages to each other no matter which stage the player
	 *	may reside on.
	 *
	 * +Fonts are now embedded in the swf to provide a consistent layout no
	 *	matter what the operating system or browser may be.
	 *
	 * +The avatars are now selected from a scrollbar rather than a wardrobe
	 *	which makes names eaisier to read & allows more possible avatars on a
	 *	stage.
	 *
	 * +Props and backdrop names now appear on mouse over to make things easier
	 *	to read.
	 *
	 * +Misc bugs relating to syncronisation of all clients have been fixed.
	 *
	 * +Avatar voices now overlap.  When more than four avatars attempt to speak
	 *	at the same time, the voice with the least left to say is preempted.
	 *
	 * +Current player & audience count are displayed on screen.
	 *	On a developer level, the entire client side code (ActionScript1) has
	 *	been rebuilt using ActionScript2 and the Model/View/Controller pattern.
	 */

	/**
	 * Entry point for application onLoad called automatically.
	 * See main.mxml
	 * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes(Package declaration, 
	 * removal of _ prefix fields, new moviclip registration method, 
	 * new event handling etc...) - also call to javascript to get init data.
	 * Shaun Narayan (Apr 2010) - Added scale variables to allow stage co-ords to be used in event handlers.
	 */

	import org.util.Construct;
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.text.*;
	import flash.ui.Mouse;

	public class App extends MovieClip
	{
		public static var transport		: Transport;
		public static var debugMsg		: TextField;
		//Shaun Narayan (04/27/10) - Allows conversion of stage co-ords to app
		//							 co-ords
		public static var scaleAmountX	: Number;
		public static var scaleAmountY	: Number;

		/**
		 * @brief Constructor
		 */
		public function App() : void {}

		/**
		 * @brief Called automatically when swf loads
		 * See application.xml
		 */
		public function onLoad() : void
		{
			var url : String = ExternalInterface.call('function(){return document.getElementById("app").data;}');
			//var url : String = root.loaderInfo.loaderURL;
			//Application begins executing here
			if(url.indexOf('mode=DEBUG') >= 0)
			{
				this.createLogger();
			}
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//Create the Transport object which gets things moving
			App.transport = new Transport(this);
			trace('Application constructor done...');
		}

		public function createLogger() : void
		{
			if(Client.LOG_TO_SCREEN)
			{
				var format : TextFormat;
                // Create a text field for debug messages, covering most of the blank space.
                //XXX Flash 8 returns a reference to the field, but Flash 7 does not.
				debugMsg = Construct.formattedTextField(this, 'debugMessages',
							Client.L_DEBUG, 5, 5, Client.RIGHT_BOUND - 10,
							Client.BOTTOM_BOUND - 10, 0.9, false, {}, {});
				debugMsg.border = true;
				debugMsg.wordWrap = true;
				debugMsg.borderColor = 0x0000cc;
				debugMsg.alpha = 50;        
				debugMsg.text = 'debug messages...';
			}
		}

		public static function debug(x : Object) : void
		{
			if(Client.LOG_TO_SCREEN && debugMsg != null)
            {     
				var scrollV : Number = debugMsg.scrollV;
				var bottomish : Boolean = (debugMsg.maxScrollV - scrollV < 5);
				//replaceText is much faster than debugMsg.text += '\n' + x;
				var len : Number = debugMsg.length;
				debugMsg.replaceText(len, len, '\n' + x);
				debugMsg.scrollV = (bottomish) ? debugMsg.maxScrollV : scrollV;
			}
			if(Client.LOG_TO_SERVER)
			{
				transport.sendDebug(x);
			}
		}

		/**
		 * @brief Used to move the avatars around the stage
		 */
		public function onMouseUp(e : MouseEvent) : void
		{
			App.transport.clicker(e.stageX / scaleAmountX, e.stageY / scaleAmountY);
		}
	}
}