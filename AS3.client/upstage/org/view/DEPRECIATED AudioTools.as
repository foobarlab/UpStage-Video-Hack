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
    
    // PQ: I duplicated this class from the DrawTools class and changed where required for Audio
    
    //import org.model.TransportInterface;
    import org.util.UiButton;
    import org.util.Slider;
    import org.util.Construct;
    import org.view.AudioScrollBar;
    import org.Client;
    import org.Sender;
    
    /**
     * AudioTools.as
     * Author: Phillip Quinlan
     * Created: 23/09/07
     * Modified by: Endre Bernhardt
     * @modified Shaun Narayan (Feb 2010) - Added package declaration, not going to do anything else since this is depricated.
     * Shown alternately with acting tools.
     */
    
    public class AudioTools extends MovieClip 
    {
        private var actBtn         :UiButton;
        private var testBtn        :UiButton; // PQ: Added 23.9.07
        private var volSlider      :Slider;
        public var audioScrollBar  :AudioScrollBar;
        private var ti             :Object;
        var sender       :Sender;    // Handle to Sender    // PQ: Added 23.9.07
        
        public static var symbolName :String = '__Packages.org.view.AudioTools';
        private static var symbolLinked :Boolean = Object.registerClass(symbolName, AudioTools);
    
        static public function create(sender: Sender, parent :MovieClip, name: String,
                                      layer :Number, x :Number, y :Number,
                                      ti:Object) :AudioTools
        {
            var out :AudioTools;
            out = AudioTools(parent.attachMovie(AudioTools.symbolName, name, layer));
            out.ti = ti;
            out._x = x;
            out._y = y;
            out.sender = sender; // PQ: Added 23.9.07
            Construct.uiRectangle(out, 0, 0, Client.WIDGET_BOX_W,
                                  Client.WIDGET_BOX_H);
    
            out.drawScreen(ti);
    
            // EB: Added 24.9.07
            //var audiosb:AudioScrollBar = AudioScrollBar.create(parent, 'audioscrollbar', layer+1, x, y, ti);
            var audiosb:AudioScrollBar = AudioScrollBar.create(out, 'audioscrollbar', layer+1, x, 0, ti);
            trace("#################################### AUDIOTOOLS.create #############################################")
            Construct.deepTrace(audiosb);
            trace("####################################################################################################")
            out.audioScrollBar = audiosb;
    
            return out;
        }
    
    
    
        /**
         * @brief Called automatically by create
         */
        private function drawScreen(ti:Object)
        {
            var that: AudioTools = this; //for event scope delegation
            
            // PQ: Added to test audio playing function
    /*        this.testBtn = UiButton.factory(this, Client.BTN_LINE_DRAW, Client.BTN_FILL_DRAW,
                                           'test', 1, 0, 0);
            this.testBtn.onPress = function(){
                trace('pressed test sound button');
                that.sender.PLAY_EFFECT('test.mp3');
            };
    */
    
            this.actBtn = UiButton.factory(this, Client.BTN_LINE_DRAW, Client.BTN_FILL_DRAW,
                                           'act', 1, 0, Client.WIDGET_BOX_H - 1 * Client.UI_BUTTON_SPACE_H - 1);
            this.actBtn.onPress = function(){
                trace('pressed act button');
                ti.setAudioMode(false);
            };
    
            this.audioScrollBar.drawUI();
    /*
            this.resetBtn = UiButton.factory(this, Client.BTN_LINE_RESET, Client.BTN_FILL_RESET,
                                             'reset', 1, 0,
                                             Client.WIDGET_BOX_H - Client.UI_BUTTON_SPACE_H - 1);
            this.resetBtn.onPress = function(){
                ti.SET_RESET();
            };
    */
            // PQ: Added a vertical slider
    /*
            this.volSlider = Slider.factory(this, 100,
                                              Client.AUDIO_VOL_X, Client.AUDIO_VOL_Y,
                                              Client.AUDIO_VOL_W, Client.AUDIO_VOL_H, false);
                                              
            this.volSlider.drawGradient(16676960, 16777215);
            // Start all audio at 100 volume                                  
            this.volSlider.setFromValue(100);
     */
    
        }
    
        /*set draw style form outside */
        function setDrawStyle(colour:Number, iVol:Number, size:Number){
            trace('colour ' + colour + ' volume '+ iVol + ' size ' + size);
            this.volSlider.setFromValue(iVol);
        }
    
        function AudioTools(){}
    };
}
