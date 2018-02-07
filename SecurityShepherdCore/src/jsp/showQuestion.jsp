<%
ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), levelName + " Accessed");
if (request.getSession() != null)
{
	HttpSession ses = request.getSession();
	//Getting CSRF Token from client
	Cookie tokenCookie = null;
	try
	{
		tokenCookie = Validate.getToken(request.getCookies());
	}
	catch(Exception htmlE)
	{
		ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), levelName +".jsp: tokenCookie Error:" + htmlE.toString());
	}
	// validateSession ensures a valid session, and valid role credentials
	// If tokenCookie == null, then the page is not going to continue loading
	if (Validate.validateSession(ses) && tokenCookie != null)
	{
		ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), levelName + " has been accessed by " + ses.getAttribute("userName").toString(), ses.getAttribute("userName"));
		Encoder encoder = ESAPI.encoder();
		String csrfToken = encoder.encodeForHTML(tokenCookie.getValue());
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Security Shepherd - <%=i18nLevelName%></title>
	<link href="../css/lessonCss/theCss.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
	<script type="text/javascript" src="../js/jquery.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/clipboard.min.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/tooltips.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/clipboard-events.js"></script>
		<div id="contentDiv">
			<h2 class="title"><%= i18nLevelName %></h2>
			<p>
				<%= bundle.getString("challenge.form.instruction") %>
				<br/>
				<br/>
				<form id="leForm" action="javascript:;">
					<table>
					<tr><td>
						Enter your answer below:
					</td></tr>
					<tr><td>
						<input style="width: 400px;" id="answer" type="text" autocomplete="off"/>
					</td></tr>
					<tr><td>
						<div id="submitButton"><input type="submit" value="Submit answer"/></div>
						<p style="display: none;" id="loadingSign">Checking...</p>
					</td></tr>
					</table>
				</form>
				<div id="resultsDiv"></div>
			</p>
		</div>
		<% /*If you need to call the Server Do it like this */ %>
		<script>
			$("#leForm").submit(function(){
				$("#submitButton").hide("fast");
				$("#loadingSign").show("slow");
				var answer = $("#answer").val();
				$("#resultsDiv").hide("slow", function(){
					var ajaxCall = $.ajax({
						type: "POST",
						url: "/VerifyAnswer",
						data: {
							levelHash: "<%= levelHash %>",
							answer: answer,
							csrfToken: "<%= csrfToken %>"
						},
						async: false
					});
					if(ajaxCall.status == 200)
					{
						$("#resultsDiv").html(ajaxCall.responseText);
					}
					else
					{
						$("#resultsDiv").html("<p> Error occurred: " + ajaxCall.status + " " + ajaxCall.statusText + "</p>");
					}
					$("#resultsDiv").show("slow", function(){
						$("#loadingSign").hide("fast", function(){
							$("#submitButton").show("slow");
						});
					});
				});
			});
		</script>

		<% if(Analytics.googleAnalyticsOn) { %><%= Analytics.googleAnalyticsScript %><% } %>
</body>
</html>
<%
	}
	else
	{
		response.sendRedirect("../loggedOutSheep.html");
	}
}
else
{
	response.sendRedirect("../loggedOutSheep.html");
}
%>
