package org.util
{
	/**
	 * A wrapper class for web methods, including getURL which was removed
	 * from AS2. 	 *
	 * @author: Shaun Narayan
	 * @version 0.1
	 * @modified 	 */
    import flash.net.navigateToURL;
    import flash.net.URLRequest;

    public class Web
    {
        public static function getURL(url:String, window:String = null):void
        {
            var req:URLRequest = new URLRequest(url);
            trace("getURL", url);
            try
            {
                navigateToURL(req, window);
            }
            catch (e:Error)
            {
                trace("Navigate to URL failed", e.message);
            }
        }
    }
}