package br.ufpe.cin.if962.Crawler;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.PriorityQueue;

import org.jsoup.Connection.Response;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import br.ufpe.cin.if962.Base.Link;
import br.ufpe.cin.if962.Base.LinkComparator;
import br.ufpe.cin.if962.Config.Config;

public class SiteCrawlerRunnable implements Runnable{
	private String siteBaseUrl;
	private String filePath;
	private PriorityQueue<Link> queue; //maybe a TreeSet
	private Long ThreadId;
	private int iterationCounter;
	private int fileNameCounter;
	private ArrayList<String> forbiddenZone;
	private ArrayList<String> linksVisited;

	/**
	 * 
	 * @param siteBaseUrl Has to be on the format "https(or http):://www.website..."
	 * @param filePath
	 * @param counter
	 */
	public SiteCrawlerRunnable(String siteBaseUrl, String filePath, int counter) {
		this.siteBaseUrl = siteBaseUrl;
		this.filePath = filePath;
		this.iterationCounter = counter;
		this.forbiddenZone = new ArrayList<String>();
		this.linksVisited = new ArrayList<String>();
		this.queue = new PriorityQueue<Link>(new LinkComparator());
		this.fileNameCounter = 0;
	}

	@Override
	public void run() {
		this.ThreadId = Thread.currentThread().getId();
		this.forbiddenZone = DisallowanceList(Arrays.asList(new String[] {"*",Config.userAgent}));
		this.queue.add(new Link(this.siteBaseUrl));
		while(!this.queue.isEmpty() && iterationCounter > 0) {
			visit();
			try {
				Thread.sleep(4 * 1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

	public void visit() {
		//System.out.println(linksVisited);
		while(this.linksVisited.contains(this.queue.peek().url) ||
				this.linksVisited.contains(this.queue.peek().url + "#")) {
			this.queue.poll();
		}
		
		String link = this.queue.poll().url;
		this.linksVisited.add(link);
		try {
			Response response = Jsoup.connect(link)
					.userAgent(Config.userAgent)
					.referrer(Config.referrer)
					.timeout(12000)
					.execute();
			if(response.contentType().startsWith("text")) {
				Document doc = response.parse();
				if(link != doc.baseUri())//saves the url after page redirection
					this.linksVisited.add(doc.baseUri());
				Elements links = doc.select("a[href]"); // a with href
				addLinks(this.siteBaseUrl,links);
				savePage(doc);
				this.iterationCounter -= 1;
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void addLinks(String baseUrl,Elements links) {
		for (Element link : links) {
			String absUrl = link.absUrl("href");
			if(validateUrl(baseUrl,absUrl)) {
				this.queue.add(new Link(absUrl));
			}
		}
	}

	public Boolean validateUrl(String baseUrl,String absUrl) {
		//System.out.println(absUrl + " contains: " + baseUrl);
		return absUrl.contains(baseUrl) && //if it's on the same site
				!this.linksVisited.contains(absUrl) && //if it's already been visited
				!this.linksVisited.contains(absUrl+"#") && 
				!isOnTheForbiddenZone(absUrl); //if it's on the disallowed zone
	}

	public void savePage(Document doc) throws IOException {
		File f = new File(this.filePath + ThreadId + fileNameCounter + ".html");
		Writer out = new OutputStreamWriter(new FileOutputStream(f), "UTF-8");
		out.write(doc.outerHtml() + '\n');
		out.write("site_url: " + doc.baseUri()); // saves page url
		out.close();
		fileNameCounter +=1;
	}
	
	//TODO: Aho-Corasick here
	public Boolean isOnTheForbiddenZone(String absUrl) {
		Boolean isOnTheForbiddenZone = false;
		for (String term : forbiddenZone) {//yikes
			if(absUrl.contains(term)) {
				isOnTheForbiddenZone = true;
			}
		}
		return isOnTheForbiddenZone;
	}

	public ArrayList<String> DisallowanceList(List<String> userAgentList) {
		ArrayList<String> disallowanceList = new ArrayList<String>();
		try {
			Response response = Jsoup.connect(this.siteBaseUrl + "robots.txt")
					.userAgent(Config.userAgent)
					.referrer(Config.referrer)
					.timeout(12000)
					.execute();
			Document doc = response.parse();
			doc.outputSettings(new Document.OutputSettings().prettyPrint(false));
			String pageText = doc.select("body").html();
			HashMap<String, ArrayList<String>> userAgentDisallowancesMap = parseDisallowances(pageText);

			for (String userAgent : userAgentList) {
				disallowanceList.addAll(userAgentDisallowancesMap.getOrDefault(userAgent, new ArrayList<String>()));
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
		return disallowanceList;
	}

	private HashMap<String,ArrayList<String>> parseDisallowances(String text){
		HashMap<String, ArrayList<String>> map = new HashMap<String,ArrayList<String>>();
		text = text.replaceAll(" ", "");
		String[] lines = text.split("\n");
		String userAgent = "";
		for (String line : lines) {
			if(line.startsWith("User-agent")) {
				userAgent = line.substring(line.lastIndexOf(":")+1);
				map.put(userAgent, new ArrayList<String>());
			}else if(line.startsWith("Disallow")) {
				map.get(userAgent).add(line.substring(line.lastIndexOf(":")+1));
			}
		}
		return map;
	}
}
