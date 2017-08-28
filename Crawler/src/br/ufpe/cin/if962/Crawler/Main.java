package br.ufpe.cin.if962.Crawler;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import br.ufpe.cin.if962.Config.Config;

public class Main {
	public static void main(String[] args) {
		List<String> baseUrls = new ArrayList<String>();
		baseUrls.add("https://www.saraiva.com.br/");
		baseUrls.add("https://www.mercadolivre.com.br/");
		
		Iterator<String> it = baseUrls.iterator();
		while(it.hasNext()) {
			new Thread(new SiteCrawlerRunnable(it.next(),Config.filePath, 100)).start();
		}
	}
}
