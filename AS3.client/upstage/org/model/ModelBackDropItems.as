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
    
    import org.Sender;
    import org.Client;
    //import org.thing.Thing;
    import org.thing.BackDrop;
    import org.view.ItemGroup;
    import org.model.TransportInterface;
    import flash.display.*;
    
    /**
     * Purpose: Handles messages that affect backdrops.
     *          Stores information about backdrops.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...)
     */
    
    public class ModelBackDropItems implements TransportInterface 
    {
        private var sender        :Sender;  // Handle to sender
        private var backDropIcons :ItemGroup;
        private var showing       :Number;    //the currently showing ID
        //Prop Pane Backdrop Color //AB: added 02.08.08
        private var NumBackDropBackGroundColour :Number = 0xFFFFFF;
        
        /**
         * @brief Construtor
         */
        public function ModelBackDropItems(sender :Sender)
        {
            if (! sender)
                trace(' ModelBackDropItems constructor called with invalid arguments');
            this.sender = sender;
            this.showing = Client.NULL_THING_ID;
        };
    
    
        /**
         * @brief Draw the components on screen (player)
         */
        public function drawScreen(parent :MovieClip) :void
        {
            this.backDropIcons = ItemGroup.create(parent, "backDropIcons",
                                                  Client.L_BG_FRAME, Client.BACKDROP_BOX_X,
                                                  Client.BACKDROP_BOX_Y, NumBackDropBackGroundColour, this);
            
        }
        
    
        /**
         * @brief Show the views
         */
        public function show() :void
        {
            this.backDropIcons.visible = true;
            
        }
    
    
        /**
         * @brief Hide the view
         */
        public function hide() :void

        {
            this.backDropIcons.visible = false;
            this.backDropIcons.left.visible = false; // AC added 23/04/08
            this.backDropIcons.right.visible = false; // AC added 23/04/08
        }
    
        /*
         * AC - 18/04/08 - Hides the backdrop scrollbuttons.
         */
         public function hideBackDropScrollButtons(hide:Boolean)
         {
             this.backDropIcons.hideScrollButtons(hide); 
         }
         
    
        /**
         * @brief Server wants model to load a new backdrop
         */
        public function GET_LOAD_BACKDROP (ID :Number, name :String, url :String, thumbnail :String,
                                    medium :String, show :Boolean, frame :Number)
        {
            this.backDropIcons.addItem(BackDrop, ID, name, url, thumbnail, medium);
            if (show)
                {
                    this.GET_SHOW_BACKDROP(ID);
                    // AC - 10/06/08 - Updates the clients backdrop to latest frame
                    this.SET_BACKDROP_FRAME(frame);
                }
        };
    
        /**
         * @brief Server wants model to select a backdrop
         */
        public function GET_SHOW_BACKDROP (ID :Number):void

        {
            this.backDropIcons.hideAll();
            if (ID != Client.NULL_THING_ID){
                var backDrop: Object = this.backDropIcons.getItemByID(ID);
                if (backDrop)
                    backDrop.show();
            }
            this.showing = ID;
        };
    
        /**
         * @brief Model wants server to select backdrop (for all clients)
         */
        public function SET_BACKDROP(ID: Number):void

        {
            if (ID == this.showing){
                trace('clicked on showing backdrop; hiding');
                ID = Client.NULL_THING_ID;
            }
            trace('SET_BACKDROP ' + ID);
            this.sender.BACKDROP(ID);
        }
        
        // Aaron (21/04/08) Multi-frame backdrop
        /**
         * @brief Server wants backdrop to display a given frame
         */
        public function SET_BACKDROP_FRAME(frameNumber: Number):void

        {
            trace("ModelBackDrop got " + frameNumber);
            var backDrop: Object = this.backDropIcons.getItemByID(this.showing);
            if (backDrop) {
                trace("BACKDROP IS TRUE:::::::::::::::::::>");
            }
            else {
                trace("BACKDROP IS FALSE :::::::::::::::::>");
            }
            backDrop.frame(frameNumber);
        }
        
        /** AB - 02-08-08
         * @brief Set Backdrop Pane Background Color
         */
       public function SET_BACKDROP_PANE_COLOR(bgColor: Number) :void

       {
               this.NumBackDropBackGroundColour = bgColor;
       }
        
    }
}
