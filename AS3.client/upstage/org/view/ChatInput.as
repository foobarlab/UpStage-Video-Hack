package org.view 
{
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
    import flash.text.*;
    import flash.display.*;
    import flash.display.Stage;

    /**
     * Module: ChatInput.as
     * Author: Douglas Bagnall, Wise Wang, Beau Hardy, Francis Palma, Lucy Chu
     * Modified by: Lauren Kilduff
     * Modified by: Shaun Narayan (02/22/10) - Added bg color.
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method,
     * 								new event handling etc...) - changed textfield attribute lists,
     * 								had to modify focusing to actually get the attention of the TF
     * Chat Input view.
     *
     */
    public class ChatInput
    {
        public var txtField      	: TextField;
        private var history      	: Array;
        private var historyIndex	: Number = 0;
        private var historyNow   	: String = ''; //current text.
        private var stage		: Stage;

        function ChatInput(parent :MovieClip, canAct :Boolean, col:Number)// Added canAct - LK 17/10/07
        {
            if(canAct)
            {
                // Chat input
                this.txtField =  Construct.formattedTextField(parent, 'chatInput',
                                                    Client.L_CHAT_INPUT, Client.CHAT_INPUT_X,
                                                    Client.CHAT_INPUT_Y, Client.CHAT_INPUT_W,
                                                    Client.CHAT_INPUT_H, 1, true, undefined, undefined);
            }
            else
            {
            	// Added else - LK 17/10/07
                // Chat input for audience
                this.txtField =  Construct.formattedTextField(parent, 'chatInput',
                                                    Client.L_CHAT_INPUT, Client.CHAT_INPUT_X,
                                                    Client.ANON_CHAT_INPUT_Y, Client.CHAT_INPUT_W,
                                                    Client.CHAT_INPUT_H, 1, true, undefined, undefined);
            }

            //this.txtField.type= 'input';

            // AC (10/06/08) - Initial set to disable until stage loaded fully.
            this.setEnabled(false);

            this.txtField.border = true;
            this.txtField.borderColor = Client.BORDER_COLOUR;
            this.txtField.textColor = Client.TEXT_COLOUR;
            //Shaun Narayan (02/22/10) - Added bg color.
            this.txtField.background = true;
            this.txtField.backgroundColor = col;
            this.history = [];
            this.stage = parent.stage;
            trace(this.stage);
            trace('ChatInput constructor done... ');
        }

        /**
         * @brief Allows or prevents text chat input.
         */
        function setEnabled(enabled :Boolean) :void
        {
            if(enabled)
            {
                this.txtField.type="input";
                this.txtField.selectable=true;
            }
            else
            {
                this.txtField.type="dynamic";
                this.txtField.selectable=false;
            }
        }

        /**
         * @brief Put the application focus on the text field
         */
        function focus() :void
        {
            this.stage.focus = this.txtField;
            var n :Number = this.txtField.selectionEndIndex;
            this.txtField.setSelection(n, n);
        }

        //-------------------------------------------------------------------------
        // Accessor functions
        /**
         * @brief Get the text from the text field
         * @return text from text field
         */
        function getText() :String
        {
            return this.txtField.text;
        };


        /**
         * @brief Set the text in the text field
         */
        function setText(str : String)
        {
            this.txtField.text = str;
        }

        /*functions for maintaining up arrow history */

        /* set the text to be the next thing in history (up arrow),
         but first add the half-finished text*/
        function historyPrev()
        {
            //store the latest thing.
            if(this.historyIndex == this.history.length)
            {
                this.historyNow = this.txtField.text;
                //this.historyIndex--;
            }
            if(this.historyIndex > 0)
                this.historyIndex--;
            //trace(this.history);
            //trace(this.historyIndex);
            //trace(this.historyNow);
            this.txtField.text = this.history[this.historyIndex] || this.historyNow;
            this.focus();
        }

        /* set the text to be the next thing in history (down arrow) */
        function historyNext()
        {
            if  (this.historyIndex >= this.history.length)
                return;

            if (this.historyIndex < this.history.length)
                this.historyIndex++;

            if (this.historyIndex == this.history.length)
                this.txtField.text = this.historyNow;
            else
                this.txtField.text = this.history[this.historyIndex];

            trace(this.history);
            trace(this.historyIndex);
            trace(this.historyNow);
            this.focus();
        }

        function historyAdd(s:String)
        {
            trace('adding ' + s + ' to '+ this.history);

            //clear empties which may have been added
            var last:String = this.history[this.history.length - 1];
            if(last == '' || last == s)
                this.history.pop();

            this.history.push(s);
            if(this.history.length > Client.CHAT_HISTORY_LENGTH)
                this.history.shift();

            this.historyIndex = this.history.length; //so subtracting 1 goes to last item.
        }
    }
}