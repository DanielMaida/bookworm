package br.ufpe.cin.if962.crawler;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import br.ufpe.cin.if962.config.Config;

public class Main {
	public static void main(String[] args) {
		System.out.println("Running...");
		List<String> baseUrls = new ArrayList<String>();
		baseUrls.add("https://www.saraiva.com.br/");
		/*baseUrls.add("https://www.mercadolivre.com.br/");
		baseUrls.add("http://www.fnac.com.br/");
		baseUrls.add("https://www.livrariacultura.com.br/");
		baseUrls.add("http://www.casasbahia.com.br/");
		baseUrls.add("https://www.amazon.com.br/");
		baseUrls.add("https://www.estantevirtual.com.br/");
		baseUrls.add("https://www.americanas.com.br/");
		baseUrls.add("https://www.submarino.com.br/");
		baseUrls.add("http://www.magazineluiza.com.br/");*/
		
		Iterator<String> it = baseUrls.iterator();
		
		System.out.println("Crawling through " + Config.numberOfPages*baseUrls.size() + " pages from " + baseUrls.size() + " sites");
		while(it.hasNext()) {
			new Thread(new SiteCrawlerRunnable(it.next(),Config.filePath, Config.numberOfPages)).start();
		}
	}
}
