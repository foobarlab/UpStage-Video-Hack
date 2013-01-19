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
    
    import org.util.Construct;
    import org.Client;
    import flash.display.*;
	import flash.text.*;
    /**
     * Module: InfoAudience.as
     * Authors: Vishaal Solanki
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     * AUDIENCE VIEW
     * Shows player and audience counts 
     *
     */
    
    public class InfoAudience 
    {
      
      private var txtField2 :TextField;
        function InfoAudience(parent :MovieClip, x :Number, y: Number)
        {                                                   
        this.txtField2 = Construct.formattedTextField(parent, 'infotext', Client.L_INFO_TEXT2,
        x, y, Client.INFO_WIDTH2, Client.INFO_HEIGHT2,
        0.9, false, undefined, undefined);
    
        txtField2.border = true;
        txtField2.borderColor = 0x669900;
        }   
       
    
       /**
       * @brief Update the player / audience count
       */
        public function update(aCount : Number, pCount : Number):void
        {                        
            this.txtField2.text = (((pCount < 10) ? ' Players: 0': ' Players: ') + 
            pCount  +
            ((aCount < 10) ? ' | Audience: 0' : ' | Audience: ') +
            aCount);
        }
        public function getTextField() :TextField
        {
        	return txtField2;
        }
       
    }
    
}
