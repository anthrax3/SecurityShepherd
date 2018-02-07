package utils;

import java.util.Locale;
import java.util.ResourceBundle;

/**
 * Manages What Google Analytics is used by the Shepherd instance. If Any
 * @author Mark Denihan
 *
 */
public class Analytics 
{

	public static boolean googleAnalyticsOn = false;
	public static String googleAnalyticsScript = "<script>\n" +
		"(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\n" +
		"(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\n" +
		"m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\n" +
		"})(window,document,'script','//www.google-analytics.com/analytics.js','ga');\n" +
		"\n" +
		"ga('create', 'UA-51746570-1', 'securityshepherd.eu');\n" +
		"ga('send', 'pageview');\n" +
		"</script>";
	public static String sourceForgeMobileVmLinkBlurb = new String(""
			+ "To complete this challenge you'll need to use the <a href='http://bit.ly/mobileShepherdVm'>Security Shepherd Android Virtual Machine</a> that contains the app. ");
	public static String sponsorshipMessage(Locale locale)
	{
		//Get Language Bundle
		ResourceBundle bundle = ResourceBundle.getBundle("i18n.text", locale);
		return new String("<h2 class=\"title\">" + bundle.getString("sponsorship.title") + "</h2>" +
			"<p>" +
			bundle.getString("sponsorship.message.1") +
			"<br/><br/>" +
			"<a href=\"https://bit.ly/BccRiskAdvisorySite\"><img src=\"css/images/bccRiskAdvisorySmallLogo.jpg\" alt=\"BCC Risk Advisory\"/></a>" +
			"<a href=\"https://bit.ly/EdgeScan\"><img src=\"css/images/edgescanSmallLogo.jpg\" alt=\"EdgeScan\" /></a>" +
			"<br/>" +
			"<a href=\"https://bit.ly/manicode\"><img src=\"css/images/manicode-logo.png\" style=\"margin-top: 5px;\"></a>" +
			"<br/><br/>" +
			bundle.getString("sponsorship.message.2") +  
			"<br/><a href=\"http://securityresearch.ie/\"><img src=\"https://www.owasp.org/images/thumb/2/24/Fontlogo.png/300px-Fontlogo.png\"/></a></p>");
	}
}
