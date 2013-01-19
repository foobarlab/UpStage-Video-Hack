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
     * Module: newSound.as
     * Created: 20.05.08
     * Author: Alan Crow - 2007/2008 AUT UpStage Team
     * Modified: Shaun Narayan (01/27/10) - Audio Pallete bug fix (AUT UStage team 09/10)
     *              Shaun Narayan (01/29/10) - Added methods to allow music to be started at a specified point.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * Purpose: To allow from much better control over the audio files.
     * Notes:
     */
    
    import flash.media.*;
    import flash.net.*;
    public class newSound extends Sound
    {
        private var bPlaying    :Boolean;
        private var bStopped    :Boolean;
        private var bLooping    :Boolean;
        private var pausePoint :Number;
        public var type            :String;
        public var myURL            :String;
        private var channel			:SoundChannel;

        /**********************************************************
        *    Constructor
        **********************************************************/
        
        function newSound() {
            super();
            //Added: Heath initializes a sound channel
            this.channel = new SoundChannel();
            trace("Creating newSound");
            this.updateState(false, true);

            //this.setLooping(false);
            trace("new Sound created");
        }
        
        /**********************************************************
        *    Local Methods
        **********************************************************/
    
        /**function loadSound(url: String, true: Boolean) {
            super.loadSound(url, true);
            this.updateState(true, false);
            trace("LOAD SOUND ::::::> isPLaying: " + this.isPlaying());
        }*/
        /**
         * Shaun Narayan (1/27/10) - New version of loadSound() which actually accepts
         * a boolean and loads the sound as playing or stopped. Fixes audio pallete bug.
         */
        public function loadSound(url: String, playNow: Boolean) :void
        {
            super.load(new URLRequest(url));
            if(playNow) play();
            this.updateState(playNow, !playNow);
            trace("LOAD SOUND ::::::> isPLaying: " + this.isPlaying() + "URL = " + url);
        }
    	
        public override function play(startTime:Number  = 0, loops:int  = 0, sndTransform:SoundTransform  = null):SoundChannel 
        {
        	if(bLooping) loops = 100;
            this.updateState(true, false);
            //SoundChannel sc = new SoundChannel();
            channel = super.play(startTime, loops);
            return channel;
        } 
        
        public function pause() :void {
            pausePoint = channel.position;
            channel.stop();
            this.updateState(false, false);
        }
        
        public function resume() :SoundChannel
        {
            this.updateState(true, false);
            channel =  play(pausePoint);
            return channel;
        }

        public function stop() :void {
            //this.setLooping(false);
            channel.stop();
            this.updateState(false, true);
        }
        
        /**
        public function setLooping(bLooping : Boolean) : void 
        {
            this.bLooping = bLooping;
            trace("setLooping");
            var pos : Number = channel.position;
            play(pos);
            channel.stop();
        }*/
        
        public function isPlaying(): Boolean {
            return this.bPlaying;
        }
        
        public function isPaused(): Boolean {
            return ((this.bPlaying == false) && (this.bStopped == false));
        }
        
        public function isLooping(): Boolean {
            return this.bLooping;
        }
        
        public function updateState(bPlay: Boolean, bStop: Boolean) :void
        {
            this.bPlaying = bPlay;
            this.bStopped = bStop;
        }
        
        /**********************************************************
        *    Event Methods
        **********************************************************/
                
    }
     
}
