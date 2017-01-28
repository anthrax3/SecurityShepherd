package servlets.module;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import dbProcs.Getter;
import utils.FindXSS;
import utils.Hash;
import utils.ShepherdLogManager;
import utils.Validate;

/**
 * VerifyAnswer is used when a level entry is expecting a particular answer. This is used
 * instead of the solution in the database to give the level entries an opportunity to
 * apply fuzzy matching or other logic.
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
 * @author Mark Denihan
 *
 */
public class VerifyAnswer
extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private static org.apache.log4j.Logger log = Logger.getLogger(VerifyAnswer.class);

  /**
	 * @param levelHash Identify current level entry
	 * @param answer Answer to be checked
	 */
	public void doPost (HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		//Setting IpAddress To Log and taking header for original IP if forwarded from proxy
		ShepherdLogManager.setRequestIp(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"));
		log.debug("VerifyAnswer Servlet Accessed");
		PrintWriter out = response.getWriter();
		out.print(getServletInfo());

		//Translation Stuff
		Locale locale = new Locale(Validate.validateLanguage(request.getSession()));
		ResourceBundle errors = ResourceBundle.getBundle("i18n.servlets.errors", locale);

		try
		{
			HttpSession ses = request.getSession(true);
			if(Validate.validateSession(ses))
			{
				ShepherdLogManager.setRequestIp(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), ses.getAttribute("userName").toString());
				log.debug("VerifyAnswer" + " accessed by: " + ses.getAttribute("userName").toString());
				Cookie tokenCookie = Validate.getToken(request.getCookies());
				Object tokenParmeter = request.getParameter("csrfToken");
				if(Validate.validateTokens(tokenCookie, tokenParmeter))
				{
					String answer = request.getParameter("answer");
          String levelHash = request.getParameter("levelHash");
					log.debug("User Submitted - " + answer);
          log.debug("level hash - " + levelHash);
          log.debug("userName - " + ses.getAttribute("userName"));
          log.debug("real path - " + getServletContext().getRealPath(""));
					String htmlOutput = new String();
					if(isValidAnswer(levelHash, answer))
					{
            String levelResult = Getter.getModuleResultFromHash(getServletContext().getRealPath(""), levelHash);
						htmlOutput = "<h2 class='title'>" + "Congrats!" + "</h2>" +
								"<p>" + "Enter the result key above:" + "<br />" +
								"" + "Result key: " +
								Hash.generateUserSolution(levelResult, (String)ses.getAttribute("userName")) + "</p>";
					}
          else
          {
            htmlOutput = "<h2 class='title'>" + "Oops!" + "</h2>" +
								"<p>" + "Sorry, that's not the right answer, try again.</p>";
          }
					log.debug("Outputting HTML");
					out.write(htmlOutput);
				}
			}
			else
			{
				log.error("VerifyAnswer accessed with no session");
				out.write(errors.getString("error.noSession"));
			}
		}
		catch(Exception e)
		{
			out.write(errors.getString("error.funky"));
			log.fatal("VerifyAnswer" + " - " + e.toString());
		}
		log.debug("End of " + "VerifyAnswer" + " Servlet");
	}

  private boolean isValidAnswer(String levelHash, String answer) {
	// This is an intermediate solution, eventually this should be refactored so
	// that logic evaluating levels is not so bundled together. This is
	// convenient for now to avoid having to make a lot more routes.
	
	String lowerAnswer = answer.toLowerCase();
	
	// HTTP Headers
	if (levelHash.equals("1cebf5680b31d9ce689797ec9e059aceeb4487db69cf007eff2bc22f1e8a809d")) {
		if (lowerAnswer.contains("private") && lowerAnswer.contains("no-cache") &&
			lowerAnswer.contains("no-store") && lowerAnswer.contains("must-revalidate")) {
			return true;
		} else {
			return false;
		}
	}
	// Basic Routes I
	else if (levelHash.equals("179f382bc60b8d010a06eda3cf7676767f60ec5ad63ddeedfd967d4230e1d41c")) {
		if (lowerAnswer.contains("ufi/reaction")) {
			return true;
		} else {
			return false;
		}
	}
	
	return false;
  }
}
