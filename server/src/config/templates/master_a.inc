<!DOCTYPE html>
<!--[if lte IE 8 ]><html class="ie8"> <![endif]-->
<!--[if (gte IE 9)|!(IE)]><!--><html> <!--<![endif]-->
<head>
<meta http-equiv="X-UA-Compatible" content="IE=8" />
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />

<title>UpStage</title>

<link rel="shortcut icon" href="/favicon.ico" />

<link rel="stylesheet" media="screen" type="text/css" href="/script/slickgrid/slick.grid.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/script/slickgrid/css/smoothness/jquery-ui-1.8.16.custom.css" />

<link rel="stylesheet" media="screen" type="text/css" href="/style/main.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/slickgrid.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/colorbox.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/multi-select.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/chosen.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/easytabs.css" />
<link rel="stylesheet" media="screen" type="text/css" href="/style/colorpicker.css" />

<!-- include html5shiv -->
<!--[if lt IE 9]>
<script src="/script/html5shiv/html5shiv.js"></script>
<![endif]-->

<!-- include font "Font Awesome" -->
<link rel="stylesheet" media="screen" href="/font/font-awesome/css/font-awesome.css">
<!--[if IE 7]>
<link rel="stylesheet" media="screen" href="/font/font-awesome/css/font-awesome-ie7.min.css">
<![endif]-->

<!-- FIXME to increase page performance some scripts should be loaded in an async way or put at the bottom -->

<!-- include various 3rd party scripts -->
<script type="text/javascript" src="/script/jshash/md5.js"></script>
<script type="text/javascript" src="/script/custom-context-menu/rightClick.js"></script>
<script type="text/javascript" src="/script/flowplayer/flowplayer-3.2.12.min.js"></script>

<!-- upstage scripts -->
<script type="text/javascript" src="/script/masterpage.js"></script>
<script type="text/javascript" src="/script/stageedit.js"></script>
<script type="text/javascript" src="/script/mediaupload.js"></script>
<script type="text/javascript" src="/script/mediaedit.js"></script>
<script type="text/javascript" src="/script/mediaedit2.js"></script>
<script type="text/javascript" src="/script/user.js"></script>
<script type="text/javascript" src="/script/image-slideshow.js"></script>

<!-- logging -->
<script type="text/javascript" src="/script/log4javascript/log4javascript.js"></script>
<script type="text/javascript">

	var log = log4javascript.getLogger();

	// log to browser console by default
	var myAppender = new log4javascript.BrowserConsoleAppender();
	log.addAppender(myAppender);
	
	// log to popup window
	var popUpAppender = new log4javascript.PopUpAppender();
	log.addAppender(popUpAppender);
	
	log4javascript.setEnabled(false); // set to false to disable logging output
</script>
<!-- /logging -->

</head>

<body>
    <div id="divShade">
    </div>
    <div id="divPopup">
    </div>
	<script type="text/javascript">test_flash()</script><!-- TODO what does this script do? does it test if flash is installed? -->
	<div id="masterpage">
		<div id="header">
			<div id="logo">
				<!-- Daniel Han (26/06/2012) - Fixed logo link to upstage.org.nz -->
				<a href="http://www.upstage.org.nz"><img border="0" src="/image/upstagelogo.jpg" alt="Upstage" width="140" height="89" /></a>
			</div>
			<!-- FIXME empty action prevents browsers from saving passwords -->
			<!-- FIXME relying on JavaScript for a login form seems like a bad behaviour -->
			<form name="hidden_form" action="">
			<input name="user_name" type ="hidden" value="%(username)s" />
			<input name="can_signup" type="hidden" value="%(allow_signup)s" />
			<input name="server_details" type="hidden" value="%(server_details)s" />
			</form>
				<div id="signup">
					<!-- FIXME naming a form 'rupert' seems inappropriate - what actually does this form? -->
					<form name="rupert" action="/perspective-init"> 
					  Login: <input name="username" size="13" />
					  Password: <input type="password" name="password" size="13" /><br />
					  Remember me? <input type="checkbox" name="remember" /><!-- FIXME the 'remember me' functionality seems broken? -->
					  <button onclick="javascript:setPassword(username.value, password.value); return false;">Login</button><br />
					  Audience members dont need to log in to view peformances!<br />
					</form>
				</div>
			<div id="nav">
	   			<a href="javascript:navHome()">HOME</a>
		    	<a href="javascript:navWorkshop()">WORKSHOP</a><!-- TODO why not hide this nav when it is not available to non-logged-in users? -->
		    	<a href="javascript:navStages()">STAGES</a>
			</div>
		</div>
		<script type="text/javascript">clearLogin();</script>
		<div id ="altnav">
		</div>
		<div id="page"><!--remove-->