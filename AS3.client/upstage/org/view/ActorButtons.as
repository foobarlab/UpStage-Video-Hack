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
    
    import org.model.TransportInterface;
    import org.util.UiButton;
    import org.util.Construct;
    import org.Client;
    import flash.display.*;
	import flash.events.*;
    
    
    /**
     * Module: ActorButtons.as
     * Author: BH
     * Modified by: PQ
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * 			Shaun Narayan (12/05/10) - Added method to allow external speed setting, and fixed slow/fast
     * 										button issue (event scope issue).
     * Purpose: Wrapper for a panel of buttons
     *         Reside on a wrapper MovieClip to allow easy show / hide
     *
     */
    
    public class ActorButtons extends MovieClip 
    {
        private var clearBtn   :UiButton;
        private var dropBtn    :UiButton;
        private var nameBtn    :UiButton;
        private var fastBtn    :UiButton;
        private var slowBtn    :UiButton;
        private var stopBtn    :UiButton;
        private var drawBtn    :UiButton;
        private var audioBtn   :UiButton; // PQ: 22.9.07
    
        /**
         * @brief Messy constructor override required to extend MovieClip
         */
        static public function create(parent :MovieClip, name: String,
                                      layer :Number, x :Number, y :Number,
                                      ti:TransportInterface, col:Number) :ActorButtons
        {
            var out :ActorButtons = new ActorButtons;
            //out = ActorButtons(parent.attachMovie(ActorButtons.symbolName, name, layer));
            out.x = x;
            out.y = y;
    
            Construct.uiRectangle(out, 0, 0, Client.AV_UI_BUTTON_W,
                                  Client.AV_UI_BUTTON_H, col);
            parent.addChild(out);
            out.draw(ti);
            return out;
        }
    
    
        /**
         * @brief Called automatically by create
         */
        private function draw(ti:Object)
        {
            var that: ActorButtons = this; //for event scope delegation
    
            this.dropBtn = UiButton.factory(this, Client.BTN_LINE_DROP, Client.BTN_FILL_DROP, 'drop', 1,
                                            Client.UI_BUTTON_SPACE_W, Client.UI_BUTTON_SPACE_H);
            this.dropBtn.addEventListener(MouseEvent.CLICK,  function(){
                ti.SET_EXIT();
            });
    
            this.clearBtn = UiButton.factory(this,  Client.BTN_LINE_CLEAR,
                                             Client.BTN_FILL_CLEAR, 'clear', 1,
                                             2 * Client.UI_BUTTON_SPACE_W, Client.UI_BUTTON_SPACE_H);
            this.clearBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.SET_EXIT_ALL();
            });
    
            this.nameBtn = UiButton.factory(this, Client.BTN_LINE_NAME, Client.BTN_FILL_NAME, 'name', 1,
                                            2 * Client.UI_BUTTON_SPACE_W, 0);
            this.nameBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.SET_SWITCH_AV_NAME();
            });
    
            this.drawBtn = UiButton.factory(this, Client.BTN_LINE_DRAW, Client.BTN_FILL_DRAW, 'draw', 1,
                                            0, Client.UI_BUTTON_SPACE_H);
            this.drawBtn.addEventListener(MouseEvent.CLICK, function(){
                trace('pressed draw button');
                ti.setDrawMode(true);
            });
    
            this.stopBtn = UiButton.factory(this, Client.BTN_LINE_STOP, Client.BTN_FILL_STOP, 'stop', 1,
                                            Client.UI_BUTTON_SPACE_W, 0);
            this.stopBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.SET_STOP();
            });
    
            // PQ: Added yellow audio button to UI - 22.9.07
            this.audioBtn = UiButton.factory(this, Client.BTN_LINE_AUDIO, Client.BTN_FILL_AUDIO, 'audio', 1,
                                             0, Client.UI_BUTTON_SPACE_H * 2);
            this.audioBtn.addEventListener(MouseEvent.CLICK, function(){
                trace('pressed audio button');
                ti.setAudioMode(true);
            });
            
            //the next two are not like others: they are linked ('radio
            //buttons'), and don't send messages to the server.
            //XXX should just have one button which renames itself!
            //XXX or a slider.
            this.fastBtn = UiButton.factory(this, Client.BTN_LINE_FAST, Client.BTN_FILL_FAST, 'fast', 1, 0, 0);
            this.fastBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.setMoveFast(true);
                that.fastBtn.visible = false;
                that.slowBtn.visible = true;
            });
    
            this.slowBtn = UiButton.factory(this, Client.BTN_LINE_SLOW, Client.BTN_FILL_SLOW, 'slow', 1, 0, 0);
            this.slowBtn.addEventListener(MouseEvent.CLICK, function(){
                ti.setMoveFast(false);
                that.slowBtn.visible = false;
                that.fastBtn.visible = true;
            });
            //set the buttons to match the initial state
            if (ti.isMoveFast()){
                this.fastBtn.visible = false;
                this.slowBtn.visible = true;
            }
            else{
                this.fastBtn.visible = true;
                this.slowBtn.visible = false;
            }
        }
        /**
         * Allows menu context to be updated from external actions.
         */
		public function updateMoveSpeed(fast:Boolean)
		{
			if (fast){
                this.fastBtn.visible = false;
                this.slowBtn.visible = true;
            }
            else{
                this.fastBtn.visible = true;
                this.slowBtn.visible = false;
            }
		}
        /**
         * @brief Toggle the name button
         */
        public function setNameButton(nameOn: Boolean) :void

        {
            if (nameOn)
                this.nameBtn.depress();
            else
                this.nameBtn.raise();
            //XXX or is it vice versa?
        }
    
        /**
         * @brief Psuedo constructor
         */
        public function ActorButtons(){}
    
    };
}
