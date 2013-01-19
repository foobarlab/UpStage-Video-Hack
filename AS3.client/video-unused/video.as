    /*
    Copyright (C) 2003 Douglas Bagnall (douglas * paradise-net-nz)
    
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
    
    
    /* Video SWF.
     * contains a single image, which reloads shortly after loading, so as
     * appear to be moving.  
     *
     * This isn't used in Upstage2, but perhaps should be -- it would
     * simplify video processing for the main client.
     *
     * It is written in actionscript 1, but should instead be in
     * actionscript 2 and use fancy stuff like movieClipLoader.
     *
     */
    
    
    _global.control = {
        debug : (_url.split(':')[2].split('/')[0] == '8083') || (_url.indexOf('&DEBUG') >= 0),
        tests: 0
    };
    
    
    if (control.debug){
        createTextField("DebugMsg",11000,5,5,230,310);
        DebugMsg.text = "debug messages";
        DebugMsg.border = true;
        DebugMsg.borderColor = 0xcccccc;
        DebugMsg.textColor = 0x333333 ;
        var debug_format = new TextFormat();
        debug_format.size = 5;
        debug_format.font = 'Arial';
        DebugMsg.setNewTextFormat(debug_format);
        //DebugMsg._alpha = 50;
    }
    
    /**
     * @brief This debug function is to display debug message 
     */
    function debug(){
        if (control.debug){
            for(var z=0; z<arguments.length; z++){
                DebugMsg.text+='\n'+arguments[z];
                DebugMsg.scroll+=2;
            }
        }
    }
    
    /**
     * @brief This deep_trace function is to display the debug message of objects
     * @param obj debug object
     */
    function deep_trace(obj){
        if (control.debug){
            for (var x in obj){
                debug(x + ' : ' + obj[x]);
            }
        }
    };
    
    //stuff to fix onload on loaded JPGs
    //  by bokel <actionscript@bokelberg.de>
    // http://chattyfig.figleaf.com/flashcoders-wiki/index.php?onLoad
    
    /**
     * @brief  This MovieClip.prototype.addOnLoadHandler function is 
     * to fix onload on loaded JPGs
     * @param path !?
     * @param func !?
     */
    MovieClip.prototype.addOnLoadHandler = function(path, func) {
        if (MovieClip._onLoadHandler_ == undefined) {
            MovieClip._onLoadHandler_ = {};
        }
        MovieClip._onLoadHandler_[path] = func;
    };
    /// @cond DOXYGEN_SHOULD_SKIP_THIS
    ASSetPropFlags(MovieClip, ["addOnLoadHandler"], 1);
    sol = function (func) { addOnLoadHandler(this, func);};
    gol = function () { return MovieClip._onLoadHandler_[this];};
    MovieClip.prototype.addProperty("onLoad", gol, sol);
    var wrap = wrapper;
    var seq = 0;
    var reload_wait = null;
    var url = '/media/video/' + 'douglas.jpg';
    var flip = 0;
    load_video(img_wrap);
    /// @endcond 
    
    /**
     * @brief !?This video_onload function is to check onload video
     */
    function video_onload(){
        flip = 100 - flip;
        reload_wait = setInterval(load_video, 500);
        unloadMovieNum(6669 + flip);
    }
    
    /**
     * @brief This load_video function is used to load video
     */
    function load_video(){
        seq++;
        if (reload_wait != null){
            clearInterval(reload_wait);
            reload_wait = null;
        }
        var iname = 'img' + flip;
        createEmptyMovieClip(iname, 6669 + flip );
        _root[iname].onLoad = video_onload;
        _root[iname].loadMovie(url + '&seq=' + v.seq);
    }
