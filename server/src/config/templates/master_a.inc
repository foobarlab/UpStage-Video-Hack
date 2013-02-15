<!DOCTYPE html>
<!--[if lte IE 8 ]><html class="ie8"> <![endif]-->
<!--[if (gte IE 9)|!(IE)]><!--><html> <!--<![endif]-->
<head>
<meta http-equiv="X-UA-Compatible" content="IE=8" />
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />

<title>UpStage</title>

<link rel="stylesheet" type="text/css" href="/style/main.css" />
<link rel="shortcut icon" href="/style/favicon.ico" />

<script language="javascript" type="text/javascript" src="/masterpage.js"></script>
<script language="javascript" type="text/javascript" src="/client.js"></script>
<script language="javascript" type="text/javascript" src="/stageedit.js"></script>
<script language="javascript" type="text/javascript" src="/mediaupload.js"></script>
<script language="javascript" type="text/javascript" src="/mediaedit.js"></script>
<script language="javascript" type="text/javascript" src="/user.js"></script>
<script language="javascript" type="text/javascript" src="/md5.js" ></script>
<script language="javascript" type="text/javascript" src="/image-slideshow.js"></script>
<script language="javascript" type="text/javascript" src="/jwplayer.js"></script>

</head>

<body>
    <div id="divShade">
    </div>
    <div id="divPopup">
    </div>
	<script type="text/javascript">test_flash()</script>
	<div id="masterpage">
		<div id="header">
			<div id="logo">
				<!-- Daniel Han (26/06/2012) - Fixed logo link to upstage.org.nz -->
				<a href="http://www.upstage.org.nz"><img border="0" src="/style/upstagelogo.jpg" alt="Upstage" /></a>
			</div>
			<form name="hidden_form" action="">
			<input name="user_name" type ="hidden" value="%(username)s"></input>
			<input name="can_signup" type="hidden" value="%(allow_signup)s"></input>
			<input name="server_details" type="hidden" value="%(server_details)s"></input>
			</form>
				<div id="signup">
					<form name="rupert" action="/perspective-init"> 
					  Login: <input name="username" size="13" />
					  Password: <input type="password" name="password" size="13" /><br />
					  Remember me? <input type="checkbox" name="remember" />
					  <button onclick="javascript:setPassword(username.value, password.value); return false;">Login</button><br />
					  Audience members dont need to log in to view peformances!<br />
					</form>
				</div>
			<div id="nav">
	   			<a href="javascript:navHome()">HOME</a>
		    	<a href="javascript:navWorkshop()">WORKSHOP</a>
		    	<a href="javascript:navStages()">STAGES</a>
				

			</div>
		</div>
		<script type="text/javascript">clearLogin();</script>
		<div id ="altnav">
		</div>
		<div id="page"><!--remove-->
