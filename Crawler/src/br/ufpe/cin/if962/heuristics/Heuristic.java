package br.ufpe.cin.if962.heuristics;

import java.util.ArrayList;
import org.jsoup.nodes.Element;

public abstract class Heuristic {
	protected ArrayList<String> relevantStrings = new ArrayList<String>() {
    {
    	add("livro");
    	add("book");
    	add("leitura");
    }};
    
	public abstract double score(Element element);
}
