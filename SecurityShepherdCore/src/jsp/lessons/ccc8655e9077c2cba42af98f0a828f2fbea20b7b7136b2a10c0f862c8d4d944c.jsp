<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" import="utils.*, org.owasp.esapi.ESAPI, org.owasp.esapi.Encoder" errorPage=""%>
<%@ page import="java.util.Locale, java.util.ResourceBundle"%>
<%
/**
 * <br/><br/>
 * This file is part of the Security Shepherd Project.
 *
 * The Security Shepherd project is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.<br/>
 *
 * The Security Shepherd project is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.<br/>
 *
 * You should have received a copy of the GNU General Public License
 * along with the Security Shepherd project.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @author Your Name
 */

//MUST be in English and no Quotes In level Name
String levelName = "PGP Lesson";
//Alphanumeric Only
String levelHash = "ccc8655e9077c2cba42af98f0a828f2fbea20b7b7136b2a10c0f862c8d4d944c";
//Translation Stuff
Locale locale = new Locale(Validate.validateLanguage(request.getSession()));
ResourceBundle bundle = ResourceBundle.getBundle("i18n.lessons.crypto." + levelHash, locale);
//Used more than once translations
String i18nLevelName = bundle.getString("title.pgp");

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

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Security Shepherd - <%=i18nLevelName%></title>
	<link href="../css/lessonCss/theCss.css" rel="stylesheet" type="text/css" media="screen" />
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/styles/github.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/highlight.min.js"></script>
  <script>hljs.initHighlightingOnLoad();</script>
</head>
<body>
	<script type="text/javascript" src="../js/jquery.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/clipboard.min.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/tooltips.js"></script>
	<script type="text/javascript" src="../js/clipboard-js/clipboard-events.js"></script>
		<div id="contentDiv">
			<h2 class="title"><%= i18nLevelName %></h2>
			<p>
				<%= bundle.getString("paragraph.info.1") %>
				<br/>
<pre><code>If you reveal your secrets to the wind,
you should not blame the wind for revealing them to the trees.</pre></code>
				<br/>
				<%= bundle.getString("paragraph.info.2") %>
				<br/>
				<pre><code>

	-----BEGIN PGP PUBLIC KEY BLOCK-----

	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
	Se8Npg==
	=s29O
	-----END PGP PUBLIC KEY BLOCK-----
						</pre></code>
						<br/>
						<%= bundle.getString("paragraph.info.3") %>
						<br/>
				<form id="leForm" action="javascript:;">
					<table>
						<tr><td>
							<textarea id="message" name="message" rows="20" cols="75"></textarea>
						</td></tr>
					<tr><td>
						<div id="submitButton">
						<input type="submit" value="Submit Message"/></div>
						<p style="display: none;" id="loadingSign">Loading...</p>
					</td></tr>
					</table>
				</form>



				<div id="resultsDiv"></div>

			</p>
			</div>
			<div>

		</div>

		<script>
			$("#leForm").submit(function(){
				var theMessage = $("#message").val();
				$("#submitButton").hide("fast");
				$("#loadingSign").show("slow");
				$("#resultsDiv").hide("slow", function(){
					var ajaxCall = $.ajax({
						type: "POST",
						url: "<%= levelHash %>",
						data: {
							message: theMessage
						},
						async: false
					});
					if(ajaxCall.status == 200)
					{
						$("#resultsDiv").html(ajaxCall.responseText);
					}
					else
					{
						$("#resultsDiv").html("<p> An Error Occurred: " + ajaxCall.status + " " + ajaxCall.statusText + "</p>");
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
