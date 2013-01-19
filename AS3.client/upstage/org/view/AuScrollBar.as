package org.view {
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
    
    import org.view.AuScrollBarItem;
    import org.util.UiButton; //PQ: Added 7.10.07
    import org.model.ModelAvatars;
    import org.model.ModelSounds;
    import org.util.ScrollButton;
    import org.thing.Audio;
    import org.util.Construct;
    import org.Client;
    import org.view.AudioSlot;
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
    /**
     * Author: Phill & Endre
     * Created: 7.10.07
     * Modified by: 
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * Purpose: The audio item scrollbar (list box) in the audio widget
     * Notes: BH, WW (AUT 2006) created AvScrollBar.as, we took that and created this class)
     */
    
    public class AuScrollBar extends MovieClip 
    {
        // PQ: Added 7.10.07
        public var actBtn              :UiButton;       // Act button
        // PQ: Added 29.10.07
        public var stopallaudioBtn     :UiButton;       // Stop All Audio button
        public var ti                    :ModelAvatars;
        public var modelsounds  :ModelSounds;
        public var nameLayer             :Number;      // mirror text
        public var layer                 :Number;      // for scroll bar items
        public var icon                  :AuScrollBarItem;
    
        public var startPos              :Number;      // first av currently visible
        public var items                 :Array;       // array of AvatarScrollBarItems
        public var loadCount             :Number;      // So know when to setReady()
        public var avName                :TextField;   // Under mirror
    
        public var layerUp                  :ScrollButton;
        public var layerDown             :ScrollButton;
    
        public var up                    :ScrollButton;   // Buttons on scrollbar
        public var down                  :ScrollButton;   // Buttons on scrollbar
    
        private var audioSlot1 : MovieClip;
        private var audioSlot2 : MovieClip;
        private var audioSlot3  : MovieClip;
            
    
        /**
         * @brief factory
         */
        static public function create(stage :MovieClip, name :String,
                                      layer :Number, x :Number, y:Number,
                                      ti :ModelAvatars, ms:ModelSounds, col:Number) :AuScrollBar
        {
            trace('Called AuScrollBar.create()');
            var out :AuScrollBar = new AuScrollBar();
            out.ti = ti;
            out.modelsounds = ms;
            out.nameLayer = layer + 1;
            out.x = x;
            out.y = y;       
            out.drawUI(ti,ms,col); //PQ: Added 7.10.07 - ti param
    
            // Which items are currently visible in the scrollbar (up / down changes)
            out.startPos  = 0;  // First item to view
            out.loadCount = 0;  // Number of avatars that have finished loading
            out.items    = []; // Array of AuScrollBarItems
            // Setup base movie position & visibility
            out.enabled = true;
            stage.addChild(out)
            return out;
        };
    
        /**
         * @brief draw the various boxes.
         */
        // PQ: Added 7.10.07 - ti param. Added 30.10.07 - ms param.
        private function drawUI(ti:ModelAvatars, ms:ModelSounds, col:Number)
        {
            // PQ: Added 7.10.07
            // Act button for the Audio Widget
            this.actBtn = UiButton.factory(this, Client.BTN_LINE_DRAW, Client.BTN_FILL_DRAW,
                                           'act', 1, 0, Client.WIDGET_BOX_H - 1 * Client.UI_BUTTON_SPACE_H - 1);   
            this.actBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.setAudioMode(false);
            });
            
            // Draw scrollbar
            Construct.uiRectangle(this, Client.AV_SCROLL_X, Client.AV_SCROLL_Y,
                                  Client.AV_SCROLL_WIDTH, Client.AV_SCROLL_HEIGHT, col);
    
            // Set up scroll buttons 
            
            var ausb: AuScrollBar = this;
    
            this.up = ScrollButton.factory(this, 'up', 1, Client.AV_SCROLL_BTN_X, Client.AV_SCROLL_UP_Y);
            this.down = ScrollButton.factory(this,'down', 1, Client.AV_SCROLL_BTN_X, Client.AV_SCROLL_DN_Y);
    
            this.up.addEventListener(MouseEvent.CLICK, function(){
                ausb.moveUp();
            });
    
            this.down.addEventListener(MouseEvent.CLICK, function(){
                ausb.moveDown();
            });
        
            /**
             * EB 22/10/07 - Gutted all of this and replaced it all to use the AudioSlot
             * object
             */
            audioSlot1 = AudioSlot.create(this, 'audioSlot1',
                                            undefined, Client.AU_CONTROL_X, Client.AU_CONTROL_Y, this.modelsounds, col);
    
            audioSlot2 = AudioSlot.create(this, 'audioSlot2',
                                            undefined, Client.AU_CONTROL_X, Client.AU_CONTROL_Y
                                            + Client.AU_CONTROL_HEIGHT - Client.BORDER_WIDTH, this.modelsounds, col);
            /*if (modelsounds) {
                effectSlot2.setSoundController(modelsounds);    
            }*/
            audioSlot3 = AudioSlot.create(this, 'audioSlot3',
                                            undefined, Client.AU_CONTROL_X, 
                                          (Client.AU_CONTROL_Y + Client.AU_CONTROL_HEIGHT - Client.BORDER_WIDTH) * 2, this.modelsounds, col);
            
            if (modelsounds) {
                audioSlot1.setSoundController(modelsounds);    
                audioSlot2.setSoundController(modelsounds);
                audioSlot3.setSoundController(modelsounds);
            }
            
            // PQ: Added 29.10.07
            // Stop All Audio button
            this.stopallaudioBtn = UiButton.Stopallaudiofactory(this, Client.BTN_LINE_STOP, Client.BTN_FILL_STOP,
                                   Client.AUDIO_STOPALLAUDIO_TEXT, 1, Client.UI_BUTTON_WIDTH, Client.WIDGET_BOX_H - 1 * Client.UI_BUTTON_SPACE_H - 1);   
            
            this.stopallaudioBtn.addEventListener(MouseEvent.CLICK, function(){
                trace('pressed Stop All Audio button');
                ms.stopAllAudio();
                var audioSlots: Array = [ausb.audioSlot1, ausb.audioSlot2, ausb.audioSlot3];
    
                for (var i :Number = 0; i < audioSlots.length; i++) {
                    if (audioSlots[i].assignedType) { 
                        audioSlots[i].setStopped(); 
                    }
                }
    
            });
        }
    
    
        /**
         * @brief Called after all movies have loaded
         */
        public function setReady() :void

        {
            trace('AvatarScrollBar.setReady() called');
            /* Sort items list.  You can't use Array.sortOn() directly
             * on MovieClips (which always sort by reference),  
             * so a sort function or Schwartzian transform is necessary
             */
            this.items.sort(function(A: AuScrollBarItem, B: AuScrollBarItem):Number
                {
                   return A.nameof.toLowerCase() <= B.nameof.toLowerCase() ? -1 : 1;            
                }
            );
    
            this.reposition();
        };
    
    
        /**
         * @brief Add an audio to the scrollbar, called by Avatar
         */
        public function addAudio(au: Audio)
        {
            if(au != null){
                trace("addAudio AuScrollBar line 200");
                this.items.push(au.icon);
                this.reposition();
            }
        };
    
        /**
         * EB & PQ 21/10/07 - Added to allow ModelSounds to update the display of what
         * is playing. As URL is the only identifier sent to ModelSounds to make sounds
         * play, 
         * 
         */
        public function updatePlaying(type:String, slot:Number, name:String, url:String)
        {
            trace("AuScrollBar.updatePlaying - type: " + type + ", slot: " + slot + ", url: "+url + ", name: " + name);
            if (type == 'sounds') {
                switch (slot) {
                    case 0:
                        this.audioSlot1.assignAudio(type, url);
                        this.audioSlot1.nametxtField.text = name;
                        break;
                    case 1:
                        this.audioSlot2.assignAudio(type, url);
                        this.audioSlot2.nametxtField.text = name;
                        break;
                        
                    case 2:    
                        this.audioSlot3.assignAudio(type, url);
                        this.audioSlot3.nametxtField.text = name;
                        break;
                }            
    
            }
        }
    
        // EB 31/10/07: Called by ModelSounds to clear a slot once a song
        // has finished playing
        public function clearSlot(type:String, slot:Number) {
            if (type == 'sounds') {
                switch (slot) {
                    case 0:
                        this.audioSlot1.clear();
                        break;
                    case 1:
                        this.audioSlot2.clear();
                        break;    
                    case 2:
                        this.audioSlot3.clear();
                        break;
                }
            }
        }
    
    
        // AC 
        public function getVolume(url:String, type:String):Number 
        {
            return this.getAudioSlot(type, url).slider.value;
        }
    
    
    
        public function updateVolumeFromRemote(type:String, slot:Number, volume:Number) {
            switch (slot) {
                case 0:
                    this.audioSlot1.slider.setFromValue(volume)
                    break;
                case 1:
                    this.audioSlot2.slider.setFromValue(volume)
                    break;    
                case 2:
                    this.audioSlot3.slider.setFromValue(volume)
                    break;
            }
        }
    
        /**
         * @brief Set the position / visibility of scrollbar items
         * based on current start  positions
         */
        public function reposition(): void
        {
            var i: Number;
            var skipped: Number = 0;
            var possibles: Array = [];
            var item :AuScrollBarItem;
            trace("reposition: this.items.length= "+this.items.length);
            //loop throught the items, putting appropriate ones in the
            //possibles array.  If the user's selected avatar would be
            //shown, don't show it, and keep note that on item was
            //skipped.  This helps in the greying of buttons.
            for (i = 0; i < this.items.length; i++)
            {
                //store the item
                item = this.items[i];
                //Modified by Heath Behrens 05/07/2011 - check for null as an exception is thrown on null item
                //make sure the item is not null before using it
                if(item != null){
                    if (i >= this.startPos && possibles.length < Client.DISPLAY_AV) {
                        possibles.push(item);
                    }
                    else {
                        item.hide();
                    }    
                }
            }
            
            //it could be that insufficient were found, if last item was
            //selected.  go back and look for selected ones.
            while(possibles.length < Client.DISPLAY_AV && this.startPos > 0)
                {
                    this.startPos--;
                    var item :AuScrollBarItem = this.items[this.startPos];
                    if (item != this.icon)
                        {
                            possibles.unshift(item);
                        }
                }
            
            //actually show the icons.
            for (i = 0; i < possibles.length; i++)
                {
                    var item :AuScrollBarItem = possibles[i];
                    // Position, show & enable
                    item.x = Client.AV_SCROLL_X + 1;
                    item.y = i * (Client.ICON_SIZE + 1);
                    item.show();
                }
    
            //if first icon is selected, and startPos is at 1,
            // you can't scroll up, but startPos doesn't know
            //
            // likewise, if last icon is selected, and startPos is such
            // that the display ends justbefore it, you can't scroll down.
            // skipped can be set to trigger greying.
    
            if (this.icon == this.items[this.startPos+ possibles.length])
                skipped = 1;
            
            // grey out scroll buttons if at top or bottom.
    
            if (this.startPos == 0 || 
                (this.startPos == 1 && this.icon == this.items[0])){
                this.up.grey();
            }
            else {
                this.up.ungrey();
            }
    
            if (this.startPos + possibles.length + skipped >= this.items.length){
                this.down.grey();
            }
            else {
                this.down.ungrey();
            }
        };
    
    
        /**
         * @brief Move the item at the given index to mirror & hide text field
         */
        public function select(item :AuScrollBarItem): void
        {
            if (this.icon){
                this.icon.unselect();
            }
            this.icon = item;
            item.selectItem();
            reposition();
        };
    
    
        /**
         * @brief Biff the icon off the mirror,
         */
        public function dropAvatar():void

        {
            this.icon.unselect();
            this.icon = null;
            this.avName.text = '';
            reposition();
        };
    
    
        /**
         *  @brief Select the audio at the given ID
         */
        public function choose(icon: AuScrollBarItem): void
        {
            // If the it is available, select it
    
            var filename:String = icon.filename;
            Construct.deepTrace(icon);
            trace('AUDIO TYPE: ' + icon.type);
            // PQ: Added 31.10.07 - If its music, play as music, of effect, play as effect
            // so that the appropriate slots are assigned properly
            // Audio is of type 'sfx' or 'music' here
             if (icon.type == 'music')
             {
                  this.ti.sender.LOAD_MUSIC(filename);
             }
             // Must be a sfx (sound effect)
             else
             {
                this.ti.sender.LOAD_EFFECT(filename);
             }
                    
             this.avName.text = icon.nameof;
        };
    
    
    
        /**
         *  @brief Scroll up one avatar
         */
        public function moveUp(): void
        {
            if (this.startPos > 0)
                {
                    //need to jump up 2 if first one will be hidden, or it apears not to move.
                    if (this.items[this.startPos - 1] == this.icon)
                        this.startPos -= 2;
                    else
                        startPos--;
                
                    this.reposition();
                }
            else{
                trace("can't go up!!");
                this.up.grey();
            }
    
        };
    
    
        /**
         *  @brief Scroll down one avatar
         */
        public function moveDown() : void
        {
            if (this.startPos + Client.DISPLAY_AV < this.items.length)
                {
                    //need to jump down 2 if first one is hidden, or it apears not to move.
                    if (this.items[this.startPos] == this.icon)
                        this.startPos += 2;
                    else
                        startPos++;
                    
                    this.reposition();
                }
            else{
                trace("can't go down!!");
                this.down.grey();
            }
        };
    
    
        /**
         *  @brief Rename an avatar for the duration of the performance
         */
        public function rename(item: AuScrollBarItem, name: String): void
        {
            item.nameof = name;
            item.nameField.text = name;
            
            // Update mirror text if this is the selected item
            if (item = this.icon)
                {
                    this.avName.text = name;
                }
        };
    
    
        /**
         *  @brief Called automatically by AuScrollBarItem when mirror has loaded
         */
        public function loaded() : void
        {
            this.loadCount++;
    
            // Check if all load requests are done
            // Possible race condition with incoming LOAD_AV messages & the speed
            // at which avatars load
            // TODO listen to CONFIRM_READY will stop race condition
    
            // XXX better for server to (early on) send the number of
            // things waiting for load, to the SplashScreen model.  then
            // it can be perfect.
            if (this.loadCount == this.items.length)
            {
                setReady();
            }
        };
    
    
        public function getAudioSlot(type: String, url: String): MovieClip
        {
            var audioSlots: Array = [this.audioSlot1, this.audioSlot2, this.audioSlot3];
            
            for (var i:Number = 0; i < audioSlots.length; i++) {
                if (audioSlots[i].assignedURL == url) {
                    return audioSlots[i];
                }
            }
            return null;
        }
    
        /**
         * @brief turn on/off animator
         */
        public function showFrame(): void
        { 
        }
    
    
        function AuScrollBar(){}
    
    };
}
