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
     * Module: Info.as
     * Authors: Wise Wang, Douglas Bagnall
     *
     * Shows player and audience counts
     * @modified Shaun Narayan (Feb 2010) - Converted to AS3. usual changes (Package declaration,
     * 								removal of _ prefix fields, new moviclip registration method, 
     * 								new event handling etc...)
     */
    
    public class Info 
    {
        private var txtField :TextField;
    
        function Info(parent :MovieClip, x :Number, y: Number)
        {
            var txtFieldAttrs:Object = {
                border: false,
                wordWrap: true,
                multiline:true,
                condenseWhite: false,
                borderColor: undefined,
                textColor: Client.TEXT_COLOUR
            };
            this.txtField = Construct.formattedTextField(parent, 'infotext', Client.L_INFO_TEXT,
                                                   x, y, Client.INFO_WIDTH, Client.INFO_HEIGHT,
                                                   0.8, false, txtFieldAttrs, undefined);
        }
    
        /**
         * @brief Update the player / audience count
         */
        public function update(aCount : Number, pCount : Number):void
        {
            this.txtField.text = (((pCount < 10) ? ' P:0': ' P:') + 
                            pCount  +
                            ((aCount < 10) ? ' | A:0' : ' | A:') +
                            aCount);
        }
    }
}
