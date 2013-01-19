package org {
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
    
    import org.Transport;
    import flash.net.*;
    /**
     * Author: 
     * Purpose: Send messages to server.
     * Modified by: Endre Bernhardt, Phillip Quinlan, Lauren Kilduff
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - also modified all methods to send data in an array rather
     * 								than allowing variable length argument lists.
     * Notes: 
     */
    
    
    public class Sender {

        private var transport :Transport;  // Handle to transport
        private var iCount      :Number;
    
        /**
         * @brief Constructor
         */
        public function Sender(transport :Transport)
        {
            this.transport = transport;
            trace('Sender constructor...');
            this.iCount = 0;
        }
    
    
        /**
         * @brief Encode a message & send via <code>Transport</code>
         */
        private function send(info :Array) :void

        {
            // Convert public function parameters into a LoadVars object
            var msg: URLVariables = new URLVariables();
            
            msg['mode'] = info[0];
            var k :String, v :String;
            var i: Number;
            //note: starts at i=1, because mode is at 0
            for(i = 1; i < info.length; i += 2)
            {
            k = info[i];
            v = info[i + 1];
            msg[k] = v;
            }
    
            trace('SENDING: ' + msg);
            // Send message to server
            this.transport.send(msg);
        };
    
    
    
        /**
         *  @brief Confirm identity with MD5 key
         *        MD5 Key received by auth, third step in handshaking
         */
        public function IDENT(msg :Object) :void
        {
        	var info:Array = ['IDENT',  'MD5', msg];
            this.send(info);
        };
    
    
        /**
         *  @brief Request to join the named stage
         *        final step in handshaking
         */
        public function JOIN(stageID :Object) :void
        {
        	var info:Array = ['JOIN', 'stage_ID', stageID];
            this.send(info);
        };
    
    
        /**
         *  @brief Send a message to server - does nothing, but does get written
         *        to server side log
         */
        public function NB(msg :String) :void

        {
            //var msg2 :String = arguments.join();
            var info:Array = [ 'NB', 'msg', msg];
            this.send(info);
        };
    
    
        /**
         *  @brief Send text to the chat log (all users)
         */
        public function TEXT(msg :String) :void
        {
        	var info:Array = [ 'TEXT', 'msg', msg];
            this.send(info);
        };
    
    
        /**
         *  @brief Select a new background for the stage
         */
        public function BACKDROP(bgID :Number) :void
        {
        	var info:Array = [ 'BACKDROP', 'ID', bgID];
            this.send(info);
        };
    
    
        /**
         *  @brief User picked up an avatar
         */
        public function AV(avID :Number) :void
        {
        	var info:Array = [ 'AV', 'ID', avID];
            this.send(info);
        };
    
    
        /**
         * @brief User picked up a prop
         */
        public function PROP(propID :Number) :void
        {
        	var info:Array = [ 'PROP', 'ID', propID];
            this.send(info);
        };
    
    
        /**
         * @brief User placed an avatar
         */
        public function MOVE(x :Number , y :Number) :void
        {
        	var info:Array = [ 'MOVE', 'X',x, 'Y',y];
            this.send(info);
        };
    
    
        /**
         * @brief User sent an avatar on a walk to a destination
         */
        public function MOVETOWARD(x :Number, y :Number) :void
        {
        	var info:Array = [ 'MOVETOWARD', 'X', x, 'Y', y];
            this.send(info);
        };
    
    
        /**
         *  @brief User renamed their current avatar
         *  NOTE changes last only until the stage is reset
         */
        public function RENAME(name :String) :void
        {
        	var info:Array = [ 'RENAME', 'name', name];
            this.send(info);
        };
    
    
        /**
         *  @brief Used to change the properties of an avatar
         *  Toggle visibility of names for now
         */
        public function AVPROPERTIES(avID :Number, showName :Boolean) :void
        {
            //some day there might be more than 'showName'
            var show_name :String = (showName==true ? 'show' : 'hide');
            var info:Array = ['AVPROPERTIES', 'ID', avID, 'show_name', show_name];
            this.send(info);
        };
        
        public function AVLAYER(id: Number, newLayer:Number) :void
        {
        	var info:Array = ['AVLAYER', 'ID', id, 'newlayer', newLayer];
            this.send(info);    
        }
    
    	/*------------ Moveable Drawing Methods ----------*/
    	
    	/**
    	 * @brief: Create moveable drawing ids
    	 * Natasha & Thomas 
    	 */
    	public function CREATE_DRAWING_ID(avID :Number) :void
    	{
    		var info:Array = ['CREATE_DRAWING_ID','ID', avID];
    		this.send(info);
    	};
    
        /**
         * @brief Client requested to drop avatar
         */
        public function EXIT(avID :Number) :void
        {
        	var info:Array = [ 'EXIT', 'ID', avID];
            this.send(info);
        };
    
    
        /**
         * @brief Client asked for details of current stage
         */
        public function DETAILS() :void
        {
        	var info:Array = ['DETAILS' ];
            this.send(info);
        };
    
    
        /**
         * @brief Client asked for license details
         */
        public function INFO() :void
        {
        	var info:Array = ['INFO'];
            this.send(info);
        }
    
        /**
         * @brief Client asked to whisper to other client(s)
         */
        public function WHISPER(msg :String) :void
        {
        	var info:Array = ['WHISPER', 'msg', msg];
            this.send(info);
        }
        
        /**
         * @brief Player has initiated a vote.
         */
         public function VOTE(msg :String) :void
         {
         	var info :Array = ['VOTE', 'msg', msg];
         	this.send(info);
         }
    
        /**
         * @breif send a thought
         */
        public function THINK(thought:String):void
        {
        	var info:Array = ['THOUGHT', 'thought', thought];
            this.send(info);
        }
        
        /**
         * @brief send a shout 
         * Wendy, Candy and Aaron -30/10/08
         * Shout Feature
         */
        public function SHOUT(shout:String):void
         {
         	var info:Array = ['SHOUT', 'shout', shout];
             this.send(info);
         }
        
        /**
         * LK added 24/9/07 
         * @brief displays the volunteer btn
         */
        public function VOLUNTEER()
        {
            //var volunteer : Boolean;
            //if (!Transport.isVolunteer()){
            //    this.transport.VOLUNTEER();
            var info:Array = ['VOLUNTEER', 'volunteer', ''];
            this.send(info);
            ////    Transport.volunteer = true;
            //    this.TEXT("Volunteer: " + Transport.volunteer);    
            //}else{
            //    this.NO_VOLUNTEER();
            //    this.TEXT("volunteer unavailable now");    
            //}
        }
    
        /**
         * LK added 31/10/07 
         * @brief hides the volunteer btn
         */
        public function NO_VOLUNTEER()
        {
            //this.transport.send("volunteer unavailable now");
            var info:Array = ['NOVOLUNTEER', 'novolunteer', ''];
            this.send(info);
        }
        
        
        public function VOL_LET_GO()
        {
            Transport.volunteer = false;
            this.transport.VOL_LET_GO();
            this.iCount = 0;
        }
        
        /**
         * LK added 31/10/07
         * @brief Shows volunteer view
         */
        public function BecomeVolunteer(): void
        {
            //this.transport.send("volunteer unavailable now");
            this.transport.VolunteerBtnClicked();
        }
        
        /**
         * LK added 17/10/07
         * @brief Show applause button
         */
        public function APPLAUSE()
        {
            //this.transport.APPLAUSE();
            var info:Array = ['APPLAUSE', 'applaud', ''];
            this.send(info);
        }
        
        /**
         * LK added 29/10/07
         * @brief Hide Applause button
         */
        public function NO_APPLAUSE()
        {
            //this.transport.APPLAUSE();
            var info:Array = ['NOAPPLAUSE', 'noapplaud', ''];
            this.send(info);
        }
    
        /**
         * @brief Client asked to select the frame for avatar
         */
        public function FRAME(frameNumber: String): void
        {
        	var info:Array = ['FRAME','frameNumber', frameNumber];
             this.send(info);
        }
        
        
        /** Aaron 1/5/08
         * @brief Client asked to change backdrop frame
         */
         public function BACKDROP_FRAME(frameNumber: String): void
         {
         	var info:Array = ['BACKDROP_FRAME', 'frameNumber', frameNumber];
             this.send(info);    
         }
    
        // PQ & LK: Added to play the applause sound
        public function PLAY_APPLAUSE(fileName: String): void
        {
            trace('got to PLAY_APPLAUSE in sender.as')
            var info:Array = ['PLAY_APPLAUSE', 'file', fileName];
            this.send(info);
        }
    
        // EB: Added to play sound effects
        public function LOAD_EFFECT(fileName: String): void
        {
            trace('got to PLAY_EFFECT in sender.as') // PQ: Added
            var info:Array = ['LOAD_EFFECT', 'file', fileName];
            this.send(info);
        }
    
        // PQ: Added to play music
        public function LOAD_MUSIC(fileName: String): void
        {
            trace('got to PLAY_MUSIC in sender.as') // PQ: Added
            var info:Array = ['LOAD_MUSIC', 'file', fileName];
            this.send(info);
        }
        
        public function PLAY_CLIP(array:String, url:String): void
        {
        	var info:Array = ['PLAY_CLIP', 'array', array, 'url', url];
            this.send(info);
        }
        
        // AC (03.06.08) - Spreads the word to pause a sound.
        public function PAUSE_CLIP(array:String, url:String): void
        {
        	var info:Array = ['PAUSE_CLIP', 'array', array, 'url', url];
            this.send(info);
        }
        
        // AC (03.06.08) - Spreads the word to set a sound to loop.
        public function LOOP_CLIP(array:String, url:String): void
        {
        	var info:Array = ['LOOP_CLIP', 'array', array, 'url', url];
            this.send(info);
        }
    
        // EB 22/10/07: For broadcasting volume changes
        public function ADJUST_VOLUME(url:String, type:String, volume:Number):void
        {
        	var info:Array = ['ADJUST_VOLUME', 'url', url, 'type', type, 'volume', volume];
            this.send(info);
        }
        
        // PQ 29/10/07: For broadcasting stopping one certain audio playing on all clients
        public function STOP_AUDIO(url:String, type:String):void
        {
        	var info:Array = ['STOP_AUDIO', 'url', url, 'type', type];
            this.send(info);
        }
        
        // AC 29.05.08 - Clears AudioSlot
        public function CLEAR_AUDIOSLOT(type: String, url: String)
        {
        	var info:Array = ['CLEAR_AUDIOSLOT', 'type', type, 'url', url];
            this.send(info);
        }        
    
        /** Drawing functions */
    
        public function DRAW_LINE(x:Number, y:Number)
        {
        	var info:Array = ['DRAW_LINE', 'x', x, 'y', y];
            this.send(info);
        }
    
        public function DRAW_MOVE(x:Number, y:Number)
        {
        	var info:Array = ['DRAW_MOVE', 'x', x, 'y', y];
            this.send(info);
        }
    
        public function DRAW_STYLE(thickness:Number, colour:Number, alpha:Number)
        {
        	var info:Array = ['DRAW_STYLE', 'thickness', thickness, 
                      'colour', colour, 'alpha', alpha];
            this.send(info);
        }
    
        public function DRAW_VIS(layer:Number, alpha:Number, visible:Boolean)
        {
        	var info:Array = ['DRAW_VIS', 'layer', layer, 
                      'alpha', alpha, 'visible', visible];
            this.send(info);
        }
    
        public function DRAW_CLEAR(layer:Number)
        {
        	var info:Array = ['DRAW_CLEAR', 'layer', layer];
            this.send(info);
        }
    
        public function DRAW_LAYER(layer:Number)
        {
        	var info:Array = ['DRAW_LAYER', 'layer', layer];
            this.send(info);
        }
    
    
    
        /**
         * @brief Client finished loading images
         */
        public function LOADED() :void
        {
        	var info:Array = ['LOADED'];
            this.send(info);
        }
    
        public function DEBUG(x:Object)
        {
            if (String(x).indexOf('DEBUG') == -1) //else eternal loop!
            var info:Array = ['DEBUG', 'msg', x];
                this.send(info);
        }
    }
}
