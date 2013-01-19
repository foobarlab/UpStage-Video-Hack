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
    
    import org.Client;
    import org.view.Info;
    import org.view.InfoAudience;
    import org.model.TransportInterface;
    import flash.display.*;
    import org.Sender; 
	
    /**
     * Module: ModelInfo.as
     * Author: Douglas Bagnall, Wise Wang, Beau Hardy, Francis Palma, Lucy Chu, Vishaal Solanki
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, new event handling etc...)
     * Process messages relating to displaying player & audience count
     * 
     */
    
    public class ModelInfo implements TransportInterface 
    {
        private var info   :Info;
        private var sender;
        private var infoAudience   :InfoAudience;
    
        /**
         * @brief Constructor
         */
        public function ModelInfo(sender:Sender)
        {
        	this.sender = sender;
        };
        
        /**
         * @brief Get all child views to draw
         */
        public function drawScreen(parent :MovieClip) :void
        {
            this.info = new Info(parent, Client.INFO_X, Client.INFO_Y);                 
        }
        
         /**
         * @brief Get all child views to draw
         * Draws the Player/Audience count for Audience View
         * Added by Vishaal 20/10/09    
         */
       public function drawScreenAudience(parent :MovieClip) :void
        {
            this.infoAudience = new InfoAudience(parent, Client.INFO_X2, Client.INFO_Y2);
        }
        
        public function getInfoAudience():InfoAudience
        {
        	return infoAudience;
        }
        /**
         * @brief Server wants model to update player / audience count
         */
        public function GET_JOINED(aCount:Number, pCount:Number) : void
        {
            if(this.info)
            {
            	this.info.update(aCount, pCount);
            }
            else 
            {
            	this.infoAudience.update(aCount, pCount);
            }
        }
        
    }
    
}
