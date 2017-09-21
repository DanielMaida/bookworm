package br.ufpe.cin.if962.crawler;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Queue;

import org.jsoup.Connection.Response;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import br.ufpe.cin.if962.base.Link;
import br.ufpe.cin.if962.config.Config;
import br.ufpe.cin.if962.factories.heuristics.Heuristic;
import br.ufpe.cin.if962.factories.heuristics.HeuristicFactory;
import br.ufpe.cin.if962.factories.queues.QueueFactory;

public class SiteCrawlerRunnable implements Runnable{
	private String siteBaseUrl;
	private String filePath;
	private Queue<Link> queue; //maybe a TreeSet
	private Long ThreadId;
	private int iterationCounter;
	private int fileNameCounter;
	private ArrayList<String> forbiddenZone;
	private ArrayList<String> linksVisited;
	private Heuristic heuristic;

	/**
	 * 
	 * @param siteBaseUrl Has to be on the format "https(or http):://www.website..."
	 * @param filePath
	 * @param counter
	 */
	public SiteCrawlerRunnable(String siteBaseUrl, String filePath, int counter) {
		this.siteBaseUrl = siteBaseUrl;
		this.filePath = filePath + Config.heuristicType.toString() + "/";
		this.iterationCounter = counter;
		this.forbiddenZone = new ArrayList<String>();
		this.linksVisited = new ArrayList<String>();
		this.queue = QueueFactory.getQueue(Config.queueType);
		this.fileNameCounter = 0;
		this.heuristic = HeuristicFactory.getHeuristic(Config.heuristicType);
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
		Link nextPage = this.queue.poll();
		String currentPageUrl = nextPage.url;
		System.out.println(currentPageUrl + "------------------------------------------------------------| score: " + nextPage.rank );
		
		this.linksVisited.add(currentPageUrl);
		this.linksVisited.add(currentPageUrl + "#"); 
		try {
			Response response = Jsoup.connect(currentPageUrl)
					.userAgent(Config.userAgent)
					.referrer(Config.referrer)
					.timeout(12000)
					.ignoreContentType(true) //ignore content type here, to avoid errors but check before attempt to parse
					.execute();
			if(response.contentType().startsWith("text")) {
				Document doc = response.parse();
				if(currentPageUrl != doc.baseUri()) {
					//saves the url after page redirection
					this.linksVisited.add(doc.baseUri());
					currentPageUrl = doc.baseUri();
				}
				Elements links = doc.select("a[href]"); // a with href
				addLinks(this.siteBaseUrl,links,currentPageUrl);
				savePage(doc);
				this.iterationCounter -= 1;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void addLinks(String baseUrl,Elements links, String currentPageUrl) {
		for (Element link : links) {
			String absUrl = link.absUrl("href").replace(" ", "%20");
			if(validateUrl(baseUrl,absUrl)) {
				int linksCount = (int) links.stream().filter(e -> e.absUrl("href").equals(link.absUrl("href"))).count();
				//System.out.println(linksCount);
				this.queue.add(new Link(absUrl, heuristic.score(link, currentPageUrl,linksCount)));
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
		f.getParentFile().mkdirs();
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
			if(line.toLowerCase().startsWith("user-agent")) {
				userAgent = line.substring(line.lastIndexOf(":")+1);
				map.put(userAgent, new ArrayList<String>());
			}else if(line.startsWith("Disallow")) {
				map.get(userAgent).add(line.substring(line.lastIndexOf(":")+1));
			}
		}
		return map;
	}
}
