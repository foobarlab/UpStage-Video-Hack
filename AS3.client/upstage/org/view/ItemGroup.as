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
    import org.thing.Thing;
    import org.util.Icon;
    import org.Client;
    import org.util.Construct;
    import org.util.ScrollButton;
    import flash.display.*;
	import flash.text.*;
	import flash.events.*;
    /**
     * Author: 
     * Purpose: To display the props and backdrops on the stage
     * Modified by: Lauren Kilduff
     * Notes:
     * Between 26/6/07 and 30/7/07:
     *    Added alphabetising - props and backdrops are now displayed in alphabetical order
     *    Added scroll buttons so that the props and backdrops drop overflow - you can
     *        now scroll along to see them all 
     *    Hid the scroll buttons if there are 8 or less items (props or backdrops)
     *
     * This is where screen action happens.
     * the main things are classes for avatars and props.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - renamed some fields to fix conflicts.
     */
    
    
    public class ItemGroup extends MovieClip 
    {
        private var backgroundColor    :Number; //AB: 01.08.08
        private var mcName    :MovieClip;  // MovieClip to place textField on
        private var txtFieldName    :TextField;  // TextField to place name on
        private var ti        :TransportInterface;
    
        private var items     :Array;
        private var type      :String;  // lazy
        private var icon      :Icon;
        private var startPos  :Number;
        
        private var MAX_ICONS :Number;
        private var WIDTH     :Number = 86;
        private var HEIGHT    :Number = 11;
        private var myItem :Thing;
        
        private var ID :Number;
        private var myName :String;
        private var url            :String;
        private var thumbnail    :String;
        private var medium        :String;
        private var Class        :Object;
        
        //LK added 25/6/07
        public var left                :ScrollButton;   // Buttons on scrollbar
        public var right               :ScrollButton;   // Buttons on scrollbar
        private var myParent        :MovieClip;
        public var canDisplayButtons    :Boolean;
        public var mustHide            :Boolean;
        private var audience    :Boolean;
    
        private var textLayer:Number;
    
        /**
         * @brief factory.
         */
        public static function create(parent :MovieClip, tname :String,
                                      layer :Number, x :Number, y :Number, bgColor :Number,
                                      ti:TransportInterface) :ItemGroup 
        {
            var out :ItemGroup = new ItemGroup();
            out.myParent = parent;
            out.textLayer = layer + 1;
            out.items = [];
            out.ti = ti;
            out.x = x;
            out.y = y;
            out.draw(x, y, bgColor, parent);
            //LK added 26/6/07 - based on code from AvScrollBar.as
            out.startPos = 0;
            out.enabled = true;
            parent.addChild(out);
            return out;
        };
    
        /**
         * @brief Called automaitcally by create
         */
        private function draw(x :Number, y :Number, backgroundColor :Number, parent :MovieClip)
        {
            // Position on stage
            this.x = x;
            this.y = y;
    
           //AB (01.08.08)
          Construct.uiRectangleBackgroundAndProp(this, 0, 0, this.WIDTH, this.HEIGHT, backgroundColor);
            
    
            var tname: String = 'txtFieldName' + this.textLayer;
            //XXX needs constants to be separated.
            this.txtFieldName = Construct.formattedTextField(parent, tname, this.textLayer,
                                                       x, y-12, this.WIDTH, this.HEIGHT, 1.1, true,
                                                       {selectable:false,
                                                        background: true,
                                                        backgroundColor: Client.UI_BACKGROUND,
                                                        visible: false
                                                       }, 
                                                       {align:'center'}
                                                       );
    
            //LK added 25/6/07 - based on code from AvScrollBar.as
            // Set up Scroll Buttons
            var propsb: ItemGroup = this;
            
            if (x == Client.PROP_BOX_X){
                //LK added
                trace("Prop created bars");
                this.left = ScrollButton.factory(parent, 'left', 1, Client.PROP_SCROLL_L_X, Client.PROP_SCROLL_BAR_Y);
                this.right = ScrollButton.factory(parent,'right', 1, Client.PROP_SCROLL_R_X, Client.PROP_SCROLL_BAR_Y);       
            }
            
            if (x == Client.BACKDROP_BOX_X){
                //LK added
                this.left = ScrollButton.factory(parent, 'left', 1, Client.BKDROP_SCROLL_L_X, Client.BKDROP_SCROLL_BTN_Y);
                this.right = ScrollButton.factory(parent,'right', 1, Client.BKDROP_SCROLL_R_X, Client.BKDROP_SCROLL_BTN_Y);               
            }
            
            //LK added
            this.left.action = function(){
                propsb.moveLeft();
            }
    
            //LK added
            this.right.action = function(){
                propsb.moveRight();
            }
            
            // AC (21.04.08) - Initial hide the scrollbuttons until items added exceed the panel.
            this.left.hide();
            this.right.hide();
            this.canDisplayButtons = false;
            
            //LK added
            //if (this.items.length == 0){
            //this.left.hide();
            //this.right.hide();
                //this.reposition();
            //}
        }
    
        /**
         * @brief Add an item to the group
         */
        public function addItem(Class :Object, ID : Number, tname :String, url :String,
                         thumbnail :String, medium :String)
        {
            trace("in ItemGroup.addItem");
            
            var item :Thing;
            
            item = Class.factory(parent, this, ID,
                                 tname, url, thumbnail,
                                 medium, 0);
                                        
             this.items.push(item);
             this.icon = this.items[0].icon;
            //LK added 25/6/07 - based on code from AvScrollBar.as
            // puts the items in alphabetical order then repositions them on the display panel
            /**this.items.sort(function(A: Thing, B: Thing):Number{  
                    return A.name.toLowerCase() <= B.name.toLowerCase() ? -1 : 1;            
                });*/
             this.reposition();
            
            var namefield :TextField = this.txtFieldName;
    		var that = item.icon;
            item.icon.addEventListener(MouseEvent.MOUSE_OVER, function ()
                {
                    namefield.text = that.myName;
                    namefield.visible = true;
                });
    
            item.icon.addEventListener(MouseEvent.MOUSE_OUT, function ()
                {
                    // Hide text field & item name
                    namefield.visible = false;
                });
    
            var _ti:Object  = this.ti;
            item.icon.addEventListener(MouseEvent.CLICK, function ()
                {
                    _ti[Class.transportSetFunctionName](ID);
                });
                item.icon.buttonMode = true;
                item.icon.useHandCursor = true;
            // AC added 10/04/08 - The prop scroll buttons are initally hidden, upon every item being 
            // added check to see if they should now be displayed.
    
              this.canDisplayButtons = ! (this.items.length <= Client.DISPLAY_PROP);
            
            if ((this.visible) && (this.left.visible == false) && 
                   (this.right.visible == false) && (this.canDisplayButtons)) {
                this.left.show();
                this.right.show();
                trace("show scroll bars");
                }
        };
    
        /**
         * LK added 25/6/07 - based on code from AvScrollBar.as
         * @brief Set the position / visibility of scrollbar items
         * based on current start  positions
         */
        public function reposition(): void
        {
            var i: Number;
            var skipped: Number = 0;
            var possibles: Array = [];
            //loop throught the items, putting appropriate ones in the
            //possibles array.  If the user's selected prop would be
            //shown, don't show it, and keep note that one item was
            //skipped.  This helps in the greying of buttons.
            for (i = 0; i < this.items.length; i++)
                {
                    var item :Thing = this.items[i];
                  
                    if (i >= this.startPos && possibles.length < Client.DISPLAY_PROP )                            
                        {
                            if (item.icon != this.icon)
                                {
                                    possibles.push(item);
                                }
                            else
                                {
                                    //note that we've skipped it
                                    skipped = 1;
                                    item.icon.hide();
                                }
                        }
                    else
                        {
                            item.icon.hide();
                        }
                }
     
            //it could be that insufficient were found, if last item was
            //selected.  go back and look for selected ones.
            while(possibles.length < Client.DISPLAY_PROP && this.startPos > 0)
                {
                    this.startPos--;
                    var item :Thing = this.items[this.startPos];
                  
                    if (item.icon != this.icon)
                        {
                            possibles.unshift(item);
                        }
                }
            //actually show the icons.
            for (i = 0; i < possibles.length; i++)
                {
                    var item :Thing = possibles[i];
                   
                    // Position, show & enable
                    item.icon.x = i * Client.ICON_SIZE + 1;
                    item.icon.y = 1;
                    item.icon.show();
                    trace("show scroll bars");             
                }
                
            //if first icon is selected, and startPos is at 1,
            // you can't scroll up, but startPos doesn't know
            //
            // likewise, if last icon is selected, and startPos is such
            // that the display ends justbefore it, you can't scroll down.
            // skipped can be set to trigger greying.
            
            if(this.icon)
            {
            	if (this.icon == this.items[this.startPos + possibles.length].icon) skipped = 1;
            }
            // grey out scroll buttons if at top or bottom.
                 
            if (this.startPos == 0 ||
                (this.startPos == 1 && this.icon == this.items[0].icon)){
                this.left.grey();
            }
            else {
                this.left.ungrey();
            }
            if (this.startPos + possibles.length + skipped >= this.items.length){
                this.right.grey();
            }
            else {
                this.right.ungrey();
            }
              
        };
    
    
        /**
         * @brief Return an item from the ID
         */
        public function getItemByID(ID: Number): Object
        {
            var i :Number;
            for (i = 0; i < this.items.length; i++){
                if (this.items[i].ID == ID)
                    return this.items[i];
            }
    
            return null;
        }
    
    
        /**
         * @brief Hide all items in the group
         */
        public function hideAll(): void
        {
            var i:Number;
            for (i = 0; i < this.items.length; i++)
                {
                    this.items[i].hide();
                }
        };
    
        /**
         *  LK added 25/6/07 - based on code from AvScrollBar.as
         *  @brief Scroll left one prop
         */
        public function moveLeft(): void
        {
            if (this.startPos > 0)
                {
                    //need to jump up 2 if first one will be hidden, or it apears not to move.
                    if (this.items[this.startPos - 1].icon == this.icon)
                        this.startPos -= 2;
                    else
                        startPos--;
                    reposition();
                }
            else{
                trace("can't go left!!");
                this.left.grey();
            }
        };
    
    
        /**
         *  LK added 25/6/07 - based on code from AvScrollBar.as
         *  @brief Scroll right one prop
         */
        public function moveRight() : void
        {
            if (this.startPos + Client.DISPLAY_PROP < this.items.length)
                {
                    //need to jump down 2 if first one is hidden, or it apears not to move.
                    if (this.items[this.startPos].icon == this.icon)
                        this.startPos += 2;
                    else
                        startPos++;
                    reposition();
                }
            else{
                trace("can't go right!!");
                this.right.grey();
            }
        };
        
        /**
         *  LK added 8/10/07
         *  @brief Hide the scroll buttons when player is drawing or playing
         *  with audio
         */
        public function hideScrollButtons(hide:Boolean) : void
        {
            trace('item group hide buttons');
              if ((hide)||(this.items.length == 0))
              {
                  this.left.hide();
                this.right.hide();
              }
        }
    
    
        public function ItemGroup(){}
    
    }
}
