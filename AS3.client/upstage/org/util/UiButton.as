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
    /*
      ordinary button.
    */
    
    import org.util.Construct;
    import org.Client;
    import org.util.ButtonMc;
    import flash.display.*;
    import flash.text.*;
    
    /**
     * Author: 
     * Modified by: Lauren Kilduff, Phillip Quinlan
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, event 
     * 								handling etc...)
     * 			 Shaun Narayan (Apr 2010) -  Modified button text offsets to centre sub menu text, added
     * 			 							avatarMenuFactory to make larger buttons for the custom menu.
     * 			 							Offset audioslot factory buttons and modified for use as submenu
     * 			 							button factory.
     * Notes: 
     */
    
    
    public class UiButton extends ButtonMc 
    {
        private var txtField        :TextField;
        private var textLayer :Number;
    
        /* points for standard ui button */
        private static var buttonPoints :Array = Client.UI_BUTTON_POINTS;
        
        // LK added 15/10/07
        private static var applauseButtonPoints :Array = Client.APPLA_UI_BUTTON_POINTS;
        //LK added 30/10/07
        private static var dropButtonPoints :Array = Client.DROP_UI_BUTTON_POINTS;
        
        // AC added 06/05/08
        private static var audioSlotButtonPoints :Array = Client.AUDIOSLOT_UI_BUTTON_POINTS;
        
        
        // PQ: Added 29.10.07 - Button for Stop All Audio
        private static var stopallaudioButtonPoints :Array = Client.STOPALLAUDIO_UI_BUTTON_POINTS;
    
        private static var drawer :Function = Construct.roundedPolygon;
    
        /* factory returns the button */
    
        static public function factory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, UiButton.buttonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, Client.UI_BUTTON_WIDTH, Client.UI_BUTTON_HEIGHT, text, Client.UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;          
        }
        static public function avatarMenuFactory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, UiButton.buttonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, Client.AV_UI_MENU_BUTTON_WIDTH, Client.AV_UI_MENU_BUTTON_HEIGHT, text, Client.UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;          
        }
        
        /*
         * Modified By: Natasha Pullan - creates UI buttons with custom points
         *
         */
        static public function customfactory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String, points : Array,
                                       width : Number, height : Number, scale : Number, 
                                       offX : Number, offY : Number):UiButton
        {
        	var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, points,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, width, height, text, Client.UI_BUTTON_TEXT_SCALE);
            btn.addChild(uiButton);
            return uiButton;   
        }
        // PQ: Added 23.9.07 - Added to fix bug of splash screen button text field too small
        static public function factorySplash(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number, iWidth: Number, iHeight: Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();//UiButton(btn);
            uiButton.draw(UiButton.drawer, UiButton.buttonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX + Client.SPLASH_BTN_TF_INDENT, offY, iWidth, iHeight, text, Client.UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;
        }
    
        // AC
        static public function AudioSlotfactory(parent :MovieClip, lineColour : Number,
                                                   fillColour : Number, text : String,
                                                   scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, UiButton.audioSlotButtonPoints,
                          lineColour, fillColour, offX, offY, scale);
            
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX-3, offY-1, Client.AUDIOSLOT_UI_BUTTON_TEXT_WIDTH, Client.AUDIOSLOT_UI_BUTTON_TEXT_HEIGHT, text, Client.AUDIOSLOT_UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;
        }
    
        // LK Added 15/10/07 - Added to create longer larger button for applause
        static public function Applausefactory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();//UiButton(btn);
            uiButton.draw(UiButton.drawer, UiButton.applauseButtonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, Client.APPLA_UI_BUTTON_WIDTH, Client.APPLA_UI_BUTTON_HEIGHT, text, Client.APPLA_UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;
        }
        
        // LK Added 30/10/07 - Added to create larger Drop button
        static public function Dropfactory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, UiButton.dropButtonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, Client.DROP_UI_BUTTON_WIDTH, Client.DROP_UI_BUTTON_HEIGHT, text, Client.APPLA_UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;
        }
    
        // PQ: Added 29.10.07 - Added to create longer larger button for Stop All Audio
        static public function Stopallaudiofactory(parent :MovieClip, lineColour : Number,
                                       fillColour : Number, text : String,
                                       scale : Number, offX : Number, offY : Number):UiButton
        {
            var btn:ButtonMc = ButtonMc.create(parent, UiButton, scale);
    
            var uiButton: UiButton = new UiButton();
            uiButton.draw(UiButton.drawer, UiButton.stopallaudioButtonPoints,
                          lineColour, fillColour, offX, offY, scale);
            uiButton.buttonMode = true;
            uiButton.useHandCursor = true;
            uiButton.mouseChildren = false;
            uiButton.textLayer = uiButton.baseLayer + 1;
            uiButton.makeTextField(offX, offY, Client.STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH, Client.STOPALLAUDIO_UI_BUTTON_TEXT_HEIGHT, text, Client.STOPALLAUDIO_UI_BUTTON_TEXT_SCALE);
            trace("made button and text for " + text);
            //Construct.deepTrace(uiButton);
            btn.addChild(uiButton);
            return uiButton;
        }
    
        /**
         * @brief Create the text field for the button
         */
        private function makeTextField(x :Number, y :Number, iWidth: Number, iHeight: Number, text:String, iTextScale:Number) :void

        {
            //XXX could separate out x and y scale for long buttons.        
            var width :Number = this.scale * iWidth;
            var height :Number = this.scale * iHeight;
            var textScale :Number = this.scale * iTextScale;
    
            this.txtField = Construct.fixedTextField(this, 'txtField' + this.textLayer, this.textLayer,
                                               x, y, iWidth, iHeight, iTextScale,
                                               false, undefined);
            this.txtField.text = text;
        }
    
    
        public function setText(text :String): void
        {
            this.txtField.text = text;
        }
    
        function UiButton()//(scale:Number)
        {
        	//super(this, UiButton, scale);
        }
    }
}
