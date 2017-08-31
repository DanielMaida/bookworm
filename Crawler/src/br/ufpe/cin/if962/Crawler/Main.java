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
		baseUrls.add("http://www.fnac.com.br/");
		baseUrls.add("https://www.livrariacultura.com.br/");
		baseUrls.add("https://www.ebay.com/");
		baseUrls.add("https://www.amazon.com.br/");
		baseUrls.add("https://www.estantevirtual.com.br/");
		baseUrls.add("https://www.americanas.com.br/");
		baseUrls.add("https://www.submarino.com.br/");
		baseUrls.add("http://www.magazineluiza.com.br/");
		
		Iterator<String> it = baseUrls.iterator();
		while(it.hasNext()) {
			new Thread(new SiteCrawlerRunnable(it.next(),Config.filePath, 1000)).start();
		}
	}
}
