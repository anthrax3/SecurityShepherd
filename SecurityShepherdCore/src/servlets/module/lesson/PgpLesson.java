package servlets.module.lesson;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.owasp.esapi.ESAPI;
import org.owasp.esapi.Encoder;

import utils.Hash;
import utils.ShepherdLogManager;
import utils.Validate;
import dbProcs.Database;

/**
 * SQL Injection Lesson - Does not use User Specific Key
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
 * @author name
 *
 */
public class PgpLesson
extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private static org.apache.log4j.Logger log = Logger.getLogger(PgpLesson.class);
	private static String levelName = "PGP Lesson";
	public static String levelHash = "ccc8655e9077c2cba42af98f0a828f2fbea20b7b7136b2a10c0f862c8d4d944c";
	private static String levelResult = "eca1e27bd993e7808330f01df30cb754773c313ea851d17a00ee46d18580d859"; // Put the Level Result Key here only if the level is not hardcoded in the database or mobile application
	/**
	 * Describe level here, and how a user is supposed to beat it
	 * @param aUserName Expected Parameters
	 */
	public void doPost (HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		//Dont Change any of this. This is logging player activity
		ShepherdLogManager.setRequestIp(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"));
		PrintWriter out = response.getWriter();
		out.print(getServletInfo());
		//Translation Stuff
		Locale locale = new Locale(Validate.validateLanguage(request.getSession()));
		ResourceBundle errors = ResourceBundle.getBundle("i18n.servlets.errors", locale);
		/*
		ResourceBundle bundle = ResourceBundle.getBundle("i18n.servlets.challenges.folder.fileNameWithoutExtention", locale);
		*/
		try
		{
			//Get the session from the request
			HttpSession ses = request.getSession(true);
			if(Validate.validateSession(ses)) //Is this an active session?
			{
				//Valid Session, time to log who it is
				ShepherdLogManager.setRequestIp(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), ses.getAttribute("userName").toString());
				log.debug(levelName + " servlet accessed by: " + ses.getAttribute("userName").toString());

				boolean returnKey = false;
				
				//Template Users: Edit from here
				String message = request.getParameter("message");
				log.debug("User submitted message: " + message); //Log what the player submitted for your expected parameters
				
				if (message != null) {
				returnKey = decrypt(message);
				} else {
					log.info("Parameter 'message' was null");
					log.info(request.getParameterMap());
				}
				/*
				//If you want to call a database function, this section if for you. All the way up until if(returnKey)
				//Get Running Context of Application to make Database Call with
				String applicationRoot = getServletContext().getRealPath("");
				String output = doLevelSqlStuff(applicationRoot, aUserName, bundle);
				log.debug("Logging in English. Going to Output " + output);
				*/
				String htmlOutput = "<h2 class='title'>" + "Results" + "</h2>";

				if(returnKey)
				{
					//Something happened and now you want the user to be given a user specific key. then do this
					//String userKey = Hash.generateUserSolution(levelResult, //(String)ses.getAttribute("userName"));
					log.debug("User has compelted level");
					//Otherwise just set userKey to "resultKey" and use the rest of this snip (If key is hardcoded, make sure you set it that way in your database level entry)
					String userKey = levelResult;
					htmlOutput = "<h2 class='title'>" + "Challenge Completed!" + "</h2>" +
							"<p>" +
							"The result key is " + " " +
							"<a>" + userKey + "</a>" +
							"</p>";

				} else {
					htmlOutput += "<p>" + "Sorry, that didn't work. Try again" + "</p>";
				}
				log.debug("Outputting HTML");
				out.write(htmlOutput);
			}
			else
			{
				//Dont change this error
				log.error(levelName + " accessed with no session");
			}
		}
		catch(Exception e)
		{
			//Dont change this error
			out.write(errors.getString("error.funky"));
			log.fatal(levelName + " - " + e.toString());
		}
	}

	private boolean decrypt(String cipherText) {
		boolean success = false;
		File tempCFile = null;
		File tempPFile = null;

		try {
			tempCFile = File.createTempFile("cipher-", "-txt");
			tempCFile.deleteOnExit();

			Files.write(Paths.get(tempCFile.toURI()), cipherText.getBytes());

			tempPFile = File.createTempFile("plain-", "-txt");
			tempPFile.deleteOnExit();


        ProcessBuilder procBuild = new ProcessBuilder(
        		"/usr/bin/gpg","--yes", "--batch", "--output",tempPFile.getCanonicalPath(), "--decrypt", tempCFile.getCanonicalPath()
            );
            Process server = procBuild.start();

            BufferedReader inputStream = new BufferedReader(new InputStreamReader(server.getInputStream()));
            BufferedReader errorStream = new BufferedReader(new InputStreamReader(server.getErrorStream()));
            //BufferedReader outputStream = new BufferedWriter(new OutputStreamWriter(server.getOutputStream()));

            String line = "";
            while((line = inputStream.readLine()) != null){
                log.debug(line);
            }
            while((line = errorStream.readLine()) != null){
                log.error(line);
            }

	    if (server.waitFor() == 0) {
	    	String plainText = new String(Files.readAllBytes(Paths.get(tempPFile.toURI())));
	    	log.debug(plainText);
	    	success = true;
	    } else {
	    	log.error("gpg exit code was 1");
	    }

		} catch (Throwable x) {
			x.printStackTrace();

		} finally {
			try {
				tempCFile.delete();
				tempPFile.delete();
			} catch (Throwable x) {
				x.printStackTrace();
			}
		}
		return success;
	}
	
	
}
