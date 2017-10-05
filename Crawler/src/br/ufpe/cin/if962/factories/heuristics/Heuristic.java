package br.ufpe.cin.if962.factories.heuristics;

import java.util.ArrayList;
import org.jsoup.nodes.Element;

public abstract class Heuristic {
	protected ArrayList<String> relevantStrings = new ArrayList<String>() {
    {
    	add("livro");
    	add("book");
    	add("leitura");
    	//add("autor");
    }};
    
    protected Boolean hasKeyword(String text) {
    	for (String keyword : relevantStrings) {
			if(text.toLowerCase().contains(keyword)) {
				return true;
			}
		}
    	return false;
    }
    
	public abstract double score(Element element, String currentPageUrl, int numberOfLinksToPage);
}
