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
Version: GnuPG v1

mQINBFmDbaUBEADUzz4qg3VJYFf4SYsIAoZQSoT2MiNTdPUWCArWpkSy/QSoXBAU
mjc+oaKtuVSfW0T5dSdfCvIBqnUWGkWQVWZv6ttkvQvi91+q7LwX6AapqW8p/WuL
PermH4Os5+6Rt+TL8B/F0pM8CAhQs4y2orue+sqOw+YO7PV6lIXLo8xVPxqMSaPk
vMTTIZK2mntNwPswHX0rF+xKu2EuCBwRlCArMaKD9E4GeR7ptInLl/yEGdVGt1qD
7fpbq8+SEntH64GqKCoGGhm7yTHq94hXHgbn3gNglGWi0zBTF0y3Y0AQd2/k+xgH
CiyiJa8pohUJU4az3NXXs2pnhfh07/8VGxsqIsRUZ169KkQhuZhGtDzgqYSobFlS
omqm/rUXCVD3cq0+1xespju1H8AOS9WDNnzONk1OFWalYKkXmdmZIMy/mLj6wZ9n
uzxhPpndbRFXrFCuAganeOfJApFBtQkQdPw9LDfEOV088TtsiQSDN51zUXJiju9u
PwejYfYWsJ8rthL8vLlxjvgnGUIDGcgbqKTR9eHmxo58GZLC5VZf7H7EdtgrD3Ry
Y+3IfXDRKfaN4CszyGpnh8RDsJhY0hWvTjKAVwDNdjQslDHnkfnp1GIn0zMYo3Yo
NPusV9Y8i87JjO8VDcavt5nPO4X4iNZm2PQqSYXJak53SQ17O4U3XDizkQARAQAB
tCRTZWN1cml0eVNoZXBoZXJkIDxpbmZvQGNvZGVwYXRoLmNvbT6JAjgEEwECACIF
AlmDbaUCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEP7ILmbOlqA147sP
+wZtUHUp2zqskzsSfnTKUhdS0jZlJfJRwnR+fBjInHsO7+ukynWuwnpcPplQNCmX
v9DnGsqjpXfcURW8bWeRMvbijdOvuypgmCEyECpcfMgOtoago3mqds+i5/zRvcRY
Pp2gwNstVwv1I5erBm8a4Mo8B24LJs1PpllsdK5w1dpV/4Vui0VQ7JMYtN2Qfc4o
kJdBhgFT3OO8xRxBXjtDGjZWu06n+r0ELeRJ9jSO0zngGUPEQf/ARDNetZWzwxg4
XSj712cZbaDFBPv9x0aPv2VNB8y+DZU8u/n4Z0IHH8gLY4Ye0Xlbkn0mTgv4po4w
RnpyD7k1Ar0G99VzyZ04ZJHzHylZKErNk+Fzc4caVwXPJjdF4D/kGV48BLRp77Pf
4cp3me8iAzVyrKBwoh5pGYImxfYyQpN0BMt+sGpDltlPFBmotMsj3rbFWn/lDWel
LeCkqVbuoXrMGyAGeGveK2/fCG3oGo6dV/W2cRIsaWIyfZyVMbS2DQdk+UdDMRAi
Nli6SRBlsYxvWgY/M5+EMtPdI8fV6o9bc1u0mTyey8GzhV6vBSgQnxqCWKJWkMBt
Pv7en2XzOHkpRZwPRUZ3j9x13/ZCkLseMV9nU5GFnEWPIFnUUyCWYNk4mc+OIvOj
eb5XWQDfyTLcB9RAs+HPMBjqgbo2dLokoALBRVXExkUkuQINBFmDbaUBEADJXXIV
OIsuFeNI+29T8Ou5uwYEsMGsEBCQkbtWIBgmnSIFDuf+91RsNsoIgb+hB9wPie3k
TkJykTF4C0N/tQBYQiXSCbyXB6KW+SwUq3uClQ4HhktmrQ8j0DYlr3p1lJqdD1lR
YP6ELQpdst/Tq2h8Y+iuuA7HCEcYD/dsw6A4YoGevxARe9zTjbf8z7VFiEUNIN0G
kQ8dZaJvmXM402dIye3JamlmlMPTQIhce6qbF1ujWf49f/AjpGu5rSalmJn6BJu0
D5aHH3V4+PI/KVpJ90oqzvh6cQI8I8XJBw8b2v3mYdOb8NQuYPurc4MeNDdtR/ML
XNN47lAr0s3kB/3eBAkqbDOIdrp8c6RkGUvEPf0iqO+0+bNb1kDswq6+XQ7T83Cx
ZnahS4KmsQEs6oLHkB4fBPfDFUU/Pd4aUBymuFg5TB6Nl+BRL4ZrIcPzODotlNZ5
JxmxMNshbZzcvZTWpH67dVy0pv4Bb5dvp7lKx15RbD653fxwcDuq+OozkKMGHUDT
AoRHc5hqKbYvmJVORxkJIL9I+erqRFQFaqnmR73LEHKuvst11NtQ3dlreMFmaKqN
MopIgBPodr/JG7eIzXu06Qaqew52Ut2pyDhh9VoVaTAEswBiYWswZfcTjpiGQapO
1b6vKYevFD7+uq/YqbhYakWoQvoWre+ZjQMXDQARAQABiQIfBBgBAgAJBQJZg22l
AhsMAAoJEP7ILmbOlqA1AbcP/03F9twIvn0UUIFrHjMS+TZH/eI2N0qOoqKbNTNq
Ueq6sT3GgNRXoGnEMJsApVcYSn1dNr8rcFQzvQqYGZYGJ4F+AGR5jO004YXCzg80
UFV4W1vjMwDQ9FZaNpSUrlYcbMyIJO9E5ywgMaKKil2sdU2+b0PbvL2/S3xOBeJG
hBF/V7hMkewlB/eE7s3xggBBwXCVgs4YeJ9cWPAI7QyLFXCh0wMt2t13ag2s6shg
qkX5CbVh84Py+UZMXqaSNqeJnrqGJXTWF4dGxVP5iIKZrRjP9rKviDgpOLAFGrWF
XkFvU0f9L2GPLTFS8D72mzwt1eMG+iuCA04du1xe28VnTICZVNj7asEakuTgx/Nz
clmeMHaFiGS3ojVNViGXl8VV86NaoishPg2UhnYMVMf84+dbZGjrI6uuza4waTxf
LCOqfOPB5fyR9hnfb7mdd4njUL/MmMDaK40s0VkJ5hSKOQr3AD27cQ+1anYX57Et
SUZVMi7V1c5S+mgZ5U+d7wHE+gc4NlJU6M5dMdWS5jbkMFwXt1mjDUxShMq8xNfH
wA6YOgEdz6BtveTwrmY0os15yM+25REpcIKMpRFzB0f08fvinEy2OFh90Qg1VBoq
HHNDhsl6ol2hVR30VstR6shkDm5h/OsBYpsH3rFeNna3T3U8ta/Wk+6tRQ1dyuSf
3W5/
=uDEc
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
