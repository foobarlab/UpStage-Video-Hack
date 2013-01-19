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
     *  Authorisation from server - the first step in handshaking Gets
     *  application talking to server when constructor called
 	 * @modified Shaun Narayan (Feb 2010) - Converted to AS3. Amongst usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...) - also changed loader to use URLRequest, URLVariables
     * 								and URLLoader (as opposed to the depricated old methods).
     */ 
    
    import org.Client;
    import flash.events.*;
	import flash.net.*;
    
    
    public class Auth {
        private var loaded    :Boolean;  // .load() completed successfully
        private var key       :String;   // MD5 key for session from server
        private var player    :String;   // Who the user logged in as (may be '')
        private var tries     :Number;   // How many times connection has been attempted
    
        private var canAdmin  :Boolean;  // Can the player admin
        private var canSu     :Boolean;  // Is the player a super user
        private var canAct    :Boolean;  // Can the player act
            
            
        /**
         * @brief Constructor Calls Auth.load() implemented in LoadVars
         */
        function Auth()
        {
            // Constructor
            trace('Auth constructor...');
                    
            // Server construtor has set weburl from _root.url
            this.tries =  0;
            this.canSu = false;
            this.canAct = false;
            this.canAdmin = false;       
        }
    
        function load(drawer: Object){//draweer used for callback
			var myLoader:URLLoader = new URLLoader();        
        	var myRequest:URLRequest = new URLRequest(Client.AUTH_URL);
        	
            trace('   Auth about to load ' + Client.AUTH_URL);
            var auth: Auth = this;
            var decode: URLVariables = new URLVariables();
            myLoader.addEventListener(Event.COMPLETE, function(evt:Event){
                var loader:URLLoader = URLLoader(evt.target);
                trace(loader.data.toString());
                trace('Auth.decoder.onLoad() ' + !(loader.data==null));
                if (loader.data != null){
                    trace('   auth is: ' + loader.data.toString());
                    var vars:URLVariables = new URLVariables();
                    vars.decode(loader.data);
                    auth.loaded = true;
                    auth.canAct = (vars.canAct == 'True');
                    auth.canSu = (vars.canSu == 'True');
                    auth.canAdmin = (vars.canAdmin == 'True');
                    auth.key = vars.key;
                    auth.player = vars.player;
                    trace("calling " + drawer.drawScreen);
                    drawer.drawScreen();
                }
                else 
                    {
                        trace('auth failed to load!');
                        auth.tries++;
                        if (auth.tries <= Client.MAX_AUTH_ATTEMPTS)
                            {
                                trace('retry number ' + auth.tries);
                                auth.load(null);
                            }
                        else 
                            {
                                trace('continuing with audience rights');
                            }
                                
                    }
            });
            myRequest.method = URLRequestMethod.GET;
			myRequest.data = decode;
            myLoader.load(myRequest);
        };
    
    
    
        //-------------------------------------------------------------------------
        // Accessor functions
        /**
         * @brief Client MD5 key
         * @return MD5 key
         */
        function getKey() :String
        {
            return key;
        }
            
            
        /**
         * @brief Can the current user act
         * @return can the current user act
         */
        function getCanAct() :Boolean
        {
            return canAct;
        };
            
            
        /**
         * @brief Can the current administer
         * @return can admin
         */
        function getCanAdmin() : Boolean
        {
            return canAdmin;
        };
    
    
        /**
         * @brief Can the current user su
         * @return can su
         */
        function getCanSu() :Boolean
        {
            return canSu;
        };
    
            
        /**
         * @brief Current users username
         * @return username
         */
        function getUserName() :String
        {
            return player;
        };  
    }
}
