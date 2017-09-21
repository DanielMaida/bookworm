package br.ufpe.cin.if962.factories.heuristics;

import java.util.ArrayList;
import java.util.Iterator;

import org.jsoup.nodes.Element;

public class StardustCrusaders extends Heuristic {
	
	private ArrayList<String> productStrings = new ArrayList<String>() {
	    {
	    	add("product");
	    	add("produto");
	    	add("sale");
	    	add("compra");
	    	add("compre");
	    	add("cart");
	    	add("adicionar");
	    }};
	    
    private ArrayList<String> bookString = new ArrayList<String>() {
	    {
	    	add("autor");
	    	add("author");
	    	
	    }};
	

	//a ideia é semelhante ao battleTendency , porém essa classe tenta priorizar os produtos de uma categoria de livros
	@Override
	public double score(Element element , String currentPageUrl, int numberOfLinksToPage) {
		double score = 0;
		score+=hasKeyword(element.absUrl("href"))?1:0;
		if(hasKeyword(currentPageUrl)) {
			score = 2;
			score += scoreElementImg(element);
			score += scoreUrlAsProductList(currentPageUrl);
			score += scoreAasABook(element);
			score += scoreAasAProduct(element);
			score += Math.min(numberOfLinksToPage/8, 0.5);
			//score -= hasKeyword(element.absUrl("href"))?(1/2):0;
		}
		return score;
	}
	
	private double scoreElementImg(Element element) {
		double score = 0;
		for (Element child : element.children()) {
			if(child.tagName().equals("img")) {
				score += 1;
				if(hasKeyword(child.attr("src"))) {
					score += 0.5;
				}
			}
		}
		return score;
	}
	
	private double scoreUrlAsProductList(String url) {
		double score = 0;
		if(url.contains("order")) {
			score += 0.5;
		}
		return score;
	}
	
	private double scoreAasABook(Element e) {
		Iterator<String> it = bookString.iterator();
		double score = 0;
		while(it.hasNext()) {
			if(e.toString().toLowerCase().contains(it.next())) {
				score += 0.5;
				//System.out.println(score);
			}
		}
			
		return Math.min(score, 1.5);
	}
	
	private double scoreAasAProduct(Element element) {
		Iterator<String> it = productStrings.iterator();
		double score = 0;
		while(it.hasNext()) {
			if(element.toString().toLowerCase().contains(it.next())) {
				score += 0.25;
			}
		}
			
		return Math.min(score, 1.5);
	}
}
