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
    
    import org.Client;
    import org.util.Construct;
    import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.external.*;
    import flash.events.TimerEvent;
    
    /**
     * Module: Bubble.as
     * Author: Douglas Bagnall, Wise Wang, Beau Hardy, Francis Palma, Lucy Chu
     * Modified by: Wendy, Candy and Aaron 30/10/2008
     * Modified: Alan Crow (AC)
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * Purpose: Speech bubble for Avatar.
     *                              -Modified: Heath Behrens 20-05-2011:
                                                Made modifications to speak() which now includes a counter to determine how long a speech bubble has been on stage. At a given point the bubble fades.
                                    -Modified: Heath Behrens 17/06/2011 - As per client feedback the speech bubbles fade faster. This is done using a timer which means that one can add functionality to allow players to set the duration of speech bubbles.
     */
    
    public class Bubble extends MovieClip
    {
        //public var mc        :MovieClip;
        public var txtField        :TextField;
        public var fadeID    :Number;
        public var mode      :String;
       
        // AC - Define variables for speech bubble positioning
		// Natasha P - Added x position 
		public var av_pos_x  :Number;
        public var av_pos_y  :Number;
        public var av_height :Number;
        public var location  :String; // 'Above' or 'Below' avatar
        //Reference to a timer.
        public var timer : Timer;
        public var initial_timer : Timer;
        // Heath B - Added to store a duration so can easily be modified.
        public var bubble_fade_speed :Number;
       
        function Bubble(av :MovieClip, parent :MovieClip)
        {
            var wrapLayer  :Number = Client.L_AV_BUBBLES + av.ID * Client.BUBBLE_LAYERS;
            var innerLayer :Number = wrapLayer + 3;
            trace([wrapLayer, innerLayer]);
    
            var tempw:Number = Math.max(Client.BUBBLE_MIN_W, av.width * 2);
            var w:Number = Math.min(Client.BUBBLE_MAX_W, tempw);

            // Create a text field on the moveiclip
            this.txtField = Construct.formattedTextField(this, 'bubbleText', innerLayer, 0, 0,
                                                   w, Client.BUBBLE_BASE_H, 1, true,
                                                   {}, {align:'center'});
    
            this.txtField.x = 0;
            this.txtField.y = 5;
            //Added to allow customization of the bubble fade properties.
            this.bubble_fade_speed = Client.BUBBLE_FADE_STEP;

            this.txtField.wordWrap = true;      // Turn on dynamic resizing based on text
            this.txtField.autoSize = 'center';
            this.txtField.text = '';
    
            //this.mc.visible = false;
			this.visible = false;
            this.mode = '';

            // Create a new Timer object with a delay of 5s delay
            this.timer = new Timer(500);
            this.initial_timer = new Timer(Client.BUBBLE_SOLID_T, 1);

            // AC - (DATE) - Initialise the used variables
			// Natasha P - set x position 
            this.av_pos_x = av.x;
			this.av_pos_y = av.y; // Initially set to 0 as bubble is created when avatar is created. (avatar position: (X:0, Y:0))
            this.av_height = av.height;
            this.location = 'Above'; // Default as above avatar.
            parent.addChild(this); // Natasha P - this makes sure it is visible on stage
        };
       
        /**
        * @brief Creates a collection of points used to shape the speech bubbles shape
        */
        private function getSpeechBubblePoints(w: Number, h: Number): Array
        {
            var points: Array = [];
            
            //trace("GetSpeechBubblePoints: w : "+w +" h : "+h)
            // AC - DATE - Check whether speech bubble point is to be display above or below avatar.
            if (location == 'Below')
            {
                // Display speech bubble underneath avatar with bubble point pointing upwards.
                 // maybe feed each point in array to construct for it to resize
                 points = [0, 3,      0,0,      3, 0,
                          w/2-3,0,   w/2-3,0,  w/2-3,0,
                          w/2-2,-5,  w/2-2,-5, w/2-2,-5,
                          w/2,0,     w/2,0,    w/2,0,
                          w-3,0,     w,0,      w, 3,
                          w,h-3,     w,h,      w-3,h,
                          3,h,       0,h,      0,h-3,           
                          0,3,       0,3,      0,3];
            }
            else
            {
                // Display speech bubble above avatar with bubble point pointing downwards.
                points = [0, 3,      0,0,       3, 0,
                          w-3,0,     w,0,       w, 3,
                          w,h-3,     w,h,       w-3,h,
                          w/2,h,     w/2,h,     w/2,h,
                          w/2-2,h+5, w/2-2,h+5, w/2-2,h+5,
                          w/2-3,h,   w/2-3,h,   w/2-3,h,
                          3,h,       0,h,       0,h-3,           
                          0,3,       0,3,       0,3];
            }
           
            return points;
        }
       
        /**
         * @brief Creates a collection of points used to shape the thinks bubble shape
         */
        private function getThoughtBubblePoints(w: Number, h: Number): Array
        {
            // Thought bubble points are the same whether appearing above or below the avatar.
            var points:Array = [];
            var x:Number, y:Number, i:Number;
            var bw:Number = Math.min(Client.THOUGHT_POLYP_W, h-1);
           
            //build up array of in-pointing points.
            var p:Array = [];
           
            //start bottom left corner, so anomalies look like mouth bubbles
            for (y = h - bw/3 - Math.random() * bw/3; y > bw/3; y-= bw){
                p.push(0);
                p.push(y);
            }
            for (x = (y > 0 ? bw:0) - y + Math.random() * bw/4; x < w-bw/3; x+= bw){
                p.push(x);
                p.push(0);
            }
            //two steps to make sure one lands on the vertical end
            y = w - (x < w ? x: x-bw) + Math.random() * bw/4;
            if (y >= h - bw/3)
                y *= 0.5;
            for (; y < h-bw/3; y+= bw){
                p.push(w);
                p.push(y);
            }
            for (x = w -(y > h ? y-h:y+bw-h) - Math.random() * bw/4; x > bw/3; x-= bw){
                p.push(x);
                p.push(h);
            }
            x = p[p.length-2] - p[0];
            x = p[p.length-1] - p[1];
            if (x*x + y*y < bw * bw / 2){
                //pop the last point off if it makes a too small polyp
                p.pop();
                p.pop();
            }              
            //so it wraps round.
            p.push(p[0]);
            p.push(p[1]);
           
            var cx:Number = w/2; //centre
            var cy:Number = h/2;
    
            for (i=0; i < p.length - 2; i+=2){
                var lx:Number, rx:Number, ly:Number, ry:Number, mx:Number, my:Number;
                lx = p[i];
                ly = p[i+1];
                rx = p[i+2];
                ry = p[i+3];
                var dx:Number = (lx + rx) / 2 - cx;
                var dy:Number = (ly + ry) / 2 - cy;
                //proportionately bigger polyps if height smaller, and not on a corner
                var ph:Number = (ly == ry || lx == rx) ? 4/h : 1/h;
                //trace(ph);
                mx = cx + (dx * (1.1 + ph + Math.random() * ph));
                my = cy + (dy * (1.1 + ph + Math.random() * ph));
                points.push(lx);
                points.push(ly);
                points.push(mx);
                points.push(my);
                points.push(rx);
                points.push(ry);          
            }

            return points;
        }
       
        /**
         *  Shout Feature
         * Wendy, Candy and Aaron
         * 30/10/08
         */
        private function getShoutBubblePoints(w: Number, h: Number): Array
        {
            // Thought bubble points are the same whether appearing above or below the avatar.
            var points:Array = [];
            var x:Number, y:Number, i:Number;
            var bw:Number = Math.min(Client.THOUGHT_POLYP_W, h-1);
           
            //build up array of in-pointing points.
            var p:Array = [];
           
            //start bottom left corner, so anomalies look like mouth bubbles
            for (y = h - bw/3 - Math.random() * bw/3; y > bw/3; y-= bw){
                p.push(0);
                p.push(y);
            }
            for (x = (y > 0 ? bw:0) - y + Math.random() * bw/4; x < w-bw/3; x+= bw){
                p.push(x);
                p.push(0);
            }
            //two steps to make sure one lands on the vertical end
            y = w - (x < w ? x: x-bw) + Math.random() * bw/4;
            if (y >= h - bw/3)
                y *= 0.5;
            for (; y < h-bw/3; y+= bw){
                p.push(w);
                p.push(y);
            }
            for (x = w -(y > h ? y-h:y+bw-h) - Math.random() * bw/4; x > bw/3; x-= bw){
                p.push(x);
                p.push(h);
            }
            x = p[p.length-2] - p[0];
            x = p[p.length-1] - p[1];
            if (x*x + y*y < bw * bw / 2){
                //pop the last point off if it makes a too small polyp
                p.pop();
                p.pop();
            }              
            //so it wraps round.
            p.push(p[0]);
            p.push(p[1]);
           
            var cx:Number = w/2; //centre
            var cy:Number = h/2;
    
            for (i=0; i < p.length - 2; i+=2){
                var lx:Number, rx:Number, ly:Number, ry:Number, mx:Number, my:Number;
                lx = p[i];
                ly = p[i+1];
                rx = p[i+2];
                ry = p[i+3];
                var dx:Number = (lx + rx) / 2 - cx;
                var dy:Number = (ly + ry) / 2 - cy;
                //proportionately bigger polyps if height smaller, and not on a corner
                var ph:Number = (ly == ry || lx == rx) ? 4/h : 1/h;
                //trace(ph);
                mx = cx + (dx * (1.1 + ph + Math.random() * ph));
                my = cy + (dy * (1.1 + ph + Math.random() * ph));
                points.push(lx);
                points.push(ly);
                points.push(mx);
                points.push(my);
                points.push(rx);
                points.push(ry);          
            }
           
            return points;
        }
       
	   /**
	   * @brief: Creates bubbles and sets the position offsets based on its position
	   * Natasha - 6/07/10
	   */
	   public function speak(mode: String, text: String) :void
	   {
            //Heath Behrens - 20-05-2011 - variable that keeps a count value to check how long the bubble has been on stage.
            var count:Number = 1.0;
			this.endFade();
            this.mode = mode;

            this.graphics.clear();
            this.graphics.lineStyle(Client.BORDER_WIDTH, Client.BORDER_COLOUR); //XXX should line width scale?
            this.graphics.beginFill(Client.BUBBLE_COLOUR);
           
            var w:Number = this.txtField.width;
            var h:Number = this.txtField.height;
            
            // AC - Check if bubble is off the stage area
            if (this.isBubbleOffScreen(this.av_pos_y))
            { 
				this.location = 'Below'; 
			}
            else
            {
				this.location = 'Above'; 
			}
    
            // Draw bubble type
            if (mode == 'thought')
            { 
                this.thoughtBubble(this, w, h); 
            }
            else if (mode == 'shout') //Wendy, Candy and Aaron 30/10/08  
            {
                    this.graphics.lineStyle(Client.BORDER_WIDTH, Client.SHOUT_COLOUR);
                    this.shoutBubble(this, w, h);
            }
            else
            { 
				this.speechBubble(this, w, h); 
			}  
           
				this.x = this.av_pos_x;
                this.y = this.av_pos_y - 12;//-h - 6;
                //this speech bubble is now visible
                this.visible = true;
                //initially full alpha
                this.alpha = 1.0;
                
                //fading from here on
                var d :Number = this.txtField.text.length * Client.BUBBLE_SOLID_T;  
                var that:Bubble = this; //store current bubble

                //Added by Heath Behrens (17/06/2011)- Added a timer to slowly fade the alpha value.
                this.initial_timer.stop();
                //create a new one shot timer
                this.initial_timer = new Timer(d, 1);
                //set the callback for the timer
                this.initial_timer.addEventListener(TimerEvent.TIMER, fading);
                //start the initial timer
                this.initial_timer.start();
                //stop the timer if already running.
                this.timer.stop();
                //call back which calls the start_fading function after a given time period
                function fading(eventArgs:TimerEvent){
                    //start fading the bubble
                    start_fading(that);
                }

            ExternalInterface.call("console.log", {Speak:"speak"});
	   }

        /**
            Added By Heath Behrens (17/06/2011): Callback funtion that starts a new timer, to
            call fade every 1 second. Needs some work though...
        */
        private function start_fading(that : Bubble):void
        {
            this.timer.addEventListener(TimerEvent.TIMER, fade);
            // Start the timer
            this.timer.start();
            // Function will be called every 1 seconds
            function fade(eventArgs:TimerEvent)
            {
                //Heath Behrens - 20-05-2011 Incremenet the counter
                //take into account the length of the string given.
                that.alpha -= 0.01;
                //if the alpha value is less than 0.05 no need to fade. Just remove it.
                if(that.alpha <= 0.05){
                    //end fading
                    that.endFade();
                }
            }
        }

        /**
        * @brief Creates thought bubbles
        */
       
        //XXX rather ad-hoc.
        private function thoughtBubble(mc:MovieClip, w:Number, h:Number) :void
        {
            // AC - DATE - Check whether to display the think bubble above or below avatar.
            if (location == 'Below')
            {
                // Display thought bubble underneath avatar
                var b_off_x :Number = 0;
                var b_off_y :Number = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
               
                this.txtField.y = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
                Construct.roundedPolygon(mc, this.getThoughtBubblePoints(w, h), 1, 0, b_off_y);   
            }
            else
            {
                // Display thought bubble above avatar
                this.txtField.y = 5;
                Construct.roundedPolygon(mc, this.getThoughtBubblePoints(w, h), 1, 0, 4.5);
            }
           
            /*var bub:Array = [0,2,  0,0, 2,0, 
                             2,0,  4,0, 4,2,
                             4,2,  4,4, 2,4,
                             2,4,  0,4, 0,2];
    
            Construct.roundedPolygon(mc, bub, 0.7, 2.5, h+6);               
            Construct.roundedPolygon(mc, bub, 0.5, 4.5, h+9); */              
        }
       
        /**
         *  Shout Feature
         * Wendy, Candy and Aaron
         * 30/10/08
         */
         private function shoutBubble(mc:MovieClip, w:Number, h:Number) :void
        {
            // AC - DATE - Check whether to display the think bubble above or below avatar.
            if (location == 'Below')
            {
                // Display thought bubble underneath avatar
                var b_off_x :Number = 0;
                var b_off_y :Number = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
               
                this.txtField.y = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
                Construct.roundedPolygon(mc, this.getShoutBubblePoints(w, h), 1, 0, b_off_y);   
            }
            else
            {
                // Display shout bubble above avatar
                this.txtField.y = 5;
                Construct.roundedPolygon(mc, this.getShoutBubblePoints(w, h), 1, 0, 4.5);
            }
                  
        }
    
        /**
        * @brief Creates speech bubbles
        */
        private function speechBubble(mc:MovieClip, w:Number, h:Number) :void
        {
            // AC - DATE - Check whether to display the speech bubble above or below avatar.
            if (this.location == 'Below')
            {
                var b_off_x :Number = 0;
                var b_off_y :Number = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
               
                this.txtField.y = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
                var points:Array = this.getSpeechBubblePoints(w,h);
                Construct.roundedPolygon(mc, points, 1, 0, b_off_y);
            }
            else
            {
                this.txtField.y = 5;
                var points:Array = this.getSpeechBubblePoints(w,h);
                
                Construct.roundedPolygon(mc, points, 1, 0, 5);
            }
        }
    
    
        /**
         * @brief End fade (clear the bubble)
         */
        public function endFade() :void
        {
            trace('endfade called!')
            this.visible = false;
            //stop the timer
            this.timer.stop();
        };
    
        /**   
         * @brief Make a thought bubble.  A thought bubble is just like a speech
         * bubble, but fluffier
         */
    
        public function think():void
        {
            this.speak('thought', undefined);
        };
       
        /**
         *  Shout Feature
         * Wendy, Candy and Aaron
         * 30/10/08
         */
        public function shout():void
        {
            this.speak('shout', undefined);
        };
       
        /**
        * @brief Check if bubble will appear off the top of the screen.
        * @author Alan
        */
        public function isBubbleOffScreen(Avatar_Y_pos: Number): Boolean
        {
            return ((Avatar_Y_pos - this.txtField.height) <= 0);
        };
       
        /**
         * @brief Sets the text inside the bubble.
         * @author Alan
         */
        public function setText(text:String):void
        {
            this.txtField.text = text;
        };
       
        /**
         * @brief Checks if bubble is showing.
         * @author Alan
         */
        public function isVisible(): Boolean
        {
            return this.visible;
        };
    
        /**
         * @brief Adjusts the bubble properties to display above avatar.
         * @author Alan
         */
        public function moveBubbleAbove(): void
        {
            // Update the current bubble location to above the avatar.
            this.location = 'Above';
           
            var w:Number = this.txtField.width;
            var h:Number = this.txtField.height;
           
            this.graphics.clear();
            this.graphics.lineStyle(Client.BORDER_WIDTH, Client.BORDER_COLOUR); //XXX should line width scale?
            this.graphics.beginFill(Client.BUBBLE_COLOUR);
           
            this.txtField.y = 5;
           
            if (mode == 'thought')
            { 
            	var points:Array = this.getThoughtBubblePoints(w, h);
            	Construct.roundedPolygon(this, points, 1, 0, 4.5); 
            }
            else if (mode == 'shout')
            { 
                this.graphics.lineStyle(Client.BORDER_WIDTH, Client.SHOUT_COLOUR);
                //Construct.constrainSize(mc, Client.BUBBLE_MAX_W, Client.BUBBLE_MAX_W);
                var points:Array = this.getShoutBubblePoints(w, h);
                Construct.roundedPolygon(this, points, 1, 0, 4.5);
                //Construct.constrainSize(mc, Client.BUBBLE_MAX_W, Client.BUBBLE_MAX_W); 
            }
            else
            { 
            	var points:Array = this.getSpeechBubblePoints(w, h);
            	Construct.roundedPolygon(this, points, 1, 0, 5); 
           	}
           	
           	this.graphics.endFill();
           	//this.mc.x = 50;
           	//this.mc.y = 50;
           	//this.mc.visible = true;
           	ExternalInterface.call("console.log", {Movebubbbleabove:"moveabove"});
           
        };
       
        /**
         * @brief Adjusts the bubble properties to display below avatar.
         * @author Alan
         */
        public function moveBubbleBelow(): void
        {
            // Adjust the current bubble location to below the avatar.
            this.location = 'Below';
           
            var w:Number = this.txtField.width;
            var h:Number = this.txtField.height;
           
            this.graphics.clear();
            this.graphics.lineStyle(Client.BORDER_WIDTH, Client.BORDER_COLOUR); //XXX should line width scale?
            this.graphics.beginFill(Client.BUBBLE_COLOUR);
           
            // Display thought bubble underneath avatar
            var b_off_x :Number = 0;
            var b_off_y :Number = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
               
            this.txtField.y = av_height + Client.AV_NAME_HEIGHT + (this.txtField.height - 5);
           
            if (mode == 'thought')
            { Construct.roundedPolygon(this, this.getThoughtBubblePoints(w, h), 1, 0, b_off_y); }
            else if (mode == 'shout')
            { 
                this.graphics.lineStyle(Client.BORDER_WIDTH, Client.SHOUT_COLOUR);
                Construct.roundedPolygon(this, this.getShoutBubblePoints(w, h), 1, 0, b_off_y);        }
            else
            { Construct.roundedPolygon(this, this.getSpeechBubblePoints(w, h), 1, 0, b_off_y); }
    
        };
    
    }
}
