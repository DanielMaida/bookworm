package br.ufpe.cin.if962.crawler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Pattern;

public class RobotsTxtManager {

	private List<String> userAgentList;
	private ArrayList<String> forbiddenZone;
	private ArrayList<String> allowedZone;
	
	public RobotsTxtManager(List<String> userAgentList, String robotsTxt) {
		
		this.userAgentList = userAgentList;
		this.forbiddenZone = new ArrayList<String>();
		this.allowedZone = new ArrayList<String>();
		parseRobotsTxt(robotsTxt);
		
	}
	
	private void parseRobotsTxt(String text){
		
		HashMap<String, ArrayList<String>> disallowedMap = new HashMap<String,ArrayList<String>>();
		HashMap<String, ArrayList<String>> allowedMap = new HashMap<String,ArrayList<String>>();
		text = text.replaceAll(" ", "");
		String[] lines = text.split("\n");
		String userAgent = "";
		int indexOfComment = -1;
		
		for (String line : lines) {
			
			//removing comments
			indexOfComment = line.indexOf("#");
			line = indexOfComment==-1?line:line.substring(0,indexOfComment); 
			
			//parsing text
			if(line.toLowerCase().startsWith("user-agent")) {
				
				userAgent = line.substring(line.indexOf(":")+1);
				disallowedMap.put(userAgent, new ArrayList<String>());
				allowedMap.put(userAgent, new ArrayList<String>());
				
			}else if(line.startsWith("Disallow")) {
				
				disallowedMap.get(userAgent).add(convertToRegex(line.substring(line.indexOf(":")+1)));
				
			}else if(line.startsWith("Allow")) {
			
				allowedMap.get(userAgent).add(convertToRegex(line.substring(line.indexOf(":")+1)));
			
			}
		}
		
		for (String user : userAgentList) {
			this.forbiddenZone.addAll(disallowedMap.getOrDefault(user, new ArrayList<String>()));
			this.allowedZone.addAll(allowedMap.getOrDefault(user, new ArrayList<String>()));
		}
	}
	
	public Boolean isAllowed(String absUrl) {
		
		Boolean isAllowed = true;
		
		for (String disallowedRegex : forbiddenZone) {
			
			if(absUrl.matches(disallowedRegex)) {
				
				isAllowed = false;
				
				for (String allowedRegex : allowedZone) {
					
					/*
					 * At a group-member level, in particular for allow and disallow directives, 
					 * the most specific rule based on the length of the [path] entry will trump the less specific (shorter) rule. 
					 * The order of precedence for rules with wildcards is undefined.
					 */
					
					if(allowedRegex.matches(allowedRegex) && allowedRegex.length() >= disallowedRegex.length()) {
						System.out.println("Being allowed:"+absUrl + " disallowedRegex: " + disallowedRegex);
						System.out.println("allowedRegex: " + allowedRegex);
						isAllowed = true;
						
					}
					
				}
				
			}
		}
		return isAllowed;
	}
	
	private String convertToRegex(String term) {
		
		String asterisk = Pattern.quote("*");
		String eof = Pattern.quote("$");
		term = Pattern.quote(term);//keep the literals

		term.replace(asterisk, ".*");
		term.replace(eof, "$");
		term = String.format(".*%s.*", term);
		
		return term;		
	}
}
