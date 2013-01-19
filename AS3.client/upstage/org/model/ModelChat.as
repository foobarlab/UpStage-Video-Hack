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
    
    //import org.Client;
    import org.Sender;
    //import org.util.Construct;
    import org.view.ChatField;
    import org.model.TransportInterface;
    import org.Transport;
    import flash.display.*;
	
    
    /**
     * Module: ModelChat.as
     * Author: Douglas Bagnall, Wise Wang, Beau Hardy, Francis Palma, Lucy Chu
     * Modified by: Lauren Kilduff
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * Modified by: Vishaal Solanki 15/10/09
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...) - also
     * 								allowed bg color to be set. 
     * Model for ChatField object
     * Sits between ChatField and Transport
     */
    
    public class ModelChat implements TransportInterface 
    {
        private var sender    :Sender;    // Handle to sender
        private var chatField :ChatField; // View
        private var player    :String;    // Current player username
        private var commands  :Object;
        private var transport :Transport;
        private var iCount      :Number;
        
        private var chatBackgroundColour :Number = 0xFFFFFF;
    
        /**
         * @brief Constructor
         */
        public function ModelChat(sender :Sender)
        {
            this.sender = sender;
            this.transport = transport;
            this.setUpCommands();
            this.iCount = 0;
        };
        
        /** @brief set up a look up table for /commands.
         *  the format is
         *   
         *   cmd: [documentation:String , public function:public function],
         *   
         *  where cmd is the command without the '/', public function is to 
         *  be executed, and documentation briefly describes it 
         * (should be a short line -- accessed via /help)
         * if documentation is non-true, the command is left out of the
         * help screen.
         */
    
        public function setUpCommands(){
            var that:ModelChat = this;  
            this.commands = {
                a:         [
                            "switch avatar views [/a NUMBER]",
                            function(msg: String){
                                that.sender.FRAME(msg);
                            }],
                b:         [ //Aaron: multi-frame backdrops 1/5/08
                            "switch backdrop views [/b NUMBER]",
                            function(msg: String){
                                that.sender.BACKDROP_FRAME(msg);
                            }],
                applause:    [// Lauren: display applause button 15/10/07
                            "display the applause button",
                            function(){
                                that.sender.APPLAUSE();
                            }],
                noapplause:[// Lauren: hide applause button 29/10/07
                            "hide the applause button",
                            function(){
                                that.sender.NO_APPLAUSE();
                            }],
                volunteer:  [ // Lauren: testing volunteer av 24/9/07
                            "control a volunteer avatar",
                            function(){
                                that.sender.VOLUNTEER();
                            }],
                novolunteer:  [ // Lauren testing volunteer av 17/10/07
                            "let go of volunteer avatar",
                            function(){
                                that.sender.NO_VOLUNTEER();
                            }],
                info:      [
                            "more words",
                            function(msg: String){
                                that.sender.INFO();
                            }],
                details:  [
                           "get stage statistics",
                           function(msg: String){
                               that.sender.DETAILS();
                           }],
                nick:     [
                           "change the avatar's name",
                           function(msg: String){
                               that.sender.RENAME(msg);
                           }],
                asize:    [
                           undefined, //will not show up
                           function(msg: String){
                               that.chatField.changeAnonFormat(msg);
                           }],
                psize:    [
                           undefined,
                           function(msg: String){
                               that.chatField.changePlFormat(msg);
                           }],
                colour:   [
                           undefined,
                           function(msg: String){
                               that.chatField.changeColour(parseInt(msg, 16));
                           }],
    
                whisper:  [
                           "send messages to other players",
                           function(msg: String){
                               that.sender.WHISPER(msg);
                           }],
                //Added by NR, 17/04/10.
                vote:	  [
                		   "allows audience members to vote on something.  Format should be the question to be asked, followed by " +
                		   "the options available, seperated by semicolons.  For example: /vote What should Juliet do?;" +
                		   "Stab herself.;Stab Romeo.;Drink more poison.",
                		   function(msg: String){
                		   		that.sender.VOTE(msg);
                          }],
                help:     [
                           "this text",
                           function(msg: String){
                               var x: String;
                               for (x in that.commands){
                                   if (that.commands[x][0])
                                       that.chatField.message('/' + x + ": " + that.commands[x][0]);
                               }
                           }]
            };
    
            //aliases
            this.commands.color = this.commands.colour;
            this.commands.wh = this.commands.whisper;
        }
    
    
        /**
         * @brief Set the user name for the player
         */
        public function setPlayer(player :String) :void

        {
            this.player = player;
        };
    
    
        /**
         * @brief Draw the components on screen (player)
         */
        public function drawScreen(parent :MovieClip) :void
        {
            this.chatField = new ChatField(transport, this.sender, parent, true, this, chatBackgroundColour);
        }
    
    
        /**
         * @brief Draw the components on screen (audience)
         */
        public function drawScreenAudience(parent :MovieClip) :void

        {
            this.chatField = new ChatField(transport, this.sender, parent, false, this, chatBackgroundColour);
        }
    
    
        //-------------------------------------------------------------------------
        // Called by ChatField when it wants information processed
        /**
         * @brief View wants model to deal with text input
         * Modified by Wendy, Candy and Aaron 30/10/08
         */
        public function SET_INPUT(text :String)
        {
            // Process text & text commands
            var prefix:String = text.substr(0, 1);
            var shortText:String = text;//.substr(0,300);//Candy,Wendy and Aaron - limited amount of text
            if (prefix == '/'){
                this.handleCommand(shortText);
            }
            else if (prefix == ':'){
                this.handleThought(shortText);
            }
            else if(prefix == '!'){
                this.handleShout(shortText); //Candy,Wendy and Aaron - Shout Feature
            }
            else if (text != ''){
                this.sender.TEXT(shortText);
            }            
            
        };
    
    
        public function handleCommand(text: String){
            if (player)  // If this is not an audience member XXX -- why not?
                {//XXX slack way to split off command.
                    var bits :Array = text.split(' ');
                    var command :String = bits.shift().substring(1);
                    var msg :String = bits.join(' ');
                    trace('command is ' + command + ' message is ' + msg);
                    var fn: Function = this.commands[command][1];
                    trace('public function is ' + fn);
                    fn(msg);
                }
        }
    
        public function handleThought(text: String){
            if (player){
                var thought:String = text.substr(1); //drop the ':' 
                this.sender.THINK(thought);
            }
        }
        /** 
         * Shout and command feature 
         * @breif handles shout and command at the same time
         * Thomas Choi - 18/10/10
         */
        /*
        public function handleCommandAndShout(text: String){
        	if (player)
        	{//redundant code. Needs fixing.
        		var bits :Array = text.split(' ');
        		var command :String = bits.shift().substring(2);
        		var msg :String = bits.join(' ');
        		trace('command is ' + command + ' message is ' + msg);
        		var fn: Function = this.commands[command][1];
        		trace('public function is ' + fn);
        		var shoutUpperCase:String = fn(msg).toUpperCase();
                this.sender.SHOUT(shoutUpperCase);
        	}
        }*/
        
        /**
         * Shout Feature
         * @brief handle shout public function
         * Candy,Wendy and Aaron - 30/10/08
         */
        public function handleShout(text: String){
            if(player){
                var shout:String = text.substr(1); //drop the '!'
                var shoutUpperCase:String = shout.toUpperCase();
                this.sender.SHOUT(shoutUpperCase);
            }
        }
        
       public function SET_CHAT_PANE_COLOUR(bgColor: Number) :void

       {
               this.chatBackgroundColour = bgColor;
               trace("## Color set to " + this.chatBackgroundColour);
       }
    
    
        //-------------------------------------------------------------------------
        // Messages from server
        /**
         * @brief Server wants model to display some text
             */
         public function GET_TEXT(name:String, msg :String) :void

        { 
          // chatField.writeChat(msg); -15/10/09 - Vishaal -Added below command to Fix Chatlog problem and existing chat
          chatField.writeChat('&lt;' + name + '&gt; ' + msg, undefined);
        };
    
        public function GET_THOUGHT(name:String, msg :String) :void

        {
             chatField.writeThought('&lt;' + name + '&gt; { ' + msg + ' }');
        };
        
        /**
         *Shout Feature
         *Wendy, Candy and Aaron 
         *30/10/08
         *Wendy
         *25/05/09
         */
        public function GET_SHOUT(name:String, msg :String) :void

        {
            chatField.writeShout('&lt;' + name + '&gt; ' + msg); //wendy, 29/05/09 remove * before and after shout texts as client required
        };
        
    
        /**
         * @brief Server wants model to show anon text
         */
        public function GET_ANONSPEAK(msg :String) :void

        {
            chatField.anonSpeak(msg);
        };
    
    
        /**
         * @brief Server wants model to display an error
         */
        public function GET_ERR(msg :String) :void

        {
            chatField.error(msg);
        };
    
    
        /**
         * @brief Server wants model to display a message
         */
        public function GET_MSG(msg :String) :void

        {
            chatField.message(msg);
        };
    
        /**
         * @brief Server wants model to display text (already typed before this client
         * joined)
         */
        public function GET_LOAD_CHAT(msg :String) :void

        {
            chatField.loadChat(msg);
        };
    
    
        /**
         * @brief Server wants model to display a whisper message sent by another player
         */
        public function GET_WHISPER(senderID :String, text :String)
        {
            chatField.whisper(senderID, text);
        };
    
        /**
         * @brief Display the applause button
         * 
         * Lauren Kilduff added on 15/10/07
         */
        public function DISP_APPLA() : void
        {
            chatField.displayApplause();
        };
        
        /**
         * @brief Hide the applause button
         * 
         * Lauren Kilduff added on 29/10/07
         */
        public function HIDE_APPLA() : void
        {
            chatField.hideApplause();
        };
        
        /**
         * @brief Display the volunteer button
         * 
         * Lauren Kilduff added on 31/10/07
         */
        
        public function DISP_VOLUNTEER_BTN() : void
        {
            chatField.displayVolunteerBtn();
        };
        
        /**
         * @brief Hide the volunteer button
         * 
         * Lauren Kilduff added on 31/10/07
         */      
        
        public function HIDE_VOLUNTEER_BTN() : void
        {
            chatField.hideVolunteerBtn();
        };
        
        /**
         * @brief Stage has been fully loaded
         *  AC (10.06.08)
         */
        public function GET_CONFIRM_LOADED() : void
        {
            chatField.setInputEnabled(true);
            trace("##Loaded, set input true");
        };
        
    
        //-------------------------------------------------------------------------
        /**
         * @brief Show message in text field
         * Used by Server, Auth, and Transport
         * onLoad / onConnect methods
         */
        public function displayConnectionLost(msg :String)
        {
            chatField.setText(msg || 'Connection Lost');
        }
    
        /**
         * @brief Set the focus to the text input box
         */
        public function focus()
        {
            chatField.focus();
        }
    };
}
