    /**
     * Module: ParseURLs.as
     * Author: Endre Bernhart, Phillip Quinlan, Lauren Kilduff
     * Turns URL's entered in the chat into clickable links formatted in HTML
     */
    
    /**
     * @brief Changes the message into a clickable URL
     */
    public function parseURLs(sMessage:String):String
    {
        sNewMsg = sMessage;
        //If there is http:// or www. in the text..
        if ((sNewMsg.indexOf("http://") != -1) || (sNewMsg.indexOf("https://") != -1) || (sNewMsg.indexOf("www.") != -1))
        {
            //Split the message up
            var aTextArray = sNewMsg.split(" ");
            //Go throught the whole message
            for (var i = 0; i < aTextArray.length; i++)
            {
                //If there is still http:// or www. in the message..
                if ((aTextArray[i].indexOf("http://") != -1) ||
                    (aTextArray[i].indexOf("https://") != -1) ||
                    (aTextArray[i].indexOf("www.") != -1))
                {
                    //Create the URL
                    newURL = buildURL(aTextArray[i]);
                    aTextArray[i] = newURL;
                }
            }
            //Join the message back together
            sNewMsg = aTextArray.join(" ");
        }
        //Return the message
        return sNewMsg;
    }
    
    /**
     * @brief Create the URL for the message
     */
    public function buildURL(sLink):String
    {
        //if there is no http:// in the message, just www...
        if (sLink.indexOf("http://") == -1)
        {
            //add http:// to the front of the message
            sLink = "http://" + sLink;
        }
        //Create the URL and return it to parseURLs
        var url:String = "<a href='" + sLink + "'>" + sLink + "</a>";
        return url;
    }
