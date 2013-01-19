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
    
    /**
     * Module: Client.as
     * Author: Douglas Bagnall
     * Modified by: Lauren Kilduff, Phillip Quinlan, Endre Bernhardt
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * Modified by: Vishaal Solanki 15/10/2009
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3.
     * 			 Shaun Narayan (Apr 2010) - Added scale proportionate, prop+avatar max size, avatar menu and various other variables.
     * Constants go here.  These are available to every module.
     * Modules should never modify a value here.
     */
    
    public class Client {
        // AC (27.05.08) - Port for receiving policy files.
        public static var POLICY_PORT       :Number = 3000;
        public static var SCREEN_WIDTH   :Number = 280;
        public static var SCREEN_HEIGHT  :Number = 240;
    	public static var SCALE_PROPORTIONATE :Boolean = true;
        //----------- sizes --------------------------//
    
        public static var ICON_SIZE      :Number = 10;      // In AvScrollBar & ItemGroup's
        //Shaun Narayan - Images suffered from scaling problems so these values help get some relativity back
        public static var AVATAR_MAX_WIDTH	 :Number = 100;
        public static var AVATAR_MAX_HEIGHT	 :Number = 100;
        public static var PROP_MAX_WIDTH	 :Number = 100;
        public static var PROP_MAX_HEIGHT	 :Number = 100;
        public static var BORDER_WIDTH   :Number = 0.5;
    
        public static var RIGHT_BOUND      :Number = 225; // lefthand edge of chat
        public static var BOTTOM_BOUND     :Number = 189; // bottom edge of chat, just above top of background pickers.
        public static var CHAT_WIDTH       :Number = 88;
        public static var ACTOR_CHAT_TOP   :Number = 70;
        public static var ACTOR_CHAT_HEIGHT:Number = 118;
        public static var ANON_CHAT_TOP    :Number = 1 +10; //VS - Change to allow for Audience view of player/audience count 08/10/09 - was 1
        
        //LK modified to allow for applause button - was 186
        //VS - Changed again to allow for Audience view of player/audience count - 08/10/09 - was 170
        public static var ANON_CHAT_HEIGHT :Number = 179 -10;
        public static var CHAT_SCROLL_X    :Number = 313;
        public static var ACT_SCROLL_UP_Y  :Number = 70;
        public static var ACT_SCROLL_DN_Y  :Number = 181;
        public static var ANON_SCROLL_UP_Y :Number = 11; // (14/10/09) Modified to account for Audience Tools
        public static var ANON_SCROLL_DN_Y :Number = 173; // AC (21/04/08): Modified to be placed at the bottom of the chat log field
        public static var CHAT_INPUT_X     :Number = 225; //cf RIGHT_BOUND
        public static var CHAT_INPUT_Y     :Number = 190; //cf BOTTOM_BOUND 
        public static var CHAT_INPUT_W     :Number = 88;  //cf CHAT_WIDTH
        public static var CHAT_INPUT_H     :Number = 11; 
        public static var ANON_CHAT_INPUT_Y     :Number = 180; //LK added 17/10/07
    
        public static var BUBBLE_BASE_H    :Number = 20;
        public static var BUBBLE_MIN_W     :Number = 60;
        public static var BUBBLE_MAX_W       :Number = 300;
        public static var BUBBLE_FADE_STEP      :Number = 0.03;
    
        //base size of thought bubble polyps
        public static var THOUGHT_POLYP_W  :Number = 9;  
    
        public static var TF_WIDTH         :Number = 40;
        public static var TF_HEIGHT        :Number = 12;
    
        public static var INFO_WIDTH       :Number = 30;
        public static var INFO_HEIGHT      :Number = 10;
        public static var INFO_WIDTH2      :Number = 88; //Player/Audience Count - Audience View - Vishaal - 08/10/09
        public static var INFO_HEIGHT2     :Number = 10; //Player/Audience Count - Audience View - Vishaal - 08/10/09
        public static var INFO_X           :Number = 240;
        public static var INFO_Y           :Number = 59;
        public static var INFO_X2          :Number = 225; //Player/Audience Count - Audience View - Vishaal - 08/10/09
        public static var INFO_Y2          :Number = 1;    //Player/Audience Count - Audience View - Vishaal - 08/10/09
    
        public static var MIRROR_ICON_W    :Number = 48;
        public static var MIRROR_ICON_H    :Number = 22;
    
        //where the prop box goes.
        public static var PROP_BOX_X       :Number = 124;
        public static var PROP_BOX_Y       :Number = 190; //cf BOTTOM_BOUND, CHAT_INPUT_Y
        //LK added 25/6/07
        public static var PROP_SCROLL_L_X   :Number = 116.5;
        public static var PROP_SCROLL_R_X   :Number = PROP_BOX_X + 86.5;
        public static var PROP_SCROLL_BAR_Y :Number = 192.25;
        
        //backdrop box
        public static var BACKDROP_BOX_X   :Number = 15; //cf BOTTOM_BOUND, CHAT_INPUT_Y
        public static var BACKDROP_BOX_Y   :Number = PROP_BOX_Y; //cf BOTTOM_BOUND, CHAT_INPUT_Y
        //LK added 25/6/07
        public static var BKDROP_SCROLL_L_X   :Number = 7.5;
        public static var BKDROP_SCROLL_R_X   :Number = BACKDROP_BOX_X + 86.5;
        public static var BKDROP_SCROLL_BTN_Y :Number = 192.25;
    
        // All other positions relative to control top left
    
        public static var CONTROL_WIDTH    :Number = CHAT_WIDTH; //players avatar controls
        public static var CONTROL_HEIGHT   :Number = 89;
        public static var CONTROL_Y        :Number = 2;
    
        // PQ: Added 21.10.07
        // The number of audio controls in the audio widget (left controls)
        public static var AU_NO_OF_AUDIO_CONTROLS    :Number = 3
        // PQ: 23.9.07 - (Generalized) Changed from DRAW_BOX_W/H to WIDGET_BOX_W/H to accommodate new audio widget
        public static var WIDGET_BOX_W       :Number = 95; //chat width + scroll bar
        public static var WIDGET_BOX_H       :Number = 67;
        
        public static var COLOUR_PICKER_X  :Number = 1;
        public static var COLOUR_PICKER_Y  :Number = 1;
        public static var COLOUR_PICKER_W  :Number = 60;
        public static var COLOUR_PICKER_H  :Number = 21;
        public static var COLOUR_PALETTE_Y :Number = COLOUR_PICKER_Y + COLOUR_PICKER_H + 2;
        public static var COLOUR_PALETTE_W :Number = 5;
        public static var COLOUR_PALETTE_H :Number = 5;
        public static var ALPHA_SLIDER_Y   :Number = COLOUR_PALETTE_Y + COLOUR_PALETTE_H + 1;
        public static var ALPHA_SLIDER_H   :Number = 4;    
        public static var SIZE_SLIDER_Y    :Number = ALPHA_SLIDER_Y + ALPHA_SLIDER_H + 1;
        public static var SIZE_SLIDER_GAP  :Number = 22;
    
        public static var LAYER_PICKER_X   :Number = 70;
        public static var LAYER_PICKER_Y   :Number = COLOUR_PICKER_Y;
        public static var LAYER_PICKER_W   :Number = 24;
        public static var LAYER_PICKER_H   :Number = 65;
        public static var LPICKER_LAYER_H  :Number = 12;
        public static var LPICKER_LABEL_H  :Number = 8;
    
        public static var AV_SCROLL_X      :Number = 50;   // Avatar selector scrollbar
        public static var AV_SCROLL_Y      :Number = 0;
        public static var AV_SCROLL_WIDTH  :Number = 38;
        public static var AV_SCROLL_HEIGHT :Number = 67;
    
        public static var AV_SCROLL_BTN_X  :Number = CONTROL_WIDTH;  //selector scrollbar buttons
        public static var AV_SCROLL_UP_Y   :Number = 0;
        public static var AV_SCROLL_DN_Y   :Number = 60;
    
        public static var AV_SCROLL_NAME_W :Number = 29; // Avatar selector label
        public static var AV_SCROLL_NAME_H :Number = 10;
        //public static var AV_SCROLL_ITEM_W :Number = ICON_SIZE + AV_SCROLL_NAME_W;
    
        public static var AV_MIRROR_X      :Number = 0;  // Avatar selector mirror
        public static var AV_MIRROR_Y      :Number = 0;
        public static var AV_MIRROR_WIDTH  :Number = 48;
        public static var AV_MIRROR_HEIGHT :Number = 24;
    
        public static var AV_LAYER_BTN_X   :Number = 41;
        public static var AV_LAYER_UP_Y    :Number = 5;
        public static var AV_LAYER_DOWN_Y  :Number = 12; 
    
        //buttons below mirror
        public static var AV_UI_BUTTON_Y   :Number = 41;
        public static var AV_UI_BUTTON_W   :Number = 48;
        public static var AV_UI_BUTTON_H   :Number = 28;
    	//Shaun Narayan (04/25/10) - Avatar Menus
    	public static var AV_UI_MENU_CUSTOM :Boolean = false;
        public static var AV_UI_MENU_ITEMS   :Number = 5;
        public static var AV_UI_MENU_COLOR   :Number = 0xFFFFFF;
        public static var AV_UI_MENU_PADDING   :Number = 5;
        public static var AV_UI_MENU_BUTTON_WIDTH   :Number = 20;
        public static var AV_UI_MENU_BUTTON_HEIGHT   :Number = 8;
        public static var AV_UI_MENU_W   :Number = AV_UI_MENU_BUTTON_WIDTH+(AV_UI_MENU_PADDING*2);
        public static var AV_UI_MENU_H   :Number = AV_UI_MENU_BUTTON_HEIGHT*AV_UI_MENU_ITEMS+(AV_UI_MENU_PADDING*2);
        
        public static var AV_NAME_WIDTH    :Number = AV_MIRROR_WIDTH;
        public static var AV_NAME_HEIGHT   :Number = 12;
        public static var AV_NAME_X        :Number = 0;
        public static var AV_NAME_Y        :Number = 26;
    
        // PQ: Added 21.10.07
        // One audio control coords and size
        public static var AU_CONTROL_X      :Number = 0;
        public static var AU_CONTROL_Y      :Number = 0;
        public static var AU_CONTROL_WIDTH  :Number = 48;
        public static var AU_CONTROL_HEIGHT :Number = (WIDGET_BOX_H - INFO_HEIGHT) / AU_NO_OF_AUDIO_CONTROLS;
        
        // AC: 31.05.08
        public static var AU_NAME_WIDTH        :Number = 35;
        public static var AU_NAME_HEIGHT    :Number = AV_NAME_HEIGHT - 3;
        
        // EB: Added - 22/10/07
        // PQ: Edited below 29.10.07
        public static var AU_SLIDER_X       :Number = 15;
        public static var AU_SLIDER_Y       :Number = 13;
        public static var AU_SLIDER_H       :Number = 4;
        public static var AU_SLIDER_W       :Number = 31;
    
        //standard slider height.
        public static var UI_SLIDER_HEIGHT :Number = 4; 
    
        //splash screen dimensions
        public static var SPLASH_TF_W      :Number = 250;
        public static var SPLASH_TF_H      :Number = 30;
    
        public static var SPLASH_MSG_W      :Number = 200;
        public static var SPLASH_MSG_H      :Number = 50;
        public static var SPLASH_MSG_Y      :Number = 40;
    
        public static var SPLASH_NAME_W      :Number = 200;
        public static var SPLASH_NAME_H      :Number = 50;
        public static var SPLASH_NAME_Y      :Number = 20;
    
    
        // splash title font scale
        public static var SPLASH_TF_SCALE   :Number = 3;
        public static var SPLASH_MSG_SCALE  :Number = 1;
        public static var SPLASH_NAME_SCALE :Number = 2;
    
        public static var SPLASH_BTN_SCALE  :Number = 1.1;
        public static var SPLASH_BTN_TF_INDENT  :Number = -2;  // PQ: Added 23.9.07 - Amount to further left the tf
        //---------- misc --------------------------//
    
        //how big are standard fonts?
        public static var BASE_FONT_SIZE   :Number = 5.1;
    
        //alpha settings for icons
        public static var INUSE_ICON_ALPHA :Number = 40;
        public static var AVAIL_ICON_ALPHA :Number = 100;
    
        //avatar stepping interval (ms)
        public static var AV_STEP_TIME     :Number = 150;
    
        //from AvScrollBar.as
        public static var DISPLAY_AV       :Number = 6;     // Number of avatars to show at once 22-Sep-2006
         //LK added 25/6/07
        public static var DISPLAY_PROP     :Number = 8;
    
        public static var VIDEO_INTERVAL_TARGET :Number = 1500; //tries to adapt wait time to reach this rate
        public static var VIDEO_INTERVAL_MIN    :Number = 500;  //but never waits for less than this.
        public static var VIDEO_MAX_FAILURES    :Number = 10;   // this many consequtive 404s before quitting
    
        public static var BUBBLE_SOLID_T        :Number = 300; //how long before bubble starts to fade
        public static var SCROLL_REPEAT         :Number = 120;
    
        public static var POST_LOAD_WAIT        :Number = 500; //wait after last thing loaded 
    
        //button colours and shapes
        public static var UI_BUTTON_POINTS      :Array = [01,02, 01,01, 02,01,
                                                          14,01, 15,01, 15,02,
                                                          15,07, 15,08, 14,08,
                                                          02,08, 01,08, 01,07,
                                                          01,02, 01,02, 01,02];
        public static var UI_BUTTON_WIDTH       :Number = 15;
        public static var UI_BUTTON_HEIGHT      :Number = 8;
        public static var UI_BUTTON_SPACE_W     :Number = 16;
        public static var UI_BUTTON_SPACE_H     :Number = 9;
        public static var UI_BUTTON_TEXT_SCALE  :Number = 0.7;
    
        //LK added 15/10/07 for audience applause button
        public static var APPLA_UI_BUTTON_POINTS :Array = [01,02, 01,01, 02,01,
                                                          33,01, 34,01, 34,02,
                                                          34,7, 34,8, 33,8,
                                                          02,8, 01,8, 01,7,
                                                          01,02, 01,02, 01,02];
                                                                                                           
        public static var APPLA_UI_BUTTON_WIDTH       :Number = 34;
        public static var APPLA_UI_BUTTON_HEIGHT      :Number = 8;
        public static var APPLA_UI_BUTTON_TEXT_SCALE  :Number = 1;
        
        //LK added 15/10/07 for volunteer drop button
        public static var DROP_UI_BUTTON_POINTS :Array = [01,02, 01,01, 02,01,
                                                          19,01, 20,01, 20,02,
                                                          20,7, 20,8, 19,8,
                                                          02,8, 01,8, 01,7,
                                                          01,02, 01,02, 01,02];
        public static var DROP_UI_BUTTON_WIDTH       :Number = 20;
        public static var DROP_UI_BUTTON_HEIGHT      :Number = 8;
        public static var DROP_UI_BUTTON_TEXT_SCALE  :Number = 1;
    
        public static var SCROLL_BUTTON_POINTS  :Array = [0,0, 7,0,  7,7, 0,7,  0,0];
        public static var SCROLL_ARROW_UP       :Array = [3.5,1, 6,6,  1,6,   3.5,1];
        public static var SCROLL_ARROW_DOWN     :Array = [1,1,   6,1,  3.5,6, 1,1];
        //LK added 25/6/07
        public static var SCROLL_ARROW_RIGHT    :Array = [1,1,   6,3.5, 1,6,  1,1];
        public static var SCROLL_ARROW_LEFT     :Array = [1,3.5, 6,1,  6,6,   1,3.5];
    
        // PQ: Added 23.9.07
        public static var AUDIO_VOL_X            :Number = 1;
        public static var AUDIO_VOL_Y            :Number = 10;
        public static var AUDIO_VOL_H            :Number = 40;
        public static var AUDIO_VOL_W            :Number = 5;
        // PQ Added 30.10.07
        // Default volume for all audios in Audio widget
        public static var AUDIO_VOL_DEFAULT_VAL :Number = 50;
        
        
        // PQ: Added 29.10.07 - Stop All Audio button sizes
        public static var STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH  :Number = 25;//32;
        public static var STOPALLAUDIO_UI_BUTTON_TEXT_HEIGHT :Number = 6;//10;
        public static var STOPALLAUDIO_UI_BUTTON_TEXT_SCALE  :Number = 0.8;
        
        // PQ: Added 29.10.07 - How to draw the Stop All Audio button
        // PQ: Edited 30.10.07 - Made sizing dynamic when change above BUTTON_TEXT_WIDTH
        //  so when change the text area width, the button size changes with it!
        public static var STOPALLAUDIO_UI_BUTTON_POINTS :Array = [01,02, 01,01, 02,01,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH-1,01,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH,01,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH,02,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH,7,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH,8,
                                                          STOPALLAUDIO_UI_BUTTON_TEXT_WIDTH-1,8,
                                                          02,8, 01,8, 01,7,
                                                          01,02, 01,02, 01,02];
                                                          
                                                          
                                                          
        // AC added (06/05/08)
        public static var AUDIOSLOT_UI_BUTTON_POINTS :Array = [01,02, 01,01, 02,01,
                                                                 15,01, 16,01, 16,02,
                                                               /*16,07, 16,08, 15,08,
                                                               02,08, 01,08, 01,07,*/
                                                               16,06, 16,07, 15,07,
                                                               02,07, 01,07, 01,06,
                                                               01,02, 01,02, 01,02];
                                                               
        public static var AUDIOSLOT_UI_BUTTON_TEXT_WIDTH       :Number = 19;//18.8;
        public static var AUDIOSLOT_UI_BUTTON_TEXT_HEIGHT      :Number = 8;
        public static var AUDIOSLOT_UI_BUTTON_TEXT_SCALE         :Number = 0.5;
                                                          
        // Natasha & Thomas: Added - Points for moveable drawing button                                                  
        public static var MD_BUTTON_WIDTH       :Number = 45;
        public static var MD_BUTTON_HEIGHT      :Number = 9;
        public static var MD_BUTTON_POINTS      :Array = [01,02, 01,01, 02,01,
                                                          MD_BUTTON_WIDTH - 1,01, MD_BUTTON_WIDTH,01, MD_BUTTON_WIDTH,02,
                                                          MD_BUTTON_WIDTH, MD_BUTTON_HEIGHT -1, MD_BUTTON_WIDTH, MD_BUTTON_HEIGHT, MD_BUTTON_WIDTH - 1, MD_BUTTON_HEIGHT,
                                                          02,MD_BUTTON_HEIGHT, 01,MD_BUTTON_HEIGHT, 01, MD_BUTTON_HEIGHT - 1,
                                                          01,02, 01,02, 01,02];        
                                                          
                                                          
        // PQ: Added
        // Path to the music note and sfx icon that display in the audio widget
        public static var MUSIC_ICON_IMAGE_URL    :String = '/media/thumb/music.jpg';
        public static var SFX_ICON_IMAGE_URL    :String = '/media/thumb/sfx.jpg';
    
        // PQ: Added 30.10.07
        // Text to display on the audio widget's "Stop All Audio" button
        public static var AUDIO_STOPALLAUDIO_TEXT :String= 'stop all';
    
        //diamond, centred on y axis, unit size.
        public static var SLIDER_DIAMOND    :Array = [0,0,  0.35,0.5,  0,1, -0.35,0.5,  0,0];
    
		public static var DRAWING_EYE_1         :Array = [9,10.4, 6,8,   5.6,4, 7,2,  9,1,    11,2,   12,5, 
                                                      11,8,   9,9,   9,10.4];


    	public static var DRAWING_EYE_2         :Array = [0,7,    2,6,   6,2,   7,1,  9,0.4,  11,1,   13,3,
                                                      17,7,   15,5,  17,7,  15,7, 11,10,  9,10.4, 6,8, 
                                                      5.6,4,  7,2,   9,1,   11,2, 12,5,   11,8,   9,9, 
                                                      6,9,    3,8,   0,7];

    	public static var DRAWING_PENCIL        :Array = [35,0, 185,150, 185,185, 150,185,  0,35, 12,22,
                                                      160,170, 170,160, 160,170, 12,22 ];
    
        public static var PALETTE_POINTS        :Array = [0,0, COLOUR_PALETTE_W,0, 
                                                          COLOUR_PALETTE_W,COLOUR_PALETTE_H,
                                                          0,COLOUR_PALETTE_W, 0,0];
    
        public static var DRAW_TRACE_POINTS     :Array = [0,-3,      0,0,  2.5,-0.5, 0,0,
                                                          -2.5,-0.5, 0,0,  -1,2,     0,0,
                                                          1,2,       0,0, 0,-3];
        public static var DRAW_TRACE_N          :Number = 20;
        public static var DRAW_TRACE_TIMEOUT    :Number = 2000;
    
        //colour transforms
        //Shaun Narayan (02/24/10) - Alpha vals now -1,...0,...1 as opposed to +-100 
        // ra, ga, ba, aa -- how much of original colour to keep (+/- 1)
        // rb, gb, bb, ab -- colour offset to mix in (+/- 255)
        public static var BUTTON_UP_CT   :Object = {ra: 1.00, rb: 0,
                                                    ga: 1.00, gb: 0,
                                                    ba: 1.00, bb: 0,
                                                    aa: 1.00, ab: 0};
        public static var BUTTON_DOWN_CT :Object = {ra: 0.75,  rb: 75,
                                                    ga: 0.75,  gb: 75,
                                                    ba: 0.75,  bb: 75,
                                                    aa: 1, ab: 0};
        public static var BUTTON_OVER_CT :Object = {ra: 0.70,  rb: 100,
                                                    ga: 0.70,  gb: 90,
                                                    ba: 0.70,  bb: 80,
                                                    aa: 1.00, ab: 0};
        public static var BUTTON_GREY_CT :Object = {ra: 0.36, rb: 148,
                                                    ga: 0.36, gb: 148,
                                                    ba: 0.36, bb: 148,
                                                    aa: 0.65, ab: 0};
    
    
    
    
        //---------------------------- colours ----------------------//
    
        public static var BORDER_COLOUR  :Number = 0x669900;
        
        public static var TEXT_COLOUR    :Number = 0x000000;
        public static var UI_BACKGROUND  :Number = 0xFFFFFF;
        public static var BUBBLE_COLOUR  :Number = 0xFFFFFF;
        public static var SCROLL_COLOUR  :Number = 0xccdd99;
        public static var SCROLL_BORDER  :Number = 0x336600;
        public static var SCROLL_ARROW   :Number = 0x669933;
        public static var CHAT_BG_MISSED :Number = 0xEECCCC;
        public static var CHAT_BG_BACK   :Number = 0xCCCCCC;
        public static var CHAT_THOUGHT   :Number = 0x337799;
        public static var SHOUT_COLOUR   :Number = 0xFF0000;//Wendy, Candy and Aaron
        public static var CHAT_SHOUT     :Number = 0xFF0000; //Wendy, Candy and Aaron
        public static var CHAT_ANON      :Number = 0x999999;
        public static var CHAT_ERROR     :Number = 0xCC0000;
        public static var CHAT_MSG       :Number = 0xCC6600;
        public static var CHAT_WHISPER   :Number = 0x000099;
        public static var CHAT_FRAME     :Number = 0x0000ff;
        public static var SLIDER_BORDER  :Number = 0x000000;
    
        public static var BTN_LINE_DROP  :Number = 0x999900;
        public static var BTN_FILL_DROP  :Number = 0xCCCC00;
        public static var BTN_LINE_CLEAR :Number = 0x999999;
        public static var BTN_FILL_CLEAR :Number = 0xcccccc;
        public static var BTN_LINE_NAME  :Number = 0xcc0033;
        public static var BTN_FILL_NAME  :Number = 0xdd99aa;
        public static var BTN_LINE_DRAW  :Number = 0x006699;
        public static var BTN_FILL_DRAW  :Number = 0x0099cc;
        public static var BTN_LINE_STOP  :Number = 0xcc0000;
        public static var BTN_FILL_STOP  :Number = 0xff0000;
        public static var BTN_LINE_FAST  :Number = 0x006600;
        public static var BTN_FILL_FAST  :Number = 0x33cc00;
        public static var BTN_LINE_SLOW  :Number = 0x996600;
        public static var BTN_FILL_SLOW  :Number = 0xff9900;
        public static var BTN_LINE_RESET :Number = 0x660033;
        public static var BTN_FILL_RESET :Number = 0xcc0033;
        public static var BTN_LINE_AUDIO  :Number = 0x006699; // PQ: Added 22.9.07
        public static var BTN_FILL_AUDIO  :Number = 0xFAFF00; // PQ: Added 22.9.07
        //Shaun Narayan (04/26/10) Avatar Menus
        public static var BTN_LINE_RENAME  :Number = 0x0000FF;
        public static var BTN_FILL_RENAME  :Number = 0x2222FF;
        public static var BTN_LINE_SHADOW :Number = 0x444444;
        public static var BTN_FILL_SHADOW :Number = 0x555555;
        public static var BTN_LINE_VOICE  :Number = 0xFFFF00;
        public static var BTN_FILL_VOICE  :Number = 0xDDDD00;
    
        public static var BTN_LINE_RELOAD:Number = 0x006611;
        public static var BTN_FILL_RELOAD:Number = 0x33cc88;
        public static var BTN_LINE_CNCL  :Number = 0x880000;
        public static var BTN_FILL_CNCL  :Number = 0xff0000;
    
    
        public static var PROGRESS_FORE  :Number = 0x000000; 
        public static var PROGRESS_LOAD_F:Number = 0x00cc33; 
        public static var PROGRESS_FAIL_F:Number = 0xcc0000; 
        public static var PROGRESS_START_F:Number= 0xddcc00; 
        public static var PROGRESS_LOAD_L:Number = 0x006600; 
        public static var PROGRESS_FAIL_L:Number = 0x660000; 
        public static var PROGRESS_START_L:Number= 0x776600; 
    
    
    
        // Layers
        //-------------------------------------------------------------------------
        // Stage lies on layer 10
    
        // Be careful adding numbers to these values use Number(...) casts
        // ActionScript seems to interpret them as string adds sometimes...
        // max Layer is just over a million (2 ** 20)
    
    
    
        /// Draw behind background images
        public static var L_DRAW_0          :Number = 90;
    
        /// Background images on stage
        public static var L_BG_IMG          :Number = 100;
    
        /// Draw between background and avatars
        public static var L_DRAW_1          :Number = 900;
        public static var L_DRAW_2          :Number = 910;
    
            // /Avatar images on screen (L_AV_IMG + ID)
        public static var L_AV_IMG          :Number = 10000;
    
        /// Prop images on stage
        public static var L_PROPS_IMG       :Number = 200000;
    
        /// Avatar names on stage (L_AV_NAME + ID)
        public static var L_AV_NAME         :Number = 210000;
    
        /// Avatar speech bubbles on stage (base mc & tf on mc)
        public static var L_AV_BUBBLES      :Number = 250000;
    
    
        /// Draw in from of avatars
        public static var L_DRAW_3          :Number = 290000;
    
    
        // -------------UI 300k - 699k-------------------
        /// Prop items frame
        public static var L_PROP_FRAME      :Number = 300000;
    
        /// Bg icons frame
        public static var L_BG_FRAME        :Number = 300100;
    
        /// Background prop  / icons
        public static var L_UI_ICONS_BASE   :Number = 310000;
    
        public static var L_DRAW_TRACE      :Number = 320000;
    
        /// Actor buttons
        public static var L_BUTTONS_FRAME   :Number = 400000;
    
        //drawing tools
        public static var L_DRAW_TOOLS      :Number = 400500;
        public static var L_COLOUR_PICKER   :Number = 401000;
        public static var L_COLOUR_PALETTE  :Number = 401500;
        public static var L_LAYER_PICKER    :Number = 402000;
        
    
        /// Player / audience count frame
        public static var L_INFO_FRAME      :Number = 405000;
    
    
        /// Avatar icons
        public static var L_AV_ICON         :Number = 410000;
    
        // PQ: Added 7.10.07
        // Audio list icons
        public static var L_AUDIO_ICON_THUMB :Number = 420000;
    
        public static var L_AUDIO_ICON        :Number = 450000;
        /// buttons created with ButtonMc (gets incremented)
        public static var L_UI_BUTTONS      :Number = 515000;
    
        /// Avatar scrollbar
        public static var L_SCROLL_FRAME    :Number = 516000;
    
        /// Player / audience count text
        public static var L_INFO_TEXT       :Number = 516200;
        public static var L_INFO_TEXT2       :Number = 516400; //Added for Audience player/Audience count view - Vishaal - 08/10/09    
        
        // PQ: Added 23.9.07
        // PQ: Edited 30.10.07 - value from 403000 to 517000 to make go over
        //  Player / audience count text
        // Audio Tools Layer Number
        public static var L_AUDIO_TOOLS     :Number = 517000; 
    
        /// Chat text and input,
        public static var L_CHAT_TEXT       :Number = 600010;
        public static var L_CHAT_INPUT      :Number = 600030;
    
    
        //---------splash screen and debug 700k - 1M
    
        // Splash screen
        public static var L_SPLASH_SCREEN   :Number = 900000;
    
        /// Debug log (top of everything ...
    
        public static var L_DEBUG           :Number = 999999;
    
    
        //how many layers allocated per type ( making room for video, etc).
        public static var AV_IMG_LAYERS     :Number = 10;
        public static var AV_ICON_LAYERS    :Number = 5;
        public static var THING_IMG_LAYERS  :Number = 5;
        public static var ICON_IMG_LAYERS   :Number = 5;
        public static var UI_BUTTON_LAYERS  :Number = 5;
        public static var BUBBLE_LAYERS     :Number = 5;
    
        //------------------where to log-------------------
    
        //should debug messages get sent to the server
        public static var LOG_TO_SERVER : Boolean = false;
        //should debug messages go to screen
        public static var LOG_TO_SCREEN : Boolean = true;
    
        //how many times to try connecting.
        public static var MAX_CONNECTION_ATTEMPTS: Number = 4;
        public static var MAX_AUTH_ATTEMPTS      : Number = 4;
    
    
        //---------------------strings ------------------//
    
        public static var AUTH_URL               :String = '/admin/id';
        // PQ & LK: Added 31.10.07
        public static var APPLAUSE_URL             :String = 'applause.mp3';
    
        //-----------------drawing layer information .
        public static var DRAWING_LAYERS :Array = [
                                            {
                                                type: 'layer',
                                                description: 'back',
                                                layer: Client.L_DRAW_0
                                            },
                                            {
                                                type: 'label',
                                                description: 'backdrops'
                                            },
                                            {
                                                type: 'layer',
                                                description: 'middle1',
                                                layer: Client.L_DRAW_1
                                            },
                                            {
                                                type: 'layer',
                                                description: 'middle2',
                                                layer: Client.L_DRAW_2
                                            },
                                            {
                                                type: 'label',
                                                description: 'avatars'
                                            },
                                            {
                                                type: 'layer',
                                                description: 'front',
                                                layer: Client.L_DRAW_3
                                            }
                                            ];
    
        public static var DRAWING_LAYERS_N      :Number = 4;
        
    
        public static var PALETTE_FIXED         :Array = [0xffffff, 0x000000];
    
        //-------------------------------- sound
        /*8 slots are available -- these numbers need to ad up toi divvy them properly */
        public static var SPEECH_SOUNDS         :Number = 15;  // Max concurrent sounds (0, 1, 2)
        //public static var SFX_SOUNDS            :Number = 2;  // For sound effects (slot 3)
        //public static var MUSIC_SOUNDS          :Number = 1;  // For music (slot 4)
        // AC: 10.06.08
        public static var AUDIO_SOUNDS            :Number = 3;
        // PQ & LK: 31.10.07
        public static var APPLAUSE_SOUNDS       :Number = 10;  // Max concurrent applauses
    
        //how many things get loaded for each media type (icons, etc count as a separate load)
        public static var LOADS_PER_AVATAR      :Number = 3;
        public static var LOADS_PER_PROP        :Number = 2;
        public static var LOADS_PER_BACKDROP    :Number = 2;
    
    
        public static var PROGRESS_BAR_W       :Number = 120;
        public static var PROGRESS_BAR_H       :Number = 8;
        public static var PROGRESS_BAR_BORDER  :Number = 2;
        
        public static var CHAT_HISTORY_LENGTH  :Number = 50;
    
        // id 0 means no thing in communication (ie, drop the prop/ backdrop/av) 
        public static var NULL_THING_ID        :Number = 0; 
    }
}
