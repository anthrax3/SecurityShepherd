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
String levelName = "Query Params 1";
//Alphanumeric Only
String levelHash = "d81c19c90b3786acdb7739e8106a7c9295949f0b0c5efd59e4c8595239c86387";
//Translation Stuff
Locale locale = new Locale(Validate.validateLanguage(request.getSession()));
ResourceBundle bundle = ResourceBundle.getBundle("i18n.challenges.directObject." + levelHash, locale);
//Used more than once translations
String i18nLevelName = bundle.getString("challenge.challengeName");

%>

<%@ include file="../showQuestion.jsp" %>
