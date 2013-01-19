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
    import org.util.Construct;
    import org.model.TransportInterface;
    import org.Sender;
    import org.thing.Audio;
    import org.view.AuScrollBar;
    
    import org.util.newSound;
    import flash.display.*;
    import flash.utils.*;

    /**
     * Module: ModelSounds.as
     * Author: Douglas Bagnall
     * Highly Modified by: Endre Bernhart, Phillip Quinlan, Lauren Kilduff, Alan Crow
     * Play streaming sounds from the server
     * Play a maximum of MAX_SOUND sounds at once
     * When more than MAX_SOUNDS are requested, makes a decision on which to kill.
     * Basically looks at how long sounds have left to run and chooses the one
     * that has the least amount of time left
     *
     * @modified: Shaun Narayan (01/27/10) - Audio Pallete bug fix (AUT UStage team 09/10)
     *            Shaun Narayan (01/29/10) - Added ability to queue music and play once client is set up.
     * 			  Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...)
     * Sound objects are created once & reused
     *            Heath Behrens, Vibhu Patel - Added code that actually reuses the slots and assigns audio correctly.     
     *
     */
    
    public class ModelSounds implements TransportInterface 
    {
        private var audioScrollBar  : AuScrollBar;
        public var audios        :Array;
        
        //arrays of sound objects for each pool.
        private var speeches    :Array;  
        private var effects     :Array;   
        private var music       :Array;
        
        private var sounds        :Array;
        
        // PQ & LK: Added 31.10.07    
        private var applause    :Array;    
        
        //offsets to the next to be tried in each pool (cycles, unless pool is full)
        private var nextSpeech  :Number;
        //private var nextEffect  :Number;
        //private var nextMusic   :Number;
        private var nextSound    :Number;
        
        // PQ & LK: Added 31.10.07
        private var nextApplause   :Number
        private var sender         :Sender;

        //Shaun Narayan (01/30/10)These should be arrays so multiple songs can be played (after it works)
        private var ready           : Boolean
        private var waitingURL      : String;
        private var waitingPosition : Number;


        /*
         * utility function for getSoundArray it can't be inlined or
         *there'd be scoping trouble for the objects in the event
         * callbacks
         */
        /*static function getSoundObject():Object
        {
            var o: Object = { sound: null };
            return o;
        }*/
    
        public static function getSoundArray(n:Number):Array
        {
            // Fill the sound array with sound objects to use.
            var a:Array = [];
            for (var i:Number = 0; i < n; i++){
                a.push(null);
            }
            return a;
        }
        
        /************************************************************************
         * 
         * @brief Constructor
         * 
         ************************************************************************/
         
        public function ModelSounds(sender: Sender)
        {        
            // Set up sound arrays
            this.speeches = ModelSounds.getSoundArray(Client.SPEECH_SOUNDS);
            this.sounds = ModelSounds.getSoundArray(Client.AUDIO_SOUNDS);        
            
            // PQ & LK: Added 31.10.07
            this.applause = ModelSounds.getSoundArray(Client.APPLAUSE_SOUNDS);
            this.nextSpeech = 0;
    
            // AC: Added 10/09/08
            this.nextSound = 0;
            
            // PQ & LK: Added 31.10.07
            this.nextApplause = 0;
            this.sender = sender;
            this.audios = new Array();
        };
        
        
        public function setAudioScrollbar(scrollbar : AuScrollBar) {
            this.audioScrollBar = scrollbar;
        }
    
        // PQ: Added 23.9.07 - Added dummy drawScreen to make Audio work
        public function drawScreen(parent :MovieClip) :void {

        }
        
        public function confirmReady(){
            ready = true;
            trace(waitingPosition);
            if(!isNaN(waitingPosition))
            {
                trace("INDA IF");
                loadMusic(waitingURL);
                remotePlayClip('sounds', waitingURL, waitingPosition);
            }
            trace("SOUNDS CONFIRMED READY");
        }
        
        public function addWait(url:String, position:Number){
            waitingURL = url;
            waitingPosition = position;
        }
    
        //============================== Local Audio methods ==============================
        /**
         * @brief called by the various playX functions.
         * Looks first for an unused sound slot.
         * if one is not found it looks for the next one due to finish.
         * if that doesn't work it goes with its original preference:
         * the one after the previously started one in the circular buffer.
         */
        private function _playSound(url : String, arrayName : String,  counterName : String)
        {

            var slot : Number = undefined;
            var sounds : Array = this[arrayName];
            var bAlready : Boolean = false;
            var counter : Number = 0; //heath/vibhu used to keep track of the number of slots used.
            
            trace("Sounds length: " + sounds.length + "\nURL: " + url + "\nCounter name: " + counterName);
            //loops through the slots and if they are not null it increments the counter.
            for(var x : Number = 0; x < sounds.length; x++){
                if (sounds[x] == null){
                    //do nothing.
                }
                else{
                    counter++; //Added by: Vibhu / Heath.
                }
                
            }

            //Added by: Vibhu / Heath. Checks if the conter is within 2 of the length of sounds if it is.
            //sets all previous slots back to null Fix for text-to-speech bugs
            if(counter == sounds.length - 2){
                trace("reset");

                for(var hv : Number = 0; hv < sounds.length; hv++){
                    sounds[hv] = null;
                }
                trace("assigned sounds to null");
            }

            //trace(bAlready);
            /* EB & PQ 31/10/07: if the item at sounds[url] is not 
               undefined, then the sound is already queued.*/
            if (!bAlready) {
    
                var offset: Number = this[counterName];
                
                for (var i: Number = 0; i < sounds.length; i++){
                    var j: Number = (offset + i) % sounds.length;
                    trace('j ' + j);
                    if (sounds[j] == null){
                        slot = j;
                        break;
                    }
                }  
        
                if (isNaN(slot)) { //all playing - got to try something different
    
                    var now:Number = getTimer();
                    var shortest:Number = 1e100; 
                               
                    for (var i: Number = 0; i < sounds.length; i++) {   
                        if (sounds[i]) { //loaded 
                            var remaining :Number = sounds[i].duration - sounds[i].position;
                                
                            if (remaining < shortest){
                                shortest = remaining;
                                slot = i;
                            }
                        }
                    }   
                }                     
        
                if (isNaN(slot)) //still no luck (all loading?). go for default
                    slot = offset;
                trace("creating newSound slot= "+slot)
                sounds[slot] = new newSound();
                sounds[slot].myURL = url;
                sounds[slot].type = arrayName;
                
                //Shaun Narayan (01/27/10)
                //Added following line to load audio before its played. (part of Audio pallete bug fix)
               
                if (arrayName == 'speeches') {
                   sounds[slot].loadSound(url, true);
                } else { //Moved for clarity
                	sounds[slot].loadSound(url, false);
                }
    
                trace("using slot of " + slot);
                Construct.deepTrace(sounds[slot]);
                this[counterName] = (slot + 1) % sounds.length;
            }
        }

        /* EB & PQ: 31/10/07: Called by the onSoundComplete sound event handler to
           clear a slot when the sound has finished playing. */
        public function clearSlot(type:String, url:String)
        {
            trace("clearSlot() type = " + type + "and url = " + url);
    
            var sounds:Array = this[type];
    
            for (var x:Number = 0; x < sounds.length; x++) {
                if ((sounds[x].url == url) && (sounds[x] != null)) {
    
                    // Clear these things
                    sounds[x] = null;
    
                    this.audioScrollBar.clearSlot(type, x);
                    // Clear slot for all clients
                    this.sender.CLEAR_AUDIOSLOT(type, url);
                }
            }
        }
    
    
        /**
         * EB & PQ 21/10/07 - For updating the scrollbar based on what
         * happened in _playSound.
         */
        public function updateScrollbar(type:String, slot:Number, url:String)
        {
            var filename:String = url.substring(url.lastIndexOf("/")+1);
            var audioName:String = this.audios[filename].name;
            this.audioScrollBar.updatePlaying(type, slot, audioName, url);
        }
    
    
        // PQ: Added 30.10.07 - Stops ALL currently playing audio if click on Stop All Audio
        public function stopAllAudio()
        {
            var clips: Array = this['sounds'];
            var bStop:Boolean = true;
            
            for (var i: Number = 0; i < clips.length; i++) {
                if (clips[i].url) {
                    clips[i].stop();
                    
                    // Stop the audio on all clients
                    this.sender.STOP_AUDIO(clips[i].url, clips[i].type);
                    
                    // Clear all the audio slots
                    this.clearSlot(clips[i].type, clips[i].url);
    
                }
            }
        }
        
        
        // PQ: Added 29.10.07 - Stops the audio if click on stop
        public function stopClip(array:String, url:String, bPause:Boolean)
        {
            var clip: Object = this.getClip(array, url);
            trace(bPause);
            if (clip.isPlaying()) {        
                // Stop the audio on this MACHINE that pressed the stop button
                clip.stop();
            }
                        
            // Stop the audio on all clients
            this.sender.STOP_AUDIO(url, array);            
                            
            // Only clear if paused is not pressed clear AFTER remoteStop call.
            this.clearSlot(array, url);
        }
    
    
    
        public function playClip(array: String, url: String)
        {
            var clip: Object = this.getClip(array, url);
    
            if (clip.isPaused()) {
                trace("RESUMING AUDIO");
                clip.resume();
            }
            else
            {
                //Shaun Narayan (27/01/10) - Changed to only play audio as opposed to load.
                trace("PLAYING AUDIO");
                // Play the audio on this MACHINE that pressed the play button
                clip.play();        
                //clip.loadSound(url, true);
                // Volume must be set once the sound file has started playing.
                clip.setVolume(this.audioScrollBar.getVolume(url, array));
            }
            
            // AC (03.06.08) - Changes the state of the audioslot buttons. 
            this.audioScrollBar.getAudioSlot(array, url).setPlaying();
            this.sender.PLAY_CLIP(array, url);
        }
        
        
        // AC (03.06.08) - Pauses the selected sound.
        public function pauseClip(array:String, url:String)
        {
            var clip: Object = this.getClip(array, url);
            if (clip.isPlaying()) {
                trace("PAUSING AUDIO");
                clip.pause();
                this.sender.PAUSE_CLIP(array, url);
            }
        }
        
        
        // AC (02.06.08) - Sets the selected sound to loop.
        public function loopClip(array:String, url:String)
        {
            var clip: Object = this.getClip(array, url);
            trace("LOOPING IS : " +clip.isLooping());
            if (clip.isLooping() == false) {
                trace("LOOPING AUDIO");
                clip.setLooping(true);
                this.sender.LOOP_CLIP(array, url);
            }
        }
                
    
        public function updateVolume(array:String, url:String, volume:Number)
        {
            // Ensure only audio slot sounds are adjusted
            if (array == 'sounds') {
                var clip: Object = this.getClip(array, url);
                clip.setVolume(volume);
                this.sender.ADJUST_VOLUME(url, array, volume);
            }
        }
        
    
        /* @brief play a speech file 
           Called by transport.WAVE
         */
        public function playSound(url : String)
        {
            this._playSound(url, 'speeches', 'nextSpeech');
        };
    
    
        /**
         * @brief Play streaming sound effects from the server
         * Called by transport.EFFECT
         */
        public function loadEffect(url :String)
        {
            this._playSound(url, 'sounds', 'nextSound');
            //this._playSound(url, 'effects', 'nextEffect');
        };
        
    
        /**
         * @brief Play streaming music from the server
         * Called by transport.MUSIC
         */
        public function loadMusic(url :String)
        {
            this._playSound(url, 'sounds', 'nextSound');
            //this._playSound(url, 'music', 'nextMusic');
        };
        
         /**
         * @brief Play streaming applause from the server
         * TODO Not implemented on server side & completely untested
         * Called by transport.APPLAUSE_PLAY
         */
        public function playApplause(url :String)
        {
            this._playSound(url, 'applause', 'nextApplause');
        };
        
        /**
        * Modified by Heath Behrens 05/07/2011. Check for null.
        */
        public function GET_LOAD_AUDIO(ID :Number, name :String, url :String, type :String)
        {
            var au :Audio;
            au = Audio.factory(ID, name, url, type, this.audioScrollBar);
            //null check as if less than 3 audio files present null is thrown.
            if(au != null){
                trace('Audio loaded with id: '+ ID + ', name ' + name + ', url ' + url + ', type ' + type);
                this.audios[url] = au; // To be used when updating the audioscrollbar (see updateScrollbar())
                this.audioScrollBar.addAudio(au);    
            } else{
                trace("GET_LOAD_AUDIO is null. ModelSounds.as line 433.");
            }
            trace("end function GET_LOAD_AUDIO");
        }
        
        
        // AC (03.06.08) - Gets the choosen sound clip based on url.
        public function getClip(arrayName:String, url:String): Object
        {
            var clips:Array = this[arrayName];
            for (var i:Number = 0; i < clips.length; i++) {
                if (clips[i].url == url) {
                    return clips[i];
                }
            }
            return null;
        }
        
        
         //============================== Remote Audio methods ==============================
    
         
         
        /***********************************************************************
         * Remote Volume Control - Audio Method
         * 
         * Description: Remotely updates the current audio files volume.
        **********************************************************************/
         
        public function remoteVolumeControl(array:String, url:String, volume:Number)
        {        
            if (array == 'sounds') {
                var clip: Object = getClip(array, url);
                clip.setVolume(volume);
            
                for (var i:Number = 0; i < this[array].length; i++) {
                    if (this[array][i].url == url) {
                        this.audioScrollBar.updateVolumeFromRemote(array, i, volume);
                    }
                }
            }
        }
        
        
        /**
         * Remote Stop - Audio Method
         * 
         * Author: PQ - 20.10.07
         * Description: Method to stop audio of clients, now this can also 
         * stop ALL currently play audio as well
         **/ 
        
        public function remoteStopAudio(array:String, url:String)
        {        
            var clip: Object = this.getClip(array, url);
            
            // If the stop command is for ONE audio only
            if (url != '')
            {
                trace("REMOTE STOP AUDIO");
                if (clip.isPlaying()) {
                    // Stop the audio on this MACHINE that pressed the stop button
                    clip.stop();
                }
                
                this.clearSlot(array, url);
                
            }
            // If the stop command is for ALL currently playing audio
            else
            {
                trace("REMOTE STOP ALL");
                var clips:Array = this[array];
                var type: String = array;
    
                for (var k:Number = 0; k < clips.length; k++)
                {
                    // Stop the audio on this MACHINE that pressed the stop button
                    clips[k].stop();
                    this.clearSlot(type, clips[k].url);
                    this.audioScrollBar.getAudioSlot(type, clips[k].url).setStopped();
                }
            }
        }
        
        
        /***********************************************************************
         * Remote Play - Audio Method
         * 
         * Description: This method is called remotely by another client
         * and starts an already assigned audio file.
         **********************************************************************/ 
         /**
          * Shaun Narayan (01/28/10) - Added position parameter to allow music to be
          * played from mid-way through (Entering a stage).
          */
        public function remotePlayClip(array:String, url:String, position:Number)
        {    
            trace("URL = "+url);
            var clip: Object = this.getClip(array, url);
    
            if (clip.isPlaying() == false) {
                if (clip.position > 0) { 
                    trace("REMOTE RESUME AUDIO");
                    clip.resume();
                }
                else {
                    trace("REMOTE PLAY AUDIO");
                    // Play the audio on this MACHINE that pressed the stop button
                    clip.startAt(position);
                    clip.focus();
                }
                
                clip.setVolume(this.audioScrollBar.getVolume(url, array));
                this.audioScrollBar.getAudioSlot(array, url).setPlaying();    
                this.audioScrollBar.getAudioSlot(array, url).focus();
                this.sender.PLAY_CLIP(array, url);
            }        
        }
        
        // AC (03.06.08) - Remotely pauses an audio file
        public function remotePauseClip(array:String, url:String)
        {
            var clip: Object = this.getClip(array, url);
            if (clip.isPaused() == false) {
                trace("REMOTE PAUSE AUDIO");
                clip.pause();
                this.audioScrollBar.getAudioSlot(array, url).setPaused();
            }
        }
        
        // AC (03.06.08) - Remotely sets an audio file to loop
        public function remoteLoopClip(array:String, url:String)
        {
            var clip: Object = this.getClip(array, url);
            if (clip.isLooping() == false) {
                trace("REMOTE LOOP AUDIO");
                clip.setLooping(true);
            }
        }
	}
}
